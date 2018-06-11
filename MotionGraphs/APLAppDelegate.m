
/*
     File: APLAppDelegate.m
 Abstract: The app delegate that has an app-wide motion manager.
  Version: 1.0.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "APLAppDelegate.h"
#import "APLGraphViewController.h"
#import "AVOSCloud.h"

APLAppDelegate *del;

@interface APLAppDelegate ()
{
    CLLocationManager *locationManager;
    CMMotionManager *motionmanager;
}

@end

@implementation APLAppDelegate

@synthesize bgTask;
@synthesize locationManager;

- (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    
//    DBAccount *account = [[DBAccountManager sharedManager]handleOpenURL:url];
//    if (account) {
//        NSLog(@"App Linked Successfully");
//        return YES;
//    }
//    
//    return NO;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Starting app");
    
    del = self;
    
//    DBAccountManager *accountManager = [[DBAccountManager alloc]initWithAppKey:@"ovziot34hyqvmlo" secret:@"japsx06g5nhkkqy"];
//    [DBAccountManager setSharedManager:accountManager];
    
    //--------------------------- Initialize Location Updates --------------------------------
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.allowsBackgroundLocationUpdates = YES;

    [locationManager startUpdatingLocation];
    
    // ---------------------------------------------------------------------------------------
    
    //获取当前的系统语言设置
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSLog(@"%@",currentLanguage);
    
    //设置用户语言为当前系统语言
    [defaults setObject:currentLanguage forKey:@"user_lang_string"];
    
    //LeanCloud即时通讯
    [AVOSCloud setApplicationId:@"2vwh1TYLAQQx3lClxPmNj39v-gzGzoHsz" clientKey:@"vOLGzfgbSHRpC1Wpyque8DcY"];
    [AVOSCloud setAllLogsEnabled:YES];
    return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"application will resign active called");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    CLLocationManager *manager = [[CLLocationManager alloc] init];
//    manager.delegate = self;
    
    NSLog(@"application did enter background called");
    UIApplication *thisApp = [UIApplication sharedApplication];
    bgTask = [thisApp beginBackgroundTaskWithExpirationHandler:^{
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //run the app with starting UpdatingLocation. backgroundTimeRemaining decremented from 600.00
        [locationManager startUpdatingLocation];
        [self printTimeRemaining];
        
        while (YES) {
            [NSThread sleepForTimeInterval:1.0];
        }
    });
}

-(void)printTimeRemaining {
    NSLog(@"Background Task Time Remaining: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"application will enter foreground called");
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationwillTerminate called");
    while (YES) {
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"Still executing code in applicationwillTerminate");
    }
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Memory Warning Received");
}



@end
