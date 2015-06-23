//
//  HKDeeplinking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplink.h"

#import "Hoko+Nullability.h"

/**
 *  HKHandlerProtocol can be implemented on any object to be mapped on to a route,
 *  common implementations are loggers, analytics, validators or A/B testing mechanics.
 */
@protocol HKHandlerProcotol <NSObject>

/**
 *  This method will be called when a deeplink has been opened in the application,
 *  the deeplink object will be passed, in order to be able to extract any associated
 *  information
 *
 *  @param deeplink The deeplink object with which the application was launched.
 */
- (void)handleDeeplink:(hk_nonnull HKDeeplink *)deeplink;

@end

/**
 *  The HKDeeplinking module provides all the necessary APIs to map, handle and generate deeplinks.
 *  Different APIs as provided in order to be as versatile as your application requires them to be.
 */
@interface HKDeeplinking : NSObject

/**
 *  mapRoute:toTarget: allows deeplinks which conform to a certain route format to target blocks.
 *  Target blocks should be used to contruct your navigation flow and your data flow from both
 *  the deeplink object and your static data (e.g. CoreData, SQLite, etc).
 *
 *  <pre>
 *  [[Hoko deeplinking] mapRoute:@"product/:product_id" toTarget:^(HKDeeplink *deeplink) {
 *    DetailViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil]instantiateViewControllerWithIdentifier:@"DetailViewController"];
 *    tableViewController.productId = deeplink.routeParameters[@"product_id"];
 *    tableViewController.productPrice = deeplink.queryParameters[@"product_price"];
 *    [HKNavigation pushViewController:tableViewController animated:YES];
 *  }];
 *  </pre>
 *
 *  @param route  The route format string (e.g. "product/:product_id").
 *  @param target The target block in which you should construct your navigation.
 */
- (void)mapRoute:(hk_nullable NSString *)route toTarget:(hk_nullable void (^)(HKDeeplink * __hk_nonnull deeplink))target;

/**
 *  mapDefaultRouteToTarget: allows any deeplink that does not apply to a mapped route to be sent
 *  to this default target. Most common usage should be to send the user to your application's main
 *  screen. The deeplink target will still receive the information contained in the deeplink.
 *
 *  <pre>
 *  [[Hoko deeplinking] mapDefaultRouteToTarget:^(HKDeeplink *deeplink) {
 *    MainViewController *tableViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil]instantiateViewControllerWithIdentifier:@"MainViewController"];
 *    [HKNavigation pushViewController:tableViewController animated:YES];
 *  }];
 *  </pre>
 *
 *  @param target The target block in which you should construct your navigation
 */
- (void)mapDefaultRouteToTarget:(hk_nullable void (^)(HKDeeplink * __hk_nonnull deeplink))target;

/**
 *  With addHandler: you can add an object which implements the HKHandlerProtocol to be called everytime
 *  your application opens a deeplink. This allows you to track incoming deeplinks outside of the
 *  deeplinking targets.
 *
 *  <pre>
 *  [[Hoko deeplinking] addHandler:[Analytics sharedInstance]];
 *  </pre>
 *
 *  @param handler An object which implements the HKHandlerProtocol.
 */
- (void)addHandler:(hk_nonnull id<HKHandlerProcotol>)handler;

/**
 *  With addHandlerBlock: you can add a block which will be called everytime your application
 *  opens a deeplink. This allows you to track incoming deeplinks outside of the deeplinking targets.
 *
 *  <pre>
 *  [[Hoko deeplinking] addHandlerBlock:^(HKDeeplink *deeplink) {
 *    [AppLogger log:deeplink];
 *  }];
 *  </pre>
 *
 *  @param handlerBlock A block that receives an HKDeeplink object.
 */
- (void)addHandlerBlock:(hk_nullable void (^)(HKDeeplink * __hk_nonnull deeplink))handlerBlock;

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
- (BOOL)handleOpenURL:(hk_nonnull NSURL *)url;

/**
 *  openURL:sourceApplication:annotation: is a mimicked method from the UIApplicationDelegate
 *  protocol for iOS >= 4.2. It serves the purpose of receiving incoming deeplinks from the AppDelegate 
 *  object and delegating them to the Hoko Deeplinking module. On a common basis, this method will be 
 *  automatically delegated to the Hoko Deeplinking module through swizzling, but in case you get an 
 *  error message at the start of your application you should manually delegate this method from your 
 *  AppDelegate to the Deeplinking module.
 *
 *  @param url  The url received by the AppDelegate.
 *
 *  @return     Returns YES if Hoko can open the deeplink or NO otherwise.
 */
- (BOOL)openURL:(hk_nonnull NSURL *)url sourceApplication:(hk_nullable NSString *)sourceApplication annotation:(hk_nullable id)annotation NS_AVAILABLE_IOS(4_2);

/**
 *  openSmartlink: serves the purpose of handling the open of a Smartlink, by resolving it through
 *  HOKO's backend, opening the resolved deeplink and calling the mapped route's target block.
 *
 *  @param smartlink A Smartlink.
 */
- (void)openSmartlink:(hk_nonnull NSString *)smartlink;

/**
 *  generateSmartlinkForDeeplink:success:failure allows the app to generate Smartlinks for the
 *  user to share with other users, independent of the platform, users will be redirected to the
 *  corresponding view. A user generated HKDeeplink object may be passed along to generate the
 *  deeplinks for all available platforms. In case the request is succesful, the success block will
 *  receive an Smartlink (e.g. http://hoko.link/XmPle ). Otherwise it will return the cause of failure in
 *  the failure block.
 *
 *  @param success      The block called in case of success, will have an Smartlink as a parameter.
 *  @param failure      The block called in case of failure, will have an NSError as a parameter.
 */
- (void)generateSmartlinkForDeeplink:(hk_nonnull HKDeeplink *)deeplink success:(hk_nullable void(^)(NSString * __hk_nonnull smartlink))success failure:(hk_nullable void(^)(NSError * __hk_nonnull error))failure;

@end

#ifndef HokoDeeplinking
  #define HokoDeeplinking [Hoko deeplinking]
#endif
