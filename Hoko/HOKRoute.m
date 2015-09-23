//
//  HOKRoute.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKRoute.h"

#import "HOKApp.h"
#import "HOKUtils.h"
#import "HOKDevice.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HOKRoutePath = @"routes";

@implementation HOKRoute

#pragma mark - Initializer
- (instancetype)initWithRoute:(NSString *)route target:(void (^)(HOKDeeplink *deeplink))target {
  self = [super init];
  if (self) {
    _route = route;
    _target = target;
  }
  return self;
}

#pragma mark - Public Static Initializer
+ (instancetype)routeWithRoute:(NSString *)route target:(void (^)(HOKDeeplink *deeplink))target {
  return [[HOKRoute alloc] initWithRoute:route target:target];
}

#pragma mark - Helper
- (NSArray *)components {
  return [self.route componentsSeparatedByString:@"/"];
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token {
  HOKNetworkOperation *networkOperation = [[HOKNetworkOperation alloc] initWithOperationType:HOKNetworkOperationTypePOST
                                                                                        path:HOKRoutePath
                                                                                       token:token
                                                                                  parameters:self.json];
  [[HOKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
}

#pragma mark - Serialization
- (NSDictionary *)json {
  return @{@"route": @{@"build": [HOKUtils jsonValue:[HOKApp app].build],
                       @"device": [HOKUtils jsonValue:[HOKDevice device].platform],
                       @"path": [HOKUtils jsonValue:self.route],
                       @"url_schemes": [HOKUtils jsonValue:[HOKApp app].urlSchemes],
                       @"version": [HOKUtils jsonValue:[HOKApp app].version]}};
}


@end
