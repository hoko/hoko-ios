//
//  HOKLinkGenerator.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@class HOKRouting;

@interface HOKLinkGenerator : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)generateSmartlinkForDeeplink:(HOKDeeplink *)deeplink
                             success:(void (^)(NSString *smartlink))success
                             failure:(void (^)(NSError *error))failure;
- (NSString *)generateLazySmartlinkForDeeplink:(HOKDeeplink *)deeplink domain:(NSString *)domain customDomain:(NSString *)customDomain;

@end
