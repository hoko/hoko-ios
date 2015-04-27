//
//  HKSession.h
//  Hoko
//
//  Created by Ivan Bruel on 15/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import "HKDeeplink.h"

@interface HKSession : NSObject

- (instancetype)initWithDeeplink:(HKDeeplink *)deeplink;

- (void)end;

- (void)postWithToken:(NSString *)token;

@property (nonatomic, strong, readonly) HKDeeplink *deeplink;
@property (nonatomic, strong, readonly) NSDate *startedAt;
@property (nonatomic, strong, readonly) NSDate *endedAt;

@property (nonatomic, strong, readonly) id json;

@end
