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
#import "HOKLogger.h"
#import "HOKDevice.h"
#import "HOKRouting.h"
#import "HOKNetworking.h"
#import "HOKDeeplink+Private.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HOKDeeplinkSmartlinkClickIdentifierKey = @"_hk_cid";
NSString *const HOKDeeplinkMetadataKey = @"_hk_md";

NSString *const HOKDeeplinkOpenPath = @"smartlinks/open";
NSString *const HOKDeeplinkMetadataPath = @"smartlinks/%@/metadata";

@interface HOKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *deeplinkURL;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong) NSMutableDictionary *urls;

@end

@implementation HOKDeeplink

#pragma mark - Public Static Initializers

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
{
    return [self deeplinkWithRoute:route
                   routeParameters:nil];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                   routeParameters:(NSDictionary *)routeParameters
{
    return [self deeplinkWithRoute:route
                   routeParameters:routeParameters
                   queryParameters:nil];
}


+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                   routeParameters:(NSDictionary *)routeParameters
                   queryParameters:(NSDictionary *)queryParameters
{
    return [self deeplinkWithRoute:route
                   routeParameters:routeParameters
                   queryParameters:queryParameters
                          metadata:nil];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
                          metadata:(NSDictionary *)metadata
{
    return [self deeplinkWithURLScheme:nil
                                       route:route
                             routeParameters:routeParameters
                       queryParameters:queryParameters
                              metadata:metadata
                           sourceApplication:nil
                                 deeplinkURL:nil];
}

#pragma mark - Private Static Initializer
+ (HOKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                route:(NSString *)route
                      routeParameters:(NSDictionary *)routeParameters
                      queryParameters:(NSDictionary *)queryParameters
                              metadata:(NSDictionary *)metadata
                    sourceApplication:(NSString *)sourceApplication
                          deeplinkURL:(NSString *)deeplinkURL
{
    HOKDeeplink *deeplink = [[HOKDeeplink alloc] initWithURLScheme:urlScheme
                                                           route:route
                                                 routeParameters:routeParameters
                                                 queryParameters:queryParameters
                                                          metadata:metadata
                                               sourceApplication:sourceApplication
                                                     deeplinkURL:deeplinkURL];
    
    if(![HOKDeeplink matchRoute:deeplink.route withRouteParameters:deeplink.routeParameters])
        return nil;
    
    return deeplink;
}

#pragma mark - Private Initializer
- (instancetype)initWithURLScheme:(NSString *)urlScheme
                            route:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
                         metadata:(NSDictionary *)metadata
                sourceApplication:(NSString *)sourceApplication
                      deeplinkURL:(NSString *)deeplinkURL
{
    self = [super init];
    if (self) {
        _urlScheme = urlScheme;
        _route = route;
        _routeParameters = routeParameters;
        _queryParameters = queryParameters;
        if ([HOKDeeplink validateMetadataDictionary:metadata]) {
            _metadata = metadata;
        }
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

- (void)setMetadata:(NSDictionary *)metadata
{
    _metadata = metadata;
}

#pragma mark - Campaign Identifiers
- (NSString *)smartlinkClickIdentifier
{
    return [self.queryParameters objectForKey:HOKDeeplinkSmartlinkClickIdentifierKey];
}

- (BOOL)isSmartlink
{
    return self.smartlinkClickIdentifier != nil;
}

- (BOOL)needsMetadata
{
    return [self.queryParameters objectForKey:HOKDeeplinkMetadataKey] && !self.metadata;
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

- (void)requestMetadataWithToken:(NSString *)token completion:(void(^)(void))completion
{
    if (self.needsMetadata) {
        NSString *path = [NSString stringWithFormat:HOKDeeplinkMetadataPath, self.smartlinkClickIdentifier];
        [HOKNetworking requestToPath:[HOKNetworkOperation urlFromPath:path] parameters:nil token:token successBlock:^(id json) {
            _metadata = json;
            completion();
        } failedBlock:^(NSError *error) {
            HOKErrorLog(error);
            completion();
        }];
    }
}

#pragma mark - Serialization
- (NSDictionary *)json
{
    return @{@"route": [HOKUtils jsonValue:self.route],
             @"routeParameters": [HOKUtils jsonValue:self.routeParameters],
             @"queryParameters": [HOKUtils jsonValue:self.queryParameters],
             @"metadata": [HOKUtils jsonValue:self.metadata]};
}

- (NSDictionary *)generateSmartlinkJSON
{
    if (!self.hasURLs) {
        return @{@"uri": [HOKUtils jsonValue:self.url],
                 @"metadata": [HOKUtils jsonValue:self.metadata]};
    } else {
        return @{@"uri": [HOKUtils jsonValue:self.url],
                 @"routes": self.urls,
                 @"metadata": [HOKUtils jsonValue:self.metadata]};
    }
    
}


- (NSDictionary *)smartlinkJSON
{
    return @{@"deeplink": [HOKUtils jsonValue:self.deeplinkURL],
             @"referrer": [HOKUtils jsonValue:self.sourceApplication]};
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"<HOKDeeplink> URLScheme='%@' route='%@' routeParameters='%@' queryParameters='%@' metadata='%@' sourceApplication='%@'",self.urlScheme, self.route, self.routeParameters, self.queryParameters, self.metadata, self.sourceApplication];
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

+ (BOOL)validateMetadataDictionary:(NSDictionary *)metadataDictionary
{
    if (!metadataDictionary || ![metadataDictionary isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    for (id key in [metadataDictionary allKeys]) {
        if (![self validateMetadataObject:key]) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)validateMetadataObject:(id)object
{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self validateMetadataDictionary:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        for (id arrayObject in object) {
            if (![self validateMetadataObject:arrayObject]) {
                return NO;
            }
        }
        return YES;
    } else {
        return [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]];
    }
}

@end
