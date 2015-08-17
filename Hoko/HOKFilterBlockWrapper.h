//
//  HOKFilterBlockWrapper.h
//  Hoko
//
//  Created by Hoko, S.A. on 04/08/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplink.h"

@interface HOKFilterBlockWrapper : NSObject

- (instancetype)initWithFilterBlock:(BOOL (^)(HOKDeeplink *deeplink))filterBlock;

@property (nonatomic, copy) BOOL (^filterBlock)(HOKDeeplink *deeplink);

@end