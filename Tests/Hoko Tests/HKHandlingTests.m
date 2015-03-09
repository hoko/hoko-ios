//
//  HKHandlingTests.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 08/03/15.
//
//

#import "HKStubbedTestCase.h"

#import <Hoko/HKHandling.h>

@interface HKHandlingTests : HKStubbedTestCase

@end

@interface HKTestHandler : NSObject<HKHandlerProcotol>

@property (nonatomic, strong) HKDeeplink *handledDeeplink;
@property (nonatomic, strong) NSDate *timestamp;

@end

@implementation HKHandlingTests

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
  HKHandling *handling = [[HKHandling alloc] init];
  
  __block HKDeeplink *blockDeeplink = nil;
  
  [handling addHandlerBlock:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [handling handle:[HKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"param"});
}

- (void)testProtocolHandling
{
  HKHandling *handling = [[HKHandling alloc] init];
  
  HKTestHandler *testHandler = [[HKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  [handling handle:[HKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(testHandler.handledDeeplink.route).will.equal(@"product/:product_id");
  expect(testHandler.handledDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(testHandler.handledDeeplink.queryParameters).will.equal(@{@"query": @"param"});
  
}

- (void)testMultipleHandling
{
  HKHandling *handling = [[HKHandling alloc] init];
  
  HKTestHandler *testHandler = [[HKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  __block HKDeeplink *blockDeeplink = nil;
  
  [handling addHandlerBlock:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [handling handle:[HKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockDeeplink.route).will.equal(@"product/:product_id");
  expect(blockDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(blockDeeplink.queryParameters).will.equal(@{@"query": @"param"});
  
  expect(testHandler.handledDeeplink.route).will.equal(@"product/:product_id");
  expect(testHandler.handledDeeplink.routeParameters).will.equal(@{@"product_id": @"1234"});
  expect(testHandler.handledDeeplink.queryParameters).will.equal(@{@"query": @"param"});
}

- (void)testHandlingOrder
{
  HKHandling *handling = [[HKHandling alloc] init];
  
  HKTestHandler *testHandler = [[HKTestHandler alloc] init];
  
  [handling addHandler:testHandler];
  
  __block HKDeeplink *blockDeeplink = nil;
  __block NSDate *blockTimestamp = nil;
  
  [handling addHandlerBlock:^(HKDeeplink *deeplink) {
    blockDeeplink = deeplink;
    blockTimestamp = [NSDate date];
  }];
  
  [handling handle:[HKDeeplink deeplinkWithRoute:@"product/:product_id" routeParameters:@{@"product_id": @"1234"} queryParameters:@{@"query": @"param"}]];
  
  expect(blockTimestamp).will.beGreaterThan(testHandler.timestamp);
}

@end

@implementation HKTestHandler

- (void)handleDeeplink:(HKDeeplink *)deeplink
{
  self.handledDeeplink = deeplink;
  self.timestamp = [NSDate date];
}

@end
