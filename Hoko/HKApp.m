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
  return [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
}

- (NSString *)bundle
{
  return [NSBundle mainBundle].bundleIdentifier;
}

- (NSString *)version
{
  NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
  return version ? version : HKAppUnknownVersion;
}

- (NSString *)build
{
  NSString *build = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
  return build ? build : HKAppUnknownBuild;
}

// URL Schemes from app requires the drill down of the main bundle, only doing it once.
- (NSArray *)urlSchemes
{
  static NSArray *_urlSchemes = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _urlSchemes = @[];
    id urlTypes = [NSBundle mainBundle].infoDictionary[@"CFBundleURLTypes"];
    if (urlTypes && [urlTypes isKindOfClass:[NSArray class]]) {
      for (id urlType in urlTypes) {
        id urlSchemes = urlType[@"CFBundleURLSchemes"];
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

// TODO test this in iOS < 8 and other types of projects
- (UIImage *)icon
{
  // Look for icon in the best resolution possible
  NSString *iconName = [[NSBundle mainBundle].infoDictionary[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"] lastObject];
  UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@@3x",iconName]];
  if (!image)
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@@2x",iconName]];
  if (!image)
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",iconName]];
  return image;
}

- (NSString *)base64Icon
{
  NSString *base64Icon = [UIImagePNGRepresentation([self icon]) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  return base64Icon ? base64Icon : @"";
}

#pragma mark - Serializer
- (id)json
{
  return @{@"name": [HKUtils jsonValue:self.name],
           @"bundle": [HKUtils jsonValue:self.bundle],
           @"version": [HKUtils jsonValue:self.version],
           @"build": [HKUtils jsonValue:self.build]};
}

- (id)iconJSON
{
  return @{@"icon": self.base64Icon};
}

- (void)postIconWithToken:(NSString *)token
{
  NSString *previousAppIconMD5 = [HKUtils objectForKey:HKAppIconKey];
  id iconJSON = [self iconJSON];
  NSString *iconJSONMD5 = [HKUtils md5FromString:[iconJSON description]];
  if (!previousAppIconMD5 || [previousAppIconMD5 compare:iconJSONMD5] != NSOrderedSame) {
    [HKUtils saveObject:iconJSONMD5 key:HKAppIconKey];
    HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                      path:@"icons"
                                                                                     token:token
                                                                                parameters:iconJSON];
    [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
  }
}

@end
