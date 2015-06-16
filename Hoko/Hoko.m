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
    [self setupWithToken:token testDevices:nil];
}

+ (void)setupWithToken:(NSString *)token testDevices:(NSArray *)testDevices
{
    if (onceToken != 0) {
        HKErrorLog([HKError setupCalledMoreThanOnceError]);
        NSAssert(NO, [HKError setupCalledMoreThanOnceError].description);
    }
    dispatch_once(&onceToken, ^{
        BOOL debugMode = [self debugModeWithTestDevices:testDevices token:token];
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
/**
 *  Checks for a new SDK version on the Github repo.
 */
- (void)checkVersions
{
    // Only posting when in debug mode to avoid spaming the service
    // Also checking for new version on github public repo
    if (self.debugMode) {
        [[HKVersionChecker versionChecker] checkForNewVersion:HokoVersion];
    }
}

#pragma mark - Test Devices
/**
 *  This will check for debug mode with the device IDs specified.
 *  iOS Simulator will always be considered a test device. 
 *  Will also print a description to help developers integrate easier.
 *
 *  @param testDevices An array with the device IDs in which debug mode should be active.
 *  @param token       The Hoko token to be printed out.
 *
 *  @return YES if debug mode is active, NO otherwise
 */
+ (BOOL)debugModeWithTestDevices:(NSArray *)testDevices token:(NSString *)token
{
    BOOL debugMode = [testDevices containsObject:[HKDevice device].uid] || [HKDevice device].isSimulator;
    if (!debugMode && [HKApp app].isDebugBuild) {
        NSArray *allDevices = [[NSArray arrayWithObject:[HKDevice device].uid] arrayByAddingObjectsFromArray:testDevices];
        NSString *testDevicesString = [allDevices componentsJoinedByString:@"\", \""];
        NSLog(@"[Hoko] To upload the mapped routes to Hoko on this device, please make sure to setup the SDK with \n[Hoko setupWithToken:\"%@\" testDevices:@[\"%@\"]]", token, testDevicesString);
    }
    return debugMode;
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