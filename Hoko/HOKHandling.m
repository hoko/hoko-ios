//
//  HOKHandling.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKHandling.h"

#import "HOKError.h"
#import "HOKLogger.h"
#import "HOKHandlerBlockWrapper.h"

@interface HOKHandling ()

@property (nonatomic, strong) NSMutableArray *handlers;

@end

@implementation HOKHandling

#pragma mark - Initializer
- (instancetype)init {
  self = [super init];
  if (self) {
    _handlers = [@[] mutableCopy];
  }
  return self;
}

#pragma mark - Add Handlers
- (void)addHandler:(id<HOKHandlerProcotol>)handler {
  if (![self.handlers containsObject:handler]) {
    [self.handlers addObject:handler];
  } else {
    HOKErrorLog([HOKError handlerAlreadyExistsError]);
  }
}

- (void)addHandlerBlock:(void (^)(HOKDeeplink *deeplink))handlerBlock {
  [self.handlers addObject:[[HOKHandlerBlockWrapper alloc] initWithHandlerBlock:handlerBlock]];
}

#pragma mark - Handle Deeplink
- (void)handle:(HOKDeeplink *)deeplink {
  for (id handler in self.handlers) {
    // Object implements protocol
    if ([handler conformsToProtocol:@protocol(HOKHandlerProcotol)]) {
      id<HOKHandlerProcotol> handlerObj = (id<HOKHandlerProcotol>)handler;
      
      if ([handlerObj respondsToSelector:@selector(handleDeeplink:)]) {
        [handlerObj handleDeeplink:deeplink];
      }
      
    } else {
      // Object is a block wrapper
      if ([handler isKindOfClass:[HOKHandlerBlockWrapper class]]) {
        HOKHandlerBlockWrapper *handlerBlockWrapper = (HOKHandlerBlockWrapper *)handler;
        if (handlerBlockWrapper.handlerBlock) {
          handlerBlockWrapper.handlerBlock(deeplink);
        }
      }
    }
  }
}

@end


