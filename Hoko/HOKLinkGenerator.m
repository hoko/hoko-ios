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

- (instancetype)initWithToken:(NSString *)token {
  self = [super init];
  if (self) {
    _token = token;
  }
  return self;
}

#pragma mark - Smartlink Generation
- (void)generateSmartlinkForDeeplink:(HOKDeeplink *)deeplink
                             success:(void (^)(NSString *smartlink))success
                             failure:(void (^)(NSError *error))failure {
  
  if (!deeplink) {
    failure([HOKError nilDeeplinkError]);
  } else if (![[Hoko deeplinking].routing routeExists:deeplink.route]) {
    failure([HOKError routeNotMappedError]);
  } else {
    [self requestForSmartlinkWithDeeplink:deeplink success:success failure:failure];
  }
}

- (NSString *)generateLazySmartlinkForDeeplink:(HOKDeeplink *)deeplink domain:(NSString *)domain customDomain:(NSString *)customDomain
{
  if (deeplink && domain) {
    if (deeplink.hasURLs) {
      HOKErrorLog([HOKError lazySmartlinkCantHaveURLsError]);
      return nil;
    }
    NSString *strippedDomain = [domain stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    strippedDomain = [strippedDomain stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    if ([strippedDomain rangeOfString:@"/"].location != NSNotFound) {
      HOKErrorLog([HOKError invalidDomain:domain]);
    } else if ([customDomain isEqualToString:strippedDomain] || [strippedDomain rangeOfString:@"hoko.link"].location != NSNotFound) {
      return [NSString stringWithFormat:@"http://%@/lazy?uri=%@", strippedDomain, [HOKLinkGenerator URLEncodeStringFromString:deeplink.url]];
    } else {
      HOKErrorLog([HOKError domainUnknown:domain customDomain:customDomain]);
    }
  }
  return nil;
}

#pragma mark - Networking
- (void)requestForSmartlinkWithDeeplink:(HOKDeeplink *)deeplink
                                success:(void (^)(NSString *smartlink))success
                                failure:(void (^)(NSError *error))failure {
  
  [HOKNetworking postToPath:[HOKNetworkOperation urlFromPath:@"smartlinks"] parameters:deeplink.generateSmartlinkJSON token:self.token successBlock:^(id json) {
    NSString *smartlink = [json objectForKey:@"smartlink"];
    if (smartlink) {
      success(smartlink);
    } else {
      failure([HOKError smartlinkGenerationError]);
    }
  } failedBlock:^(id error) {
    HOKErrorLog([HOKError serverErrorFromJSON:error]);
    failure([HOKError serverErrorFromJSON:error]);
  }];
}

#pragma mark - URL Encoding
+ (NSString *)URLEncodeStringFromString:(NSString *)string
{
  static CFStringRef charset = CFSTR("!@#$%&*()+'\";:=,/?[] ");
  CFStringRef str = (__bridge CFStringRef)string;
  CFStringEncoding encoding = kCFStringEncodingUTF8;
  return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, str, NULL, charset, encoding));
}

@end
