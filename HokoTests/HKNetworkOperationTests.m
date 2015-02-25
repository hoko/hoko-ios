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

#import "HKApp.h"
#import "HKUser.h"
#import "HKUtils.h"
#import "HKObserver.h"
#import "Hoko+Private.h"
#import "HKNetworkOperationQueue.h"
#import "HKNetworkOperationQueue+Private.h"

@interface HKNetworkOperationTests : XCTestCase

@end

@implementation HKNetworkOperationTests


- (void)setUp
{
  [super setUp];
  [HKUtils saveObject:nil toFile:@"networkOperations"];
  id hkApp = OCMClassMock([HKApp class]);
  [[[hkApp stub] andReturn:@[@"hoko"]] urlSchemes];
  [Hoko setupWithToken:@"1234"];
}

- (void)tearDown
{
  [super tearDown];
  [OHHTTPStubs removeAllStubs];
  [Hoko reset];
  
}

- (void)testQueueFlushing
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Operations completed with success"];
  
  // Stubbing for success
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return YES;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:200 headers:nil];
  }];
  
  HKUser *user = [[HKUser alloc] initWithIdentifier:@"testuser" accountType:HKUserAccountTypeGithub name:nil email:nil birthDate:nil gender:HKUserGenderUnknown previousIdentifier:nil];
  
  [[HKNetworkOperationQueue sharedQueue] addOperation:[[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST path:@"user" token:@"1234" parameters:user.json]];
  [[HKNetworkOperationQueue sharedQueue] addOperation:[[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST path:@"user" token:@"1234" parameters:user.json]];
  
  // Force flush for timer wait time
  [[HKNetworkOperationQueue sharedQueue] flush];
  
  // Add a block after adding all the operations to detect the inner operation array
  [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:^{
    if ([HKNetworkOperationQueue sharedQueue].networkOperations.count != 0) {
      XCTAssert(0, @"Queue should be empty after successful execution");
    }
   [expectation fulfill];
  }];
  
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testQueueRetrying
{
  XCTestExpectation *expectation = [self expectationWithDescription:@"Operations discarded after 10 retries"];
  
  // Stub for failure
  [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
    return YES;
  } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
    NSDictionary *json = @{};
    return [OHHTTPStubsResponse responseWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] statusCode:500 headers:nil];
  }];
  
  HKUser *user = [[HKUser alloc] initWithIdentifier:@"testuser" accountType:HKUserAccountTypeGithub name:nil email:nil birthDate:nil gender:HKUserGenderUnknown previousIdentifier:nil];
  HKNetworkOperation *networkOperation = [[HKNetworkOperation alloc] initWithOperationType:HKNetworkOperationTypePOST path:@"user" token:@"1234" parameters:user.json];
  [[HKNetworkOperationQueue sharedQueue] addOperation:networkOperation];
  [[HKNetworkOperationQueue sharedQueue] flush];
  
  // Check inner operation array after the end of each flush, give up on 10th try
  __block NSInteger tries = 1;
  __block void (^wRetryBlock)();
  void (^retryBlock)();
  wRetryBlock = retryBlock = ^{
    if ([HKNetworkOperationQueue sharedQueue].networkOperations.count != 0) {
      tries ++;
      [[HKNetworkOperationQueue sharedQueue] flush];
      [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:wRetryBlock];
    }
    else if (tries == HKNetworkOperationQueueMaxRetries) {
      [expectation fulfill];
    } else {
      XCTAssert(0,"Queue should not be empty before retry #%@",@(HKNetworkOperationQueueMaxRetries));
      [expectation fulfill];
    }
  };
  
  [[HKNetworkOperationQueue sharedQueue].operationQueue addOperationWithBlock:retryBlock];
  
  [self waitForExpectationsWithTimeout:30 handler:nil];
  
}

@end
