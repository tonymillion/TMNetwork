/*
 Copyright (c) 2011-2014, Tony Million.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

#import "TMNetwork.h"
#import "TMNetworkActivityIndicatorManager.h"
#import "NSDictionary+URLParameterEncoding.h"


@interface TMNetwork () <NSURLSessionDelegate>

@property(strong) NSURLSession  *session;
@property(strong) NSOperationQueue *delegateQueue;

@property(strong, nonatomic) NSMutableDictionary    *headers;

@property(strong) NSMutableDictionary   *hookDict;
@property(strong) NSMutableDictionary   *successWatchers;

@property(strong) NSMutableDictionary   *uploadTaskMap;

@end



@implementation TMNetwork

+(BOOL)hasAcceptableStatusCodeForStatus:(NSInteger)status
{
    return [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)] containsIndex:status];
}

+(NSSet *)acceptableJSONContentTypes
{
    return [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
}

+(NSSet *)acceptableImageContentTypes
{
    return [NSSet setWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];
}

+(NSSet *)acceptableTextContentTypes
{
    return [NSSet setWithObjects:@"text/plain", @"text/html", nil];
}


#pragma mark - Singleton MADNESS!

+(TMNetwork*)sharedInstance
{
    static TMNetwork * sharedNetwork = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetwork = [[TMNetwork alloc] init];
    });

    return sharedNetwork;
}

#pragma mark -

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

        NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

        NSString * agent = [NSString stringWithFormat:@"%@/%@ (%@)",
                            [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey],
                            version,
                            build];

        [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json",
                                                  @"Accept-Encoding": @"gzip",
                                                  @"User-Agent": agent}];

        sessionConfig.timeoutIntervalForRequest = 10.0;
        sessionConfig.timeoutIntervalForResource = 30.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 10;


        self.delegateQueue = [[NSOperationQueue alloc] init];

        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:self.delegateQueue];

        self.headers = [NSMutableDictionary dictionaryWithCapacity:2];

        self.hookDict           = [NSMutableDictionary dictionaryWithCapacity:2];
        self.successWatchers    = [NSMutableDictionary dictionaryWithCapacity:2];
        self.uploadTaskMap      = [NSMutableDictionary dictionaryWithCapacity:2];
    }

    return self;
}

-(instancetype)initWithBaseURL:(NSURL*)baseURL
{
    self = [self init];
    if(self)
    {
        self.baseURL = baseURL;
    }
    return self;
}


#pragma mark - HTTP Header management

-(NSString *)valueForHeader:(NSString *)header
{
    return [self.headers valueForKey:header];
}

-(void)removeHeader:(NSString *)header
{
    [self.headers removeObjectForKey:header];
}

-(void)setValue:(NSString *)value forHeader:(NSString *)header
{
    if(value == nil)
    {
        [self removeHeader:header];
    }
    else
    {
        [self.headers setValue:value
                        forKey:header];
    }
}


#pragma mark - auth headers

-(void)setBasicAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password
{
    // create an auth string, base64 encode it then pass it in the auth header (really???)
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", username, password];
    NSString *base64String = [[basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];


    [self setValue:[NSString stringWithFormat:@"Basic %@", base64String]
         forHeader:@"Authorization"];
}

-(void)setBearerAuthorizationHeaderWithToken:(NSString *)token
{
    if(token == nil)
    {
        [self clearAuthorizationHeader];
        return;
    }

    [self setValue:[NSString stringWithFormat:@"Bearer %@", token]
         forHeader:@"Authorization"];
}

-(void)setAuthorizationHeaderWithType:(NSString*)type  token:(NSString *)token
{
    if(token == nil || type==nil)
    {
        [self clearAuthorizationHeader];
        return;
    }

    [self setValue:[NSString stringWithFormat:@"%@ %@", type, token]
         forHeader:@"Authorization"];
}

-(void)clearAuthorizationHeader
{
    [_headers removeObjectForKey:@"Authorization"];
}

#pragma mark - HTTP Methods

-(NSURLSessionTask *)multipartPOST:(NSString*)path
                            asJSON:(BOOL)asJSON
                            params:(id)params
                   chunkedEncoding:(BOOL)chunked
                  bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                           success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                           failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{

    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:_headers];

    TMMultipartInputStream * mpInput = [[TMMultipartInputStream alloc] init];

    if(params)
    {
        if(!asJSON)
        {
            [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [mpInput addParameter:key value:obj];
            }];
        }
        else
        {
            //TODO: JSON encoding?
        }
    }

    bodyConstruction((id<TMNetworkBodyMaker>)mpInput);

    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", mpInput.boundary]
   forHTTPHeaderField:@"Content-Type"];


    // finally send the request
    NSURLSessionUploadTask * uploadTask = nil;

    if(chunked)
    {
        // create the upload task
        uploadTask = [self.session uploadTaskWithStreamedRequest:request];
        // add the stream to the map of task<->stream so the delegate can pick it up
        self.uploadTaskMap[uploadTask] = [@{
                                            @"bodyStream": mpInput,
                                            @"successBlock": success,
                                            @"failBlock": failure
                                            } mutableCopy];
    }
    else
    {
        // if we DONT want chunked encoding then we have to spit all this stuff out into a file
        // and ask NSURLSession to upload that
        // This will correctly send a Content-Length header
        NSString * filename = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
        NSOutputStream * output = [NSOutputStream outputStreamToFileAtPath:filename
                                                                    append:NO];

        [output open];

        //[output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:nil];

        while ([mpInput hasBytesAvailable]) {
            uint8_t buffer[4096];
            NSUInteger len = [mpInput read:buffer maxLength:4096];
            [output write:buffer maxLength:len];
        }

        uploadTask = [self.session uploadTaskWithRequest:request
                                                fromFile:[NSURL fileURLWithPath:filename]
                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                           [self dealWithResponseStuff:data
                                                              response:response
                                                                 error:error
                                                               success:success
                                                               failure:failure];

                                           [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                       } ];
        [output close];
    }
    [uploadTask resume];


    return uploadTask;
}

-(NSURLSessionTask *)POST:(NSString*)path
                   asJSON:(BOOL)asJSON
                   params:(id)params
                  success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                  failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:_headers];

    // set up the post body data pls!

    NSData * body = [self encodePOSTParameters:params
                                        asJSON:asJSON
                                    forRequest:request];
    if(!body)
    {
        //TODO: error should be a custom error?
        failure(nil, nil, nil, nil);
        return nil;
    }

    NSURLSessionTask * task = [self.session uploadTaskWithRequest:request
                                                         fromData:body
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [self dealWithResponseStuff:data
                                                                       response:response
                                                                          error:error
                                                                        success:success
                                                                        failure:failure];

                                                    [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                }];

    [task resume];
    return task;
}

-(NSURLSessionTask *)PUT:(NSString*)path
                  asJSON:(BOOL)asJSON
                  params:(id)params
                 success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                 failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:_headers];

    // set up the post body data pls!
    NSData * body = [self encodePOSTParameters:params
                                        asJSON:asJSON
                                    forRequest:request];
    if(!body)
    {
        //TODO: error should be a custom error?
        failure(nil, nil, nil, nil);
        return nil;
    }

    NSURLSessionTask * task = [self.session uploadTaskWithRequest:request
                                                         fromData:body
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [self dealWithResponseStuff:data
                                                                       response:response
                                                                          error:error
                                                                        success:success
                                                                        failure:failure];

                                                    [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                }];

    [task resume];
    return task;
}


-(NSURLSessionTask *)PATCH:(NSString*)path
                    asJSON:(BOOL)asJSON
                    params:(id)params
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setAllHTTPHeaderFields:_headers];

    // set up the post body data pls!
    NSData * body = [self encodePOSTParameters:params
                                        asJSON:asJSON
                                    forRequest:request];
    if(!body)
    {
        //TODO: error should be a custom error?
        failure(nil, nil, nil, nil);
        return nil;
    }

    NSURLSessionTask * task = [self.session uploadTaskWithRequest:request
                                                         fromData:body
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [self dealWithResponseStuff:data
                                                                       response:response
                                                                          error:error
                                                                        success:success
                                                                        failure:failure];

                                                    [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                }];

    [task resume];
    return task;
}


-(NSURLSessionTask *)GET:(NSString*)path
                  params:(NSDictionary*)params
                 success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                 failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure

{
    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    if (params)
    {
        NSString * encodedparams = [params URLParameters];

        //TODO: replace this with if(url.query.length) append else set;
        BOOL append = NO;
        if (url.query &&url.query.length) {
            append = YES;
        }
        url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat: !append ? @"?%@" : @"&%@", encodedparams]];
    }


    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:_headers];

    NSURLSessionTask * task = [self.session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  [self dealWithResponseStuff:data
                                                                     response:response
                                                                        error:error
                                                                      success:success
                                                                      failure:failure];

                                                  [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                              }];

    [task resume];

    return task;
}


-(NSURLSessionTask*)DELETE:(NSString*)path
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    [[TMNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    NSURL *url = [NSURL URLWithString:path
                        relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    [request setHTTPMethod:@"DELETE"];
    [request setAllHTTPHeaderFields:_headers];

    NSURLSessionTask * task = [self.session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  [self dealWithResponseStuff:data
                                                                     response:response
                                                                        error:error
                                                                      success:success
                                                                      failure:failure];

                                                  [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                              }];
    [task resume];

    return task;
}


#pragma mark - response dealing

-(void)determineSuccessAndSend:(id)object
                          data:(NSData*)data
                         error:(NSError*)error
                   httpRequest:(NSURLRequest*)request
                  httpResponse:(NSHTTPURLResponse*)response
                       success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                       failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    // if an error was passed in then something went amiss
    if(object && (error == nil))
    {
        // if we get here we got a response, but we still might fail if status != 200,299

        if( [TMNetwork hasAcceptableStatusCodeForStatus:response.statusCode])
        {
            success(response, data, object);
        }
        else
        {
            // yep it was a 300-600 status code!
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:[request URL]
                        forKey:NSURLErrorFailingURLErrorKey];

            [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"HTTP Status: %d", @""), response.statusCode]
                        forKey:NSLocalizedDescriptionKey];

            failure(response, data, object, [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                                       code:NSURLErrorBadServerResponse
                                                                   userInfo:userInfo]);
        }

        // add a block to iterate the success handlers and call them
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            // call the watchers on a background thread so they dont intefere with the operation of the app
            for (id thing in self.successWatchers) {
                void (^successHandler)(NSHTTPURLResponse *httpResponse);
                successHandler = self.successWatchers[thing];
                if(successHandler)
                {
                    successHandler(response);
                }
            }
        });

    }
    else
    {
        // ITS A BIG FAIL
        failure(response, data, object, error);
    }
}

-(void)dealWithResponseStuff:(NSData*)data
                    response:(NSURLResponse *)response
                       error:(NSError *)error
                     success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                     failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{

    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;


    NSString *_contentType;
    _contentType = [httpResponse MIMEType];
    if(!_contentType)
    {
        _contentType = @"application/octet-stream";
    }

    BOOL (^handler)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error);
    handler = self.hookDict[@(httpResponse.statusCode)];
    if(handler)
    {
        if(handler(httpResponse, data, nil, error))
        {
            return;
        }
    }


    if(error)
    {
        [self determineSuccessAndSend:nil
                                 data:data
                                error:error
                          httpRequest:nil
                         httpResponse:httpResponse
                              success:success
                              failure:failure];
    }
    else
    {
        if([[TMNetwork acceptableJSONContentTypes] containsObject:_contentType])
        {
            // this was JSON
            NSError * err = nil;
            id jsonObject = nil;

            if (data) {
                jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&err];
            }
            [self determineSuccessAndSend:jsonObject
                                     data:data
                                    error:err
                              httpRequest:nil
                             httpResponse:httpResponse
                                  success:success
                                  failure:failure];
        }
        else if([[TMNetwork acceptableTextContentTypes] containsObject:_contentType])
        {
            // this was either text or something else!
            [self determineSuccessAndSend:[[NSString alloc] initWithData:data
                                                                encoding:NSUTF8StringEncoding]
                                     data:data
                                    error:nil
                              httpRequest:nil
                             httpResponse:httpResponse
                                  success:success
                                  failure:failure];
        }
        else if([[TMNetwork acceptableImageContentTypes] containsObject:_contentType])
        {
            // this was AN IMAGE
            //note we DO NOT DECODE THE IMAGE HERE - thats a client-side thing

            [self determineSuccessAndSend:data
                                     data:data
                                    error:nil
                              httpRequest:nil
                             httpResponse:httpResponse
                                  success:success
                                  failure:failure];
        }
        else
        {
            // this is BINARY DATA
            [self determineSuccessAndSend:data
                                     data:data
                                    error:nil
                              httpRequest:nil
                             httpResponse:httpResponse
                                  success:success
                                  failure:failure];
        }
    }
}

#pragma mark - URLSession delegate stuff

#pragma mark - URLSession delegate stuff
/*
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    //NSString *host = challenge.protectionSpace.host;

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if(self.trustInvalidSSL)
        {
            completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
            return;
        }
    }

    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}
*/

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler
{
    TMMultipartInputStream * stream = self.uploadTaskMap[task][@"bodyStream"];

    // we return the stream that maps to the task
    completionHandler(stream);
}


- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    [self dealWithResponseStuff:self.uploadTaskMap[task][@"body"]
                       response:task.response
                          error:error
                        success:self.uploadTaskMap[task][@"successBlock"]
                        failure:self.uploadTaskMap[task][@"failBlock"]];

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    self.uploadTaskMap[dataTask][@"body"] = data;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
}


#pragma mark - status code & success hook

-(void)setHook:(BOOL (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))hook
 forStatusCode:(NSInteger)code
{
    if (hook)
    {
        self.hookDict[@(code)] = [hook copy];
    }
    else
    {
        [self.hookDict removeObjectForKey:@(code)];
    }
}

-(void)addNetworkSuccessWatchBlock:(void(^)(NSHTTPURLResponse *httpResponse))watcherBlock
                         forObject:(id)object
{
    // Allows you to set a block to be called on every "successful" network request
    // We classify success as having gotten *any* response from the server.
    if (watcherBlock)
    {
        self.successWatchers[object] = [watcherBlock copy];
    }
    else
    {
        [self.successWatchers removeObjectForKey:object];
    }
}

#pragma mark - request building helpers

-(NSData*)encodePOSTParameters:(id)parameters
                        asJSON:(BOOL)asJSON
                    forRequest:(NSMutableURLRequest*)request
{
    NSError * error = nil;
    NSData * body = nil;
    if(parameters)
    {
        NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        if (asJSON)
        {
            [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset]
           forHTTPHeaderField:@"Content-Type"];

            body = [NSJSONSerialization dataWithJSONObject:parameters
                                                   options:0
                                                     error:&error];
        }
        else
        {
            [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
           forHTTPHeaderField:@"Content-Type"];

            NSString * encodedparams = [parameters URLParameters];

            body = [encodedparams dataUsingEncoding:NSUTF8StringEncoding];
        }

        if(!body)
        {
            [[TMNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

            return nil;
        }
        [request setHTTPBody:body];
    }
    else
    {
        body = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    }

    return body;
}

@end
