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


// Based on and simplified from:
// PKMultipartInputStream by py.kerembellec@gmail.com
// https://github.com/pyke369/PKMultipartInputStream
/*
 Copyright (c) 2010 Pierre-Yves Kerembellec <py.kerembellec@gmail.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


// This is the protocol we adopt the rest of the calls are opaque to the outside world

@protocol TMNetworkBodyMaker <NSObject>

-(void)addParameter:(NSString*)name
              value:(NSString*)value;

// add a string (this can be used for URLEncoded parameters
- (void)addPartWithName:(NSString *)name
                 string:(NSString *)string
            contentType:(NSString *)type;


// add a NSData - if filename is nil it will act like above function (with pre-encoded params)
// if filename is set it will pretend to be a file (i.e. an in-memory file)
- (void)addPartWithName:(NSString *)name
               filename:(NSString*)filename
                   data:(NSData *)data
            contentType:(NSString *)type;

// add file (filename is optional, and if you override it we will use that, otherwise we use the filename from the path)
// we work out the content type from the filename, or the filename part of the path
// you can override all of this by passing in a contentType
- (void)addPartWithName:(NSString *)name
               filename:(NSString *)filename
                   path:(NSString *)path
            contentType:(NSString *)type;


// add a NSInputStream - this can be from anywhere if filename is set it will be a file upload, otherwise it will act
// like the NSData method above. contentType can be set to override the auto-determination from the filename
// if filename is not set, then contentType should be
- (void)addPartWithName:(NSString *)name
               filename:(NSString *)filename
                 stream:(NSInputStream *)stream
           streamLength:(NSUInteger)streamLength
            contentType:(NSString *)type;
@end


@interface TMMultipartInputStream : NSInputStream <TMNetworkBodyMaker>

@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly) NSUInteger length;

@end
