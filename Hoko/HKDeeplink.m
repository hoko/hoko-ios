//
//  HKDeeplink.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplink.h"

#import "HKURL.h"
#import "HKUser.h"
#import "HKUtils.h"
#import "HKDevice.h"
#import "HKRouting.h"
#import "HKDeeplink+Private.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKDeeplinkSmartlinkIdentifierKey = @"hk_sid";
NSString *const HKDeeplinkOpenIdentifierKey = @"hk_oid";

NSString *const HKDeeplinkOpenPath = @"smartlinks/%@/open";

@interface HKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSDictionary *json;
@property (nonatomic, strong, readonly) NSString *sourceApplication;

@end

@implementation HKDeeplink

#pragma mark - Public Static Initializer
+ (HKDeeplink *)deeplinkWithRoute:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
{
  return [HKDeeplink deeplinkWithURLScheme:nil
                                     route:route
                           routeParameters:routeParameters
                           queryParameters:queryParameters
                         sourceApplication:nil];
}

#pragma mark - Private Static Initializer
+ (HKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication
{
  HKDeeplink *deeplink = [[HKDeeplink alloc] initWithURLScheme:urlScheme
                                                         route:route
                                               routeParameters:routeParameters
                                               queryParameters:queryParameters
                                             sourceApplication:sourceApplication];
  
  if(![HKDeeplink matchRoute:deeplink.route withRouteParameters:deeplink.routeParameters])
    return nil;
  
  return deeplink;
}

#pragma mark - Private Initializer
- (instancetype)initWithRoute:(NSString *)route
              routeParameters:(NSDictionary *)routeParameters
              queryParameters:(NSDictionary *)queryParameters
{
  return [self initWithURLScheme:nil
                           route:route
                 routeParameters:routeParameters
                 queryParameters:queryParameters
               sourceApplication:nil];
}
- (instancetype)initWithURLScheme:(NSString *)urlScheme
                            route:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
                sourceApplication:(NSString *)sourceApplication
{
  self = [super init];
  if (self) {
    _urlScheme = urlScheme;
    _route = route;
    _routeParameters = routeParameters;
    _queryParameters = queryParameters;
    _sourceApplication = sourceApplication;
  }
  
  return self;
}

- (NSString *)path
{
  NSString *path = self.route;
  for (NSString *routeParameterKey in self.routeParameters.allKeys) {
    path = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",routeParameterKey]
                                           withString:[NSString stringWithFormat:@"%@",self.routeParameters[routeParameterKey]]];
  }
  
  if (self.queryParameters.count > 0) {
    path = [path stringByAppendingString:@"?"];
    for (NSString *queryParameterKey in self.queryParameters.allKeys) {
      path = [path stringByAppendingFormat:@"%@=%@&", queryParameterKey, [NSString stringWithFormat:@"%@",self.queryParameters[queryParameterKey]]];
    }
    path = [path substringToIndex:path.length - 1];
  }
  return path;
}

#pragma mark - Campaign Identifiers
- (NSString *)openIdentifier
{
  return self.queryParameters[HKDeeplinkOpenIdentifierKey];
}

- (NSString *)smartlinkIdentifier
{
  return self.queryParameters[HKDeeplinkSmartlinkIdentifierKey];
}

- (BOOL)isSmartlink
{
  return self.smartlinkIdentifier != nil;
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token user:(HKUser *)user statusCode:(HKDeeplinkStatus)statusCode
{
  if (self.isSmartlink) {
    HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                        path:[NSString stringWithFormat:HKDeeplinkOpenPath, self.smartlinkIdentifier]
                                                                                       token:token
                                                                                  parameters:[self smartlinkJSONWithUser:user]];
    [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
    
  }
}

#pragma mark - Serialization
- (id)json
{
    return @{@"routes": @{[[HKDevice device] platform].lowercaseString: [HKUtils jsonValue:self.path]}};
  
}

- (id)smartlinkJSONWithUser:(HKUser *)user
{
  return @{@"smartlink": @{@"smartlink_open_id": [HKUtils jsonValue:self.openIdentifier],
                          @"opened_at": [HKUtils stringFromDate:[NSDate date]],
                          @"user": user.baseJSON}};
}

#pragma mark - Description
- (NSString *)description
{
  return [NSString stringWithFormat:@"<HKDeeplink> URLScheme='%@' route='%@' routeParameters='%@' queryParameters='%@' sourceApplication='%@'",self.urlScheme, self.route, self.routeParameters, self.queryParameters, self.sourceApplication];
}

#pragma mark - Helper
+ (BOOL)matchRoute:(NSString *)route withRouteParameters:(NSDictionary *)routeParameters
{
  // Separate string by '/' char and look for substrings starting with ':'
  // then check if they match with the routeParameters
  NSArray *routeComponents = [route componentsSeparatedByString:@"/"];
  for (NSInteger index = 0; index < routeComponents.count; index++) {
    NSString *routeComponent = routeComponents[index];
    
    if ([routeComponent hasPrefix:@":"] && [routeComponent length] > 2) {
      NSString *token = [routeComponent substringFromIndex:1];
      if (!routeParameters[token])
        return NO;
    }
  }
  return YES;
}

@end
