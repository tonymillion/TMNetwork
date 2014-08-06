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

#import "NSDictionary+URLParameterEncoding.h"
#import "NSString+URLEncoding.h"

@implementation NSDictionary (URLParameterEncoding)

-(NSString*)URLParameters
{
    NSMutableArray * encodedPairs = [NSMutableArray array];
    
    for(NSString *key in self)
    {
        id temp = [self objectForKey:key];
        
        NSString * strParam;
        
        if([temp isKindOfClass:[NSString class]])
        {
            strParam = temp;
        }
        else
        {
            strParam = [NSString stringWithFormat:@"%@", temp];
        }
        
        NSString * kvp = [NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [strParam URLEncodedString]];
        
        [encodedPairs addObject:kvp];
    }
    
    return [encodedPairs componentsJoinedByString:@"&"];
}

@end
