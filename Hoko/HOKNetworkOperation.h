//
//  HOKNetworkOperation.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HOKNetworkOperationType) {
  HOKNetworkOperationTypeGET,
  HOKNetworkOperationTypePOST,
  HOKNetworkOperationTypePUT,
};

@interface HOKNetworkOperation : NSOperation <NSCoding>

- (instancetype)initWithOperation:(HOKNetworkOperation *)operation;
- (instancetype)initWithOperationType:(HOKNetworkOperationType)operationType
                                 path:(NSString *)path
                                token:(NSString *)token
                           parameters:(id)parameters;

+ (NSString *)urlFromPath:(NSString *)path;

@property (nonatomic, assign, readonly) HOKNetworkOperationType operationType;
@property (nonatomic, strong, readonly) NSString *path;
@property (nonatomic, strong, readonly) NSString *token;
@property (nonatomic, strong, readonly) id parameters;
@property (nonatomic, readonly) NSInteger numberOfRetries;

@end
