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

#pragma mark - Smartlink Generation
- (void)generateSmartlinkForDeeplink:(HKDeeplink *)deeplink
                             success:(void (^)(NSString *smartlink))success
                             failure:(void (^)(NSError *error))failure
{
  if (!deeplink) {
    failure([HKError nilDeeplinkError]);
  } else if (![[Hoko deeplinking].routing routeExists:deeplink.route]) {
    failure([HKError routeNotMappedError]);
  }else {
    [self requestForSmartlinkWithDeeplink:deeplink success:success failure:failure];
  }
}

#pragma mark - Networking
- (void)requestForSmartlinkWithDeeplink:(HKDeeplink *)deeplink
                                success:(void (^)(NSString *smartlink))success
                                failure:(void (^)(NSError *error))failure
{
  NSString *path = deeplink.hasURLs ? @"smartlinks/create_custom" : @"smartlinks/create_with_template";
  [HKNetworking postToPath:[HKNetworkOperation urlFromPath:path] parameters:deeplink.json token:self.token successBlock:^(id json) {
    if(json[@"smartlink"])
      success(json[@"smartlink"]);
    else
      failure([HKError smartlinkGenerationError]);
  } failedBlock:^(id error) {
    HKErrorLog([HKError serverErrorFromJSON:error]);
    failure([HKError serverErrorFromJSON:error]);
  }];
}

@end
