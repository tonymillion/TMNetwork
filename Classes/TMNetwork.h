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

#import <Foundation/Foundation.h>

#import "TMMultipartInputStream.h"

@interface TMNetwork : NSObject

+(instancetype)sharedInstance;

-(instancetype)initWithBaseURL:(NSURL*)baseURL;

-(NSString *)valueForHeader:(NSString *)header;
-(void)setValue:(NSString *)value forHeader:(NSString *)header;
-(void)removeHeader:(NSString *)header;

-(void)setBasicAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password;
-(void)setBearerAuthorizationHeaderWithToken:(NSString *)token;
-(void)setAuthorizationHeaderWithType:(NSString*)type  token:(NSString *)token;
-(void)clearAuthorizationHeader;

-(NSURLSessionTask*)GET:(NSString*)path
                 params:(NSDictionary*)params
                success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)POST:(NSString*)path
                   asJSON:(BOOL)asJSON
                   params:(id)params
                  success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                  failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)PUT:(NSString*)path
                  asJSON:(BOOL)asJSON
                  params:(id)params
                 success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                 failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)PATCH:(NSString*)path
                    asJSON:(BOOL)asJSON
                    params:(id)params
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask*)DELETE:(NSString*)path
                   success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                   failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)multipartPOST:(NSString*)path
                            params:(id)params
                   chunkedEncoding:(BOOL)chunked
                  bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                           success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                           failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;

-(NSURLSessionTask *)multipartPOST:(NSString*)path
                            params:(id)params
                  bodyConstruction:(void (^)(id<TMNetworkBodyMaker> maker))bodyConstruction
                           success:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject))success
                           failure:(void (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))failure;


@property(strong) NSURL *baseURL;
@property(assign) BOOL useChunkedEncoding;

-(void)setHook:(BOOL (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))hook forStatusCode:(NSInteger)code;

-(void)addNetworkSuccessWatchBlock:(void(^)(NSHTTPURLResponse *httpResponse))watcherBlock forObject:(id)object;


@end
