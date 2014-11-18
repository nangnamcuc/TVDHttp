//
//  TVDDownloadItem.h
//  TdTinAnh
//
//  Created by Ta Van Dai on 17/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import "TVDRequest.h"

@protocol TVDDownloadDelegate;

@interface TVDDownloadItem : TVDRequest

@property (strong, nonatomic) NSString *pathDownloading, *pathDownload;
@property (assign) BOOL resume,queue;
@property (assign) unsigned long long fileSize,currentDown;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *dataDownload;
@property (strong, nonatomic) NSFileHandle *handleFile;
@property (nonatomic, assign) id<TVDDownloadDelegate> delegate;

@end

@protocol TVDDownloadDelegate

- (void) TVDCompleteDownloadLink:(NSString*)link;
- (void) TVDFailDownloadLink:(NSString*)link;
- (void) TVDStartDownloadLink:(NSString*)link;
- (void) TDVDownloadLink:(NSString*)link responseFilesize:(unsigned long long)filesize downloaded:(unsigned long long) downloaded;

@optional

@end
