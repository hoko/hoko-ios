//
//  HOKHandlingTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 08/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKHandling.h>

@interface HOKHandlingTests : HOKStubbedTestCase

@end

@interface HOKTestHandler : NSObject<HOKHandlerProtocol>

@property (nonatomic, strong) HOKDeeplink *handledDeeplink;
@property (nonatomic, strong) NSDate *timestamp;

@end

@implementation HOKHandlingTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBlockHandling
{
  HOKHandling *handling = [[HOKHandling alloc] init];
  
  __block HOKDeeplink *blockDeeplink = nil;
  
  [handling addHandlerBlock:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [handling handle:[HOKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"param"});
}

- (void)testProtocolHandling
{
  HOKHandling *handling = [[HOKHandling alloc] init];
  
  HOKTestHandler *testHandler = [[HOKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  [handling handle:[HOKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(testHandler.handledDeeplink.route).will.equal(@"product/:product_id");
  expect(testHandler.handledDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(testHandler.handledDeeplink.queryParameters).will.equal(@{@"query": @"param"});
  
}

- (void)testMultipleHandling
{
  HOKHandling *handling = [[HOKHandling alloc] init];
  
  HOKTestHandler *testHandler = [[HOKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  __block HOKDeeplink *blockDeeplink = nil;
  
  [handling addHandlerBlock:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [handling handle:[HOKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"param"});
  
  expect(testHandler.handledDeeplink.route).will.equal(@"product/:product_id");
  expect(testHandler.handledDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(testHandler.handledDeeplink.queryParameters).will.equal(@{@"query": @"param"});
}

- (void)testHandlingOrder
{
  HOKHandling *handling = [[HOKHandling alloc] init];
  
  HOKTestHandler *testHandler = [[HOKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  __block HOKDeeplink *blockDeeplink = nil;
  __block NSDate *blockTimestamp = nil;
  
  [handling addHandlerBlock:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
    blockTimestamp = [NSDate date];
  }];
  
  [handling handle:[HOKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockTimestamp).will.beGreaterThan(testHandler.timestamp);
}

@end

@implementation HOKTestHandler

- (void)handleDeeplink:(HOKDeeplink *)deeplink
{
  self.handledDeeplink = deeplink;
  self.timestamp = [NSDate date];
}

@end
