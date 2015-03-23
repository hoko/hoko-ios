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
#import <Hoko/HKNetworking.h>

@interface HKLinkGeneratorTests : HKStubbedTestCase

@end

@implementation HKLinkGeneratorTests

- (void)setUp
{
  [super setUp];
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [HKNetworkingEndpoint rangeOfString:request.URL.host].location != NSNotFound && [request.URL.absoluteString hasSuffix:@"routes.json"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [HKNetworkingEndpoint rangeOfString:request.URL.host].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{@"smartlink":@"http://hoko.link/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] mapRoute:@"store/:language_code/product/:product_id" toTarget:nil];
  
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testBasicSmartlink
{
  __block NSString *blockSmartlink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"store/:language_code/product/:product_id" routeParameters:@{@"language_code":@"en-US",@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
    blockSmartlink = smartlink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockSmartlink).will.equal(@"http://hoko.link/PRMLNK");
  expect(blockError).will.beNil();
}

- (void)testMissingRouteParameterSmartlink
{
  __block NSString *blockSmartlink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/product/:product_id" routeParameters:@{@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
    blockSmartlink = smartlink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HKError nilDeeplinkError]);
  expect(blockSmartlink).will.beNil();
}

- (void)testUnknownRouteSmartlink
{
  __block NSString *blockSmartlink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HKDeeplink deeplinkWithRoute:@"/store/:language_code/collection/:collection_id" routeParameters:@{@"language_code": @"en-US", @"collection_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
    blockSmartlink = smartlink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HKError routeNotMappedError]);
  expect(blockSmartlink).will.beNil();
}

@end
