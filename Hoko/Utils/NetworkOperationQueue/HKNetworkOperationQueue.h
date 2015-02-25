//
//  HKNetworkOperationQueue.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKNetworkOperation.h"

@interface HKNetworkOperationQueue : NSObject

+ (instancetype)sharedQueue;

- (void)addOperation:(HKNetworkOperation *)networkOperation;
- (void)finishedOperation:(HKNetworkOperation *)networkOperation;
- (void)failedOperation:(HKNetworkOperation *)networkOperation;

@end
