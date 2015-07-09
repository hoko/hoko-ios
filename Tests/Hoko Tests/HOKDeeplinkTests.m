//
//  HOKDeeplinkTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 09/07/15.
//
//

#import "HOKStubbedTestCase.h"

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

@end