//
//  Hoko.h
//  Version 1.0.1
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplinking.h"

#import "HKDeeplink.h"

/**
 *  Hoko is an easy-to-use Framework to handle Deeplinking.
 *
 *  This is a simple drop-in class for handling incoming deeplinks.
 *  With the Hoko framework you can map routes to your view controllers, add handlers that trigger when
 *  deeplinks are the point of entry to your application.
 *
 *  - HKDeeplinking - handles every incoming deeplink, so long as it has been mapped
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
 *  will be shown on your Hoko dashboards. Debug mode will automatically be enabled when
 *  your app is signed with a provisioning profile or you are running on the simulator. Debug
 *  mode serves the purpose of uploading the app icon and the mapped routes to the Hoko 
 *  backend service.
 *  <pre>
 *  [Hoko setupWithToken:@"YOUR-API-TOKEN"];
 *  </pre>
 *
 *  @param token Hoko service API key.
 */
+ (void)setupWithToken:(NSString *)token;

/**
 *  Setups all the Hoko module instances, logging and asynchronous networking queues.
 *  Setting up with a token will make sure you can take full advantage of the Hoko service,
 *  as you will be able to track everything through automatic Analytics, which
 *  will be shown on your Hoko dashboards. Also sets the debug mode manually. Debug mode 
 *  serves the purpose of uploading the app icon and the mapped routes to the Hoko backend
 *  service.
 *  <pre>
 *  [Hoko setupWithToken:@"YOUR-API-TOKEN" debugMode:YES];
 *  </pre>
 *
 *  @param token Hoko service API key.
 */
+ (void)setupWithToken:(NSString *)token debugMode:(BOOL)debugMode;

/**
 *  The HKDeeplinking module provides all the necessary APIs to map, handle and generate deeplinks.
 *  Different APIs as provided in order to be as versatile as your application requires them to be.
 *
 *  @return A reference to the HKDeeplinking instance.
 */
+ (HKDeeplinking *)deeplinking;


/**
 *  Use this function to enable or disable logging from the Hoko SDK
 *
 *  @param verbose YES to enable logging, NO to disable.
 */
+ (void)setVerbose:(BOOL)verbose;

@end

