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

- (void)generateSmartlinkForDeeplink:(HKDeeplink *)deeplink
                            success:(void (^)(NSString *smartlink))success
                            failure:(void (^)(NSError *error))failure;

@end
