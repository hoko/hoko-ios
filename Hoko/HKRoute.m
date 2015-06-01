//
//  HKRoute.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKRoute.h"

#import "HKApp.h"
#import "HKUtils.h"
#import "HKDevice.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKRoutePath = @"routes";

@implementation HKRoute

#pragma mark - Initializer
- (instancetype)initWithRoute:(NSString *)route target:(void (^)(HKDeeplink *deeplink))target {
    self = [super init];
    if (self) {
        _route = route;
        _target = target;
    }
    return self;
}

#pragma mark - Public Static Initializer
+ (instancetype)routeWithRoute:(NSString *)route target:(void (^)(HKDeeplink *deeplink))target{
    return [[HKRoute alloc] initWithRoute:route target:target];
}

#pragma mark - Helper
- (NSArray *)components
{
    return [self.route componentsSeparatedByString:@"/"];
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token
{
    if (![self hasBeenPosted]) {
        [HKUtils saveBool:YES key:self.route]; //TODO check if response was 200
        HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                            path:HKRoutePath
                                                                                           token:token
                                                                                      parameters:self.json];
        [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
    }
}

#pragma mark - Serialization
- (id)json
{
    return @{@"route": @{@"build": [HKApp app].build,
                         @"device": [HKDevice device].platform,
                         @"path": self.route,
                         @"url_schemes": [HKApp app].urlSchemes,
                         @"version": [HKApp app].version}};
}

- (BOOL)hasBeenPosted
{
    return [HKUtils boolForKey:self.route];
}

@end
