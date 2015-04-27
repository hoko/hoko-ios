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

@end

@implementation HKSession

#pragma mark - Initializer
- (instancetype)initWithDeeplink:(HKDeeplink *)deeplink
{
  self = [super init];
  if (self) {
    _deeplink = deeplink;
    _startedAt = [NSDate date];
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
                         HKDeeplinkOpenIdentifierKey: [HKUtils jsonValue:self.deeplink.openIdentifier],
                         HKDeeplinkSmartlinkIdentifierKey: [HKUtils jsonValue:self.deeplink.smartlinkIdentifier]}};
}

@end
