//
//  HOKDevice.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDevice.h"

#import <sys/sysctl.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "HOKApp.h"
#import "HOKUtils.h"
#import "HOKLogger.h"

NSString *const HOKDeviceReachabilityUrl = @"www.google.com";

NSString *const HOKDeviceUUIDKey = @"UUID";

NSString *const HOKDeviceVendor = @"Apple";
NSString *const HOKDeviceNoCarrier = @"No Carrier";
NSString *const HOKDeviceUnknownPlatform = @"Unknown";
NSString *const HOKDeviceReachabilityWifi = @"Wifi";
NSString *const HOKDeviceReachabilityCellular = @"Cellular";
NSString *const HOKDeviceReachabilityNoConnectivity = @"No Connectivity";
NSString *const HOKDeviceNoTelephonyFramework = @"No Telephony Framework";

NSString *const HOKDeviceIPhoneSimulator = @"iPhone Simulator";
NSString *const HOKDeviceIPadSimulator = @"iPad Simulator";

@interface HOKDevice ()

@property (nonatomic, strong) NSString *internetConnectivity;
@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;

@end

@implementation HOKDevice

#pragma mark - Shared Instance
+ (instancetype)device {
  static HOKDevice *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HOKDevice new];
  });
  return _sharedInstance;
}

#pragma mark - Methods
- (NSString *)vendor {
  return HOKDeviceVendor;
}

- (NSString *)platform
{
  NSString *model = [UIDevice currentDevice].model;
  
  if ([model rangeOfString:@"iPhone"].location != NSNotFound) {
    return @"iPhone";
  } else if ([model rangeOfString:@"iPod"].location != NSNotFound) {
    return @"iPod";
  } else if ([model rangeOfString:@"iPad"].location != NSNotFound) {
    return @"iPad";
  }
  
  return HOKDeviceUnknownPlatform;
}

- (NSString *)model {
  static NSString *_model = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    _model = [NSString stringWithUTF8String:machine];
    free(machine);
  });
  
  return _model;
}

- (NSString *)systemVersion {
  return [UIDevice currentDevice].systemVersion;
}

- (NSString *)systemLanguage {
  return [NSLocale preferredLanguages].firstObject;
}

- (NSString *)name {
  return [UIDevice currentDevice].name;
}

- (NSString *)screenSize {
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  NSInteger width = screenSize.width * scale;
  NSInteger height = screenSize.height * scale;
  return [NSString stringWithFormat:@"%ldx%ld", (unsigned long)height, (unsigned long)width];
}

// Load UUID from Disk, if it does not exist, use the Ad Identifier, if it can't
// use the Vendor Identifier, as a last resort generate a random UUID.
- (NSString *)uid {
  NSString *uid = [HOKUtils objectForKey:HOKDeviceUUIDKey];
  if (uid == nil) {
    NSString *newUid = self.appleIFA;
    
    if (newUid == nil) {
      newUid = self.appleIFV;
    }
    
    if (newUid == nil) {
      newUid = [HOKUtils generateUUID];
    }
    
    [HOKUtils saveObject:newUid key:HOKDeviceUUIDKey];
    uid = newUid;
  }
  
  return uid;
}

- (BOOL)hasInternetConnection {
  return ![self.internetConnectivity isEqualToString:HOKDeviceReachabilityNoConnectivity];
}

- (BOOL)isSimulator {
  return [self.name compare:HOKDeviceIPhoneSimulator] == NSOrderedSame || [self.name compare:HOKDeviceIPadSimulator] == NSOrderedSame;
}

#pragma mark - ID Getters

// Try to get the Ad Identifier without importing the AdSupport framework
// The actual call is [ASIdentifierManager sharedManaged].advertisingIdentifier.UUIDString
- (NSString *)appleIFA {
  NSString *ifa = nil;
  Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
  if (ASIdentifierManagerClass) {
    SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
    id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
    SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
    NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
    ifa = advertisingIdentifier.UUIDString;
  }
  
  return ifa;
}

- (NSString *)appleIFV {
  NSString *ifv = nil;
  if (HOKSystemVersionGreaterThanOrEqualTo(@"6.0")) {
    if (NSClassFromString(@"UIDevice")) {
      ifv = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
  }
  
  return ifv;
}

#pragma mark - Serializer
- (NSDictionary *)json {
  return @{@"vendor": [HOKUtils jsonValue:self.vendor],
           @"platform": [HOKUtils jsonValue:self.platform],
           @"model": [HOKUtils jsonValue:self.model],
           @"system_version": [HOKUtils jsonValue:self.systemVersion],
           @"uid": [HOKUtils jsonValue:self.uid]};
}

#pragma mark - Reachability
- (void)setupReachability {
  [self initReachabilityCallback];
  SCNetworkReachabilityFlags flags;
  if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
    [self reachabilityChanged:flags];
  } else {
    _internetConnectivity = HOKDeviceReachabilityNoConnectivity;
  }
}

// Really messy code extracted from Reachability lib
- (void)initReachabilityCallback {
  BOOL reachabilityInitated = NO;
  self.networkReachability = SCNetworkReachabilityCreateWithName(NULL, [HOKDeviceReachabilityUrl UTF8String]);
  if (self.networkReachability != NULL) {
    SCNetworkReachabilityContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(self.networkReachability, HOKDeviceNetworkReachabilityCallback, &context)) {
      dispatch_queue_t queue  = dispatch_queue_create("HOKReachabilityQueue", DISPATCH_QUEUE_SERIAL);
      
      if (SCNetworkReachabilitySetDispatchQueue(self.networkReachability, queue)) {
        reachabilityInitated = YES;
      } else {
        // cleanup callback if setting dispatch queue failed
        SCNetworkReachabilitySetCallback(self.networkReachability, NULL, NULL);
      }
    }
  }
  
  if (!reachabilityInitated) {
    HOKLog(@"%@ failed to set up reachability callback: %s", self, SCErrorString(SCError()));
  }
}

static void HOKDeviceNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
  if (info != NULL && [(__bridge NSObject*)info isKindOfClass:[HOKDevice class]]) {
    @autoreleasepool {
      HOKDevice *device = (__bridge HOKDevice *)info;
      [device reachabilityChanged:flags];
    }
    
  } else {
    HOKLog(@"Reachability: Unexpected info");
  }
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
  if (flags & kSCNetworkReachabilityFlagsReachable) {
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
      self.internetConnectivity = HOKDeviceReachabilityCellular;
    } else {
      self.internetConnectivity = HOKDeviceReachabilityWifi;
    }
  } else {
    self.internetConnectivity = HOKDeviceReachabilityNoConnectivity;
  }
}

@end
