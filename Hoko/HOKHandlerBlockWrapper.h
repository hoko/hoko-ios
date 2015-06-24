//
//  HOKHandlerBlockWrapper.h
//  Hoko
//
//  Created by Ivan Bruel on 15/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import "HOKDeeplink.h"

@interface HOKHandlerBlockWrapper : NSObject

- (instancetype)initWithHandlerBlock:(void(^)(HOKDeeplink *deeplink))handlerBlock;

@property (nonatomic, copy) void (^handlerBlock)(HOKDeeplink *deeplink);

@end