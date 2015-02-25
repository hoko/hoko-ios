//
//  HKHandlerBlockWrapper.h
//  Hoko
//
//  Created by Ivan Bruel on 15/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import "HKDeeplink.h"

@interface HKHandlerBlockWrapper : NSObject

- (instancetype)initWithHandlerBlock:(void(^)(HKDeeplink *deeplink))handlerBlock;

@property (nonatomic, copy) void (^handlerBlock)(HKDeeplink *deeplink);

@end