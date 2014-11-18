//
//  ViewController.m
//  TVDHttp_ObjectiveC_Demo
//
//  Created by Ta Van Dai on 18/11/2014.
//  Copyright (c) Năm 2014 Ta Van Dai. All rights reserved.
//

#import "ViewController.h"
#import "TVDHttp.h"

@interface ViewController ()
{
    __weak IBOutlet UILabel *lbldownload;
    __weak IBOutlet UILabel *lbldownload2;
    __weak IBOutlet UITextView *textview;
    __weak IBOutlet UIImageView *imgview1;
    __weak IBOutlet UIImageView *imgview2;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[TVDHttp shareInstance] getStringWithLink:@"http://nachbaur.com/blog/resuming-large-downloads-with-nsurlconnection" complete:^(NSString *responseString) {
        textview.text = responseString;
    } error:^(NSError *error) {
        textview.text=[NSString stringWithFormat:@"%@",error];
    }];
    
    //after get string done then load image1
    [[TVDHttp shareInstance] getImageWithLink:@"http://clip.bhmedia.vn/codeigniter_cke/uploads/images/Chicken-Curry.jpg" complete:^(UIImage *responseImage) {
        imgview1.image = responseImage;
    } error:^(NSError *error) {
        
    }];
    
    // load image2 do not wait get string and load image1
    TVDHttp *http = [[TVDHttp alloc] init];
    [http getImageWithLink:@"http://clip.bhmedia.vn/codeigniter_cke/uploads/images/28.jpg" complete:^(UIImage *responseImage) {
        imgview2.image = responseImage;
    } error:^(NSError *error) {
        
    }];
    
    //down file man.zip
    [[TVDHttp shareInstance] downloadFileWithLink:@"http://app.bhmedia.vn/idata/monan/400px.zip" saveFileAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/man.zip"] delegate:self];
    
    //after download man.zin done then download AndroidStudio.zip
    [[TVDHttp shareInstance] downloadFileWithLink:@"https://dl.google.com/dl/android/studio/ide-zips/0.8.14/android-studio-ide-135.1538390-mac.zip" saveFileAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/AndroidStudio.zip"] delegate:self];
    
    // download EclipseAdt.zip do not wait download man.zip and AndroidStudio.zip
    [http downloadFileWithLink:@"https://dl.google.com/android/adt/adt-bundle-mac-x86_64-20140702.zip" saveFileAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents/EclipseAdt.zip"] delegate:self];
}

- (void) TVDCompleteDownloadLink:(NSString*)link{
    NSLog(@"TVDCompleteDownloadLink");
}
- (void) TVDFailDownloadLink:(NSString*)link{
    NSLog(@"TVDFailDownloadLink");
}
- (void) TVDStartDownloadLink:(NSString*)link{
    NSLog(@"TVDStartDownloadLink");
}
- (void) TDVDownloadLink:(NSString*)link responseFilesize:(unsigned long long)filesize downloaded:(unsigned long long) downloaded{
    if([link isEqualToString:@"https://dl.google.com/android/adt/adt-bundle-mac-x86_64-20140702.zip"]){
        lbldownload2.text = [NSString stringWithFormat:@"Adt %lld - %lld",filesize,downloaded ];
    }else{
        lbldownload.text = [NSString stringWithFormat:@"TDVDownloadLink %lld - %lld",filesize,downloaded ];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
