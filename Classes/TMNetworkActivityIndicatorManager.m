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


#import <UIKit/UIKit.h>
#import "TMNetworkActivityIndicatorManager.h"

@interface TMNetworkActivityIndicatorManager ()

@property(strong) dispatch_queue_t      activityQueue;
@property(assign) NSInteger             count;

@end


@implementation TMNetworkActivityIndicatorManager

+(TMNetworkActivityIndicatorManager*)sharedManager
{
    static TMNetworkActivityIndicatorManager * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TMNetworkActivityIndicatorManager alloc] init];
    });

    return shared;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        self.count = 0;
        self.activityQueue = dispatch_queue_create("com.tonymillion.activityqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.activityQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    }

    return self;
}

-(void)updateActivityDisplay
{
    if(self.count)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
    }
    else
    {
        // we wait a wee while after hitting 0
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            // if the count is STILL 0 then we'll turn it off
            if(self.count == 0)
            {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
        });
    }
}

-(void)incrementActivityCount
{
    dispatch_async(self.activityQueue, ^{
        self.count++;
        [self updateActivityDisplay];
    });
}

-(void)decrementActivityCount
{
    dispatch_async(self.activityQueue, ^{
        if(self.count > 0)
            self.count--;
        [self updateActivityDisplay];
    });
}

-(void)resetActivityCount
{
    dispatch_async(self.activityQueue, ^{
		self.count=0;
        [self updateActivityDisplay];
    });
}


@end
