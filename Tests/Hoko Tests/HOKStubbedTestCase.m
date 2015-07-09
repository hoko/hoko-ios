//
//  HOKStubbedTest.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 05/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/HOKApp.h>
#import <Hoko/HOKNetworkOperationQueue+Private.h>

@interface HOKStubbedTestCase ()

@property (nonatomic, strong) id appMock;
@property (nonatomic, strong) id networkOperationQueueMock;

@end

@implementation HOKStubbedTestCase

- (void)setUp
{
  [super setUp];
  self.appMock = OCMPartialMock([HOKApp app]);
  [[[self.appMock stub] andReturn:@[@"hoko"]] urlSchemes];
  
  self.networkOperationQueueMock = OCMPartialMock([HOKNetworkOperationQueue sharedQueue]);
  [[[self.networkOperationQueueMock stub] andDo:nil] saveNetworkOperations];
  
  [Hoko setVerbose:NO];
  [Hoko setupWithToken:@"1234"];
}

- (void)tearDown
{
  [super tearDown];
  [self.appMock stopMocking];
  [self.networkOperationQueueMock stopMocking];
  [OHHTTPStubs removeAllStubs];
  [Hoko reset];
}

@end
