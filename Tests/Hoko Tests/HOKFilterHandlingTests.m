//
//  HOKFilterHandlingTests.m
//  Hoko Tests
//
//  Created by Pedro Vieira on 05/08/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKDeeplinking+Private.h>
#import <Hoko/HOKRouting.h>

@interface HOKFilterHandlingTests : HOKStubbedTestCase

@end

@implementation HOKFilterHandlingTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testSingleTruthFilterHandling {
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return YES;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  
  expect(blockDeeplink).notTo.beNil();
  expect(HokoDeeplinking.currentDeeplink).toNot.beNil();
  expect(HokoDeeplinking.currentDeeplink.wasOpened).to.beTruthy();
  expect(HokoDeeplinking.currentDeeplink.isDeferred).to.beFalsy();
}

- (void)testSingleFalseFilterHandling {
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return NO;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  
  expect(blockDeeplink).to.beNil();
  expect(HokoDeeplinking.currentDeeplink).toNot.beNil();
  expect(HokoDeeplinking.currentDeeplink.wasOpened).to.beFalsy();
  expect(HokoDeeplinking.currentDeeplink.isDeferred).to.beFalsy();
}

- (void)testMultipleTruthFilterHandling {
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    if ([deeplink.route isEqualToString:@"product/:product_id"])
      return YES;
    else
      return NO;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return YES;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return YES;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  
  expect(blockDeeplink).notTo.beNil();
  expect(HokoDeeplinking.currentDeeplink).toNot.beNil();
  expect(HokoDeeplinking.currentDeeplink.wasOpened).to.beTruthy();
  expect(HokoDeeplinking.currentDeeplink.isDeferred).to.beFalsy();
}

- (void)testMultipleFalseFilterHandling {
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return NO;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    if ([deeplink.route isEqualToString:@"product/:product_id"])
      return NO;
    else
      return YES;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink *deeplink) {
    return NO;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  
  expect(blockDeeplink).to.beNil();
  expect(HokoDeeplinking.currentDeeplink).toNot.beNil();
  expect(HokoDeeplinking.currentDeeplink.wasOpened).to.beFalsy();
  expect(HokoDeeplinking.currentDeeplink.isDeferred).to.beFalsy();
}

- (void)testMultipleFilterHandling {
  __block HOKDeeplink *blockDeeplink = nil;
  [HokoDeeplinking mapRoute:@"product/:product_id" toTarget:^(HOKDeeplink *deeplink) {
    blockDeeplink = deeplink;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink * deeplink) {
    return NO;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink * deeplink) {
    return YES;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink * deeplink) {
    return NO;
  }];
  
  [HokoDeeplinking addFilterBlock:^BOOL (HOKDeeplink * deeplink) {
    return YES;
  }];
  
  [HokoDeeplinking.routing openURL:[NSURL URLWithString:@"hoko://product/2"] sourceApplication:@"com.hoko.black" annotation:nil deferredDeeplink:NO];
  
  expect(blockDeeplink).to.beNil();
  expect(HokoDeeplinking.currentDeeplink).toNot.beNil();
  expect(HokoDeeplinking.currentDeeplink.wasOpened).to.beFalsy();
  expect(HokoDeeplinking.currentDeeplink.isDeferred).to.beFalsy();
}

@end
