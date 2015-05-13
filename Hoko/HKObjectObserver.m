//
//  HKObjectObserver.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKObjectObserver.h"

#import "HKObserver.h"

@implementation HKObjectObserver

#pragma mark - Initializer
- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath triggered:(HKObjectObserverTriggered)triggered
{
  self = [super init];
  if (self) {
    _object = object;
    _keyPath = keyPath;
    _triggered = triggered;
    [self observe];
  }
  return self;
}

#pragma mark - Observe
- (void)observe
{
  [self.object addObserver:self forKeyPath:self.keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if ([keyPath isEqualToString:self.keyPath]) {
      if (self.triggered(object, [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey])) {
      [self.object removeObserver:self forKeyPath:self.keyPath context:NULL];
      [[HKObserver observer] removeObserver:self];
    }
  }
}

@end
