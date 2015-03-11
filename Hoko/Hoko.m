//
//  Hoko.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"
#import "Hoko+Private.h"

#import "HKApp.h"
#import "HKError.h"
#import "HKLogger.h"
#import "HKDevice.h"
#import "HKVersionChecker.h"
#import "HKAnalytics+Private.h"
#import "HKDeeplinking+Private.h"
#import "HKNetworkOperationQueue.h"
#import "HKPushNotifications+Private.h"

NSString *const HokoVersion = @"1.1.1";

@interface Hoko ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) HKAnalytics *analytics;
@property (nonatomic, strong) HKDeeplinking *deeplinking;
@property (nonatomic, strong) HKPushNotifications *pushNotifications;

@end

@implementation Hoko

#pragma mark - Singleton
// Outside of setupWithToken:debugMode: for testing purposes
static dispatch_once_t onceToken = 0;
static Hoko *_sharedInstance = nil;

+ (instancetype)hoko
{
  return _sharedInstance;
}

#pragma mark - Setup
+ (void)setupWithToken:(NSString *)token
{
  [self setupWithToken:token debugMode:[HKApp app].isDebugBuild];
}

+ (void)setupWithToken:(NSString *)token debugMode:(BOOL)debugMode
{
  if (onceToken != 0) {
    HKErrorLog([HKError setupCalledMoreThanOnceError]);
    NSAssert(NO, [HKError setupCalledMoreThanOnceError].description);
  }
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[Hoko alloc] initWithToken:token debugMode:debugMode];
  });
}

#pragma mark - Initializer
- (instancetype)initWithToken:(NSString *)token
                    debugMode:(BOOL)debugMode
{
  if (self = [super init]) {
    _token = token;
    _debugMode = debugMode;
    
    [[HKDevice device] setupReachability];
    
    // Hoko Analytics implements the HKHandlerProtocol
    [[HKNetworkOperationQueue sharedQueue] setup];
    _analytics = [[HKAnalytics alloc] initWithToken:token];
    _deeplinking = [[HKDeeplinking alloc] initWithToken:token debugMode:debugMode];
    [_deeplinking addHandler:_analytics];
    
    _pushNotifications = [HKPushNotifications pushNotificationsWithToken:token];
    
    // Only posting when in debug mode to avoid spaming the service
    // Also checking for new version on github public repo
    if (debugMode) {
      [[HKApp app] postIconWithToken:_token];
      [[HKVersionChecker versionChecker] checkForNewVersion:HokoVersion];
    }
    
    if (![HKApp app].hasURLSchemes)
      HKErrorLog([HKError noURLSchemesError]);
  }
  return self;
}

#pragma mark - Module accessors
+ (HKAnalytics *)analytics
{
  if (![Hoko hoko].analytics) {
    HKErrorLog([HKError setupNotCalledYetError]);
  }
  return [Hoko hoko].analytics;
}

+ (HKDeeplinking *)deeplinking
{
  if (![Hoko hoko].deeplinking) {
    HKErrorLog([HKError setupNotCalledYetError]);
  }
  return [Hoko hoko].deeplinking;
}

+ (HKPushNotifications *)pushNotifications
{
  if (![Hoko hoko].pushNotifications) {
    HKErrorLog([HKError setupNotCalledYetError]);
  }
  return [Hoko hoko].pushNotifications;
}

#pragma mark - Logging
+ (void)setVerbose:(BOOL)verbose {
  [HKLogger logger].verbose = verbose;
}

#pragma mark - Resetting
+ (void)reset
{
  onceToken = 0;
  _sharedInstance = nil;
}

@end