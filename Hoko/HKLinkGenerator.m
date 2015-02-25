//
//  HKLinkGenerator.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKLinkGenerator.h"

#import "HKError.h"
#import "HKLogger.h"
#import "HKRouting.h"
#import "HKNetworking.h"
#import "Hoko+Private.h"
#import "HKNetworkOperation.h"
#import "HKDeeplink+Private.h"
#import "HKDeeplinking+Private.h"

@interface HKLinkGenerator ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HKLinkGenerator

- (instancetype)initWithToken:(NSString *)token
{
  self = [super init];
  if (self) {
    _token = token;
  }
  return self;
}

#pragma mark - Hokolink Generation
- (void)generateHokolinkForDeeplink:(HKDeeplink *)deeplink success:(void (^)(NSString *hokolink))success failure:(void (^)(NSError *error))failure
{
  if (!deeplink) {
    failure([HKError nilDeeplinkError]);
  } else if (![[Hoko deeplinking].routing routeExists:deeplink.route]) {
    failure([HKError routeNotMappedError]);
  }else {
    [self requestForDeeplink:deeplink success:success failure:failure];
  }
}


#pragma mark - Networking
- (void)requestForDeeplink:(HKDeeplink *)deeplink success:(void (^)(NSString *hokolink))success failure:(void (^)(NSError *error))failure
{
  // TODO Change to hokolink
  [HKNetworking postToPath:[HKNetworkOperation urlFromPath:@"omnilinks"] parameters:deeplink.json token:self.token successBlock:^(id json) {
    if(json[@"omnilink"])
      success(json[@"omnilink"]);
    else
      failure([HKError hokolinkGenerationError]);
  } failedBlock:^(id error) {
    HKErrorLog([HKError serverErrorFromJSON:error]);
    failure([HKError serverErrorFromJSON:error]);
  }];
}

@end
