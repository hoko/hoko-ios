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

NSString *const HOKAppEnvironmentDebug = @"debug";
NSString *const HOKAppEnvironmentRelease = @"release";

@implementation HOKApp

#pragma mark - Shared Instance
+ (instancetype)app {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[HOKApp alloc] init];
  });
  return sharedInstance;
}

#pragma mark - Methods
- (NSString *)name {
  return [[NSBundle mainBundle].infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
}

- (NSString *)bundle {
  return [NSBundle mainBundle].bundleIdentifier;
}

- (NSString *)version {
  NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
  return version ? version : HOKAppUnknownVersion;
}

- (NSString *)build {
  NSString *build = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
  return build ? build : HOKAppUnknownBuild;
}

// URL Schemes from app requires the drill down of the main bundle, only doing it once.
- (NSArray *)urlSchemes {
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

- (BOOL)hasURLSchemes {
  return self.urlSchemes.count > 0;
}

- (NSString *)embeddedMobileProvision {
  static NSString *embeddedMobileProvision;
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
      embeddedMobileProvision = [[profile componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] componentsJoinedByString:@""];
    }
  });
  
  return embeddedMobileProvision;
}

- (BOOL)isDebugBuild {
  if ([HOKDevice device].isSimulator) {
    return YES;
  }
  
  return [self.embeddedMobileProvision rangeOfString:@"<key>get-task-allow</key><true/>"].length > 0;
}

/**
 *  This function will look for the team identifier on the embedded mobile provisioning file.
 *  The mobile provisioning file will only exist on apps running on the device but not downloaded form the Store.
 *
 *  @return The Team ID (or null).
 */
- (NSString *)teamId {
  static NSString *teamId;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<key>com\\.apple\\.developer\\.team-identifier</key><string>(\\w+)</string>" options:0 error:&error];
    
    if (!error && self.embeddedMobileProvision) {
      NSTextCheckingResult *match = [regularExpression firstMatchInString:self.embeddedMobileProvision options:0 range:NSMakeRange(0, self.embeddedMobileProvision.length)];
      
      if (match.numberOfRanges > 1) {
        teamId = [self.embeddedMobileProvision substringWithRange:[match rangeAtIndex:1]];
      }
    }
  });
  
  return teamId;
}

- (NSString *)environment {
  return self.isDebugBuild ? HOKAppEnvironmentDebug : HOKAppEnvironmentRelease;
}

#pragma mark - Serializer
- (NSDictionary *)json {
  return @{@"name": [HOKUtils jsonValue:self.name],
           @"bundle": [HOKUtils jsonValue:self.bundle],
           @"version": [HOKUtils jsonValue:self.version],
           @"build": [HOKUtils jsonValue:self.build]};
}


@end
