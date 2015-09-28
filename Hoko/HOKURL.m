//
//  HOKURL.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKURL.h"

#import "HOKApp.h"

@interface HOKURL ()

@property (nonatomic, strong) NSURL *url;

@end

NSString *const HOKDefaultURLScheme = @"hoko";

@implementation HOKURL

#pragma mark - Initializer
- (instancetype)initWithURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _url = [HOKURL sanitizeURL:url];
    _scheme = [HOKURL urlSchemeFromURLString:url.absoluteString];
    _queryParameters = [HOKURL queryParametersFromURL:url];
  }
  
  return self;
}

#pragma mark - Public Methods
- (BOOL)matchesWithRoute:(HOKRoute *)route routeParameters:(NSDictionary **)routeParameters {
  NSArray *pathComponents = self.pathComponents;
  NSArray *routeComponents = route.components;
  
  if (pathComponents.count != routeComponents.count) {
    return NO;
  }
  
  NSDictionary *parameters = [HOKURL matchPathComponents:pathComponents withRouteComponents:routeComponents];
  if (!parameters) {
    return NO;
  }
  
  if (routeParameters) {
    *routeParameters = parameters;
  }
  
  return YES;
}

#pragma mark - Private Methods
- (NSArray *)pathComponents {
  NSString *path = [self.url host];
  if (path && [self.url path]) {
    path = [path stringByAppendingString:[self.url path]];
  }
  return [path componentsSeparatedByString:@"/"];
}

// Separates string by '&' and then each substring by the '=' sign
+ (NSDictionary *)queryParametersFromURL:(NSURL *)url {
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
      [parameters setObject:[NSNull null] forKey:[HOKURL decodeURLString:component]];
    } else {
      NSString *key = [HOKURL decodeURLString:[component substringToIndex:equalsLocation.location]];
      NSString *value = [HOKURL decodeURLString:[component substringFromIndex:equalsLocation.location + 1]];
      [parameters setObject:value forKey:key];
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

+ (NSString *)sanitizeURLString:(NSString *)urlString {
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

+ (NSURL *)sanitizeURL:(NSURL *)url {
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

+ (NSString *)urlStringWithoutQueryString:(NSString *)urlString {
  NSString *url = urlString;
  NSInteger queryStringStart = [url rangeOfString:@"?"].location;
  
  if (queryStringStart != NSNotFound) {
    url = [url substringToIndex:queryStringStart];
  }
  
  return url;
}

// Using this method instead of NSURL's scheme because it doesn't recognize "app:" as a scheme, for instance
+ (NSString *)urlSchemeFromURLString:(NSString *)urlString {
  NSMutableString *urlScheme = [NSMutableString string];
  for (NSInteger index = 0; index < urlString.length; index ++) {
    char character = [urlString characterAtIndex:index];
    
    // if '/' is before a ':' we have no urlScheme
    if (character == '/') {
      urlScheme = [NSMutableString stringWithString:@":"];
      break;
    }
    
    if (character == ':') {
      break;
    }
    
    [urlScheme appendFormat:@"%c",character];
  }
  
  return urlScheme;
}

+ (NSString *)pathForURLString:(NSString *)urlString urlScheme:(NSString *)urlScheme {
  if (urlScheme != nil) {
    if (urlString.length > urlScheme.length) {
      NSMutableString *path = [[urlString substringFromIndex:urlScheme.length] mutableCopy];
      while ([path hasPrefix:@"/"] && path.length > 0) {
        [path deleteCharactersInRange:NSMakeRange(0, 1)];
      }
      
      if ([path hasSuffix:@"/"] && path.length > 0) {
        [path deleteCharactersInRange:NSMakeRange(path.length-1, 1)];
      }
      
      return path;
    }
  }
  
  return @"";
}

+ (NSDictionary *)matchPathComponents:(NSArray *)pathComponents withRouteComponents:(NSArray *)routeComponents {
  NSMutableDictionary *routeParameters = [NSMutableDictionary dictionary];
  for (NSInteger index = 0; index < pathComponents.count; index++) {
    NSString *pathComponent = [pathComponents objectAtIndex:index];
    NSString *routeComponent = [routeComponents objectAtIndex:index];
    
    if ([routeComponent hasPrefix:@":"]) {
      routeParameters[[routeComponent substringFromIndex:1]] = pathComponent;
    } else if (![pathComponent isEqualToString:routeComponent]) {
      return nil;
    }
  }
  
  return routeParameters;
}

+ (NSURL *)deeplinkifyURL:(NSURL *)url {
  if (!url) {
    return nil;
  }
  
  NSString *prefix = [self grabURLScheme];
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", prefix, [self pathForURLString:url.absoluteString urlScheme:[NSString stringWithFormat:@"%@://%@", url.scheme, url.host]]]];
}

+ (NSString *)grabURLScheme {
  HOKApp *app = [HOKApp app];
  if (app.hasURLSchemes) {
    return app.urlSchemes[0];
  } else {
    return HOKDefaultURLScheme;
  }
}

@end
