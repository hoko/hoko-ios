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
#import "HokoAnalytics+Private.h"
#import "HokoDeeplinking+Private.h"
#import "HKNetworkOperationQueue.h"

NSString *const HokoVersion = @"1.0.2";

@interface Hoko ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) HokoAnalytics *analytics;
@property (nonatomic, strong) HokoDeeplinking *deeplinking;
@property (nonatomic, strong) HKNetworkOperationQueue *networkOperationQueue;

@end

@implementation Hoko

#pragma mark - Singleton
// Outside of setupWithToken:debugMode: for testing purposes
static dispatch_once_t onceToken = 0;
static Hoko *_sharedInstance = nil;

+ (instancetype)sharedHoko
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
    _networkOperationQueue = [HKNetworkOperationQueue sharedQueue];
    _analytics = [[HokoAnalytics alloc] initWithToken:token];
    _deeplinking = [[HokoDeeplinking alloc] initWithToken:token debugMode:debugMode];
    [_deeplinking addHandler:_analytics];
    
    // Only posting when in debug mode to avoid spaming the service
    // Also checking for new version on github public repo
    if (debugMode) {
      [[HKApp app] postIconWithToken:_token];
      [[HKVersionChecker sharedInstance] checkForNewVersion:HokoVersion];
    }
    
    if (![HKApp app].hasURLSchemes)
      HKErrorLog([HKError noURLSchemesError]);
  }
  return self;
}

#pragma mark - Module accessors
+ (HokoAnalytics *)analytics
{
  if (![Hoko sharedHoko].analytics) {
    HKErrorLog([HKError setupNotCalledYetError]);
  }
  return [Hoko sharedHoko].analytics;
}
+ (HokoDeeplinking *)deeplinking
{
  if (![Hoko sharedHoko].deeplinking) {
    HKErrorLog([HKError setupNotCalledYetError]);
  }
  return [Hoko sharedHoko].deeplinking;
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