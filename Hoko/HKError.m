//
//  HKError.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKError.h"

NSString *const HKErrorDomain = @"Hoko";
NSString *const HKServerErrorDomain = @"HokoServerError";
NSString *const HKServerWarningDomain = @"HokoServerWarning";

@implementation HKError

#pragma mark - Initializers
+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description{
  return [self errorWithDomain:HKErrorDomain code:code description:description];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description{
  return [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey: description?description:@"No Description"}];
}

#pragma mark - Public Errors
+ (NSError *)setupNotCalledYetError
{
  return [self errorWithCode:1 description:@"Cannot access modules without calling [Hoko setup] or [Hoko setupWithToken:] beforehand."];
}

+ (NSError *)setupCalledMoreThanOnceError
{
  return [self errorWithCode:2 description:@"Cannot call the [Hoko setup] or [Hoko setupWithToken:] methods more than once on the application's lifecycle."];
}

+ (NSError *)noURLSchemesError
{
  return [self errorWithCode:3 description:@"No URL Schemes have been detected on your application. To make it deeplinkable you need to set a URL Scheme beforehand. Please follow our guide in http://hokolinks.com/sdk/ios"];
}

+ (NSError *)duplicateRouteError:(NSString *)route
{
  return [self errorWithCode:4 description:[NSString stringWithFormat:@"The route %@ will be ignored as it was already mapped before.",route]];
}

+ (NSError *)notDeeplinkableError:(id)object
{
  return [self errorWithCode:5 description:[NSString stringWithFormat:@"%@ does not conform to the HKDeeplinkable Protocol.",object]];
}

+ (NSError *)noDeeplinkMethodError:(id)object
{
  return [self errorWithCode:6 description:[NSString stringWithFormat:@"%@ does not implement the '- (HKDeeplink *)deeplink' method of the HKDeeplinkable Protocol.",object]];
}

+ (NSError *)noDeeplinkOpenedMethodError:(id)object
{
  return [self errorWithCode:7 description:@"Object does not implement the 'deeplinkOpened:' method of the HKDeeplinkable Protocol."];
}

+ (NSError *)hokolinkGenerationError
{
  return [self errorWithCode:8 description:@"Could not generate Hokolink. Please try again later."];
}

+ (NSError *)genericServerError
{
  return [self errorWithCode:9 description:@"Could not reach the Hoko service. Please try again later."];
}

+ (NSError *)routeNotMappedError
{
  return [self errorWithCode:10 description:@"The route is not mapped. Please map it in the AppDelegate before trying to generate an Hokolink."];
}

+ (NSError *)nilDeeplinkError
{
  return [self errorWithCode:11 description:@"Deeplink provided was nil. Be sure the route format and route parameters are correct when creating a HKDeeplink object."];
}

+ (NSError *)couldNotFindAppDelegateError
{
  return [self errorWithCode:12 description:@"Could not find the AppDelegate class. Please delegate the deeplinking methods to the corresponding Hoko modules."];
}

+ (NSError *)jsonParseError:(id)object
{
  return [self errorWithCode:13 description:[NSString stringWithFormat:@"Could not parse %@ into JSON",object]];
}

+ (NSError *)networkingError:(NSError *)error
{
  return [self errorWithCode:14 description:error.description];
}

+ (NSError *)ignoringKeyEventError:(id)event
{
  return [self errorWithCode:15 description:[NSString stringWithFormat:@"Ignoring key event %@ because there is no deeplinking session.", event]];
}

+ (NSError *)handlerAlreadyExistsError
{
  return [self errorWithCode:16 description:@"The handler being added has already been added."];
}

+ (NSError *)unknownError
{
  return [self errorWithCode:0 description:@"Unkown Error"];
}

#pragma mark - Server Errors
+ (NSError *)serverErrorFromJSON:(id)json
{
  if([json isKindOfClass:[NSDictionary class]]) {
    if (json[@"warning"]) {
      return [HKError serverWarning:json];
    } else if (json[@"error"]) {
      return [HKError serverError:json];
    }
  }
  return [HKError genericServerError];
}

+ (NSError *)serverError:(NSDictionary *)errorJSON
{
  return [self serverError:errorJSON[@"error"] code:errorJSON[@"status"]];
}

+ (NSError *)serverError:(NSString *)error code:(NSNumber *)code
{
  return [self errorWithDomain:HKServerErrorDomain code:code.integerValue description:error];
}

+ (NSError *)serverWarning:(NSDictionary *)warningJSON
{
  if (warningJSON[@"warning"] && warningJSON[@"status"])
    return [self serverWarning:warningJSON[@"warning"] code:warningJSON[@"status"]];
  return nil;
}

+ (NSError *)serverWarning:(NSString *)warning code:(NSNumber *)code
{
  return [self errorWithDomain:HKServerWarningDomain code:code.integerValue description:warning];
}



@end
