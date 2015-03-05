//
//  HKNetworkOperationQueue.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKNetworkOperationQueue.h"

#import <UIKit/UIApplication.h>

#import "HKUtils.h"
#import "HKDevice.h"
#import "HKObserver.h"

NSInteger const HKNetworkOperationQueueMaxRetries = 2;
NSTimeInterval const HKNetworkOperationQueueFlushInterval = 10;
NSString *const HKNetworkOperationQueueOperationsKey = @"networkOperations";

@interface HKNetworkOperationQueue ()

@property (atomic, strong) NSTimer *flushTimer;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *networkOperations;

@end

@implementation HKNetworkOperationQueue

#pragma mark - Singleton
+ (instancetype)sharedQueue
{
  static HKNetworkOperationQueue *_sharedQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedQueue = [HKNetworkOperationQueue new];
  });
  
  return _sharedQueue;
}

#pragma mark - Setup
- (void)setup
{
  _operationQueue = [NSOperationQueue new];
  _operationQueue.name = NSStringFromClass([self class]);
  _operationQueue.maxConcurrentOperationCount = 1;
  [self loadNetworkOperations];
  [self flush];
  [self setupObservers];
}

#pragma mark - Operations
- (void)flush
{
  if (self.networkOperations.count > 0 && [HKDevice device].hasInternetConnection) {
    [self stopFlushTimer];
    for (HKNetworkOperation *operation in self.networkOperations) {
      if (operation.isFinished || operation.isCancelled || operation.isExecuting || [self.operationQueue.operations containsObject:operation])
        continue;
      [self.operationQueue addOperation:operation];
    }
    __weak HKNetworkOperationQueue *wself = self;
    [self.operationQueue addOperationWithBlock:^{
      [wself performSelectorOnMainThread:@selector(startFlushTimer) withObject:nil waitUntilDone:NO];
    }];
  } else {
    [self startFlushTimer];
  }
}

- (void)addOperation:(HKNetworkOperation *)networkOperation
{
  if (networkOperation.numberOfRetries < HKNetworkOperationQueueMaxRetries) {
    [self.networkOperations addObject:networkOperation];
  }
  [self saveNetworkOperations];
}

- (void)finishedOperation:(HKNetworkOperation *)networkOperation
{
  [self.networkOperations removeObject:networkOperation];
  [self saveNetworkOperations];
}

- (void)failedOperation:(HKNetworkOperation *)networkOperation
{
  [self.networkOperations removeObject:networkOperation];
  [self addOperation:[[HKNetworkOperation alloc] initWithOperation:networkOperation]];
}

#pragma mark - Timer
- (void)startFlushTimer
{
  if (!self.flushTimer && [HKDevice device].hasInternetConnection) {
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:HKNetworkOperationQueueFlushInterval 
                                                       target:self
                                                     selector:@selector(flush)
                                                     userInfo:nil
                                                      repeats:YES];
  }
}

- (void)stopFlushTimer
{
  if (self.flushTimer) {
    [self.flushTimer invalidate];
    self.flushTimer = nil;
  }
}

#pragma mark - Observers
- (void)setupObservers
{
  [[HKObserver observer] registerForNotification:UIApplicationWillEnterForegroundNotification triggered:^(NSNotification *notification) {
    [self performSelectorOnMainThread:@selector(flush) withObject:nil waitUntilDone:NO];
  }];
  [[HKObserver observer] registerForNotification:UIApplicationWillResignActiveNotification triggered:^(NSNotification *notification) {
    [self performSelectorOnMainThread:@selector(stopFlushTimer) withObject:nil waitUntilDone:NO];
  }];
  
  [[HKObserver observer] observe:[HKDevice device] keyPath:@"internetConnectivity" triggered:^BOOL(id object, id oldValue, id newValue) {
    if ([HKDevice device].hasInternetConnection) {
      [self performSelectorOnMainThread:@selector(startFlushTimer) withObject:nil waitUntilDone:NO];
    } else {
      [self performSelectorOnMainThread:@selector(stopFlushTimer) withObject:nil waitUntilDone:NO];
    }
    return NO;
  }];
  
}

#pragma mark - Storing
- (void)saveNetworkOperations
{
  [HKUtils saveObject:self.networkOperations.copy toFile:HKNetworkOperationQueueOperationsKey];
}

- (void)loadNetworkOperations
{
  self.networkOperations = [[HKUtils objectFromFile:HKNetworkOperationQueueOperationsKey] mutableCopy];
  if (!self.networkOperations) {
    self.networkOperations = [@[] mutableCopy];
  }
}



@end
