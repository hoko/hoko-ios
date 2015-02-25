//
//  HKHandling.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKHandling.h"

#import "HKError.h"
#import "HKLogger.h"
#import "HKHandlerBlockWrapper.h"

@interface HKHandling ()

@property (nonatomic, strong) NSArray *handlers;

@end

@implementation HKHandling

#pragma mark - Initializer
- (instancetype)init
{
  self = [super init];
  if (self) {
    _handlers = @[];
  }
  return self;
}

#pragma mark - Add Handlers
- (void)addHandler:(id<HKHandlerProcotol>)handler
{
  if (![self.handlers containsObject:handler])
    self.handlers = [self.handlers arrayByAddingObject:handler];
  else
    HKErrorLog([HKError handlerAlreadyExistsError]);
}

- (void)addHandlerBlock:(void(^)(HKDeeplink *deeplink))handlerBlock
{
  self.handlers = [self.handlers arrayByAddingObject:[[HKHandlerBlockWrapper alloc] initWithHandlerBlock:handlerBlock]];
}

#pragma mark - Handle Deeplink
- (void)handle:(HKDeeplink *)deeplink
{
  for (id handler in self.handlers) {
    // Object implements protocol
    if ([handler conformsToProtocol:@protocol(HKHandlerProcotol)]) {
      id<HKHandlerProcotol> handlerObj = (id<HKHandlerProcotol>)handler;
      if ([handlerObj respondsToSelector:@selector(handleDeeplink:)])
        [handlerObj handleDeeplink:deeplink];
    } else {
      // Object is a block wrapper
      if ([handler isKindOfClass:[HKHandlerBlockWrapper class]]) {
        HKHandlerBlockWrapper *handlerBlockWrapper = (HKHandlerBlockWrapper *)handler;
        if(handlerBlockWrapper.handlerBlock)
          handlerBlockWrapper.handlerBlock(deeplink);
      }
    }
  }
}

@end


