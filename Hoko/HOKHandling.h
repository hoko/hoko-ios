//
//  HOKHandling.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "Hoko.h"

@interface HOKHandling : NSObject

- (void)addHandler:(id<HOKHandlerProcotol>)handler;
- (void)addHandlerBlock:(void (^)(HOKDeeplink *deeplink))handlerBlock;

- (void)handle:(HOKDeeplink *)deeplink;

@end
