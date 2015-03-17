//
//  HKSession.m
//  Hoko
//
//  Created by Ivan Bruel on 15/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import "HKSession.h"

#import "HKUtils.h"
#import "HKDeeplink+Private.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKSessionPath = @"sessions";

@interface HKSession ()

@property (nonatomic, strong) HKDeeplink *deeplink;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, strong) NSDate *endedAt;
@property (nonatomic, strong) NSArray *keyEvents;

@end

@implementation HKSession

#pragma mark - Initializer
- (instancetype)initWithUser:(HKUser *)user deeplink:(HKDeeplink *)deeplink
{
  self = [super init];
  if (self) {
    _user = user;
    _deeplink = deeplink;
    _startedAt = [NSDate date];
    _keyEvents = @[];
    _endedAt = nil;
  }
  return self;
}

#pragma mark - Logic
// Duration in seconds
- (NSNumber *)duration
{
  return @(round([self.endedAt timeIntervalSinceDate:self.startedAt]));
}

#pragma mark - Events
- (void)trackKeyEvent:(HKEvent *)event
{
  self.keyEvents = [self.keyEvents arrayByAddingObject:event];
}

#pragma mark - End Session
- (void)end
{
  self.endedAt = [NSDate date];
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token
{
  HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc]initWithOperationType:HKNetworkOperationTypePOST
                                                                                     path:HKSessionPath
                                                                                    token:token
                                                                               parameters:self.json];
  [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
}

#pragma mark - Serialization
- (id)json
{
  return @{@"session": @{@"started_at": [HKUtils jsonValue:[HKUtils stringFromDate:self.startedAt]],
                         @"duration": [HKUtils jsonValue:self.duration],
                         @"user": [HKUtils jsonValue:self.user.json[@"user"]],
                         @"key_events": [HKUtils jsonValue:[self eventsJSON]],
                         HKDeeplinkOpenIdentifierKey: [HKUtils jsonValue:self.deeplink.openIdentifier],
                         HKDeeplinkSmartlinkIdentifierKey: [HKUtils jsonValue:self.deeplink.smartlinkIdentifier]}};
}

- (id)eventsJSON
{
  NSArray *eventsJSON = @[];
  for (HKEvent *event in self.keyEvents)
    eventsJSON = [eventsJSON arrayByAddingObject:event.json];
  return eventsJSON;
}

@end
