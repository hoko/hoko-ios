//
//  HKObjectObserver.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

typedef BOOL (^HKObjectObserverTriggered)(id object, id oldValue, id newValue);

@interface HKObjectObserver : NSObject

- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath triggered:(HKObjectObserverTriggered)triggered;

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSString *keyPath;
@property (nonatomic, copy) HKObjectObserverTriggered triggered;

@end