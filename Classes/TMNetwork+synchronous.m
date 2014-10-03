//
//  TMNetwork+TMNetwork_synchronous.m
//  Journal
//
//  Created by Tony Million on 24/09/2014.
//  Copyright (c) 2014 Narrato. All rights reserved.
//

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
                                asJSON:(BOOL)asJSON
                                params:(id)params
                       chunkedEncoding:(BOOL)chunked
                      bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                               success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                               failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure
{
    dispatch_semaphore_t sync_block = dispatch_semaphore_create(0);


    [self multipartPOST:path
                 asJSON:asJSON
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
