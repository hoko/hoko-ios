//
//  HKObserver.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKObserver.h"

@interface HKObserver ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation HKObserver

#pragma mark - Public Static Instance
+ (instancetype)observer {
  static HKObserver *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HKObserver new];
    _sharedInstance.observers = [@[] mutableCopy];
  });
  
  return _sharedInstance;
}

#pragma mark - Observe
- (HKNotificationObserver *)registerForNotification:(NSString *)name triggered:(HKNotificationTriggeredBlock)triggered
{
  HKNotificationObserver *notificationObserver = [[HKNotificationObserver alloc] initWithNotification:name triggered:triggered];
  [self.observers addObject:notificationObserver];
}

- (void)observe:(id)object keyPath:(NSString *)keyPath triggered:(HKObjectObserverTriggered)triggered
{
  HKObjectObserver *objectObserver = [[HKObjectObserver alloc] initWithObject:object keyPath:keyPath triggered:triggered];
  [self.observers addObject:objectObserver];

}

- (void)removeObserver:(id)observer
{
  [self.observers removeObject:observer];
}

@end


