//
//  HKHandling.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@interface HKHandling : NSObject

- (void)addHandler:(id<HKHandlerProcotol>)handler;
- (void)addHandlerBlock:(void(^)(HKDeeplink *deeplink))handlerBlock;

- (void)handle:(HKDeeplink *)deeplink;

@end
