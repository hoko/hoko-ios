//
//  HOKApp.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKApp.h"

#import "HOKUtils.h"
#import "HOKDevice.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HOKAppUnknownBuild = @"Unknown Build";
NSString *const HOKAppUnknownVersion = @"Unknown Version";
NSString *const HOKAppIconKey = @"HKAppIconKey";

NSString *const HOKAppEnvironmentDebug = @"debug";
NSString *const HOKAppEnvironmentRelease = @"release";

@implementation HOKApp

#pragma mark - Shared Instance
+ (instancetype)app
{
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[HOKApp alloc] init];
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
  return version ? version : HOKAppUnknownVersion;
}

- (NSString *)build
{
  NSString *build = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
  return build ? build : HOKAppUnknownBuild;
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
  if ([HOKDevice device].isSimulator)
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
    return self.isDebugBuild ? HOKAppEnvironmentDebug : HOKAppEnvironmentRelease;
}

#pragma mark - Serializer
- (NSDictionary *)json
{
  return @{@"name": [HOKUtils jsonValue:self.name],
           @"bundle": [HOKUtils jsonValue:self.bundle],
           @"version": [HOKUtils jsonValue:self.version],
           @"build": [HOKUtils jsonValue:self.build]};
}


@end
