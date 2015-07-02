//
//  HOKLinkGeneratorTests.m
//  HokoTests
//
//  Created by Ivan Bruel on 23/07/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HOKStubbedTestCase.h"

#import <Hoko/Hoko+Private.h>

#import <Hoko/HOKApp.h>
#import <Hoko/HOKError.h>
#import <Hoko/HOKLinkGenerator.h>
#import <Hoko/HOKDeeplinking+Private.h>
#import <Hoko/HOKNetworking.h>

@interface HOKLinkGeneratorTests : HOKStubbedTestCase

@end

@implementation HOKLinkGeneratorTests

- (void)setUp
{
  [super setUp];
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [HOKNetworkingEndpoint rangeOfString:request.URL.host].location != NSNotFound && [request.URL.absoluteString hasSuffix:@"routes.json"];
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [HOKNetworkingEndpoint rangeOfString:request.URL.host].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{@"smartlink":@"http://hoko.link/PRMLNK"};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  [[Hoko deeplinking] mapRoute:@"store/:language_code/product/:product_id" toTarget:^(HOKDeeplink *deeplink) {}];
  
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testBasicSmartlink
{
  __block NSString *blockSmartlink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HOKDeeplink deeplinkWithRoute:@"store/:language_code/product/:product_id" routeParameters:@{@"language_code":@"en-US",@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
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
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HOKDeeplink deeplinkWithRoute:@"/store/:language_code/product/:product_id" routeParameters:@{@"product_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
    blockSmartlink = smartlink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HOKError nilDeeplinkError]);
  expect(blockSmartlink).will.beNil();
}

- (void)testUnknownRouteSmartlink
{
  __block NSString *blockSmartlink = nil;
  __block NSError *blockError = nil;
  
  [[Hoko deeplinking] generateSmartlinkForDeeplink:[HOKDeeplink deeplinkWithRoute:@"/store/:language_code/collection/:collection_id" routeParameters:@{@"language_code": @"en-US", @"collection_id":@1234} queryParameters:@{@"utm_source":@"test_case",@"timestamp":@1234324}] success:^(NSString *smartlink) {
    blockSmartlink = smartlink;
  } failure:^(NSError *error) {
    blockError = error;
  }];
  
  expect(blockError).will.equal([HOKError routeNotMappedError]);
  expect(blockSmartlink).will.beNil();
}

@end
