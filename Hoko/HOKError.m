//
//  HOKError.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HOKError.h"

NSString *const HOKErrorDomain = @"Hoko";
NSString *const HOKServerErrorDomain = @"HokoServerError";
NSString *const HOKServerWarningDomain = @"HokoServerWarning";

@implementation HOKError

#pragma mark - Initializers
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
  return [self errorWithDomain:HOKErrorDomain code:code description:description];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description {
  return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey: description?description:@"No Description"}];
}

#pragma mark - Public Errors
+ (NSError *)setupNotCalledYetError {
  return [self errorWithCode:1 description:@"Cannot access modules without calling [Hoko setupWithToken:] beforehand."];
}

+ (NSError *)setupCalledMoreThanOnceError {
  return [self errorWithCode:2 description:@"Cannot call the [Hoko setupWithToken:] method more than once on the application's lifecycle."];
}

+ (NSError *)noURLSchemesError {
  return [self errorWithCode:3 description:@"No URL Schemes have been detected on your application. To make it deeplinkable you need to set a URL Scheme beforehand. Please follow our guide in http://hokolinks.com/sdk/ios"];
}

+ (NSError *)duplicateRouteError:(NSString *)route {
  return [self errorWithCode:4 description:[NSString stringWithFormat:@"The route %@ will be ignored as it was already mapped before.",route]];
}

+ (NSError *)notDeeplinkableError:(id)object {
  return [self errorWithCode:5 description:[NSString stringWithFormat:@"%@ does not conform to the HOKDeeplinkable Protocol.",object]];
}

+ (NSError *)noDeeplinkMethodError:(id)object {
  return [self errorWithCode:6 description:[NSString stringWithFormat:@"%@ does not implement the '- (HOKDeeplink *)deeplink' method of the HOKDeeplinkable Protocol.",object]];
}

+ (NSError *)noDeeplinkOpenedMethodError:(id)object {
  return [self errorWithCode:7 description:@"Object does not implement the 'deeplinkOpened:' method of the HOKDeeplinkable Protocol."];
}

+ (NSError *)smartlinkGenerationError {
  return [self errorWithCode:8 description:@"Could not generate Smartlink. Please try again later."];
}

+ (NSError *)genericServerError {
  return [self errorWithCode:9 description:@"Could not reach the Hoko service. Please try again later."];
}

+ (NSError *)routeNotMappedError {
  return [self errorWithCode:10 description:@"The route is not mapped. Please map it in the AppDelegate before trying to generate a Smartlink."];
}

+ (NSError *)nilDeeplinkError {
  return [self errorWithCode:11 description:@"Deeplink provided was nil. Be sure the route format and route parameters are correct when creating a HOKDeeplink object."];
}

+ (NSError *)couldNotFindAppDelegateError {
  return [self errorWithCode:12 description:@"Could not find the AppDelegate class. Please delegate the deeplinking methods to the corresponding Hoko modules."];
}

+ (NSError *)jsonParseError:(id)object {
  return [self errorWithCode:13 description:[NSString stringWithFormat:@"Could not parse %@ into JSON",object]];
}

+ (NSError *)networkingError:(NSError *)error {
  return [self errorWithCode:14 description:error.description];
}

+ (NSError *)handlerAlreadyExistsError {
  return [self errorWithCode:16 description:@"The handler being added has already been added."];
}

+ (NSError *)invalidJSONMetadata {
  return [self errorWithCode:15 description:@"Metadata is not valid JSON, only NSString, NSNumber, NSNull or NSDictionary/NSarray of such values are allowed."];
}

+ (NSError *)lazySmartlinkCantHaveURLsError
{
  return [self errorWithCode:17 description:@"Lazy smartlinks cannot have custom URLs for each platform."];
}

+ (NSError *)domainUnknown:(NSString *)domain customDomain:(NSString *)customDomain
{
  if (!customDomain) {
    return [self errorWithCode:18 description:[NSString stringWithFormat:@"To generate a lazy smartlink you need to provide a known domain. %@ is not a hoko.link subdomain.", domain]];
  } else {
    return [self errorWithCode:18 description:[NSString stringWithFormat:@"To generate a lazy smartlink you need to provide a known domain. %@ is not a hoko.link subdomain nor is it your custom domain %@.", domain, customDomain]];
  }
}

+ (NSError *)invalidDomain:(NSString *)domain
{
  return [self errorWithCode:19 description:@"%@ is not a valid domain. It should be something like yourapp.hoko.link or your.customdomain.com"];
}


+ (NSError *)unknownError {
  return [self errorWithCode:0 description:@"Unkown Error"];
}



#pragma mark - Server Errors
+ (NSError *)serverErrorFromJSON:(id)json {
  if([json isKindOfClass:[NSDictionary class]]) {
    if ([json objectForKey:@"warning"]) {
      return [HOKError serverWarning:json];
    } else if ([json objectForKey:@"error"]) {
      return [HOKError serverError:json];
    }
  }
  
  return [HOKError genericServerError];
}

+ (NSError *)serverError:(NSDictionary *)errorJSON {
  return [self serverError:[errorJSON objectForKey:@"error"] code:[errorJSON objectForKey:@"status"]];
}

+ (NSError *)serverError:(NSString *)error code:(NSNumber *)code {
  return [self errorWithDomain:HOKServerErrorDomain code:code.integerValue description:error];
}

+ (NSError *)serverWarning:(NSDictionary *)warningJSON {
  if ([warningJSON objectForKey:@"warning"] && [warningJSON objectForKey:@"status"])
    return [self serverWarning:[warningJSON objectForKey:@"warning"] code:[warningJSON objectForKey:@"status"]];
  
  return nil;
}

+ (NSError *)serverWarning:(NSString *)warning code:(NSNumber *)code {
  return [self errorWithDomain:HOKServerWarningDomain code:code.integerValue description:warning];
}


@end
