//
//  HKNetworking.m
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import "HKNetworking.h"

#import "HKGZip.h"
#import "HKError.h"
#import "HKLogger.h"
#import "Hoko+Private.h"
#import "HKNetworkOperation.h"

double const HKNetworkingRequestTimeout = 15.0f;

NSString *const HKNetworkingEndpoint = @"https://api.hokolinks.com";
//NSString *const HKNetworkingEndpoint = @"http://192.168.1.5:3000";
NSString *const HKNetworkingVersion = @"v1";
NSString *const HKNetworkingFormat = @"json";

@interface HKNetworking () <NSURLConnectionDataDelegate>

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, copy) HKNetworkingFailedBlock failedBlock;
@property (nonatomic, copy) HKNetworkingSuccessBlock successBlock;

@end

@implementation HKNetworking

#pragma mark - Class Methods
//
//  GET
//
+ (void)requestToPath:(NSString *)path
           parameters:(NSDictionary *)parameters
                token:(NSString *)token
         successBlock:(HKNetworkingSuccessBlock)successBlock
          failedBlock:(HKNetworkingFailedBlock)failedBlock
{
  HKNetworking *networkingRequest = [[HKNetworking alloc] initWithSuccessBlock:successBlock
                                                                   failedBlock:failedBlock];
  if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [networkingRequest performRequestWithUrl:path token:token parameters:parameters];
    });
  } else {
    [networkingRequest performRequestWithUrl:path token:token parameters:parameters];
  }
}

//
//  POST
//
+ (void)postToPath:(NSString *)path
        parameters:(NSDictionary *)parameters
             token:(NSString *)token
      successBlock:(HKNetworkingSuccessBlock)successBlock
       failedBlock:(HKNetworkingFailedBlock)failedBlock
{
  HKNetworking *networkingRequest = [[HKNetworking alloc] initWithSuccessBlock:successBlock
                                                                   failedBlock:failedBlock];
  if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [networkingRequest performPostWithUrl:path
                                      token:token
                                 parameters:parameters];
    });
  } else {
    [networkingRequest performPostWithUrl:path
                                    token:token
                               parameters:parameters];
  }
}

//
//  PUT
//
+ (void)putToPath:(NSString *)path
       parameters:(NSDictionary *)parameters
            token:(NSString *)token
     successBlock:(HKNetworkingSuccessBlock)successBlock
      failedBlock:(HKNetworkingFailedBlock)failedBlock
{
  HKNetworking *networkingRequest = [[HKNetworking alloc] initWithSuccessBlock:successBlock
                                                                   failedBlock:failedBlock];
  if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [networkingRequest performPutWithUrl:path
                                     token:token
                                parameters:parameters];
    });
  } else {
    [networkingRequest performPutWithUrl:path
                                   token:token
                              parameters:parameters];
  }
}

#pragma mark - Initialization
- (id)initWithSuccessBlock:(HKNetworkingSuccessBlock)successBlock
               failedBlock:(HKNetworkingFailedBlock)failedBlock
{
  self = [super init];
  
  if(self){
    _successBlock = successBlock;
    _failedBlock = failedBlock;
  }
  return self;
}

#pragma mark - Instance Methods
//
//  GET
//
- (void)performRequestWithUrl:(NSString *)url
                        token:(NSString *)token
                   parameters:(NSDictionary *)parameters
{
  NSURL *encodedUrl = [HKNetworking encodeURL:url
                               withParameters:parameters];
  HKLog(@"GET from %@", encodedUrl.absoluteString);
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:encodedUrl
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:HKNetworkingRequestTimeout];
  [request setHTTPMethod:@"GET"];
  
  [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

  if (token) {
    [request setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
    [request setValue:HokoVersion forHTTPHeaderField:@"Hoko-SDK-Version"];
  }
  
  _urlConnection = [[NSURLConnection alloc] initWithRequest:request
                                                   delegate:self];
}

//
//  POST
//
-(void)performPostWithUrl:(NSString *)url
                    token:(NSString *)token
               parameters:(NSDictionary *)parameters
{
  
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  HKLog(@"POST to %@\n%@", url, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
  if(error != nil)
  {
    HKErrorLog([HKError jsonParseError:parameters]);
    jsonData = nil;
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:HKNetworkingRequestTimeout];
  
  [request setHTTPMethod:@"POST"];
  
  [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  if (token) {
    [request setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
    [request setValue:HokoVersion forHTTPHeaderField:@"Hoko-SDK-Version"];
  }
  [request setHTTPBody:jsonData];
  
  _urlConnection = [[NSURLConnection alloc] initWithRequest:request
                                                   delegate:self];
}

//
//  PUT
//
-(void)performPutWithUrl:(NSString *)url token:(NSString *)token parameters:(NSDictionary *)parameters
{
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
  HKLog(@"Putting %@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
  if(error != nil)
  {
    HKErrorLog([HKError jsonParseError:parameters]);
    jsonData = nil;
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:HKNetworkingRequestTimeout];
  
  HKLog(@"PUT to %@\n%@", url, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
  
  [request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

  
  if (token) {
    [request setValue:[NSString stringWithFormat:@"Token %@",token] forHTTPHeaderField:@"Authorization"];
    [request setValue:HokoVersion forHTTPHeaderField:@"Hoko-SDK-Version"];
  }
  [request setHTTPBody:jsonData];
  
  _urlConnection = [[NSURLConnection alloc] initWithRequest:request
                                                   delegate:self];
}

#pragma mark - NSURLConnectionDelegate
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
  return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    if ([HKNetworkingEndpoint rangeOfString:challenge.protectionSpace.host].location != NSNotFound) {
      [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
           forAuthenticationChallenge:challenge];
    }
  }
  [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
  _statusCode = [httpResponse statusCode];
  _responseData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
  [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
  return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSError *error;
  NSData *data = _responseData;
  if (_responseData.length > 1) {
    data = [HKGZip gunzippedData:_responseData];
  }
  id json = [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableContainers
                                              error:&error];
  HKLog(@"Response for %@\n%@", connection.originalRequest.URL.absoluteString, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
  if(error && _responseData.length > 1)
  {
    if(_failedBlock != nil)
      _failedBlock(error);
    
  }
  else if (_statusCode >= 300) {
    if(_failedBlock != nil)
      _failedBlock(json);
  }
  else
  {
    if(_successBlock != nil)
      _successBlock(json);
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  HKErrorLog([HKError networkingError:error]);
  if(_failedBlock != nil)
    _failedBlock(error);
  
}

#pragma mark - URL Encoded
+ (NSURL *)encodeURL:(NSString *)url withParameters:(NSDictionary *)parameters
{
  NSString *encodedParameters = @"";
  
  if(parameters.count > 0)
    encodedParameters = [encodedParameters stringByAppendingString:@"?"];
  
  for(NSString *key in [parameters allKeys])
  {
    NSString *value = [parameters[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    encodedParameters = [encodedParameters stringByAppendingFormat:@"%@=%@&", key, value];
  }
  
  // Remove the extra '&'
  if(parameters.count > 0)
    encodedParameters = [encodedParameters substringToIndex:encodedParameters.length - 1];
  
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url,encodedParameters]];
}


@end
