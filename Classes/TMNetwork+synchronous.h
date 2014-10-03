//
//  TMNetwork+synchronous.h
//  Journal
//
//  Created by Tony Million on 24/09/2014.
//  Copyright (c) 2014 Narrato. All rights reserved.
//

#import "TMNetwork.h"

@interface TMNetwork (synchronous)

-(NSURLSessionTask*)syncGET:(NSString*)path
                 params:(NSDictionary*)params
                success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)syncPOST:(NSString*)path
                   asJSON:(BOOL)asJSON
                   params:(id)params
                  success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                  failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)syncPUT:(NSString*)path
                  asJSON:(BOOL)asJSON
                  params:(id)params
                 success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                 failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)syncPATCH:(NSString*)path
                    asJSON:(BOOL)asJSON
                    params:(id)params
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask*)syncDELETE:(NSString*)path
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)syncMultipartPOST:(NSString*)path
                            asJSON:(BOOL)asJSON
                            params:(id)params
                   chunkedEncoding:(BOOL)chunked
                  bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                           success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                           failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;


@end
