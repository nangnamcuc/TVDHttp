//
//  TVDRequest.h
//  TdTinAnh
//
//  Created by Ta Van Dai on 13/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVDHttp.h"

@interface TVDRequest : NSObject

@property (strong, nonatomic) NSString *link, *userAgent;
@property (assign) BOOL cache;
@property (assign) int timeOutSeconds;
@property (assign) long cacheSeconds;
@property (copy) TVDBLOCKCompleteData blockComData;
@property (copy) TVDBLOCKError blockError;

@end
