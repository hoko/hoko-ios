//
//  HOKNetworkOperationQueue.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKNetworkOperationQueue.h"

#import <UIKit/UIApplication.h>

#import "HOKUtils.h"
#import "HOKDevice.h"
#import "HOKObserver.h"

NSInteger const HOKNetworkOperationQueueMaxRetries = 2;
NSTimeInterval const HOKNetworkOperationQueueFlushInterval = 10;
NSString *const HOKNetworkOperationQueueOperationsKey = @"networkOperations";

@interface HOKNetworkOperationQueue ()

@property (atomic, strong) NSTimer *flushTimer;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *networkOperations;

@end

@implementation HOKNetworkOperationQueue

#pragma mark - Singleton
+ (instancetype)sharedQueue {
  static HOKNetworkOperationQueue *_sharedQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedQueue = [HOKNetworkOperationQueue new];
  });
  
  return _sharedQueue;
}

#pragma mark - Initialization
- (instancetype)init {
  if (self = [super init]) {
    [self setupObservers];
  }
  return self;
}

#pragma mark - Setup
- (void)setup {
  self.operationQueue = [NSOperationQueue new];
  self.operationQueue.name = NSStringFromClass([self class]);
  self.operationQueue.maxConcurrentOperationCount = 1;
  
  [self loadNetworkOperations];
  [self flush];
}

#pragma mark - Operations
- (void)flush {
  if (self.networkOperations.count > 0 && [HOKDevice device].hasInternetConnection) {
    [self stopFlushTimer];
    
    for (HOKNetworkOperation *operation in [self.networkOperations copy]) {
      if (operation.isFinished || operation.isCancelled || operation.isExecuting || [self.operationQueue.operations containsObject:operation]) {
        continue;
      }
      
      [self.operationQueue addOperation:operation];
    }
    
    __weak HOKNetworkOperationQueue *wself = self;
    [self.operationQueue addOperationWithBlock:^{
      [wself performSelectorOnMainThread:@selector(startFlushTimer) withObject:nil waitUntilDone:NO];
    }];
    
  } else {
    [self startFlushTimer];
  }
}

- (void)addOperation:(HOKNetworkOperation *)networkOperation {
  if (networkOperation.numberOfRetries < HOKNetworkOperationQueueMaxRetries) {
    [self.networkOperations addObject:networkOperation];
  }
  [self saveNetworkOperations];
}

- (void)finishedOperation:(HOKNetworkOperation *)networkOperation {
  [self.networkOperations removeObject:networkOperation];
  [self saveNetworkOperations];
}

- (void)failedOperation:(HOKNetworkOperation *)networkOperation {
  [self.networkOperations removeObject:networkOperation];
  [self addOperation:[[HOKNetworkOperation alloc] initWithOperation:networkOperation]];
}

#pragma mark - Timer
- (void)startFlushTimer {
  if (!self.flushTimer && [HOKDevice device].hasInternetConnection) {
    self.flushTimer = [NSTimer scheduledTimerWithTimeInterval:HOKNetworkOperationQueueFlushInterval
                                                       target:self
                                                     selector:@selector(flush)
                                                     userInfo:nil
                                                      repeats:YES];
  }
}

- (void)stopFlushTimer {
  if (self.flushTimer) {
    [self.flushTimer invalidate];
    self.flushTimer = nil;
  }
}

#pragma mark - Observers
- (void)setupObservers {
  [[HOKObserver observer] registerForNotification:UIApplicationWillEnterForegroundNotification triggered:^(NSNotification *notification) {
    [self performSelectorOnMainThread:@selector(flush) withObject:nil waitUntilDone:NO];
  }];
  
  [[HOKObserver observer] registerForNotification:UIApplicationWillResignActiveNotification triggered:^(NSNotification *notification) {
    [self performSelectorOnMainThread:@selector(stopFlushTimer) withObject:nil waitUntilDone:NO];
  }];
  
  [[HOKObserver observer] observe:[HOKDevice device] keyPath:@"internetConnectivity" triggered:^BOOL(id object, id oldValue, id newValue) {
    if ([HOKDevice device].hasInternetConnection) {
      [self performSelectorOnMainThread:@selector(startFlushTimer) withObject:nil waitUntilDone:NO];
    } else {
      [self performSelectorOnMainThread:@selector(stopFlushTimer) withObject:nil waitUntilDone:NO];
    }
    
    return NO;
  }];
  
}

#pragma mark - Storing
- (void)saveNetworkOperations {
  [HOKUtils saveObject:self.networkOperations.copy toFile:HOKNetworkOperationQueueOperationsKey];
}

- (void)loadNetworkOperations {
  self.networkOperations = [[HOKUtils objectFromFile:HOKNetworkOperationQueueOperationsKey] mutableCopy];
  if (!self.networkOperations) {
    self.networkOperations = [@[] mutableCopy];
  }
}



@end
