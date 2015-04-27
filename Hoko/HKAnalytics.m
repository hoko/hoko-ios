//
//  HKAnalytics.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKAnalytics.h"

#import "HKError.h"
#import "HKUtils.h"
#import "HKLogger.h"
#import "HKSession.h"
#import "HKObserver.h"
#import "Hoko+Private.h"
#import "HKDeeplink+Private.h"
#import "HKNetworkOperationQueue.h"
#import "HKAnalytics+Private.h"

@interface HKAnalytics ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) HKSession *session;

@end

@implementation HKAnalytics

#pragma mark - Initialization
- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
        self.session = nil;
        
        // Load user from Storage if possible otherwise create new anonymous user
        [self observeApplicationLifecycle];
    }
    return self;
}

#pragma mark - Sessions
- (void)endCurrentSession{
    if (self.session) {
        [self.session end];
        [self.session postWithToken:self.token];
        self.session = nil;
    }
}

#pragma mark - HKHandlerProtocol
- (void)handleDeeplink:(HKDeeplink *)deeplink
{
    [self endCurrentSession];
    self.session = [[HKSession alloc] initWithDeeplink:deeplink];
    [deeplink postWithToken:self.token statusCode:HKDeeplinkStatusOpened];
}

#pragma mark - Observers
- (void)observeApplicationLifecycle
{
    __weak HKAnalytics *wself = self;
    [[HKObserver observer] registerForNotification:UIApplicationWillResignActiveNotification triggered:^(NSNotification *notification) {
        [wself applicationWillResignActive];
    }];
}

- (void)applicationWillResignActive
{
    [self endCurrentSession];
}

@end
