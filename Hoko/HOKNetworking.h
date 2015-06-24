//
//  HOKNetworking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HOKNetworkingSuccessBlock)(id json);
typedef void (^HOKNetworkingFailedBlock)(NSError *error);

extern NSString *const HOKNetworkingEndpoint;
extern NSString *const HOKNetworkingVersion;
extern NSString *const HOKNetworkingFormat;

@interface HOKNetworking : NSObject

+ (void)requestToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HOKNetworkingSuccessBlock)successBlock failedBlock:(HOKNetworkingFailedBlock)failedBlock;

+ (void)postToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HOKNetworkingSuccessBlock)successBlock failedBlock:(HOKNetworkingFailedBlock)failedBlock;

+ (void)putToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HOKNetworkingSuccessBlock)successBlock failedBlock:(HOKNetworkingFailedBlock)failedBlock;

@end
