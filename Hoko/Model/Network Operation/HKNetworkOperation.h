//
//  HKNetworkOperation.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HKNetworkOperationType) {
  HKNetworkOperationTypeGET,
  HKNetworkOperationTypePOST,
  HKNetworkOperationTypePUT,
};

FOUNDATION_EXPORT NSString *const HKNetworkingOperationEndpoint;

@interface HKNetworkOperation : NSOperation <NSCoding>

- (instancetype)initWithOperation:(HKNetworkOperation *)operation;
- (instancetype)initWithOperationType:(HKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters;

+ (NSString *)urlFromPath:(NSString *)path;

@property (nonatomic, assign, readonly) HKNetworkOperationType operationType;
@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) id parameters;
@property (nonatomic, readonly) NSInteger numberOfRetries;

@end
