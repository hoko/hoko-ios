//
//  HKError.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

@interface HKError : NSError

+ (NSError *)setupCalledMoreThanOnceError;
+ (NSError *)setupNotCalledYetError;
+ (NSError *)noURLSchemesError;
+ (NSError *)duplicateRouteError:(NSString *)route;
+ (NSError *)notDeeplinkableError:(id)object;
+ (NSError *)noDeeplinkMethodError:(id)object;
+ (NSError *)noDeeplinkOpenedMethodError:(id)object;
+ (NSError *)hokolinkGenerationError;
+ (NSError *)genericServerError;
+ (NSError *)routeNotMappedError;
+ (NSError *)nilDeeplinkError;
+ (NSError *)jsonParseError:(id)object;
+ (NSError *)networkingError:(NSError *)error;
+ (NSError *)couldNotFindAppDelegateError;
+ (NSError *)ignoringKeyEventError:(id)event;
+ (NSError *)handlerAlreadyExistsError;
+ (NSError *)unknownError;
+ (NSError *)serverErrorFromJSON:(id)json;
+ (NSError *)serverWarning:(NSDictionary *)warningJSON;


@end
