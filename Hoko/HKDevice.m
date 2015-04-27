//
//  HKDevice.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDevice.h"

#import <sys/sysctl.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "HKApp.h"
#import "HKUtils.h"
#import "HKLogger.h"

NSString *const HKDeviceReachabilityUrl = @"www.google.com";

NSString *const HKDeviceUUIDKey = @"UUID";
NSString *const HKDeviceAPNSTokenKey = @"APNSToken";

NSString *const HKDeviceVendor = @"Apple";
NSString *const HKDeviceNoCarrier = @"No Carrier";
NSString *const HKDeviceUnknownPlatform = @"Unknown";
NSString *const HKDeviceReachabilityWifi = @"Wifi";
NSString *const HKDeviceReachabilityCellular = @"Cellular";
NSString *const HKDeviceReachabilityNoConnectivity = @"No Connectivity";
NSString *const HKDeviceNoTelephonyFramework = @"No Telephony Framework";

NSString *const HKDeviceIPhoneSimulator = @"iPhone Simulator";
NSString *const HKDeviceIPadSimulator = @"iPad Simulator";

@interface HKDevice ()

@property (nonatomic, strong) NSString *internetConnectivity;
@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;

@end

@implementation HKDevice

#pragma mark - Shared Instance
+ (instancetype)device
{
  static HKDevice *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HKDevice new];
  });
  return _sharedInstance;
}

#pragma mark - Methods
- (NSString *)vendor
{
  return HKDeviceVendor;
}

- (NSString *)platform
{
  UIUserInterfaceIdiom idiom = [UIDevice currentDevice].userInterfaceIdiom;
  if(idiom == UIUserInterfaceIdiomPhone)
    return @"iPhone";
  else if(idiom == UIUserInterfaceIdiomPad)
    return @"iPad";
  
  return HKDeviceUnknownPlatform;
}

- (NSString *)model
{
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

- (NSString *)systemVersion
{
  return [UIDevice currentDevice].systemVersion;
}

- (NSString *)systemLanguage
{
  return [NSLocale preferredLanguages].firstObject;
}

- (NSString *)locale
{
  return [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
}

- (NSString *)name
{
  return [UIDevice currentDevice].name;
}

- (NSString *)screenSize
{
  CGFloat scale = [UIScreen mainScreen].scale;
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  NSInteger width = screenSize.width * scale;
  NSInteger height = screenSize.height * scale;
  return [NSString stringWithFormat:@"%ldx%ld", (unsigned long)height, (unsigned long)width];
}

// Using reflection to avoid unecessary framework imports on the actual application
// Call is actually [[[CTTelephonyNetworkInfo alloc]init]subscriberCellularProvider].carrierName
- (NSString *)carrier
{
  Class CTTelephonyNetworkInfoClass = NSClassFromString(@"CTTelephonyNetworkInfo");
  if (CTTelephonyNetworkInfoClass) {
    id networkInfo = [[CTTelephonyNetworkInfoClass alloc] init];
    SEL subscriberCellularProviderSelector = NSSelectorFromString(@"subscriberCellularProvider");
    id carrier = ((id (*)(id, SEL))[networkInfo methodForSelector:subscriberCellularProviderSelector])(networkInfo, subscriberCellularProviderSelector);
    NSString *carrierName = [carrier valueForKey:@"carrierName"];
    if (carrierName.length)
      return carrierName;
    return HKDeviceNoCarrier;
  }
  return HKDeviceNoTelephonyFramework;
}

// Load UUID from Disk, if it does not exist, use the Ad Identifier, if it can't
// use the Vendor Identifier, as a last resort generate a random UUID.
- (NSString *)uid
{
  NSString *uid = [HKUtils objectForKey:HKDeviceUUIDKey];
  if(uid == nil) {
    NSString *newUid = self.appleIFA;
    if (newUid == nil)
      newUid = self.appleIFV;
    if (newUid == nil)
      newUid = [HKUtils generateUUID];
    [HKUtils saveObject:newUid key:HKDeviceUUIDKey];
    uid = newUid;
  }
  return uid;
}

- (NSString *)apnsToken
{
  return [HKUtils objectForKey:HKDeviceAPNSTokenKey];
}

- (void)setApnsToken:(NSString *)apnsToken
{
  [HKUtils saveObject:apnsToken key:HKDeviceAPNSTokenKey];
}

- (BOOL)hasInternetConnection
{
  return ![self.internetConnectivity isEqualToString:HKDeviceReachabilityNoConnectivity];
}

- (BOOL)isSimulator
{
  return [self.name compare:HKDeviceIPhoneSimulator] == NSOrderedSame || [self.name compare:HKDeviceIPadSimulator] == NSOrderedSame;
}

- (NSString *)timezoneOffset
{
    return [NSString stringWithFormat:@"%@",@([[NSTimeZone localTimeZone] secondsFromGMT] / ( 60.0f * 60.0f))];
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
  if (HKSystemVersionGreaterThanOrEqualTo(@"6.0")) {
    if (NSClassFromString(@"UIDevice")) {
      ifv = [UIDevice currentDevice].identifierForVendor.UUIDString;
    }
  }
  return ifv;
}

#pragma mark - Serializer
- (id)json
{
  return @{@"timestamp": [HKUtils jsonValue:[HKUtils stringFromDate:[NSDate date]]],
           @"vendor": [HKUtils jsonValue:self.vendor],
           @"platform": [HKUtils jsonValue:self.platform],
           @"model": [HKUtils jsonValue:self.model],
           @"system_version": [HKUtils jsonValue:self.systemVersion],
           @"system_language": [HKUtils jsonValue:self.systemLanguage],
           @"locale": [HKUtils jsonValue:self.locale],
           @"device_name": [HKUtils jsonValue:self.name],
           @"screen_size": [HKUtils jsonValue:self.screenSize],
           @"carrier": [HKUtils jsonValue:self.carrier],
           @"internet_connectivity": [HKUtils jsonValue:self.internetConnectivity],
           @"uid": [HKUtils jsonValue:self.uid],
           @"token": [HKUtils jsonValue:self.apnsToken],
           @"application": [HKApp app].json};
}

#pragma mark - Reachability
- (void)setupReachability
{
  [self initReachabilityCallback];
  SCNetworkReachabilityFlags flags;
  if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
    [self reachabilityChanged:flags];
  } else {
    _internetConnectivity = HKDeviceReachabilityNoConnectivity;
  }
}

// Really messy code extracted from Reachability lib
- (void)initReachabilityCallback {
  BOOL reachabilityInitated = NO;
  self.networkReachability = SCNetworkReachabilityCreateWithName(NULL, [HKDeviceReachabilityUrl UTF8String]);
  if (self.networkReachability != NULL) {
    SCNetworkReachabilityContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
    if (SCNetworkReachabilitySetCallback(self.networkReachability, HKDeviceNetworkReachabilityCallback, &context)) {
      dispatch_queue_t queue  = dispatch_queue_create("HKReachabilityQueue", DISPATCH_QUEUE_SERIAL);
      if (SCNetworkReachabilitySetDispatchQueue(self.networkReachability, queue)) {
        reachabilityInitated = YES;
      } else {
        // cleanup callback if setting dispatch queue failed
        SCNetworkReachabilitySetCallback(self.networkReachability, NULL, NULL);
      }
    }
  }
  if (!reachabilityInitated) {
    HKLog(@"%@ failed to set up reachability callback: %s", self, SCErrorString(SCError()));
  }
}

static void HKDeviceNetworkReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
  if (info != NULL && [(__bridge NSObject*)info isKindOfClass:[HKDevice class]]) {
    @autoreleasepool {
      HKDevice *device = (__bridge HKDevice *)info;
      [device reachabilityChanged:flags];
    }
  } else {
    HKLog(@"Reachability: Unexpected info");
  }
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
  if(flags & kSCNetworkReachabilityFlagsReachable) {
    if(flags & kSCNetworkReachabilityFlagsIsWWAN) {
      self.internetConnectivity = HKDeviceReachabilityCellular;
    } else {
      self.internetConnectivity = HKDeviceReachabilityWifi;
    }
  } else {
    self.internetConnectivity = HKDeviceReachabilityNoConnectivity;
  }
}

@end
