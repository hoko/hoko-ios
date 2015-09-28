//
//  Hoko.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"
#import "Hoko+Private.h"

#import "HOKApp.h"
#import "HOKError.h"
#import "HOKUtils.h"
#import "HOKLogger.h"
#import "HOKDevice.h"
#import "HOKVersionChecker.h"
#import "HOKDeeplinking+Private.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HokoVersion = @"2.3.0";

@interface Hoko ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) HOKDeeplinking *deeplinking;


@end

@implementation Hoko

#pragma mark - Singleton
// Outside of setupWithToken: for testing purposes
static dispatch_once_t onceToken = 0;
static Hoko *_sharedInstance = nil;

+ (instancetype)hoko {
  return _sharedInstance;
}

#pragma mark - Setup
+ (void)setupWithToken:(NSString *)token {
  [self setupWithToken:token customDomain:nil];
}

+ (void)setupWithToken:(NSString *)token customDomain:(NSString *)customDomain {
  if (onceToken != 0) {
    HOKErrorLog([HOKError setupCalledMoreThanOnceError]);
    NSAssert(NO, [HOKError setupCalledMoreThanOnceError].description);
  }
  
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[Hoko alloc] initWithToken:token
                                    customDomain:customDomain
                                        debugMode:[HOKApp app].isDebugBuild];
  });
}

#pragma mark - Initializer
- (instancetype)initWithToken:(NSString *)token
                customDomain:(NSString *)customDomain
                    debugMode:(BOOL)debugMode {
  
  if (self = [super init]) {
    _token = token;
    _debugMode = debugMode;
    
    [[HOKDevice device] setupReachability];
    
    [[HOKNetworkOperationQueue sharedQueue] setup];
    _deeplinking = [[HOKDeeplinking alloc] initWithToken:token customDomain:customDomain debugMode:debugMode];
    
    [self checkVersions];
    
    if (![HOKApp app].hasURLSchemes) {
      HOKErrorLog([HOKError noURLSchemesError]);
    }
  }
  
  return self;
}

#pragma mark - Module accessors
+ (HOKDeeplinking *)deeplinking {
  if (![Hoko hoko].deeplinking) {
    HOKErrorLog([HOKError setupNotCalledYetError]);
  }
  
  return [Hoko hoko].deeplinking;
}

#pragma mark - Versioning
/**
 *  Checks for a new SDK version on the Github repo.
 */
- (void)checkVersions {
  // Only posting when in debug mode to avoid spaming the service
  // Also checking for new version on github public repo
  if (self.debugMode) {
    [[HOKVersionChecker versionChecker] checkForNewVersion:HokoVersion token:self.token];
  }
}

#pragma mark - Logging
+ (void)setVerbose:(BOOL)verbose {
  [HOKLogger logger].verbose = verbose;
}

#pragma mark - Resetting
+ (void)reset {
  onceToken = 0;
  _sharedInstance = nil;
}

@end
