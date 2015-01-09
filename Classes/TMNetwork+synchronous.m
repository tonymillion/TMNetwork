/*
Copyright (c) 2014 Tony Million <tonymillion@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
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
