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


#import <Foundation/Foundation.h>

#import "TMMultipartInputStream.h"

/** `TMNetwork` is a wrapper around NSURLSession & NSURLSessionTask that makes
 accessing HTTP based services a pleasurable experience. It gives you verb based
 calling (i.e. `GET`,`PUT`) and block based success & failure handlers.

 `TMNetwork` is highly opinionated and has decided only urlencoded query-string
 parameters or JSON are acceptable forms of data exchange. What this means for
 you, the programmer, is you pass a dictionary as a set of parameters, tell
 `TMNetwork` if you want it sent as urlencoded query params or a JSON encoded
 blob, then let `TMNetwork` do its job.

 Once the HTTP call has been executed `TMNetwork` will look at the HTTP Response
 code, Content-Type, etc. then execute the success or failure blocks you passed
 in.

 If the server response is a "decodable" type it will be decoded and passed in
 via the responseObject parameter. i.e. if JSON is returned from the server it
 will be decoded and passed in to the responseObject if the decoding fails then
 the failureBlock will be called.

 The decoding will take place regardless of the HTTP status code i.e. if a
 server responds with a 400 error and a blob of JSON the failureBlock will be
 called with responseObject being the decoded JSON (i.e. A NSDictionary or
 NSArray)

 */

@interface TMNetwork : NSObject

/**-----------------------------------------------------------------------------
 * @name Accessing the Shared TMNetwork instance
 * -----------------------------------------------------------------------------
 */

/** Returns a shared `TMNetwork` instance, creating it if necessary.

 @return The shared `TMNetwork` instance.

 */
+(instancetype)sharedInstance;

/** Create a `TMNetwork` instance with a given baseURL.

 @param baseURL the base url that should be used for network requests, should
 be a url like `[NSURL urlWithString:@"https://www.yourservice.com/api/1/"]
 you should include the final slash so we can construct the full URLS properly

 @return A `TMNetwork` instance.

 */
-(instancetype)initWithBaseURL:(NSURL*)baseURL;

/**
 Returns a string for the given header name or nil if the header is not set.

 @param header The name of the header e.g. `Content-Type`

 @return The value for that header name or nil if its not set
 */
-(NSString *)valueForHeader:(NSString *)header;

/**
 Sets the value for a given header. Overwrites any existing header with the same
 name

 @param header The name of the header e.g. `Content-Type`
 */

-(void)setValue:(NSString *)value forHeader:(NSString *)header;

/**
 Remove a header with a given name

 @param header The name of the header e.g. `Content-Type`
 */
-(void)removeHeader:(NSString *)header;

/**
 Sets the `Authorization` header to `Basic` type i.e. a base64 encoded string of
 the username & password.

 @param username The users username
 @param password The users password
 */
-(void)setBasicAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password;

/**
 Sets the `Authorization` header to `Bearer` type i.e. `Authorization: Bearer
 <token string>` used
in OAuth2 compatible services.

 @param token The OAuth token to access the service
 */
-(void)setBearerAuthorizationHeaderWithToken:(NSString *)token;

-(void)setAuthorizationHeaderWithType:(NSString*)type  token:(NSString *)token;

/**
 Removes the `Authorization` header
 */

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

/**
 Specifies the base URL to use for requests.

 e.g. [NSURL urlWithString:@"https://server.com/api/1/"] (the trailing slash is
 important.

 It means if you call `GET` with a relative url it will be concatenated i.e.
 GET:@"users/me/name" will turn into @"https://server.com/api/1/users/me/name"
 */
@property(strong) NSURL *baseURL;


/**
 Enable Chunked-Encoding for network requests, which is more optimal, however
 in practice badly supported and thus this is NO by default.
 */

@property(assign) BOOL useChunkedEncoding;


/**
  Allows you to set a block to be executed whenever status code `code` is encountered
  The rationale behind this is a global handler for 401 which will clear the current user/pass/token
  and log the user out in one place

 @param hook The block to be executed
 @param code the status code to watch for
 */
-(void)setHook:(BOOL (^)(NSHTTPURLResponse *httpResponse, NSData * responseData, id responseObject, NSError *error))hook forStatusCode:(NSInteger)code;


/**
  Allows you to set a block to be executed whenever network activity successfully completes.
  TMNetwork classifies success as getting *any* response from a server (a 400 for example is still a response)
  to remove the watcher block, simple pass nil to watcherBlock for the same object.

 @param watcherBlock The block to be executed
 @param object an object you own to associate the block with (this is used to remove the block later)
 */
-(void)addNetworkSuccessWatchBlock:(void(^)(NSHTTPURLResponse *httpResponse))watcherBlock forObject:(id)object;


@end
