//
//  HKURL.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKURL.h"

@interface HKURL ()

@property (nonatomic, strong) NSURL *url;

@end

@implementation HKURL

#pragma mark - Initializer
- (instancetype)initWithURL:(NSURL *)url
{
  self = [super init];
  if (self) {
    _url = [HKURL sanitizeURL:url];
    _scheme = [HKURL urlSchemeFromURLString:url.absoluteString];
    _queryParameters = [HKURL queryParametersFromURL:url];
  }
  
  return self;
}

#pragma mark - Public Methods
- (BOOL)matchesWithRoute:(HKRoute *)route routeParameters:(NSDictionary **)routeParameters
{
  NSArray *pathComponents = self.pathComponents;
  NSArray *routeComponents = route.components;
  
  if (pathComponents.count != routeComponents.count) {
    return NO;
  }
  
  NSDictionary *parameters = [HKURL matchPathComponents:pathComponents withRouteComponents:routeComponents];
  if(!parameters)
    return NO;
  
  if(routeParameters)
    *routeParameters = parameters;
  return YES;
}

#pragma mark - Private Methods
- (NSArray *)pathComponents
{
  NSString *path = [self.url host];
  if(path && [self.url path])
    path = [path stringByAppendingString:[self.url path]];
  return [path componentsSeparatedByString:@"/"];
}

// Separates string by '&' and then each substring by the '=' sign
+ (NSDictionary *)queryParametersFromURL:(NSURL *)url
{
  NSMutableDictionary *parameters = [@{} mutableCopy];
  NSString *query = url.query;
  if ([query isEqualToString:@""]) {
    return @{};
  }
  NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
  for (NSString *component in queryComponents) {
    NSRange equalsLocation = [component rangeOfString:@"="];
    if (equalsLocation.location == NSNotFound) {
      // There's no equals, so associate the key with NSNull
      parameters[[HKURL decodeURLString:component]] = [NSNull null];
    } else {
      NSString *key = [HKURL decodeURLString:[component substringToIndex:equalsLocation.location]];
      NSString *value = [HKURL decodeURLString:[component substringFromIndex:equalsLocation.location + 1]];
      parameters[key] = value;
    }
  }
  return [NSDictionary dictionaryWithDictionary:parameters];
}

#pragma mark - Sanitization
+ (NSString *)decodeURLString:(NSString *)string {
  return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL,
                                                                                  (CFStringRef)[string stringByReplacingOccurrencesOfString:@"+" withString:@"%20"],
                                                                                  CFSTR("")));
}

+ (NSString *)sanitizeURLString:(NSString *)urlString
{
  NSString *sanitizedURLString = [urlString stringByReplacingOccurrencesOfString:@"^/+"
                                                                      withString:@""
                                                                         options:NSRegularExpressionSearch
                                                                           range:NSMakeRange(0, urlString.length)];
  sanitizedURLString = [sanitizedURLString stringByReplacingOccurrencesOfString:@"/+$"
                                                                     withString:@""
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, sanitizedURLString.length)];
  sanitizedURLString = [sanitizedURLString stringByReplacingOccurrencesOfString:@"(?<!:)(/)+"
                                                                     withString:@"/"
                                                                        options:NSRegularExpressionSearch
                                                                          range:NSMakeRange(0, sanitizedURLString.length)];
  return sanitizedURLString;
}

+ (NSURL *)sanitizeURL:(NSURL *)url
{
  NSString *urlString = url.absoluteString;
  
  // Strip out query string
  urlString = [self urlStringWithoutQueryString:urlString];
  
  // URL Scheme from url
  NSString *urlScheme = [self urlSchemeFromURLString:urlString];
  
  // Remove URL Scheme from url
  NSString *path = [self pathForURLString:urlString urlScheme:[NSString stringWithFormat:@"%@:",urlScheme]];
  
  NSString *sanitizedURLString = [NSString stringWithFormat:@"%@://%@",
                                  urlScheme,
                                  path];
  return [NSURL URLWithString:sanitizedURLString];
  
}

+ (NSString *)urlStringWithoutQueryString:(NSString *)urlString
{
  NSString *url = urlString;
  NSInteger queryStringStart = [url rangeOfString:@"?"].location;
  if (queryStringStart != NSNotFound)
    url = [url substringToIndex:queryStringStart];
  return url;
}

+ (NSString *)urlSchemeFromURLString:(NSString *)urlString
{
  NSString *urlScheme = @"";
  for (NSInteger index = 0; index < urlString.length; index ++) {
    char character = [urlString characterAtIndex:index];
    
    // if '/' is before a ':' we have no urlScheme
    if (character == '/') {
      urlScheme = @":";
      break;
    }
    
    if (character == ':') {
      break;
    }
    urlScheme = [urlScheme stringByAppendingFormat:@"%c",character];
  }
  return urlScheme;
}

+ (NSString *)pathForURLString:(NSString *)urlString urlScheme:(NSString *)urlScheme
{
  if (urlScheme != nil) {
    if (urlString.length > urlScheme.length) {
      NSString *path = [urlString substringFromIndex:urlScheme.length];
      while ([path hasPrefix:@"/"] && path.length > 0) {
        path = [path substringFromIndex:1];
      }
      return path;
    }
  }
  return @"";
}

+ (NSDictionary *)matchPathComponents:(NSArray *)pathComponents withRouteComponents:(NSArray *)routeComponents
{
  NSMutableDictionary *routeParameters = [@{} mutableCopy];
  for (NSInteger index = 0; index < pathComponents.count; index++) {
    NSString *pathComponent = pathComponents[index];
    NSString *routeComponent = routeComponents[index];
    
    if ([routeComponent hasPrefix:@":"]) {
      routeParameters[[routeComponent substringFromIndex:1]] = pathComponent;
    } else if (![pathComponent isEqualToString:routeComponent]) {
      return nil;
    }
  }
  return routeParameters;
}

@end
