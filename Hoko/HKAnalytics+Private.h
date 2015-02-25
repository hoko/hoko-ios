//
//  HKAnalytics+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@class HKUser;

@interface HKAnalytics (Private)

- (instancetype)initWithToken:(NSString *)token;

- (void)postCurrentUser;
- (HKUser *)currentUser;

@end