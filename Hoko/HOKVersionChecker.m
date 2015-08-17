//
//  HOKVersionChecker.m
//  Hoko
//
//  Created by Hoko, S.A. on 22/01/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKVersionChecker.h"

#import "HOKLogger.h"
#import "HOKNetworking.h"
#import "HOKNetworkOperation.h"

@implementation HOKVersionChecker

#pragma mark - Static Instance
+ (instancetype)versionChecker {
    static HOKVersionChecker *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [HOKVersionChecker new];
    });
    return _sharedInstance;
}

#pragma mark - Class Methods
- (void)checkForNewVersion:(NSString *)currentVersion token:(NSString *)token {
    [HOKNetworking requestToPath:[HOKNetworkOperation urlFromPath:@"version"] parameters:nil token:token successBlock:^(id json) {
        NSString *versionName = [json objectForKey:@"version"];
        if ([versionName compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            NSLog(@"A new version of HOKO is available please update your Podfile to \"pod 'Hoko' '~> %@'\"",versionName);
        }
    } failedBlock:^(NSError *error) {
        HOKErrorLog(error);
    }];
}



@end
