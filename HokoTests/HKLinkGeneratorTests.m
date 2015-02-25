//
//  HokoTests.m
//  HokoTests
//
//  Created by Ivan Bruel on 23/07/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "Hoko+Private.h"

#import "HKApp.h"
#import "HKError.h"
#import "HKLinkGenerator.h"
#import "HokoDeeplinking+Private.h"

@interface HKLinkGeneratorTests : XCTestCase

@end

@implementation HKLinkGeneratorTests

- (void)setUp
{
  [super setUp];
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:@"api.hokolinks.com"] && [request.URL.absoluteString hasSuffix:@"routes.json"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  id hkApp = OCMClassMock([HKApp class]);
  [[[hkApp stub] andReturn:@[@"hoko"]] urlSchemes];
  [Hoko setupWithToken:@"1234"];
  [[Hoko deeplinking] mapRoute:@"store/:language_code/product/:product_id" toTarget:nil];
  
}

- (void)tearDown
{
  [super tearDown];
  [Hoko reset];
  [OHHTTPStubs removeLastStub];
}

- (void)testBasicHokolink
{
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"generate hokolink"];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:@"api.hokolinks.com"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    //TODO change to hokolink
    NSDictionary *json = @{@"omnilink":@"http://hoko.com/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"store/:language_code/product/:product_id" routeParameters:@{@"language_code":@"en-US",@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *omnilink) {
    XCTAssertEqualObjects(@"http://hoko.com/PRMLNK", omnilink);
    [expectation fulfill];
  } failure:^(NSError *error) {
    XCTFail(@"returned an error %@",error.description);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testMissingRouteParameterHokolink
{
  
  XCTestExpectation *expectation = [self expectationWithDescription:@"cant create deeplink"];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:@"api.hokolinks.com"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{@"omnilink":@"http://hoko.com/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/product/:product_id" routeParameters:@{@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *hokolink) {
    XCTFail(@"Should not even call service");
    [expectation fulfill];
  } failure:^(NSError *error) {
    XCTAssertEqualObjects(error, [HKError nilDeeplinkError]);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testUnknownRouteOmnilink
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"unknown route"];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:@"api.hokolinks.com"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    //TODO change to hokolink
    NSDictionary *json = @{@"omnilink":@"http://hoko.com/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/collection/:collection_id" routeParameters:@{@"language_code": @"en-US", @"collection_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *hokolink) {
    XCTFail(@"Should not even call service");
    [expectation fulfill];
  } failure:^(NSError *error) {
    XCTAssertEqualObjects(error, [HKError routeNotMappedError]);
    [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:3 handler:nil];
}

@end
