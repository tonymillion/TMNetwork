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

#import "TMNetwork+synchronous.h"

@implementation TMNetwork (synchronous)

-(NSURLSessionTask*)syncGET:(NSString*)path
                     params:(NSDictionary*)params
                    success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                    failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);

    [self GET:path
       params:params
      success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
          if(success)
          {
              success(httpResponse, responseData, responseObject);
          }

          dispatch_semaphore_signal(sync_block);
      }
      failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
          if(failure)
          {
              failure(httpResponse, responseData, responseObject, error);
          }

          dispatch_semaphore_signal(sync_block);
      }];


    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;
}

-(NSURLSessionTask *)syncPOST:(NSString*)path
                       asJSON:(BOOL)asJSON
                       params:(id)params
                      success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                      failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);

    [self POST:path
        asJSON:asJSON
        params:params
       success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
           if(success)
           {
               success(httpResponse, responseData, responseObject);
           }

           dispatch_semaphore_signal(sync_block);
       }
       failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
           if(failure)
           {
               failure(httpResponse, responseData, responseObject, error);
           }

           dispatch_semaphore_signal(sync_block);
       }];

    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;
}

-(NSURLSessionTask *)syncPUT:(NSString*)path
                      asJSON:(BOOL)asJSON
                      params:(id)params
                     success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                     failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);

    [self PUT:path
       asJSON:asJSON
       params:params
      success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
          if(success)
          {
              success(httpResponse, responseData, responseObject);
          }

          dispatch_semaphore_signal(sync_block);
      }
      failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
          if(failure)
          {
              failure(httpResponse, responseData, responseObject, error);
          }

          dispatch_semaphore_signal(sync_block);
      }];

    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;

}

-(NSURLSessionTask *)syncPATCH:(NSString*)path
                        asJSON:(BOOL)asJSON
                        params:(id)params
                       success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                       failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);

    [self PATCH:path
         asJSON:asJSON
         params:params
        success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
            if(success)
            {
                success(httpResponse, responseData, responseObject);
            }

            dispatch_semaphore_signal(sync_block);
        }
        failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
            if(failure)
            {
                failure(httpResponse, responseData, responseObject, error);
            }

            dispatch_semaphore_signal(sync_block);
        }];

    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;

}

-(NSURLSessionTask*)syncDELETE:(NSString*)path
                       success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                       failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);

    [self DELETE:path
       success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
           if(success)
           {
               success(httpResponse, responseData, responseObject);
           }

           dispatch_semaphore_signal(sync_block);
       }
       failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
           if(failure)
           {
               failure(httpResponse, responseData, responseObject, error);
           }

           dispatch_semaphore_signal(sync_block);
       }];

    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;
}


-(NSURLSessionTask *)syncMultipartPOST:(NSString*)path
                                params:(id)params
                      bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                               success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                               failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    return [self syncMultipartPOST:path
                            params:params
                   chunkedEncoding:self.useChunkedEncoding
                  bodyConstruction:bodyConstruction
                           success:success
                           failure:failure];
}

-(NSURLSessionTask *)syncMultipartPOST:(NSString*)path
                                params:(id)params
                       chunkedEncoding:(BOOL)chunked
                      bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                               success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                               failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);


    [self multipartPOST:path
                 params:params
        chunkedEncoding:chunked
       bodyConstruction:bodyConstruction
                success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
                    if(success)
                    {
                        success(httpResponse, responseData, responseObject);
                    }

                    dispatch_semaphore_signal(sync_block);
                }
                failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
                    if(failure)
                    {
                        failure(httpResponse, responseData, responseObject, error);
                    }

                    dispatch_semaphore_signal(sync_block);
                }];

    dispatch_semaphore_wait(sync_block, DISPATCH_TIME_FOREVER);

    return nil;

}


@end
