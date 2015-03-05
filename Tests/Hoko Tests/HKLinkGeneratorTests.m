//
//  HokoTests.m
//  HokoTests
//
//  Created by Ivan Bruel on 23/07/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HKStubbedTestCase.h"

#import <Hoko/Hoko+Private.h>

#import <Hoko/HKApp.h>
#import <Hoko/HKError.h>
#import <Hoko/HKLinkGenerator.h>
#import <Hoko/HKDeeplinking+Private.h>

@interface HKLinkGeneratorTests : HKStubbedTestCase

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
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.host isEqualToString:@"api.hokolinks.com"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    //TODO change to hokolink
    NSDictionary *json = @{@"omnilink":@"http://hoko.link/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] mapRoute:@"store/:language_code/product/:product_id" toTarget:nil];
  
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testBasicHokolink
{
  __block NSString *blockHokolink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"store/:language_code/product/:product_id" routeParameters:@{@"language_code":@"en-US",@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *hokolink) {
    blockHokolink = hokolink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockHokolink).will.equal(@"http://hoko.link/PRMLNK");
  expect(blockError).will.beNil();
}

- (void)testMissingRouteParameterHokolink
{
  __block NSString *blockHokolink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/product/:product_id" routeParameters:@{@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *hokolink) {
    blockHokolink = hokolink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HKError nilDeeplinkError]);
  expect(blockHokolink).will.beNil();
}

- (void)testUnknownRouteOmnilink
{
  __block NSString *blockHokolink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateHokolinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/collection/:collection_id" routeParameters:@{@"language_code": @"en-US", @"collection_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *hokolink) {
    blockHokolink = hokolink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HKError routeNotMappedError]);
  expect(blockHokolink).will.beNil();
}

@end
