//
//  HOKFilterBlockWrapper.m
//  Hoko
//
//  Created by Hoko, S.A. on 04/08/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKFilterBlockWrapper.h"

@implementation HOKFilterBlockWrapper

#pragma mark - Initializer
- (instancetype)initWithFilterBlock:(BOOL (^)(HOKDeeplink *deeplink))filterBlock
{
    self = [super init];
    if (self) {
        _filterBlock = filterBlock;
    }
    
    return self;
}


@end
