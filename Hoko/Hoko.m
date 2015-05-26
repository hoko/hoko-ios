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
#import "HKUtils.h"
#import "HKLogger.h"
#import "HKDevice.h"
#import "HKVersionChecker.h"
#import "HKDeeplinking+Private.h"
#import "HKNetworkOperationQueue.h"

NSString *const HokoVersion = @"2.0";

NSString *const HokoPreviousVersionKey = @"hokoVersion";
NSString *const AppPreviousVersionKey = @"appVersion";

@interface Hoko ()

@property (nonatomic, assign) BOOL debugMode;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) HKDeeplinking *deeplinking;


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
        
        [[HKNetworkOperationQueue sharedQueue] setup];
        _deeplinking = [[HKDeeplinking alloc] initWithToken:token debugMode:debugMode];
        
        [self checkVersions];
        
        if (![HKApp app].hasURLSchemes)
            HKErrorLog([HKError noURLSchemesError]);
    }
    return self;
}

#pragma mark - Module accessors
+ (HKDeeplinking *)deeplinking
{
    if (![Hoko hoko].deeplinking) {
        HKErrorLog([HKError setupNotCalledYetError]);
    }
    return [Hoko hoko].deeplinking;
}

#pragma mark - Versioning
- (void)checkVersions
{
    // Only posting when in debug mode to avoid spaming the service
    // Also checking for new version on github public repo
    if (self.debugMode) {
        [[HKVersionChecker versionChecker] checkForNewVersion:HokoVersion];
    }
    
    NSString *previousHokoVersion = [HKUtils objectForKey:HokoPreviousVersionKey];
    [HKUtils saveObject:HokoVersion key:HokoPreviousVersionKey];
    
    NSString *previousAppVersion = [HKUtils objectForKey:AppPreviousVersionKey];
    NSString *currentAppVersion = [HKApp app].build;
    [HKUtils saveObject:currentAppVersion key:AppPreviousVersionKey];
    
    if ((previousHokoVersion != nil && ![previousHokoVersion isEqualToString:HokoVersion]) ||
        (previousAppVersion != nil && ![previousAppVersion isEqualToString:currentAppVersion])) {
        [HKUtils clearAllBools];
    }
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