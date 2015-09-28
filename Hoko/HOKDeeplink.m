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
#import "HOKError.h"
#import "HOKLogger.h"
#import "HOKDevice.h"
#import "HOKRouting.h"
#import "HOKNetworking.h"
#import "HOKDeeplink+Private.h"
#import "HOKNetworkOperationQueue.h"

NSString *const HOKDeeplinkSmartlinkClickIdentifierKey = @"_hk_cid";
NSString *const HOKDeeplinkSmartlinkIdentifierKey = @"_hk_sid";
NSString *const HOKDeeplinkMetadataKey = @"_hk_md";

NSString *const HOKDeeplinkOpenPath = @"smartlinks/open";
NSString *const HOKDeeplinkMetadataPath = @"smartlinks/metadata";

@interface HOKDeeplink ()

@property (nonatomic, strong, readonly) NSString *urlScheme;
@property (nonatomic, strong, readonly) NSString *deeplinkURL;
@property (nonatomic, strong, readonly) NSDictionary *generateSmartlinkJSON;
@property (nonatomic, strong, readonly) NSString *sourceApplication;
@property (nonatomic, strong) NSMutableDictionary *urls;
@property (nonatomic) BOOL isDeferred;
@property (nonatomic) BOOL wasOpened;
@property (nonatomic) BOOL unique;

@end

@implementation HOKDeeplink

#pragma mark - Public Static Initializers

+ (HOKDeeplink *)deeplink {
  return [self deeplinkWithRoute:nil];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route {
  return [self deeplinkWithRoute:route
                 routeParameters:nil];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route routeParameters:(NSDictionary *)routeParameters {
  return [self deeplinkWithRoute:route
                 routeParameters:routeParameters
                 queryParameters:nil];
}


+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                   routeParameters:(NSDictionary *)routeParameters
                   queryParameters:(NSDictionary *)queryParameters {
  
  return [self deeplinkWithRoute:route
                 routeParameters:routeParameters
                 queryParameters:queryParameters
                        metadata:nil];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                   routeParameters:(NSDictionary *)routeParameters
                   queryParameters:(NSDictionary *)queryParameters
                          metadata:(NSDictionary *)metadata {
  
  return [self deeplinkWithRoute:route
                     routeParameters:routeParameters
                     queryParameters:queryParameters
                            metadata:metadata
                              unique:NO];
}

+ (HOKDeeplink *)deeplinkWithRoute:(NSString *)route
                   routeParameters:(NSDictionary *)routeParameters
                   queryParameters:(NSDictionary *)queryParameters
                          metadata:(NSDictionary *)metadata
                            unique:(BOOL)unique {
  
  return [self deeplinkWithURLScheme:nil
                               route:route
                     routeParameters:routeParameters
                     queryParameters:queryParameters
                            metadata:metadata
                   sourceApplication:nil
                         deeplinkURL:nil
                            deferred:NO
                              unique:YES];
}

#pragma mark - Private Static Initializer
+ (HOKDeeplink *)deeplinkWithURLScheme:(NSString *)urlScheme
                                 route:(NSString *)route
                       routeParameters:(NSDictionary *)routeParameters
                       queryParameters:(NSDictionary *)queryParameters
                              metadata:(NSDictionary *)metadata
                     sourceApplication:(NSString *)sourceApplication
                           deeplinkURL:(NSString *)deeplinkURL
                              deferred:(BOOL)isDeferred
                                unique:(BOOL)unique {
  
  HOKDeeplink *deeplink = [[HOKDeeplink alloc] initWithURLScheme:urlScheme
                                                           route:route
                                                 routeParameters:routeParameters
                                                 queryParameters:queryParameters
                                                        metadata:metadata
                                               sourceApplication:sourceApplication
                                                     deeplinkURL:deeplinkURL
                                                        deferred:isDeferred
                                                          unique:unique];
  
  if ([HOKDeeplink matchRoute:deeplink.route withRouteParameters:deeplink.routeParameters] || (route == nil && routeParameters == nil && queryParameters == nil && metadata == nil)) {
    return deeplink;
  }
  
  return nil;
}

#pragma mark - Private Initializer
- (instancetype)init {
  return [self initWithURLScheme:nil route:nil routeParameters:nil queryParameters:nil metadata:nil sourceApplication:nil deeplinkURL:nil deferred:NO unique:NO];
}

- (instancetype)initWithURLScheme:(NSString *)urlScheme
                            route:(NSString *)route
                  routeParameters:(NSDictionary *)routeParameters
                  queryParameters:(NSDictionary *)queryParameters
                         metadata:(NSDictionary *)metadata
                sourceApplication:(NSString *)sourceApplication
                      deeplinkURL:(NSString *)deeplinkURL
                         deferred:(BOOL)isDeferred
                           unique:(BOOL)unique {
  
  self = [super init];
  if (self) {
    _urlScheme = urlScheme;
    _route = route;
    _routeParameters = routeParameters;
    _queryParameters = queryParameters;
    if ([HOKDeeplink validateMetadataDictionary:metadata]){
      _metadata = metadata;
    } else {
      HOKErrorLog([HOKError invalidJSONMetadata]);
    }
    _sourceApplication = sourceApplication;
    _urls = [@{} mutableCopy];
    _deeplinkURL = deeplinkURL;
    
    _isDeferred = isDeferred;
    _wasOpened = NO;
    _unique = unique;
  }
  
  return self;
}

- (NSString *)url {
  NSString *url = self.route;
  for (NSString *routeParameterKey in self.routeParameters.allKeys) {
    url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@", routeParameterKey]
                                         withString:[NSString stringWithFormat:@"%@", [self.routeParameters objectForKey:routeParameterKey]]];
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
- (void)addURL:(NSString *)url forPlatform:(HOKDeeplinkPlatform)platform {
  NSString *urlString = url;
  if ([url isKindOfClass:[NSURL class]]) {
    urlString = [(NSURL *)url absoluteString];
  }
  
  [self.urls setObject:@{@"link": urlString} forKey:[self stringForPlatform:platform]];
}

- (NSString *)stringForPlatform:(HOKDeeplinkPlatform)platform {
  switch (platform) {
    case HOKDeeplinkPlatformIPhone:
      return @"iphone";
    case HOKDeeplinkPlatformIPad:
      return @"ipad";
    case HOKDeeplinkPlatformIOSUniversal:
      return @"universal";
    case HOKDeeplinkPlatformAndroid:
      return @"android";
    case HOKDeeplinkPlatformWeb:
      return @"web";
    default:
      return nil;
  }
}

- (BOOL)hasURLs {
  return self.urls.count > 0;
}

- (void)setMetadata:(NSDictionary *)metadata {
  if ([HOKDeeplink validateMetadataDictionary:metadata]) {
    _metadata = metadata;
  } else {
    HOKErrorLog([HOKError invalidJSONMetadata]);
  }
}

#pragma mark - Campaign Identifiers
- (NSString *)smartlinkClickIdentifier {
  return [self.queryParameters objectForKey:HOKDeeplinkSmartlinkClickIdentifierKey];
}

- (NSString *)smartlinkIdentifier {
  return [self.queryParameters objectForKey:HOKDeeplinkSmartlinkIdentifierKey];
}


- (BOOL)isSmartlink {
  return self.smartlinkClickIdentifier || self.smartlinkIdentifier;
}

- (BOOL)needsMetadata {
  return [self.queryParameters objectForKey:HOKDeeplinkMetadataKey] && !self.metadata;
}

#pragma mark - Networking
- (void)postWithToken:(NSString *)token {
  if (self.isSmartlink) {
    HOKNetworkOperation *networkOperation = [[HOKNetworkOperation alloc] initWithOperationType:HOKNetworkOperationTypePOST
                                                                                          path:HOKDeeplinkOpenPath
                                                                                         token:token
                                                                                    parameters:[self smartlinkJSON]];
    [[HOKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
    
  }
}

- (void)requestMetadataWithToken:(NSString *)token completion:(void(^)(void))completion {
  if (self.needsMetadata) {
    [HOKNetworking requestToPath:[HOKNetworkOperation urlFromPath:HOKDeeplinkMetadataPath] parameters:[self metadataJSON] token:token successBlock:^(id json) {
      _metadata = json;
      completion();
      
    } failedBlock:^(NSError *error) {
      HOKErrorLog(error);
      completion();
    }];
  }
}

#pragma mark - Serialization
- (NSDictionary *)json {
  return @{@"route": [HOKUtils jsonValue:self.route],
           @"routeParameters": [HOKUtils jsonValue:self.routeParameters],
           @"queryParameters": [HOKUtils jsonValue:self.queryParameters],
           @"metadata": [HOKUtils jsonValue:self.metadata]};
}

- (NSDictionary *)generateSmartlinkJSON {
  if (!self.hasURLs) {
    return @{@"uri": [HOKUtils jsonValue:self.url],
             @"unique": [HOKUtils jsonValue:@(self.unique)],
             @"metadata": [HOKUtils jsonValue:self.metadata]};
  } else {
    return @{@"uri": [HOKUtils jsonValue:self.url],
             @"routes": [HOKUtils jsonValue:self.urls],
             @"unique": [HOKUtils jsonValue:@(self.unique)],
             @"metadata": [HOKUtils jsonValue:self.metadata]};
  }
  
}


- (NSDictionary *)smartlinkJSON {
  return @{@"deeplink": [HOKUtils jsonValue:self.deeplinkURL],
           @"referrer": [HOKUtils jsonValue:self.sourceApplication],
           @"uid": [HOKUtils jsonValue:[HOKDevice device].uid]};
}

- (NSDictionary *)metadataJSON {
  if (self.smartlinkClickIdentifier) {
    return @{HOKDeeplinkSmartlinkClickIdentifierKey: [HOKUtils jsonValue:self.smartlinkClickIdentifier]};
  } else {
    return @{HOKDeeplinkSmartlinkIdentifierKey: [HOKUtils jsonValue:self.smartlinkIdentifier]};
  }
}

#pragma mark - Description
- (NSString *)description {
  return [NSString stringWithFormat:@"<HOKDeeplink> URLScheme='%@' route='%@' routeParameters='%@' queryParameters='%@' metadata='%@' sourceApplication='%@'", self.urlScheme, self.route, self.routeParameters, self.queryParameters, self.metadata, self.sourceApplication];
}

#pragma mark - Helper
+ (BOOL)matchRoute:(NSString *)route withRouteParameters:(NSDictionary *)routeParameters {
  // Separate string by '/' char and look for substrings starting with ':'
  // then check if they match with the routeParameters
  NSArray *routeComponents = [route componentsSeparatedByString:@"/"];
  for (NSInteger index = 0; index < routeComponents.count; index++) {
    NSString *routeComponent = [routeComponents objectAtIndex:index];
    
    if ([routeComponent hasPrefix:@":"] && [routeComponent length] > 2) {
      NSString *token = [routeComponent substringFromIndex:1];
      
      if (![routeParameters objectForKey:token]) {
        return NO;
      }
    }
  }
  
  return YES;
}

+ (BOOL)validateMetadataDictionary:(NSDictionary *)metadataDictionary {
  if (metadataDictionary && ![metadataDictionary isKindOfClass:[NSDictionary class]]) {
    return NO;
  }
  
  for (id object in [metadataDictionary allValues]) {
    if (![self validateMetadataObject:object]) {
      return NO;
    }
  }
  
  return YES;
}

+ (BOOL)validateMetadataObject:(id)object {
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
