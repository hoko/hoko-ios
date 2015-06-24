//
//  Hoko.h
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplinking.h"

#import "HOKDeeplink.h"

#import "Hoko+Nullability.h"

/**
 *  Hoko is an easy-to-use Framework to handle Deeplinking.
 *
 *  This is a simple drop-in class for handling incoming deeplinks.
 *  With the Hoko framework you can map routes to your view controllers, add handlers that trigger when
 *  deeplinks are the point of entry to your application.
 *
 *  - HOKDeeplinking - handles every incoming deeplink, so long as it has been mapped
 *
 *  You should setup Hoko on your AppDelegate's application:didFinishLaunchingWithOptions:, by calling
 *  [Hoko setupWithToken:@"YOUR-API-TOKEN"].
 *
 */
@interface Hoko : NSObject

/**
 *  Setups all the Hoko module instances, logging and asynchronous networking queues.
 *  Setting up with a token will make sure you can take full advantage of the Hoko service,
 *  as you will be able to track everything through automatic Analytics, which
 *  will be shown on your Hoko dashboards. 
 *  <pre>
 *  [Hoko setupWithToken:@"YOUR-API-TOKEN"];
 *  </pre>
 *
 *  @param token Hoko service API key.
 */
+ (void)setupWithToken:(hok_nonnull NSString *)token;

/**
 *  Setups all the Hoko module instances, logging and asynchronous networking queues.
 *  Setting up with a token will make sure you can take full advantage of the Hoko service,
 *  as you will be able to track everything through automatic Analytics, which
 *  will be shown on your Hoko dashboards. Also sets the debug mode for the devices set. 
 *  Debug mode serves the purpose of the mapped routes to the Hoko backend service.
 *  Check the logs for your device's ID.
 *  <pre>
 *  [Hoko setupWithToken:@"YOUR-API-TOKEN" testDevices:@[@"YOUR-DEVICE-ID"]];
 *  </pre>
 *
 *  @param token Hoko service API key.
 */
+ (void)setupWithToken:(hok_nonnull NSString *)token testDevices:(hok_nullable NSArray *)testDevices;

/**
 *  The HOKDeeplinking module provides all the necessary APIs to map, handle and generate deeplinks.
 *  Different APIs as provided in order to be as versatile as your application requires them to be.
 *
 *  @return A reference to the HKDeeplinking instance.
 */
+ (hok_nonnull HOKDeeplinking *)deeplinking;


/**
 *  Use this function to enable or disable logging from the Hoko SDK
 *
 *  @param verbose YES to enable logging, NO to disable.
 */
+ (void)setVerbose:(BOOL)verbose;

@end

