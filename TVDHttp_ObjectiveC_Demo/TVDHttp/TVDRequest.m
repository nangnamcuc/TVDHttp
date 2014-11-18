//
//  TVDRequest.m
//  TdTinAnh
//
//  Created by Ta Van Dai on 13/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import "TVDRequest.h"

@implementation TVDRequest

@synthesize userAgent,link,blockError,blockComData,cache,timeOutSeconds,cacheSeconds;

-(id)init{
    self = [super init];
    if(self){
        timeOutSeconds=5;
        cache = NO;
        blockComData = nil;
        blockError = nil;
        link = nil;
        userAgent = nil;
        cacheSeconds=0;
    }
    return self;
}

@end
