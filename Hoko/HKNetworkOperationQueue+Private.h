//
//  HKNetworkOperationQueue+Private.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

extern NSInteger const HKNetworkOperationQueueMaxRetries;

@interface HKNetworkOperationQueue (Private)

- (void)flush;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableArray *networkOperations;

@end