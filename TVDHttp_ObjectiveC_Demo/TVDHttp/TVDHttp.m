//
//  TVDHttp.m
//  TdTinAnh
//
//  Created by Ta Van Dai on 13/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
// download and resume file
// http://nachbaur.com/blog/resuming-large-downloads-with-nsurlconnection
//


#import "TVDHttp.h"
#import "TVDDownloadItem.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TVDHttp{
    NSMutableArray *listRequest;
    BOOL reqiesting,isDownloading;
    NSMutableData *theData;
    NSURLConnection *theConnection;
    NSMutableArray *listReqDown;
}

static TVDHttp *tvdhttp;
+(TVDHttp*)shareInstance{
    if(!tvdhttp){
        tvdhttp = [[TVDHttp alloc] init];
    }
    return tvdhttp;
}

-(id)init{
    self = [super init];
    if(self){
        reqiesting = NO;
        isDownloading = NO;
        NSString *rootPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
        NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
        for(NSString *foder in arr){
            NSString *path = [NSString stringWithFormat:@"%@/%@",rootPath,foder];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/info.plist",path]];
            if([[NSDate date] timeIntervalSince1970]>[[dic valueForKey:@"date"] timeIntervalSince1970]){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    }
    return self;
}

- (void)getDataWithLink:(NSString*)link complete:(TVDBLOCKCompleteData)blockComplete error:(TVDBLOCKError)blockError{
    [self getDataWithLink:link timeOutSeconds:15 cache:NO cacheSeconds:0 userAgent:kUserAgentChrome complete:^(NSData *responseData) {
        blockComplete(responseData);
    } error:^(NSError *error) {
        blockError(error);
    }];
}

- (void)getDataWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteData)blockComplete error:(TVDBLOCKError)blockError{
    if(!listRequest)listRequest = [[NSMutableArray alloc] init];
    TVDRequest *request = [[TVDRequest alloc] init];
    [request setTimeOutSeconds:timeOutSeconds];
    [request setLink:link];
    [request setCache:cache];
    [request setCacheSeconds:cacheSeconds];
    if(userAgent){
        [request setUserAgent:userAgent];
    }else{
        [request setUserAgent:kUserAgentChrome];
    }
    [request setBlockComData:blockComplete];
    [request setBlockError:blockError];
    if(request.cache){
        NSString *fodel = [self MD5String:request.link];
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
        path = [path stringByAppendingString:fodel];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]+request.cacheSeconds];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"date", nil];
            [dic writeToFile:[path stringByAppendingString:@"/info.plist"] atomically:YES];
            NSData *dataa = [NSData dataWithContentsOfFile:[path stringByAppendingString:@"/data"]];\
            if(request.blockComData){
                request.blockComData(dataa);
            }
            return;
        }
    }
    [listRequest addObject:request];
    [self requestData];
}

- (void)getImageWithLink:(NSString*)link complete:(TVDBLOCKCompleteImage)blockComplete error:(TVDBLOCKError)blockError{
    [self getDataWithLink:link timeOutSeconds:15 cache:YES cacheSeconds:60*60*24*365 userAgent:kUserAgentChrome complete:^(NSData *responseData) {
        blockComplete([UIImage imageWithData:responseData]);
    } error:^(NSError *error) {
        blockError(error);
    }];
}

- (void)getImageWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteImage)blockComplete error:(TVDBLOCKError)blockError{
    [self getDataWithLink:link timeOutSeconds:timeOutSeconds cache:cache cacheSeconds:cacheSeconds userAgent:userAgent complete:^(NSData *responseData) {
        blockComplete([UIImage imageWithData:responseData]);
    } error:^(NSError *error) {
        blockError(error);
    }];
}

- (void)getStringWithLink:(NSString*)link complete:(TVDBLOCKCompleteString)blockComplete error:(TVDBLOCKError)blockError{
    [self getDataWithLink:link timeOutSeconds:15 cache:NO cacheSeconds:0 userAgent:kUserAgentChrome complete:^(NSData *responseData) {
        blockComplete([[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    } error:^(NSError *error) {
        blockError(error);
    }];
}

- (void)getStringWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteString)blockComplete error:(TVDBLOCKError)blockError{
    [self getDataWithLink:link timeOutSeconds:timeOutSeconds cache:cache cacheSeconds:cacheSeconds userAgent:userAgent complete:^(NSData *responseData) {
        blockComplete([[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    } error:^(NSError *error) {
        blockError(error);
    }];
}

-(void)requestData{
    if(reqiesting)return;
    if(listRequest.count==0)return;
    TVDRequest *request = [listRequest objectAtIndex:0];
    if(request.cache){
        NSString *fodel = [self MD5String:request.link];
        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
        path = [path stringByAppendingString:fodel];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]+request.cacheSeconds];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"date", nil];
            [dic writeToFile:[path stringByAppendingString:@"/info.plist"] atomically:YES];
            [listRequest removeObjectAtIndex:0];
            NSData *dataa = [NSData dataWithContentsOfFile:[path stringByAppendingString:@"/data"]];
            if(request.blockComData){
                request.blockComData(dataa);
            }
            [self requestData];
            return;
        }
    }
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:request.link] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:request.timeOutSeconds];
    [req setValue:request.userAgent forHTTPHeaderField:@"User-Agent"];
    theData = [[NSMutableData alloc] init];
    reqiesting=YES;
    theConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [theConnection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (connection == theConnection){
        [theData appendData:data];
    }else{
        for(TVDDownloadItem *request in listReqDown){
            if(connection==request.connection){
                [request.handleFile writeData:data];
                [request.handleFile synchronizeFile];
                request.currentDown += [data length];
                [request.delegate TDVDownloadLink:request.link responseFilesize:request.fileSize downloaded:request.currentDown];
                break;
            }
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    for(TVDDownloadItem *request in listReqDown){
        if(request.connection == connection){
            request.fileSize = [response expectedContentLength];
            NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:request.pathDownloading];
            request.handleFile = fh;
            request.currentDown=0;
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
            switch (httpResponse.statusCode) {
                case 206: {
                    NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
                    NSError *error = nil;
                    NSRegularExpression *regex = nil;
                    regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
                    if (error) {
                        [fh truncateFileAtOffset:0];
                        break;
                    }
                    NSTextCheckingResult *match = [regex firstMatchInString:range
                                                                    options:NSMatchingAnchored
                                                                      range:NSMakeRange(0, range.length)];
                    if (match.numberOfRanges < 2) {
                        [fh truncateFileAtOffset:0];
                        break;
                    }
                    NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
                    long long bytes = [byteStr longLongValue];
                    if (bytes <= 0) {
                        [fh truncateFileAtOffset:0];
                        [request.delegate TDVDownloadLink:request.link responseFilesize:request.fileSize downloaded:0];
                        break;
                    } else {
                        [fh seekToFileOffset:bytes];
                        request.currentDown=bytes;
                        request.fileSize = [response expectedContentLength]+bytes;
                        [request.delegate TDVDownloadLink:request.link responseFilesize:request.fileSize downloaded:bytes];
                    }
                    break;
                }
                default:
                    [fh truncateFileAtOffset:0];
                    [request.delegate TDVDownloadLink:request.link responseFilesize:request.fileSize downloaded:0];
                    break;
            }
            break;
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if(connection==theConnection){
        TVDRequest *request = [listRequest objectAtIndex:0];
        [listRequest removeObjectAtIndex:0];
        if(request.blockError){
            request.blockError(error);
        }
        reqiesting=NO;
        [self requestData];
    }else{
        for(TVDDownloadItem *request in listReqDown){
            if(request.connection == connection){
                [request.delegate TVDFailDownloadLink:request.link];
                isDownloading=NO;
                [listReqDown removeObject:request];
                [self requestDownload];
                break;
            }
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (connection == theConnection){
        TVDRequest *request = [listRequest objectAtIndex:0];
        [listRequest removeObjectAtIndex:0];
        NSData *datacom = [NSData dataWithData:theData];
        if(request.cache){
            NSString *fodel = [self MD5String:request.link];
            NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
                [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            }
            path = [path stringByAppendingString:fodel];
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]){
                [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                [datacom writeToFile:[path stringByAppendingString:@"/data"] atomically:YES];
            }
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]+request.cacheSeconds];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:date,@"date", nil];
            [dic writeToFile:[path stringByAppendingString:@"/info.plist"] atomically:YES];
        }
        if(request.blockComData){
            request.blockComData(datacom);
        }
        reqiesting = NO;
        [self requestData];
    }else{
        for(TVDDownloadItem *request in listReqDown){
            if(request.connection == connection){
                [request.handleFile synchronizeFile];
                [request.handleFile closeFile];
                NSFileManager *fm = [NSFileManager defaultManager];
                NSError *error = nil;
                if([fm fileExistsAtPath:request.pathDownload]){
                    [fm removeItemAtPath:request.pathDownload error:nil];
                }
                if ([fm moveItemAtPath:request.pathDownloading toPath:request.pathDownload error:&error]) {
                    [request.delegate TVDCompleteDownloadLink:request.link];
                    [fm removeItemAtPath:request.pathDownloading error:nil];
                }
                [listReqDown removeObject:request];
                isDownloading=NO;
                [self requestDownload];
                break;
            }
        }
    }
    connection=nil;
}

- (NSString *)MD5String:(NSString*) str{
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

-(void)cancelUrl:(NSString*)stringUrl{
    for(int i=0;i<listRequest.count;i++){
        TVDRequest *request = [listRequest objectAtIndex:i];
        if([request.link isEqualToString:stringUrl]){
            if(i==0 && theConnection!=nil){
                [theConnection cancel];
                reqiesting = NO;
            }
            [listRequest removeObjectAtIndex:i];
            [self requestData];
            break;
        }
    }
}

-(void)removeCache{
    NSString *rootPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    for(NSString *foder in arr){
        NSString *path = [NSString stringWithFormat:@"%@/%@",rootPath,foder];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

-(void)removeCacheWithLink:(NSString*)link{
    NSString *rootPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/TVDHttp/"];
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil];
    for(NSString *foder in arr){
        NSString *path = [NSString stringWithFormat:@"%@/%@",rootPath,foder];
        if([foder isEqualToString:[self MD5String:link]]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

-(void)downloadFileWithLink:(NSString*)link saveFileAtPath:(NSString*)path delegate:(id)delegate{
    if(!listReqDown)listReqDown = [[NSMutableArray alloc] init];
    TVDDownloadItem *request = [[TVDDownloadItem alloc] init];
    [request setTimeOutSeconds:20];
    [request setLink:link];
    [request setCache:NO];
    [request setCacheSeconds:0];
    [request setUserAgent:kUserAgentChrome];
    [request setBlockComData:nil];
    [request setBlockError:nil];
    [request setDelegate:delegate];
    [request setPathDownload:path];
    [request setPathDownloading:[path stringByAppendingString:@".download"]];
    [listReqDown addObject:request];
    [self requestDownload];
}

-(void)downloadFileWithLink:(NSString*)link saveFileAtPath:(NSString*)path downloadingPath:(NSString*)dowloadingPath delegate:(id)delegate{
    if(!listReqDown)listReqDown = [[NSMutableArray alloc] init];
    TVDDownloadItem *request = [[TVDDownloadItem alloc] init];
    [request setTimeOutSeconds:20];
    [request setLink:link];
    [request setCache:NO];
    [request setCacheSeconds:0];
    [request setUserAgent:kUserAgentChrome];
    [request setBlockComData:nil];
    [request setBlockError:nil];
    [request setDelegate:delegate];
    [request setPathDownload:path];
    [request setPathDownloading:dowloadingPath];
    [listReqDown addObject:request];
    [self requestDownload];
}

-(void)requestDownload{
    if(isDownloading)return;
    if(listReqDown.count==0)return;
    TVDDownloadItem *request = [listReqDown objectAtIndex:0];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:request.link] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:request.timeOutSeconds];
    [req setValue:request.userAgent forHTTPHeaderField:@"User-Agent"];
    if (![NSURLConnection canHandleRequest:req]) {
        // Handle the error
    }
    // Check to see if the download is in progress
    unsigned long long downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:request.pathDownloading]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:request.pathDownloading error:&error];
        if (!error && fileDictionary){
            downloadedBytes = [fileDictionary fileSize];
        }
    } else {
        [fm createFileAtPath:request.pathDownloading contents:nil attributes:nil];
    }
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%lld-", downloadedBytes];
        [req setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    isDownloading=YES;
    request.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    [request.connection start];
}

-(void)cancelDownloadLink:(NSString*)link{
    for(TVDDownloadItem *request in listReqDown){
        if([request.link isEqualToString:link]){
            if(request.connection){
                [request.connection cancel];
            }
            [listReqDown removeObject:request];
        }
    }
}

-(void)stopDownloadLink:(NSString*)link{
    for(TVDDownloadItem *request in listReqDown){
        if([request.link isEqualToString:link]){
            if(request.connection){
                [request.connection cancel];
                if([[NSFileManager defaultManager] fileExistsAtPath:request.pathDownloading]){
                    [[NSFileManager defaultManager] removeItemAtPath:request.pathDownloading error:nil];
                }
            }
            [listReqDown removeObject:request];
        }
    }
}

@end
