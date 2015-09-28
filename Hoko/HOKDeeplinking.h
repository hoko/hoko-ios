//
//  HOKDeeplinking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HOKDeeplink.h"
#import "Hoko+Macros.h"

/**
 *  HOKHandlerProtocol can be implemented on any object to be mapped on to a route,
 *  common implementations are loggers, analytics, validators or A/B testing mechanics.
 */
@protocol HOKHandlerProcotol <NSObject>

/**
 *  This method will be called when a deeplink has been opened in the application,
 *  the deeplink object will be passed, in order to be able to extract any associated
 *  information
 *
 *  @param deeplink The deeplink object with which the application was launched.
 */
- (void)handleDeeplink:(hok_nonnull HOKDeeplink *)deeplink;

@end

/**
 *  The HOKDeeplinking module provides all the necessary APIs to map, handle and generate deeplinks.
 *  Different APIs as provided in order to be as versatile as your application requires them to be.
 */
@interface HOKDeeplinking : NSObject

/**
 *  This method will return the last deep link that was processed (whether it was sucessfully opened, or not, due to filters)
 *  by the HOKO SDK. If no deeplinks were processed at the time of the call, this will return nil.
 *
 *  @return currentDeeplink The last deeplink object that was processed by the SDK.
 */
- (hok_nullable HOKDeeplink *)currentDeeplink;

/**
 *  This method will try to open the last deep link that was processed (whether it was sucessfully opened, or not, due to filters)
 *  by calling the route that is currently mapping this deeplink and the handlers.
 *  If the deeplink object is not nil and was opened during this call, the method will return YES, otherwise NO.
 *
 *  @return Returns YES if the current deeplink object was successfully opened. NO otherwise.
 */
- (BOOL)openCurrentDeeplink;

/**
 *  isLaunchingFromDeeplinkWithOptions: will let you know if the launchOptions from 
 *  application:didFinishLaunchingWithOptions: contain a deeplink which will be processed asynchronously.
 *
 *  @code
 *  if ([[Hoko deeplinking] isLaunchingFromDeeplinkWithOptions:launchOptions]) {
 *    // Hoko will open the deeplink asynchronously.
 *  } else {
 *    // Show your initial view controller by default.
 *  }
 *  @endcode
 *
 *  @param launchOptions  The launchOptions obtained in application:didFinishLaunchingWithOptions:
 */
- (BOOL)isLaunchingFromDeeplinkWithOptions:(hok_nullable NSDictionary *)launchOptions;

/**
 *  mapRoute:toTarget: allows deeplinks which conform to a certain route format to target blocks.
 *  Target blocks should be used to contruct your navigation flow and your data flow from both
 *  the deeplink object and your static data (e.g. CoreData, SQLite, etc).
 *
 *  @code
 *  [[Hoko deeplinking] mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
 *    DetailViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil]instantiateViewControllerWithIdentifier:@"DetailViewController"];
 *    tableViewController.productId = deeplink.routeParameters[@"product_id"];
 *    tableViewController.productPrice = deeplink.queryParameters[@"product_price"];
 *    [HOKNavigation pushViewController:tableViewController animated:YES];
 *  }];
 *  @endcode
 *
 *  @param route  The route format string (e.g. "product/:product_id").
 *  @param target The target block in which you should construct your navigation.
 */
- (void)mapRoute:(hok_nullable NSString *)route toTarget:(hok_nonnull void (^)(HOKDeeplink * __hok_nonnull deeplink))target;

/**
 *  mapDefaultRouteToTarget: allows any deeplink that does not apply to a mapped route to be sent
 *  to this default target. Most common usage should be to send the user to your application's main
 *  screen. The deeplink target will still receive the information contained in the deeplink.
 *
 *  @code
 *  [[Hoko deeplinking] mapDefaultRouteToTarget:^(HOKDeeplink *deeplink) {
 *    MainViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil]instantiateViewControllerWithIdentifier:@"MainViewController"];
 *    [HOKNavigation pushViewController:tableViewController animated:YES];
 *  }];
 *  @endcode
 *
 *  @param target The target block in which you should construct your navigation
 */
- (void)mapDefaultRouteToTarget:(hok_nonnull void (^)(HOKDeeplink * __hok_nonnull deeplink))target;

/**
 *  With addHandler: you can add an object which implements the HOKHandlerProtocol to be called everytime
 *  your application opens a deeplink. This allows you to track incoming deeplinks outside of the
 *  deeplinking targets.
 *
 *  @code
 *  [[Hoko deeplinking] addHandler:[Analytics sharedInstance]];
 *  @endcode
 *
 *  @param handler An object which implements the HOKHandlerProtocol.
 */
- (void)addHandler:(hok_nonnull id<HOKHandlerProcotol>)handler;

/**
 *  With addHandlerBlock: you can add a block which will be called everytime your application
 *  opens a deeplink. This allows you to track incoming deeplinks outside of the deeplinking targets.
 *
 *  @code
 *  [[Hoko deeplinking] addHandlerBlock:^(HOKDeeplink *deeplink) {
 *    [AppLogger log:deeplink];
 *  }];
 *  @endcode
 *
 *  @param handlerBlock A block that receives an HOKDeeplink object.
 */
- (void)addHandlerBlock:(hok_nonnull void (^)(HOKDeeplink * __hok_nonnull deeplink))handlerBlock;


/**
 *  This method will add a filter block that will be called whenever a new deep link is opened by the SDK.
 *  By calling the block, the SDK will expect a BOOL return value from it, that says if the HOKDeeplink object
 *  given in the block's parameters should be opened (YES) or not (NO). By saying NO (the deep link should not
 *  be opened), the SDK will save in the "currentDeeplink" that can be accessed later with the "wasOpened" property set to NO.
 *  By saying YES (the deep link should be opened) the SDK will try to open it normally.
 *
 *  One of the use cases for this is to only open deep links with a "friends" route if the user is already logged in in your application,
 *  otherwise it should open all deep links.
 *  @code
 *  [[Hoko deeplinking] addFilterBlock:^BOOL (HOKDeeplink * deeplink) {
 *      if ([deeplink.route isEqualToString:@"friends/:friend_id"]) {
 *          return currentUser.isLoggedIn;
 *      } else {
 *          return YES;
 *      }
 *  }];
 *  @endcode
 *
 *  @param filterBlock A block that receives an HOKDeeplink object and returns a BOOL.
 */
- (void)addFilterBlock:(hok_nonnull BOOL (^)(HOKDeeplink * __hok_nonnull deeplink))filterBlock;


/**
 *  handleOpenURL: is a mimicked method from the UIApplicationDelegate protocol for iOS < 4.2. 
 *  It serves the purpose of receiving incoming deeplinks from the AppDelegate object and delegating 
 *  them to the Hoko Deeplinking module. On a common basis, this method will be automatically delegated
 *  to the Hoko Deeplinking module through swizzling, but in case you get an error message at the
 *  start of your application you should manually delegate this method from your AppDelegate
 *  to the Deeplinking module.
 *
 *  @param url  The url received by the AppDelegate.
 *
 *  @return     Returns YES if Hoko can open the deeplink or NO otherwise.
 */
- (BOOL)handleOpenURL:(hok_nullable NSURL *)url;

/**
 *  openURL:sourceApplication:annotation: is a mimicked method from the UIApplicationDelegate
 *  protocol for iOS >= 4.2. It serves the purpose of receiving incoming deeplinks from the AppDelegate 
 *  object and delegating them to the Hoko Deeplinking module. On a common basis, this method will be 
 *  automatically delegated to the Hoko Deeplinking module through swizzling, but in case you get an 
 *  error message at the start of your application you should manually delegate this method from your 
 *  AppDelegate to the Deeplinking module.
 *
 *  @param url  The url received by the App Delegate.
 *  @param sourceApplication The source application string received on the App Delegate.
 *  @param annotation The annotation object received on the App Delegate.
 *
 *  @return     Returns YES if Hoko can open the deeplink or NO otherwise.
 */
- (BOOL)openURL:(hok_nullable NSURL *)url sourceApplication:(hok_nullable NSString *)sourceApplication annotation:(hok_nullable id)annotation NS_AVAILABLE_IOS(4_2);

/**
 *  continueUserActivity:restorationHandler is a mimicked method from the UIApplicationDelegate protocol
 *  for iOS >= 8.0. It serves many purposes, but HOKO uses it to open Smartlinks directly from the 
 *  NSUserActivity object. This method call will only return YES if the NSUserActivity is 
 *  NSUserActivityTypeBrowsingWeb and the webpageURL property has the hoko.link domain. This will trigger
 *  a link resolve on the HOKO backend, resulting on a deeplink open by the App itself.
 *
 *  @param userActivity       The NSUserActivity object from the AppDelegate call.
 *  @param restorationHandler The restoration handler from the AppDelegate call.
 *
 *  @return YES in case it contains a Smartlink, NO otherwise.
 */
- (BOOL)continueUserActivity:(hok_nonnull NSUserActivity *)userActivity restorationHandler:(hok_nonnull void (^)(NSArray * __hok_nullable restorableObjects))restorationHandler NS_AVAILABLE_IOS(8_0);

/**
 *  This method will try to open the deeplink object given in the parameters,
 *  by calling the route that is currently mapping that deeplink object's route and the handlers.
 *  If the deeplink was opened during this call, the method will return YES, otherwise NO.
 *
 *  @param deeplink The deeplink object that will be opened.
 *
 *  @return Returns YES if the deeplink object given in the parameters was successfully opened. NO otherwise.
 */
- (BOOL)openDeeplink:(hok_nonnull HOKDeeplink *)deeplink;

/**
 *  openSmartlink: serves the purpose of handling the open of a Smartlink, by resolving it through
 *  HOKO's backend, opening the resolved deeplink and calling the mapped route's target block.
 *
 *  @param smartlink A Smartlink.
 */
- (void)openSmartlink:(hok_nonnull NSString *)smartlink;

/**
 *  openSmartlink: serves the purpose of handling the open of a Smartlink, by resolving it through
 *  HOKO's backend, opening the resolved deeplink and calling the mapped route's target block. 
 *  Will also receive a completion block which will be executed when the deeplink is opened.
 *
 *  @param smartlink A Smartlink.
 *  @param completion A completion block that will be executed upon opening a Smartlink.
 */
- (void)openSmartlink:(hok_nonnull NSString *)smartlink completion:(hok_nullable void (^)(HOKDeeplink * __hok_nullable deeplink))completion;


/**
 *  generateSmartlinkForDeeplink:success:failure: allows the app to generate Smartlinks for the
 *  user to share with other users, independent of the platform, users will be redirected to the
 *  corresponding view. A user generated HOKDeeplink object may be passed along to generate the
 *  deeplinks for all available platforms. In case the request is succesful, the success block will
 *  receive a Smartlink (e.g. http://yourapp.hoko.link/XmPle ). Otherwise it will return the cause of failure in
 *  the failure block.
 *
 *  @param deeplink     The deeplink to which HOKO should generate a Smartlink.
 *  @param success      The block called in case of success, will have an Smartlink as a parameter.
 *  @param failure      The block called in case of failure, will have an NSError as a parameter.
 */
- (void)generateSmartlinkForDeeplink:(hok_nonnull HOKDeeplink *)deeplink success:(hok_nullable void (^)(NSString * __hok_nonnull smartlink))success failure:(hok_nullable void (^)(NSError * __hok_nonnull error))failure;

/**
 *  generateLazySmartlinkForDeeplink:domain: allows the app to generate lazy Smartlinks for the
 *  user to share with other users, independent of the platform, users will be redirected to the
 *  corresponding view. A user generated HOKDeeplink object may be passed along to generate the
 *  deeplinks for all available platforms. In case the translation is possible, the method will return
 *  a lazy Smartlink (e.g. http://yourapp.hoko.link/lazy?uri=%2Fproduct%2F0 ). Where the uri query parameter
 *  will be the url encoded version of the translated deep link.
 *
 *  @param deeplink     The deeplink to which HOKO should generate a lazy Smartlink.
 *  @param domain       The domain to which HOKO should generate a lazy Smartlink. (e.g. yourapp.hoko.link or yourapp.customdomain.com).
 */
- (hok_nullable NSString *)generateLazySmartlinkForDeeplink:(hok_nonnull HOKDeeplink *)deeplink domain:(hok_nonnull NSString *)domain;

@end

#ifndef HokoDeeplinking
  #define HokoDeeplinking [Hoko deeplinking]
#endif
