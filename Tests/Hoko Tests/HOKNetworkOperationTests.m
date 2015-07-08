//
//  HOKNetworkOperationTests.m
//  Hoko
//
//  Created by Ivan Bruel on 03/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKApp.h>
#import <Hoko/HOKUtils.h>
#import <Hoko/HOKObserver.h>
#import <Hoko/Hoko+Private.h>
#import <Hoko/HOKDeeplink+Private.h>
#import <Hoko/HOKNetworkOperationQueue.h>
#import <Hoko/HOKNetworkOperationQueue+Private.h>

@interface HOKNetworkOperationTests : HOKStubbedTestCase

@end

@implementation HOKNetworkOperationTests


- (void)setUp
{
  id utilsMock = OCMClassMock([HOKUtils class]);
  OCMStub([utilsMock objectFromFile:@"networkOperations"]).andReturn(nil);

  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
  [OHHTTPStubs removeAllStubs];
}

- (void)testQueueFlushing
{
  __block BOOL lastOperationExecuted = NO;
  
  // Stubbing for success
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.absoluteString rangeOfString:@"smartlinks"].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"route" routeParameters:nil queryParameters:@{@"_hk_cid" : @"1234"}];
  
  [deeplink postWithToken:@"1234"];
  [deeplink postWithToken:@"1234"];
  
  // Force flush for timer wait time
  [[HOKNetworkOperationQueue sharedQueue] flush];
  
  [[HOKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:^{
    lastOperationExecuted = YES;
  }];
  
  expect(lastOperationExecuted).will.beTruthy();
  expect([HOKNetworkOperationQueue sharedQueue].networkOperations.count).will.equal(0);
}

- (void)testQueueRetrying
{
  __block NSInteger retryCount = 0;
  
  // Stub for failure
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.path rangeOfString:@"smartlinks"].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:500 headers:nil];
  }];
  
  HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"route" routeParameters:nil queryParameters:@{@"_hk_cid" : @"1234"}];
  
  [deeplink postWithToken:@"1234"];
  [[HOKNetworkOperationQueue sharedQueue] flush];
  
  // Check inner operation array after the end of each flush, give up on 10th try
  __block void (^wRetryBlock)();
  void (^retryBlock)();
  wRetryBlock = retryBlock = ^{
    retryCount ++;
    if ([HOKNetworkOperationQueue sharedQueue].networkOperations.count != 0) {
      [[HOKNetworkOperationQueue sharedQueue] flush];
      [[HOKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:wRetryBlock];
    }
  };
  
  [[HOKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:retryBlock];
  
  expect(retryCount).will.equal(HOKNetworkOperationQueueMaxRetries);
}

@end
