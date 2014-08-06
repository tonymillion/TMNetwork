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
