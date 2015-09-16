//
//  HOKObserver.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKSwizzling.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "Hoko.h"
#import "HOKError.h"
#import "HOKLogger.h"
#import "HOKDeeplinking+Private.h"

@implementation HOKSwizzling

#pragma mark - AppDelegate ClassName
/**
 *  Searches for the app delegate class name. Will not work if more than one class
 *  implements the UIApplicationDelegate protocol. If this does not detect the class,
 *  the developer needs to implement and delegate all the deeplinking methods to the
 *  corresponding modules.
 *
 *  @return The AppDelegate class name.
 */
+ (NSString *)appDelegateClassName {
  NSArray *appDelegates = @[];
  int numClasses;
  Class *classes = NULL;
  numClasses = objc_getClassList(NULL, 0);
  
  if (numClasses > 0) {
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    
    for (int i = 0; i < numClasses; i++) {
      Class class = classes[i];
      // Avoiding StoreKit inner classes
      if (class_conformsToProtocol(class, @protocol(UIApplicationDelegate)) && ![class isSubclassOfClass:[UIApplication class]] && class_getSuperclass(class) == [UIResponder class]) {
        appDelegates = [appDelegates arrayByAddingObject:NSStringFromClass(classes[i])];
      }
    }
    
    free(classes);
  }
  
  if (appDelegates.count == 1) {
    return appDelegates.firstObject;
  } else if (appDelegates.count > 1) {
    NSLog(@"[HOKO] We have detected that you have %@ classes that implement the UIApplicationDelegate protocol (%@), please go to http://goo.gl/DGZGSL for how to manually delegate deep links to HOKO.", @(appDelegates.count), appDelegates);
  } else {
    NSLog(@"[HOKO] We could not detect your AppDelegate class, HOKO requires your AppDelegate to descend from UIResponder and implement UIApplicationDelegate. Please go to http://goo.gl/DGZGSL for how to manually delegate deep links to HOKO.");
  }
  return nil;
}

#pragma mark - Generic Swizzling
/**
 *  Swizzles a class' selector with another selector.
 *
 *  @param classname        The class' name.
 *  @param originalSelector The original selector.
 *  @param swizzledSelector The new selector, which should call the original.
 */
+ (void)swizzleClassname:(NSString *)classname
        originalSelector:(SEL)originalSelector
        swizzledSelector:(SEL)swizzledSelector {
  
  Class class = NSClassFromString(classname);
  
  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
  
  BOOL didAddMethod = class_addMethod(class,
                                      originalSelector,
                                      method_getImplementation(swizzledMethod),
                                      method_getTypeEncoding(swizzledMethod));
  
  if (didAddMethod) {
    class_replaceMethod(class,
                        swizzledSelector,
                        method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
}

/**
 *  Swizzles a selector with a block. This is a very versatile way of swizzling
 *  due to the way instance swizzling works. Also very easy to actually use to
 *  swizzle unknown classes.
 *
 *  @param classname        The class' name.
 *  @param originalSelector The selector to be swizzled.
 *  @param block            The block which will replace the original implementation.
 *
 *  @return An IMP pointer so the block can call the original implementation.
 */
+ (IMP)swizzleClassWithClassname:(NSString *)classname
                originalSelector:(SEL)originalSelector
                           block:(id)block {
  
  IMP newImplementation = imp_implementationWithBlock(block);
  Class class = NSClassFromString(classname);
  Method method = class_getInstanceMethod(class, originalSelector);
  
  if (method == nil) {
    class_addMethod(class, originalSelector, newImplementation, "");
    return nil;
  } else {
    return class_replaceMethod(class, originalSelector, newImplementation, method_getTypeEncoding(method));
  }
}

#pragma mark - HOKDeeplinking Swizzles
+ (void)swizzleHOKDeeplinking {
  NSString *appDelegateClassName = [self appDelegateClassName];
  if (appDelegateClassName) {
    [self swizzleOpenURLWithAppDelegateClassName:appDelegateClassName];
    [self swizzleLegacyOpenURLWithAppDelegateClassName:appDelegateClassName];
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self swizzleContinueUserActivityWithAppDelegateClassName:appDelegateClassName];
#endif
    
  } else {
    HOKErrorLog([HOKError couldNotFindAppDelegateError]);
  }
}

+ (void)swizzleOpenURLWithAppDelegateClassName:(NSString *)appDelegateClassName {
  __block IMP implementation = [HOKSwizzling swizzleClassWithClassname:appDelegateClassName originalSelector:@selector(application:openURL:sourceApplication:annotation:) block:^BOOL (id blockSelf, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation){
    
    BOOL result = [[Hoko deeplinking] openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (!result && implementation) {
      BOOL (*func)() = (void *)implementation;
      result = func(blockSelf, @selector(application:openURL:sourceApplication:annotation:), application, url, sourceApplication, annotation);
    }
    
    return result;
  }];
}

+ (void)swizzleLegacyOpenURLWithAppDelegateClassName:(NSString *)appDelegateClassName {
  __block IMP implementation = [HOKSwizzling swizzleClassWithClassname:appDelegateClassName originalSelector:@selector(application:handleOpenURL:) block:^BOOL (id blockSelf, UIApplication *application, NSURL *url){
    
    BOOL result = [[Hoko deeplinking] handleOpenURL:url];
    
    if (!result && implementation) {
      BOOL (*func)() = (void *)implementation;
      result = func(blockSelf, @selector(application:handleOpenURL:), application, url);
    }
    
    return result;
  }];
}

#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
+ (void)swizzleContinueUserActivityWithAppDelegateClassName:(NSString *)appDelegateClassName {
  __block IMP implementation = [HOKSwizzling swizzleClassWithClassname:appDelegateClassName originalSelector:@selector(application:continueUserActivity:restorationHandler:) block:^BOOL (id blockSelf, UIApplication *application, NSUserActivity *userActivity, id restorationHandler){
    
    BOOL result = [[Hoko deeplinking] continueUserActivity:userActivity restorationHandler:restorationHandler];
    
    if (!result && implementation) {
      BOOL (*func)() = (void *)implementation;
      return func(blockSelf, @selector(application:continueUserActivity:restorationHandler:), application, userActivity, restorationHandler);
    }
    
    return NO;
  }];
}
#endif

@end
