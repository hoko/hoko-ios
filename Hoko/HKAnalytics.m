//
//  HKAnalytics.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKAnalytics.h"

#import "HKUser.h"
#import "HKEvent.h"
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

@property (nonatomic, strong) HKUser *user;
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
    self.user = [HKUser currentUser];
    if (!self.user) {
      [self identifyUser];
    } else {
      [self.user postWithToken:self.token];
    }
    
    [self observeApplicationLifecycle];
  }
  return self;
}

#pragma mark - Private accessors
- (HKUser *)currentUser
{
  return self.user;
}

#pragma mark - User Identification
- (void)identifyUser
{
  // Don't identify another anonymous user when current user is already anonymous
  if (!self.user.anonymous) {
    [self endCurrentSession];
    self.user = [HKUser new];
    [self.user postWithToken:self.token];
  }
}

- (void)identifyUserWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType
{
  [self identifyUserWithIdentifier:identifier
                       accountType:accountType
                              name:nil
                             email:nil
                         birthDate:nil
                            gender:HKUserGenderUnknown];
}

- (void)identifyUserWithIdentifier:(NSString *)identifier
                       accountType:(HKUserAccountType)accountType
                              name:(NSString *)name
                             email:(NSString *)email
                         birthDate:(NSDate *)birthDate
                            gender:(HKUserGender)gender
{
  // Ignore equal users (by comparing identifiers)
  if (!self.user || ![identifier isEqualToString:self.user.identifier]) {
    NSString *previousIdentifier = self.user.anonymous ? self.user.identifier : nil;
    self.user = [[HKUser alloc] initWithIdentifier:identifier
                                       accountType:accountType
                                              name:name
                                             email:email
                                         birthDate:birthDate
                                            gender:gender
                                previousIdentifier:previousIdentifier];
    [self.user postWithToken:self.token];
    
    // end session if not merging users or update session's user otherwise (in case he session exists)
    if (!previousIdentifier) {
      [self endCurrentSession];
    } else if(self.session) {
      self.session.user = self.user;
    }
  }
}

- (void)postCurrentUser
{
  [self.user postWithToken:self.token];
}

#pragma mark - Event Tracking
- (void)trackKeyEvent:(NSString *)eventName
{
  [self trackKeyEvent:eventName amount:nil];
}

- (void)trackKeyEvent:(NSString *)eventName
               amount:(NSNumber *)amount
{
  HKEvent *event = [[HKEvent alloc] initWithName:eventName amount:amount];
  if (self.session) {
    [self.session trackKeyEvent:event];
  } else {
    HKErrorLog([HKError ignoringKeyEventError:event]);
  }
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
  self.session = [[HKSession alloc] initWithUser:self.user deeplink:deeplink];
  [deeplink postWithToken:self.token user:self.user statusCode:HKDeeplinkStatusOpened];
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
