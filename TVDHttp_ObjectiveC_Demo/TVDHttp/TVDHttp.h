//
//  TVDHttp.h
//  TdTinAnh
//
//  Created by Ta Van Dai on 13/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kUserAgentChrome @"Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36"
#define kUserAgentFireFox @"Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0"
#define kUserAgentIOS @"Mozilla/5.0 (iPad; CPU OS 7_0_2 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A501 Safari/9537.53"
#define kUserAgentAndroid @"Mozilla/5.0 (Linux; Android 4.4; Nexus 7 Build/KOT24) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.105 Safari/537.36"

typedef void (^TVDBLOCKCompleteString)(NSString *responseString);
typedef void (^TVDBLOCKCompleteImage)(UIImage *responseImage);
typedef void (^TVDBLOCKCompleteData)(NSData *responseData);
typedef void (^TVDBLOCKError)(NSError *error);

@interface TVDHttp : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

+(TVDHttp*)shareInstance;

/*!
 @method         removeCache
 
 @abstract
                 remove all cache
 */
-(void)removeCache;

-(void)cancelUrl:(NSString*)stringUrl;

-(void)removeCacheWithLink:(NSString*)link;

- (void)getDataWithLink:(NSString*)link complete:(TVDBLOCKCompleteData)blockComplete error:(TVDBLOCKError)blockError;
- (void)getDataWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteData)blockComplete error:(TVDBLOCKError)blockError;

- (void)getImageWithLink:(NSString*)link complete:(TVDBLOCKCompleteImage)blockComplete error:(TVDBLOCKError)blockError;
- (void)getImageWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteImage)blockComplete error:(TVDBLOCKError)blockError;

- (void)getStringWithLink:(NSString*)link complete:(TVDBLOCKCompleteString)blockComplete error:(TVDBLOCKError)blockError;
- (void)getStringWithLink:(NSString*)link timeOutSeconds:(int)timeOutSeconds cache:(BOOL)cache cacheSeconds:(long)cacheSeconds userAgent:(NSString*)userAgent complete:(TVDBLOCKCompleteString)blockComplete error:(TVDBLOCKError)blockError;

-(void)downloadFileWithLink:(NSString*)link saveFileAtPath:(NSString*)path delegate:(id)delegate;
-(void)downloadFileWithLink:(NSString*)link saveFileAtPath:(NSString*)path downloadingPath:(NSString*)dowloadingPath delegate:(id)delegate;

-(void)cancelDownloadLink:(NSString*)link;
-(void)stopDownloadLink:(NSString*)link;

@end
