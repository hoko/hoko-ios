//
//  HOKDeeplink.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKDeeplink.h"

#import "HOKURL.h"
#import "HOKUtils.h"
#import "HOKDevice.h"
#import "HOKRouting.h"
#import "HOKDeeplink+Private.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HOKDeeplinkSmartlinkClickIdentifierKey = @"_hk_cid";

NSString *const HOKDeeplinkOpenPath = @"smartlinks/open";

@interface HOKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *deeplinkURL;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong) NSMutableDictionary *urls;


@end

@implementation HOKDeeplink

#pragma mark - Public Static Initializer
+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
{
    return [HOKDeeplink deeplinkWithURLScheme:nil
                                       route:route
                             routeParameters:routeParameters
                             queryParameters:queryParameters
                           sourceApplication:nil
                                 deeplinkURL:nil];
}

#pragma mark - Private Static Initializer
+ (HOKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                    sourceApplication:(NSString *)sourceApplication
                          deeplinkURL:(NSString *)deeplinkURL
{
    HOKDeeplink *deeplink = [[HOKDeeplink alloc] initWithURLScheme:urlScheme
                                                           route:route
                                                 routeParameters:routeParameters
                                                 queryParameters:queryParameters
                                               sourceApplication:sourceApplication
                                                     deeplinkURL:deeplinkURL];
    
    if(![HOKDeeplink matchRoute:deeplink.route withRouteParameters:deeplink.routeParameters])
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
- (void)addURL:(NSString *)url forPlatform:(HOKDeeplinkPlatform)platform
{
    NSString *urlString = url;
    if ([url isKindOfClass:[NSURL class]]) {
        urlString = [(NSURL *)url absoluteString];
    }
    [self.urls setObject:@{@"link": urlString} forKey:[self stringForPlatform:platform]];
}

- (NSString *)stringForPlatform:(HOKDeeplinkPlatform)platform
{
    switch (platform) {
        case HOKDeeplinkPlatformiPhone:
            return @"iphone";
        case HOKDeeplinkPlatformiPad:
            return @"ipad";
        case HOKDeeplinkPlatformiOSUniversal:
            return @"ios";
        case HOKDeeplinkPlatformAndroid:
            return @"android";
        case HOKDeeplinkPlatformWeb:
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
    return [self.queryParameters objectForKey:HOKDeeplinkSmartlinkClickIdentifierKey];
}

- (BOOL)isSmartlink
{
    return self.smartlinkOpenIdentifier != nil;
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token
{
    if (self.isSmartlink) {
        HOKNetworkOperation *networkOperation = [[HOKNetworkOperation alloc] initWithOperationType:HOKNetworkOperationTypePOST
                                                                                            path:HOKDeeplinkOpenPath
                                                                                           token:token
                                                                                      parameters:[self smartlinkJSON]];
        [[HOKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
        
    }
}

#pragma mark - Serialization
- (NSDictionary *)json
{
    return @{@"route": [HOKUtils jsonValue:self.route],
             @"routeParameters": [HOKUtils jsonValue:self.routeParameters],
             @"queryParameters": [HOKUtils jsonValue:self.queryParameters]};
}

- (NSDictionary *)generateSmartlinkJSON
{
    if (!self.hasURLs) {
        return @{@"uri": [HOKUtils jsonValue:self.url]};
    } else {
        return @{@"uri": [HOKUtils jsonValue:self.url],
                 @"routes": self.urls};
    }
    
}


- (NSDictionary *)smartlinkJSON
{
    return @{@"deeplink": [HOKUtils jsonValue:self.deeplinkURL]};
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"<HOKDeeplink> URLScheme='%@' route='%@' routeParameters='%@' queryParameters='%@' sourceApplication='%@'",self.urlScheme, self.route, self.routeParameters, self.queryParameters, self.sourceApplication];
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
