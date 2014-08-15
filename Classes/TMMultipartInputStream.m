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

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTType.h>
#import "TMMultipartInputStream.h"

#define kHeaderStringFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n"
//Content-Disposition: form-data; name="adtitle"

#define kHeaderDataFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\nContent-Type: %@\r\n\r\n"
//Content-Disposition: form-data; name="thing"
//Content-Type: whatever/things

#define kHeaderPathFormat @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n"
//Content-Disposition: form-data; name="thumb"; filename="sgrada_thumb.jpg"
//Content-Type: image/jpeg

#define kFooterFormat @"--%@--\r\n"

#pragma mark - MIMEType working out
static NSString * MIMETypeForExtension(NSString * extension)
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    if (uti != NULL)
    {
        CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        if (mime != NULL)
        {
            NSString *type = [NSString stringWithString:(__bridge NSString *)mime];
            CFRelease(mime);
            return type;
        }
    }
    return @"application/octet-stream";
}


#pragma mark - PKMultipartElement

@interface TMMultipartElement : NSObject

@property (nonatomic, strong) NSData *headers;
@property (nonatomic, strong) NSInputStream *body;
@property (nonatomic) NSUInteger headersLength;
@property (nonatomic) NSUInteger bodyLength;
@property (nonatomic) NSUInteger length;
@property (nonatomic) NSUInteger delivered;

@end


@implementation TMMultipartElement

#pragma mark part header creation

-(NSData*)createHeaderWithName:(NSString*)name filename:(NSString*)filename contentType:(NSString*)contentType boundary:(NSString*)boundary
{
    // if the filename is set but the content type isn't wing it dynamically
    if(filename && !contentType)
    {
        contentType = MIMETypeForExtension(filename.pathExtension);
    }

    NSString * header;

    if(name && filename && contentType)
    {
        header = [NSString stringWithFormat:kHeaderPathFormat, boundary, name, filename, contentType];
    }
    else if (name && contentType)
    {
        header = [NSString stringWithFormat:kHeaderDataFormat, boundary, name, contentType];
    }
    // the name & filename case is handled by the fact we workout the content-type from the filename (bad, but whatever)
    else if (name)
    {
        header = [NSString stringWithFormat:kHeaderStringFormat, boundary, name];
    }
    else
    {
        NSLog(@"Warning!! No part name is set!");
        return nil;
    }

    return [header dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark initializers

- (id)initWithName:(NSString *)name
            string:(NSString *)string
       contentType:(NSString *)contentType
          boundary:(NSString *)boundary
{
    self               = [super init];
	if(self)
	{
	    self.headers       = [self createHeaderWithName:name
                                               filename:nil
                                            contentType:contentType
                                               boundary:boundary];
	    self.headersLength = [self.headers length];

	    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
	    self.body          = [NSInputStream inputStreamWithData:stringData];
	    self.bodyLength    = stringData.length;

	    [self updateLength];
	}
    return self;
}


- (id)initWithName:(NSString *)name
          filename:(NSString*)filename
              data:(NSData *)data
       contentType:(NSString *)contentType
          boundary:(NSString *)boundary
{
    self               = [super init];
	if(self)
	{
	    self.headers       = [self createHeaderWithName:name
                                               filename:filename
                                            contentType:contentType
                                               boundary:boundary];
	    self.headersLength = [self.headers length];

	    self.body          = [NSInputStream inputStreamWithData:data];
	    self.bodyLength    = [data length];

	    [self updateLength];
	}
    return self;
}

- (id)initWithName:(NSString *)name
          filename:(NSString *)filename
              path:(NSString *)path
       contentType:(NSString *)contentType
          boundary:(NSString *)boundary
{
    if (!filename)
    {
        filename = path.lastPathComponent;
    }

	self = [super init];
	if(self)
	{
	    self.headers       = [self createHeaderWithName:name
                                               filename:filename
                                            contentType:nil
                                               boundary:boundary];
	    self.headersLength = [self.headers length];

	    self.body          = [NSInputStream inputStreamWithFileAtPath:path];
	    self.bodyLength    = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
	    [self updateLength];
	}
    return self;
}

- (id)initWithName:(NSString *)name
          filename:(NSString *)filename
            stream:(NSInputStream *)stream
      streamLength:(NSUInteger)streamLength
       contentType:(NSString *)contentType
          boundary:(NSString *)boundary
{
	self = [super init];
	if(self)
	{
	    self.headers       = [self createHeaderWithName:name
                                               filename:filename
                                            contentType:contentType
                                               boundary:boundary];
	    self.headersLength = [self.headers length];

	    self.body          = stream;
	    self.bodyLength    = streamLength;
	    [self updateLength];
	}
    return self;
}

#pragma mark the meat of it

- (void)updateLength
{
    self.length = self.headersLength + self.bodyLength + 2;
    [self.body open];
}

- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;

    if (self.delivered >= self.length)
    {
        return 0;
    }

    if (self.delivered < self.headersLength && sent < len)
    {
        read            = MIN(self.headersLength - self.delivered, len - sent);
        [self.headers getBytes:buffer + sent range:NSMakeRange(self.delivered, read)];
        sent           += read;
        self.delivered += sent;
    }

    while (self.delivered >= self.headersLength && self.delivered < (self.length - 2) && sent < len)
    {
        if ((read = [self.body read:buffer + sent maxLength:len - sent]) == 0)
        {
            break;
        }
        sent           += read;
        self.delivered += read;
    }

    if (self.delivered >= (self.length - 2) && sent < len)
    {
        if (self.delivered == (self.length - 2))
        {
            *(buffer + sent) = '\r';
            sent ++;
			self.delivered ++;
        }
        *(buffer + sent) = '\n';
        sent ++;
		self.delivered ++;
    }

    return sent;
}
@end

#pragma mark - TMMultipartInputStream

@interface TMMultipartInputStream : NSObject

@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, strong) NSData *footer;
@property (nonatomic) NSUInteger currentPart, delivered, length;
@property (nonatomic) NSStreamStatus status;

@end


@implementation TMMultipartInputStream

#pragma mark initializer

- (id)init
{
    self = [super init];
    if (self)
    {
        self.parts    = [NSMutableArray array];
        self.boundary = [[NSProcessInfo processInfo] globallyUniqueString];
        self.footer   = [[NSString stringWithFormat:kFooterFormat, self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
        [self updateLength];
    }
    return self;
}

#pragma mark TMNetworkBodyMaker protocol support

-(void)addParameter:(NSString*)name
              value:(NSString*)value
{
    [self.parts addObject:[[TMMultipartElement alloc] initWithName:name
                                                            string:value
                                                       contentType:@"application/x-www-form-urlencoded"
                                                          boundary:self.boundary]];
    [self updateLength];

}

- (void)addPartWithName:(NSString *)name
                 string:(NSString *)string
            contentType:(NSString *)type
{
    [self.parts addObject:[[TMMultipartElement alloc] initWithName:name
                                                            string:string
                                                       contentType:type
                                                          boundary:self.boundary]];
    [self updateLength];
}

- (void)addPartWithName:(NSString *)name
               filename:(NSString*)filename
                   data:(NSData *)data
            contentType:(NSString *)type
{
    [self.parts addObject:[[TMMultipartElement alloc] initWithName:name
                                                          filename:filename
                                                              data:data
                                                       contentType:type
                                                          boundary:self.boundary]];

    [self updateLength];
}

- (void)addPartWithName:(NSString *)name
               filename:(NSString *)filename
                   path:(NSString *)path
            contentType:(NSString *)type
{
    [self.parts addObject:[[TMMultipartElement alloc] initWithName:name
                                                          filename:filename
                                                              path:path
                                                       contentType:type
                                                          boundary:self.boundary]];
    [self updateLength];
}

- (void)addPartWithName:(NSString *)name
               filename:(NSString *)filename
                 stream:(NSInputStream *)stream
           streamLength:(NSUInteger)streamLength
            contentType:(NSString *)type
{
    [self.parts addObject:[[TMMultipartElement alloc] initWithName:name
                                                          filename:filename
                                                            stream:stream
                                                      streamLength:streamLength
                                                       contentType:type
                                                          boundary:self.boundary]];
    [self updateLength];
}

#pragma mark the meat

- (void)updateLength
{
    self.length = self.footer.length + [[self.parts valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;

    self.status = NSStreamStatusReading;
    while (self.delivered < self.length && sent < len && self.currentPart < self.parts.count)
    {
        if ((read = [[self.parts objectAtIndex:self.currentPart] read:(buffer + sent) maxLength:(len - sent)]) == 0)
        {
            self.currentPart ++;
            continue;
        }
        sent            += read;
        self.delivered  += read;
    }
    if (self.delivered >= (self.length - self.footer.length) && sent < len)
    {
        read            = MIN(self.footer.length - (self.delivered - (self.length - self.footer.length)), len - sent);
        [self.footer getBytes:buffer + sent range:NSMakeRange(self.delivered - (self.length - self.footer.length), read)];
        sent           += read;
        self.delivered += read;
    }
    return sent;
}

- (BOOL)hasBytesAvailable
{
    return self.delivered < self.length;
}

- (void)open
{
    self.status = NSStreamStatusOpen;
}

- (void)close
{
    self.status = NSStreamStatusClosed;
}

- (NSStreamStatus)streamStatus
{
    if (self.status != NSStreamStatusClosed && self.delivered >= self.length)
    {
        self.status = NSStreamStatusAtEnd;
    }

    return self.status;
}

- (void)_scheduleInCFRunLoop:(NSRunLoop *)runLoop forMode:(id)mode {}
- (void)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext)context {}

@end
