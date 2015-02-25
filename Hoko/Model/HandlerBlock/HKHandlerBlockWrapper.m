//
//  HKHandlerBlockWrapper.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKHandlerBlockWrapper.h"

@implementation HKHandlerBlockWrapper

#pragma mark - Initializer
- (instancetype)initWithHandlerBlock:(void(^)(HKDeeplink *deeplink))handlerBlock
{
  self = [super init];
  if (self) {
    _handlerBlock = handlerBlock;
  }
  
  return self;
}

@end