//
//  HKVersionChecker.m
//  Hoko
//
//  Created by Ivan Bruel on 22/01/15.
//  Copyright (c) 2015 Faber Ventures. All rights reserved.
//

#import "HKVersionChecker.h"

#import "HKNetworking.h"
#import "HKLogger.h"

NSString *const HKVersionCheckerGitHubApi = @"https://api.github.com/repos/hokolinks/hoko-ios/releases?per_page=1";
NSString *const HKVersionCheckerGithubVersionName = @"tag_name";

@implementation HKVersionChecker

#pragma mark - Static Instance
+ (instancetype)versionChecker
{
  static HKVersionChecker *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HKVersionChecker new];
  });
  return _sharedInstance;
}

#pragma mark - Class Methods
- (void)checkForNewVersion:(NSString *)currentVersion
{
  [HKNetworking requestToPath:HKVersionCheckerGitHubApi parameters:nil token:nil successBlock:^(id json) {
    id firstJson = json[0];
    NSString *versionName = firstJson[HKVersionCheckerGithubVersionName];
    NSString *currentVersionName = [NSString stringWithFormat:@"v%@",currentVersion];
    if ([versionName compare:currentVersionName options:NSNumericSearch] == NSOrderedDescending) {
      NSLog(@"[HOKO] A new version of HOKO is available at http://github.com/hokolinks/hoko-ios: %@",versionName);
    }
  } failedBlock:^(NSError *error) {
    HKErrorLog(error);
  }];
}



@end
