//
//  HOKRouting+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 05/08/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKRouting.h"

extern NSString *const HOKRoutingBannerRoute;


@interface HOKRouting (Private)

- (void)mapInternalRoute:(NSString *)route toTarget:(void (^)(HOKDeeplink *deeplink))target;
- (BOOL)openDeeplink:(HOKDeeplink *)deeplink;

@end