//
//  HOKStubbedTest.m
//  Hoko Tests
//
//  Created by Ivan Bruel on 05/03/15.
//
//

#import "HOKStubbedTestCase.h"

#import <Hoko/Hoko.h>
#import <Hoko/HOKApp.h>
#import <Hoko/HOKIframe.h>
#import <Hoko/HOKNetworkOperationQueue+Private.h>

@interface HOKStubbedTestCase ()

@property (nonatomic, strong) id appMock;
@property (nonatomic, strong) id networkOperationQueueMock;
@property (nonatomic, strong) id iframeMock;

@end

@implementation HOKStubbedTestCase

- (void)setUp
{
  [super setUp];
  self.appMock = OCMPartialMock([HOKApp app]);
  [[[self.appMock stub] andReturn:@[@"hoko"]] urlSchemes];
  
  self.networkOperationQueueMock = OCMPartialMock([HOKNetworkOperationQueue sharedQueue]);
  [[[self.networkOperationQueueMock stub] andDo:nil] saveNetworkOperations];
  
  self.iframeMock = OCMClassMock([HOKIframe class]);
  [[[self.iframeMock stub] andDo:nil] requestPageWithURL:[OCMArg any] completion:[OCMArg any]];
  
  [Hoko setVerbose:NO];
  [Hoko setupWithToken:@"1234"];
}

- (void)tearDown
{
  [super tearDown];
  [self.appMock stopMocking];
  [self.networkOperationQueueMock stopMocking];
  [self.iframeMock stopMocking];
  [OHHTTPStubs removeAllStubs];
  [Hoko reset];
}

@end
