# TMNetwork

[![CI Status](http://img.shields.io/travis/Tony Million/TMNetwork.svg?style=flat)](https://travis-ci.org/Tony Million/TMNetwork)
[![Version](https://img.shields.io/cocoapods/v/TMNetwork.svg?style=flat)](http://cocoadocs.org/docsets/TMNetwork)
[![License](https://img.shields.io/cocoapods/l/TMNetwork.svg?style=flat)](http://cocoadocs.org/docsets/TMNetwork)
[![Platform](https://img.shields.io/cocoapods/p/TMNetwork.svg?style=flat)](http://cocoadocs.org/docsets/TMNetwork)

Simple, Highly Opinionated, networking

## Usage

TMNetwork is a simple to use, very powerful networking library for iOS 7 and above. It makes use of the latest APIs like NSURLSession & NSURLSessionTask. For the basic use case of accessing a RESTful api that returns JSON its probably the best tool for the job!

Since an example will tell you far more than a thousand words, heres a basic GET request.

```
    [[TMNetwork sharedInstance] setBaseURL:[NSURL URLWithString:@"https://api.github.com/"]];
	[[TMNetwork sharedInstance] GET:@"events"
                             params:nil
                            success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
                                }
                            failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
                                }];
```

Yes TMNetwork has a singleton - I dont care if you dont like it, it also supports alloc/init if you want to avoid the singleton.

In the above example a request is made to github for all the events. Github responds in JSON (which TMNetwork _loves_) and assuming you get a 200 response the success block is called and the __DECODED__ JSON is passed into responseObject (along with the response, and the original request response data).

In the failure case, maybe github responds with a 400 or a 403 (if you make too many requests), the failure block will be called. _However_ if the server responds with a decodable format (i.e. JSON) it will be decoded and passed into responseObject just as in the success case along with an `NSError`

In addition to GET, TMNetwork supports POST, PUT, PATCH, DELETE.

####Multi-part & file uploads

`TMNetwork` can even do multi-part posts with file attachments so you can build your cat photo sharing network using it. (See the `TMMultipartInputStream` class for more details) Heres an example:

```
        [[TMNetwork sharedInstance] multipartPOST:@"publish_cat"
                                           params:@{
                                                    @"text":@"OMG I LOVE MY CAT",
                                                }
                                 bodyConstruction:^(id<TMNetworkBodyMaker> maker) {
                                     if(self.capturedCatImage)
                                     {
                                         [maker addPartWithName:@"cat"
                                                       filename:@"cat.jpg"
                                                           data:UIImageJPEGRepresentation(self.capturedCatImage, 0.7)
                                                    contentType:@"image/jpeg"];
                                     }
                                 }
                            success:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject) {
                                }
                            failure:^(NSHTTPURLResponse *httpResponse, NSData *responseData, id responseObject, NSError *error) {
                                }];
```

Here we POST to an endpoint <base>/publish_cat we send the params text=OMG I LOVE MY CAT and include an image, the image shows up as a file (so in PHP it'll show up in `$_FILES` as `cat`).

####Synchronous Category

`TMNetwork` has a category which enables synchronous operation i.e. the networking call will **block** the current thread until it has completed. Generally you dont want to do this, unless you do. If you do make sure all your network operations are happening in a background thread, if you call any of the synchronous calls on the main thread your app will lock up for the duration of the network call.

All of the synchronous operations are identical to the async versions with sync prepended i.e. `syncGet`, `syncPost`, `syncMultipartPOST` etc.


####Wrap up

TMNetwork is designed to be lean and mean, its basically 2 files (plus a couple of helpers), with a category which implements synchronous network IO (if you need that kind of thing).

The headers contain appledocs and should guide you through usage.

Finally, TMNetwork is well tested having been used in a number of AppStore apps one of which has 250,000 active users.

## Installation

TMNetwork is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TMNetwork"

## Author

Tony Million, tonymillion@gmail.com

## License

TMNetwork is available under the MIT license. See the LICENSE file for more info.
