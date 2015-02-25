//
//  HKNotificationObserver.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKNotificationObserver.h"

#import "HKObserver.h"

@implementation HKNotificationObserver

#pragma mark - Initializer
- (instancetype)initWithNotification:(NSString *)name triggered:(HKNotificationTriggeredBlock)triggered
{
  self = [super init];
  if (self) {
    _name = name;
    _triggered = triggered;
    [self observe];
  }
  
  return self;
}

#pragma mark - Observe
- (void)observe
{
  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self
                         selector:@selector(triggered:)
                             name:self.name
                           object:nil];
}

- (void)triggered:(NSNotification *)notification
{
  self.triggered(notification);
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[HKObserver observer] removeObserver:self];
}

@end