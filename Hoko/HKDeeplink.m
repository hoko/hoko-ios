//
//  HKDeeplink.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKDeeplink.h"

#import "HKURL.h"
#import "HKUtils.h"
#import "HKDevice.h"
#import "HKRouting.h"
#import "HKDeeplink+Private.h"
#import "HKNetworkOperationQueue.h"

NSString *const HKDeeplinkSmartlinkIdentifierKey = @"_hk_sid";
NSString *const HKDeeplinkOpenIdentifierKey = @"_hk_oid";

NSString *const HKDeeplinkOpenPath = @"smartlinks/%@/open";


@interface HKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSDictionary *json;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong) NSMutableDictionary *urls;

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
        _urls = [@{} mutableCopy];
    }
    
    return self;
}

- (NSString *)url
{
    NSString *url = self.route;
    for (NSString *routeParameterKey in self.routeParameters.allKeys) {
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",routeParameterKey]
                                             withString:[NSString stringWithFormat:@"%@",self.routeParameters[routeParameterKey]]];
    }
    
    if (self.queryParameters.count > 0) {
        url = [url stringByAppendingString:@"?"];
        for (NSString *queryParameterKey in self.queryParameters.allKeys) {
            url = [url stringByAppendingFormat:@"%@=%@&", queryParameterKey, [NSString stringWithFormat:@"%@",self.queryParameters[queryParameterKey]]];
        }
        url = [url substringToIndex:url.length - 1];
    }
    return url;
}

#pragma mark - Linking
- (void)addURL:(NSString *)url forPlatform:(HKDeeplinkPlatform)platform
{
    NSString *urlString = url;
    if ([url isKindOfClass:[NSURL class]]) {
        urlString = [(NSURL *)url absoluteString];
    }
    self.urls[[self stringForPlatform:platform]] = @{@"link": urlString};
}

- (NSString *)stringForPlatform:(HKDeeplinkPlatform)platform
{
    switch (platform) {
        case HKDeeplinkPlatformiPhone:
            return @"iphone";
        case HKDeeplinkPlatformiPad:
            return @"ipad";
        case HKDeeplinkPlatformiOSUniversal:
            return @"ios";
        case HKDeeplinkPlatformAndroid:
            return @"android";
        case HKDeeplinkPlatformWeb:
            return @"web";
        default:
            return nil;
    }
}

- (BOOL)hasURLs
{
    return self.urls.count > 0;
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
- (void)postWithToken:(NSString *)token statusCode:(HKDeeplinkStatus)statusCode
{
    if (self.isSmartlink) {
        HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                            path:[NSString stringWithFormat:HKDeeplinkOpenPath, self.smartlinkIdentifier]
                                                                                           token:token
                                                                                      parameters:[self smartlinkJSON]];
        [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
        
    }
}

#pragma mark - Serialization
- (id)json
{
    if (!self.hasURLs) {
        return @{@"original_url": [HKUtils jsonValue:self.url]};
    } else {
        return @{@"original_url": [HKUtils jsonValue:self.url],
                 @"routes": self.urls};
    }
    
}


- (id)smartlinkJSON
{
    return @{@"smartlink": @{HKDeeplinkOpenIdentifierKey: [HKUtils jsonValue:self.openIdentifier],
                             @"opened_at": [HKUtils stringFromDate:[NSDate date]],
                             @"device": [HKDevice device].json}};
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
