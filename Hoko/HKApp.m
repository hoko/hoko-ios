//
//  HKApp.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKApp.h"

#import "HKUtils.h"
#import "HKDevice.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKAppUnknownBuild = @"Unknown Build";
NSString *const HKAppUnknownVersion = @"Unknown Version";
NSString *const HKAppIconKey = @"HKAppIconKey";

NSString *const HKAppEnvironmentDebug = @"debug";
NSString *const HKAppEnvironmentRelease = @"release";

@implementation HKApp

#pragma mark - Shared Instance
+ (instancetype)app
{
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[HKApp alloc] init];
  });
  return sharedInstance;
}

#pragma mark - Methods
- (NSString *)name
{
  return [[NSBundle mainBundle].infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
}

- (NSString *)bundle
{
  return [NSBundle mainBundle].bundleIdentifier;
}

- (NSString *)version
{
  NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
  return version ? version : HKAppUnknownVersion;
}

- (NSString *)build
{
  NSString *build = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
  return build ? build : HKAppUnknownBuild;
}

// URL Schemes from app requires the drill down of the main bundle, only doing it once.
- (NSArray *)urlSchemes
{
  static NSArray *_urlSchemes = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _urlSchemes = @[];
    id urlTypes = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleURLTypes"];
    if (urlTypes && [urlTypes isKindOfClass:[NSArray class]]) {
      for (id urlType in urlTypes) {
        id urlSchemes = [urlType objectForKey:@"CFBundleURLSchemes"];
        if (urlSchemes && [urlSchemes isKindOfClass:[NSArray class]]) {
          for (id urlScheme in urlSchemes) {
            _urlSchemes = [_urlSchemes arrayByAddingObject:urlScheme];
          }
        }
      }
    }
  });
  
  return _urlSchemes;
}

- (BOOL)hasURLSchemes
{
  return self.urlSchemes.count > 0;
}

- (BOOL)isDebugBuild
{
  if ([HKDevice device].isSimulator)
    return YES;
  
  static BOOL isDebugBuild = NO;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // There is no provisioning profile in AppStore Apps.
    NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"embedded" ofType:@"mobileprovision"]];
    if (data) {
      const char *bytes = [data bytes];
      NSMutableString *profile = [[NSMutableString alloc] initWithCapacity:data.length];
      for (NSUInteger i = 0; i < data.length; i++) {
        [profile appendFormat:@"%c", bytes[i]];
      }
      // Look for debug value, if detected we're a development build.
      NSString *cleared = [[profile componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
      isDebugBuild = [cleared rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
    }
  });
  return isDebugBuild;
}

- (NSString *)environment
{
    return self.isDebugBuild ? HKAppEnvironmentDebug : HKAppEnvironmentRelease;
}

#pragma mark - Serializer
- (id)json
{
  return @{@"name": [HKUtils jsonValue:self.name],
           @"bundle": [HKUtils jsonValue:self.bundle],
           @"version": [HKUtils jsonValue:self.version],
           @"build": [HKUtils jsonValue:self.build]};
}


@end
