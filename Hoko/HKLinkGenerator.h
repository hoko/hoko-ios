//
//  HKLinkGenerator.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@class HKRouting;

@interface HKLinkGenerator : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)generateHokolinkForDeeplink:(HKDeeplink *)deeplink success:(void (^)(NSString *hokolink))success failure:(void (^)(NSError *error))failure;

@end
