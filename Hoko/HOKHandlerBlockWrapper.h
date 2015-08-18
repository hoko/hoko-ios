//
//  HOKHandlerBlockWrapper.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplink.h"

@interface HOKHandlerBlockWrapper : NSObject

- (instancetype)initWithHandlerBlock:(void (^)(HOKDeeplink *deeplink))handlerBlock;

@property (nonatomic, copy) void (^handlerBlock)(HOKDeeplink *deeplink);

@end