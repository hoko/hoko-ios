//
//  HOKDeeplinkTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 09/07/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKError.h>
#import <Hoko/HOKDeeplinking+Private.h>
#import <Hoko/HOKRouting.h>

@interface HOKDeeplinkTests : HOKStubbedTestCase

@end

@implementation HOKDeeplinkTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testMetadataValidation
{
  NSDictionary *metadata = @{@"string": @"a string", @"number": @42, @"null": [NSNull null], @"dictionary": @{@"string": @"another string"}, @"array": @[@"hi", @2, [NSNull null]]};
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"something" routeParameters:nil queryParameters:@{@"queryParam" : @2} metadata:metadata];
  expect(deeplink.metadata).to.equal(metadata);
}

- (void)testInvalidMetadata
{
  NSDictionary *metadata = @{@"string": @"a string", @"number": @42, @"null": [NSNull null], @"dictionary": @{@"string": @"another string"}, @"array": @[@"hi", @2, [NSNull null]], @"date": [NSDate date]};
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"something" routeParameters:nil queryParameters:@{@"queryParam" : @2} metadata:metadata];
  expect(deeplink.metadata).to.beNil();
}

- (void)testNilMetadata
{
  id errorMock = OCMClassMock([HOKError class]);
  [[[errorMock stub] andThrow:[NSException exceptionWithName:@"ShouldNotBeCalled" reason:@"Should not be called" userInfo:nil]] invalidJSONMetadata];
  
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"something" routeParameters:nil queryParameters:@{@"queryParam" : @2} metadata:nil];
  expect(deeplink.metadata).to.beNil();
  [errorMock stopMocking];
}

- (void)testManualOpenDeeplink {
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"products/:id" routeParameters:@{@"id": @(2)}];
  
  __block BOOL deeplinkWasSuccessfullyOpened = NO;
  [HokoDeeplinking mapRoute:@"products/:id" toTarget:^(HOKDeeplink *deeplink) {
    deeplinkWasSuccessfullyOpened = YES;
  }];
  
  [HokoDeeplinking openDeeplink:deeplink];
  expect(deeplinkWasSuccessfullyOpened).to.beTruthy();
  expect(deeplink.wasOpened).to.beTruthy();
  expect([HokoDeeplinking currentDeeplink]).equal(deeplink);
}

- (void)testOpenDeferredDeeplink {
  __block BOOL deeplinkWasSuccessfullyOpened = NO;
  [HokoDeeplinking mapRoute:@"products/:id" toTarget:^(HOKDeeplink *deeplink) {
    deeplinkWasSuccessfullyOpened = YES;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://products/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:YES];
  
  expect(deeplinkWasSuccessfullyOpened).to.beTruthy();
  expect([HokoDeeplinking currentDeeplink].isDeferred).to.beTruthy();
}



@end