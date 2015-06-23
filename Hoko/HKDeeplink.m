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

NSString *const HKDeeplinkSmartlinkClickIdentifierKey = @"_hk_cid";

NSString *const HKDeeplinkOpenPath = @"smartlinks/open";

@interface HKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *deeplinkURL;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;
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
                           sourceApplication:nil
                                 deeplinkURL:nil];
}

#pragma mark - Private Static Initializer
+ (HKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication
                          deeplinkURL:(NSString *)deeplinkURL
{
    HKDeeplink *deeplink = [[HKDeeplink alloc] initWithURLScheme:urlScheme
                                                           route:route
                                                 routeParameters:routeParameters
                                                 queryParameters:queryParameters
                                               sourceApplication:sourceApplication
                                                     deeplinkURL:deeplinkURL];
    
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
                 sourceApplication:nil
                       deeplinkURL:nil];
}
- (instancetype)initWithURLScheme:(NSString *)urlScheme
                            route:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
                sourceApplication:(NSString *)sourceApplication
                      deeplinkURL:(NSString *)deeplinkURL
{
    self = [super init];
    if (self) {
        _urlScheme = urlScheme;
        _route = route;
        _routeParameters = routeParameters;
        _queryParameters = queryParameters;
        _sourceApplication = sourceApplication;
        _urls = [@{} mutableCopy];
        _deeplinkURL = deeplinkURL;
    }
    
    return self;
}

- (NSString *)url
{
    NSString *url = self.route;
    for (NSString *routeParameterKey in self.routeParameters.allKeys) {
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@",routeParameterKey]
                                             withString:[NSString stringWithFormat:@"%@",[self.routeParameters objectForKey:routeParameterKey]]];
    }
    
    if (self.queryParameters.count > 0) {
        url = [url stringByAppendingString:@"?"];
        for (NSString *queryParameterKey in self.queryParameters.allKeys) {
            url = [url stringByAppendingFormat:@"%@=%@&", queryParameterKey, [NSString stringWithFormat:@"%@", [self.queryParameters objectForKey:queryParameterKey]]];
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
    [self.urls setObject:@{@"link": urlString} forKey:[self stringForPlatform:platform]];
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
- (NSString *)smartlinkOpenIdentifier
{
    return [self.queryParameters objectForKey:HKDeeplinkSmartlinkClickIdentifierKey];
}

- (BOOL)isSmartlink
{
    return self.smartlinkOpenIdentifier != nil;
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token
{
    if (self.isSmartlink) {
        HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST
                                                                                            path:HKDeeplinkOpenPath
                                                                                           token:token
                                                                                      parameters:[self smartlinkJSON]];
        [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
        
    }
}

#pragma mark - Serialization
- (NSDictionary *)json
{
    return @{@"route": [HKUtils jsonValue:self.route],
             @"routeParameters": [HKUtils jsonValue:self.routeParameters],
             @"queryParameters": [HKUtils jsonValue:self.queryParameters]};
}

- (NSDictionary *)generateSmartlinkJSON
{
    if (!self.hasURLs) {
        return @{@"uri": [HKUtils jsonValue:self.url]};
    } else {
        return @{@"uri": [HKUtils jsonValue:self.url],
                 @"routes": self.urls};
    }
    
}


- (NSDictionary *)smartlinkJSON
{
    return @{@"deeplink": [HKUtils jsonValue:self.deeplinkURL]};
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
        NSString *routeComponent = [routeComponents objectAtIndex:index];
        
        if ([routeComponent hasPrefix:@":"] && [routeComponent length] > 2) {
            NSString *token = [routeComponent substringFromIndex:1];
            if (![routeParameters objectForKey:token])
                return NO;
        }
    }
    return YES;
}

@end
