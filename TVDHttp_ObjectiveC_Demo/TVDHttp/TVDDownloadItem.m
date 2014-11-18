//
//  TVDDownloadItem.m
//  TdTinAnh
//
//  Created by Ta Van Dai on 17/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import "TVDDownloadItem.h"

@implementation TVDDownloadItem

@synthesize pathDownload,pathDownloading,resume,queue,fileSize,connection,dataDownload,delegate;

-(id)init{
    self = [super init];
    if(self){
        resume = NO;
        queue=YES;
    }
    return self;
}

@end
