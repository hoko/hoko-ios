//
//  HKNetworking.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

typedef void (^HKNetworkingSuccessBlock)(id json);
typedef void (^HKNetworkingFailedBlock)(NSError *error);

extern NSString *const HKNetworkingEndpoint;
extern NSString *const HKNetworkingVersion;
extern NSString *const HKNetworkingFormat;

@interface HKNetworking : NSObject

+ (void)requestToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HKNetworkingSuccessBlock)successBlock failedBlock:(HKNetworkingFailedBlock)failedBlock;

+ (void)postToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HKNetworkingSuccessBlock)successBlock failedBlock:(HKNetworkingFailedBlock)failedBlock;

+ (void)putToPath:(NSString *)path parameters:(id)parameters token:(NSString *)token successBlock:(HKNetworkingSuccessBlock)successBlock failedBlock:(HKNetworkingFailedBlock)failedBlock;

@end
