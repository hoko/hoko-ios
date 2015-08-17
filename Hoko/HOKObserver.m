//
//  HOKObserver.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKObserver.h"

@interface HOKObserver ()

@property (nonatomic, strong) NSMutableArray *observers;

@end

@implementation HOKObserver

#pragma mark - Public Static Instance
+ (instancetype)observer {
  static HOKObserver *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [HOKObserver new];
    _sharedInstance.observers = [@[] mutableCopy];
  });
  
  return _sharedInstance;
}

#pragma mark - Observe
- (HOKNotificationObserver *)registerForNotification:(NSString *)name triggered:(HOKNotificationTriggeredBlock)triggered {
  HOKNotificationObserver *notificationObserver = [[HOKNotificationObserver alloc] initWithNotification:name triggered:triggered];
  [self.observers addObject:notificationObserver];
  
  return notificationObserver;
}

- (void)observe:(id)object keyPath:(NSString *)keyPath triggered:(HOKObjectObserverTriggered)triggered {
  HOKObjectObserver *objectObserver = [[HOKObjectObserver alloc] initWithObject:object keyPath:keyPath triggered:triggered];
  [self.observers addObject:objectObserver];
}

- (void)removeObserver:(id)observer {
  [self.observers removeObject:observer];
}

@end


