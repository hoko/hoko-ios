//
//  HOKLinkGenerator.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKLinkGenerator.h"

#import "HOKError.h"
#import "HOKLogger.h"
#import "HOKRouting.h"
#import "HOKNetworking.h"
#import "Hoko+Private.h"
#import "HOKNetworkOperation.h"
#import "HOKDeeplink+Private.h"
#import "HOKDeeplinking+Private.h"

@interface HOKLinkGenerator ()

@property (nonatomic, strong) NSString *token;

@end

@implementation HOKLinkGenerator

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

#pragma mark - Smartlink Generation
- (void)generateSmartlinkForDeeplink:(HOKDeeplink *)deeplink
                             success:(void (^)(NSString *smartlink))success
                             failure:(void (^)(NSError *error))failure
{
    if (!deeplink) {
        failure([HOKError nilDeeplinkError]);
    } else if (![[Hoko deeplinking].routing routeExists:deeplink.route]) {
        failure([HOKError routeNotMappedError]);
    }else {
        [self requestForSmartlinkWithDeeplink:deeplink success:success failure:failure];
    }
}

#pragma mark - Networking
- (void)requestForSmartlinkWithDeeplink:(HOKDeeplink *)deeplink
                                success:(void (^)(NSString *smartlink))success
                                failure:(void (^)(NSError *error))failure
{
    [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:@"smartlinks/create"] parameters:deeplink.generateSmartlinkJSON token:self.token successBlock:^(id json) {
        NSString *smartlink = [json objectForKey:@"smartlink"];
        if(smartlink)
            success(smartlink);
        else
            failure([HOKError smartlinkGenerationError]);
    } failedBlock:^(id error) {
        HOKErrorLog([HOKError serverErrorFromJSON:error]);
        failure([HOKError serverErrorFromJSON:error]);
    }];
}

@end
