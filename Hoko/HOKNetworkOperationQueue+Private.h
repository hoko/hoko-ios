//
//  HOKNetworkOperationQueue+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKNetworkOperationQueue.h"

extern NSInteger const HOKNetworkOperationQueueMaxRetries;

@interface HOKNetworkOperationQueue (Private)

- (void)flush;
- (void)saveNetworkOperations;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *networkOperations;

@end