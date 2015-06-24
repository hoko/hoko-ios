//
//  HOKNetworkOperationQueue.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HOKNetworkOperation.h"

@interface HOKNetworkOperationQueue : NSObject

+ (instancetype)sharedQueue;

- (void)setup;

- (void)addOperation:(HOKNetworkOperation *)networkOperation;
- (void)finishedOperation:(HOKNetworkOperation *)networkOperation;
- (void)failedOperation:(HOKNetworkOperation *)networkOperation;

@end
