//
//  HKNetworkOperationTests.m
//  Hoko
//
//  Created by Ivan Bruel on 03/09/14.
//  Copyright (c) 2015 Hoko S.A. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "HKStubbedTestCase.h"

#import <Hoko/HKSession.h>
#import <Hoko/HKApp.h>
#import <Hoko/HKUtils.h>
#import <Hoko/HKObserver.h>
#import <Hoko/Hoko+Private.h>
#import <Hoko/HKNetworkOperationQueue.h>
#import <Hoko/HKNetworkOperationQueue+Private.h>

@interface HKNetworkOperationTests : HKStubbedTestCase

@end

@implementation HKNetworkOperationTests


- (void)setUp
{
  id utilsMock = OCMClassMock([HKUtils class]);
  OCMStub([utilsMock objectFromFile:@"networkOperations"]).andReturn(nil);

  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testQueueFlushing
{
  __block BOOL lastOperationExecuted = NO;
  
  // Stubbing for success
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.absoluteString rangeOfString:@"session"].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  HKSession *session = [[HKSession alloc] initWithDeeplink:[HKDeeplink deeplinkWithRoute:@"route" routeParameters:nil queryParameters:nil]];
  
  [session postWithToken:@"1234"];
  [session postWithToken:@"1234"];
  
  // Force flush for timer wait time
  [[HKNetworkOperationQueue sharedQueue] flush];
  
  [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:^{
    lastOperationExecuted = YES;
  }];
  
  expect([HKNetworkOperationQueue sharedQueue].networkOperations.count).will.equal(0);
  expect(lastOperationExecuted).will.beTruthy();
}

- (void)testQueueRetrying
{
  __block NSInteger retryCount = 0;
  
  // Stub for failure
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return [request.URL.path rangeOfString:@"session"].location != NSNotFound;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:500 headers:nil];
  }];
  
  HKSession *session = [[HKSession alloc] initWithDeeplink:[HKDeeplink deeplinkWithRoute:@"route" routeParameters:nil queryParameters:nil]];
  
  [session postWithToken:@"1234"];
  [[HKNetworkOperationQueue sharedQueue] flush];
  
  // Check inner operation array after the end of each flush, give up on 10th try
  __block void (^wRetryBlock)();
  void (^retryBlock)();
  wRetryBlock = retryBlock = ^{
    retryCount ++;
    if ([HKNetworkOperationQueue sharedQueue].networkOperations.count != 0) {
      [[HKNetworkOperationQueue sharedQueue] flush];
      [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:wRetryBlock];
    }
  };
  
  [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:retryBlock];
  
  expect(retryCount).will.equal(HKNetworkOperationQueueMaxRetries);
}

@end
