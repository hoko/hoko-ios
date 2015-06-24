//
//  HOKVersionChecker.m
//  Hoko
//
//  Created by Ivan Bruel on 22/01/15.
//  Copyright (c) 2015 Faber Ventures. All rights reserved.
//

#import "HOKVersionChecker.h"

#import "HOKNetworking.h"
#import "HOKLogger.h"

NSString *const HOKVersionCheckerGitHubApi = @"https://api.github.com/repos/hokolinks/hoko-ios/releases?per_page=1";
NSString *const HOKVersionCheckerGithubVersionName = @"tag_name";
NSString *const HOKVersionCheckerGithubPrerelease = @"prerelease";

@implementation HOKVersionChecker

#pragma mark - Static Instance
+ (instancetype)versionChecker
{
    static HOKVersionChecker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [HOKVersionChecker new];
    });
    return _sharedInstance;
}

#pragma mark - Class Methods
- (void)checkForNewVersion:(NSString *)currentVersion
{
    [HOKNetworking requestToPath:HOKVersionCheckerGitHubApi parameters:nil token:nil successBlock:^(id json) {
        if ([json isKindOfClass:[NSArray class]]) {
            id firstJson = [json objectAtIndex:0];
            NSString *versionName = [firstJson objectForKey:HOKVersionCheckerGithubVersionName];
            NSString *currentVersionName = [NSString stringWithFormat:@"v%@",currentVersion];
            BOOL isPrerelease = [[firstJson objectForKey:HOKVersionCheckerGithubPrerelease] boolValue];
            if ([versionName compare:currentVersionName options:NSNumericSearch] == NSOrderedDescending && !isPrerelease) {
                HOKLog(@"A new version of HOKO is available at http://github.com/hokolinks/hoko-ios: %@",versionName);
            }
        } else {
            HOKLog(@"Unexpected response from GITHUB.");
        }
    } failedBlock:^(NSError *error) {
        HOKErrorLog(error);
    }];
}



@end
