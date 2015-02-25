//
//  HKSession.h
//  Hoko
//
//  Created by Ivan Bruel on 15/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import "HKUser.h"
#import "HKEvent.h"
#import "HKDeeplink.h"

@interface HKSession : NSObject

- (instancetype)initWithUser:(HKUser *)user deeplink:(HKDeeplink *)deeplink;

- (void)trackKeyEvent:(HKEvent *)event;
- (void)end;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) HKDeeplink *deeplink;
@property (nonatomic, strong, readonly) NSDate *startedAt;
@property (nonatomic, strong, readonly) NSDate *endedAt;
@property (nonatomic, strong) HKUser *user;
@property (nonatomic, strong, readonly) NSArray *keyEvents;

@property (nonatomic, strong, readonly) id json;

@end
