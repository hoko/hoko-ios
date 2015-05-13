//
//  HKDeferredDeeplinking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKDeferredDeeplinking : NSObject

- (instancetype)initWithToken:(NSString *)token;

- (void)ignoreFirstRun;
- (void)requestDeferredDeeplink:(void(^)(NSString *deeplink))handler;

@end
