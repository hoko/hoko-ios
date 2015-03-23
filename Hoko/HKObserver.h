//
//  HKObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKObjectObserver.h"
#import "HKNotificationObserver.h"

@interface HKObserver : NSObject

+ (instancetype)observer;

- (HKNotificationObserver *)registerForNotification:(NSString *)name triggered:(HKNotificationTriggeredBlock)triggered;
- (void)observe:(id)object keyPath:(NSString *)keyPath triggered:(HKObjectObserverTriggered)triggered;

- (void)removeObserver:(id)observer;

@end
