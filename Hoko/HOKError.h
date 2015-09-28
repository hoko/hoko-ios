//
//  HOKError.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOKError : NSError

+ (NSError *)setupCalledMoreThanOnceError;
+ (NSError *)setupNotCalledYetError;
+ (NSError *)noURLSchemesError;
+ (NSError *)duplicateRouteError:(NSString *)route;
+ (NSError *)notDeeplinkableError:(id)object;
+ (NSError *)noDeeplinkMethodError:(id)object;
+ (NSError *)noDeeplinkOpenedMethodError:(id)object;
+ (NSError *)smartlinkGenerationError;
+ (NSError *)genericServerError;
+ (NSError *)routeNotMappedError;
+ (NSError *)nilDeeplinkError;
+ (NSError *)jsonParseError:(id)object;
+ (NSError *)networkingError:(NSError *)error;
+ (NSError *)couldNotFindAppDelegateError;
+ (NSError *)handlerAlreadyExistsError;
+ (NSError *)unknownError;
+ (NSError *)serverErrorFromJSON:(id)json;
+ (NSError *)serverWarning:(NSDictionary *)warningJSON;
+ (NSError *)invalidJSONMetadata;
+ (NSError *)lazySmartlinkCantHaveURLsError;
+ (NSError *)domainUnknown:(NSString *)domain customDomain:(NSString *)customDomain;
+ (NSError *)invalidDomain:(NSString *)domain;

@end
