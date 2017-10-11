//
//  APLAccelerometerGraphViewController03.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 12/15/14.
//
// App Key - ovziot34hyqvmlo            // ashishduwaju@gmail.com
// App Secret - japsx06g5nhkkqy

#import "APLAccelerometerGraphViewController03.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"
#import "APLViralSwitch.h"
#import "APLPulsingHaloLayer.h"
#import "APLSAMultisectorControl.h"
#import "APLWaveformView.h"
#import "AppSandboxViewController.h"
#import "APLDocument.h"
#import "APLCloudFile.h"
#import "BufferRecords.h"
#import "SeismicRecords.h"
#import "AppSandboxDetailViewController.h"
#import <mach/mach.h>
#import <CloudKit/CloudKit.h>

#define UBIQUITY_CONTAINER_URL @"iCloud.com.saitama.MotionGraphs"

#define RGB_Alpha(r, g, b, alp) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: alp]
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: 1]

@interface APLAccelerometerGraphViewController03 ()

@property (strong,nonatomic) BufferRecords *bufferRecord;
@property (strong,nonatomic) SeismicRecords *seismicRecord;
//@property (strong,nonatomic) AccelerationRecords *accelerationRecord;
@property (strong,nonatomic) AppSandboxDetailViewController *asdvc;
@property BOOL InitialBuffer, WeAreRecording, remoteNotification, isRemoteFunctionOn, isStopByButton, remoteStartStop, remoteBuffer, forceStartStopTrigger, isInTheSameDayFolder, uploadSummary, isWaitingForceTriggered, isForceTriggered;

@property (weak, nonatomic) IBOutlet UIView *whiteView;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UIView *grayView;
@property (weak, nonatomic) IBOutlet UIView *blackView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *haloView;
@property (weak, nonatomic) IBOutlet APLWaveformView *waveformView;
@property (strong, nonatomic) APLPulsingHaloLayer *halo;

@property (weak, nonatomic) IBOutlet UITextView *statusOfRecord;
@property (weak, nonatomic) IBOutlet UIButton *bufferButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteStartStopButton;
@property (weak, nonatomic) IBOutlet UIButton *forceRemoteStartStopButton;
@property (weak, nonatomic) IBOutlet UILabel *controlMode;
@property (weak, nonatomic) IBOutlet UILabel *recordInfo;
@property (weak, nonatomic) IBOutlet UILabel *remoteSync;
@property (weak, nonatomic) IBOutlet UILabel *remoteNote;
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalUnit;
@property (weak, nonatomic) IBOutlet APLViralSwitch *mySwitch;
@property (weak, nonatomic) IBOutlet APLSAMultisectorControl *multisectorControl;

@property (strong,nonatomic) NSDate *startBufferDate;
@property (strong,nonatomic) NSDate *recordedBufferDate;
@property (strong,nonatomic) NSDate *endBufferDate;
@property (strong,nonatomic) NSDate *startRecordDate;
@property (strong,nonatomic) NSDate *endRecordDate;
@property (strong,nonatomic) NSDate *notificationStartDate;
@property (strong,nonatomic) NSDate *dBFileSystemReleaseDate;
@property (nonatomic) double timeOfRecord;
@property (strong,nonatomic) NSDate *serverCheckDate;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;
@property (strong,nonatomic) NSArray *arr;
@property (nonatomic) float userSamplingRate, triggerThreshold, bufferLength, recordLength, day, month, year, angleX, angleY, angleZ, lastNormalizedValue;
@property (strong, nonatomic) NSMetadataQuery *query;
@property (strong, nonatomic) NSMetadataQuery *remoteStartQuery;
@property (strong, nonatomic) NSMetadataQuery *remoteStopQuery;
@property (strong, nonatomic) NSMetadataQuery *forceRemoteStartQuery;
@property (strong, nonatomic) NSMetadataQuery *forceRemoteStopQuery;
@property (strong, nonatomic) NSMetadataQuery *triggeredInfoQuery;

@property (nonatomic) APLDocument *document;
@property (nonatomic) NSFileManager *manager;
@property (nonatomic) NSURL *rootUrl;
@property (nonatomic) NSURL *destinationUrl;

@end


@implementation APLAccelerometerGraphViewController03

@synthesize filename,dataString,dayFolder,monthFolder,yearFolder;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    _manager = [NSFileManager defaultManager];
    _rootUrl = [_manager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL];
    
    // Init Frames
    
    self.controlMode.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height*0.28-64);
    
    self.whiteView.frame = CGRectMake(0, self.view.frame.size.height*0.28, self.view.frame.size.width, self.view.frame.size.height*0.056);
    self.whiteView.layer.borderWidth = 0.2;
    self.whiteView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.intervalLabel.frame = CGRectMake(8, 0, 26, self.view.frame.size.height*0.056);
    self.updateIntervalLabel.frame = CGRectMake(36, 0, 36, self.view.frame.size.height*0.056);
    self.intervalUnit.frame = CGRectMake(72, 0, 6, self.view.frame.size.height*0.056);
    self.updateIntervalSlider.frame = CGRectMake(102, 0, self.view.frame.size.width-102-16, self.view.frame.size.height*0.056);
    
    self.blueView.frame = CGRectMake(0, self.view.frame.size.height*0.336, self.view.frame.size.width, self.view.frame.size.height*0.2);
    self.remoteSync.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.07);
    self.remoteNote.frame = CGRectMake(0, self.view.frame.size.height*0.054, self.view.frame.size.width, self.view.frame.size.height*0.06);
    self.mySwitch.frame = CGRectMake((self.view.frame.size.width-self.mySwitch.frame.size.width)/2.0, self.view.frame.size.height*0.124, self.view.frame.size.width, self.view.frame.size.height*0.06);
    
    self.blackView.frame = CGRectMake(0, self.view.frame.size.height*0.536, self.view.frame.size.width, self.view.frame.size.height*0.04);
    self.blackView.layer.borderWidth = 0.2;
    self.blackView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.waveformView.frame = CGRectMake(0, self.view.frame.size.height*0.576, self.view.frame.size.width, self.view.frame.size.height*0.05);
    [self.waveformView setWaveColor:[UIColor blackColor]];
    [self.waveformView setPrimaryWaveLineWidth:1.0f];
    [self.waveformView setSecondaryWaveLineWidth:0.5];
    self.phoneView.frame = CGRectMake((self.view.frame.size.width-self.waveformView.frame.size.height*0.55)/2.0, self.view.frame.size.height*0.576+2.0, self.waveformView.frame.size.height*0.55, self.waveformView.frame.size.height-4.0);
    
    // 初始化halo
    self.halo = [APLPulsingHaloLayer layer];
    self.halo.frame = CGRectMake(0, 0, self.haloView.frame.size.width, self.haloView.frame.size.height);
    [self.haloView.layer insertSublayer:self.halo atIndex:0];
    
    self.halo.radius = 0;
    
    self.grayView.frame = CGRectMake(0, self.view.frame.size.height*0.626, self.view.frame.size.width, self.view.frame.size.height*0.1);
    self.grayView.layer.borderWidth = 0.2;
    self.grayView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.statusOfRecord.frame = CGRectMake(0, self.view.frame.size.height*0.626, self.view.frame.size.width, self.view.frame.size.height*0.1);
    
    self.bufferButton.layer.cornerRadius = self.bufferButton.frame.size.height/2;
    self.bufferButton.backgroundColor = [UIColor whiteColor];
    [self.bufferButton setTitle:NSLocalizedString(@"Buffer",@"") forState:UIControlStateNormal];
    [self.bufferButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.bufferButton.titleLabel.font = [UIFont systemFontOfSize:14];

    self.recordButton.layer.cornerRadius = self.recordButton.frame.size.height/2;
    self.recordButton.backgroundColor = [UIColor whiteColor];
    [self.recordButton setTitle:NSLocalizedString(@"Record",@"") forState:UIControlStateNormal];
    [self.recordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.remoteStartStopButton.layer.cornerRadius = self.bufferButton.frame.size.height/2;
    self.remoteStartStopButton.backgroundColor = RGB(31, 183, 252);
    [self.remoteStartStopButton setTitle:NSLocalizedString(@"Remote Buffer",@"") forState:UIControlStateNormal];
    [self.remoteStartStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.remoteStartStopButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    self.forceRemoteStartStopButton.layer.cornerRadius = self.bufferButton.frame.size.height/2;
    self.forceRemoteStartStopButton.backgroundColor = RGB(31, 183, 252);
    [self.forceRemoteStartStopButton setTitle:NSLocalizedString(@"Remote Record",@"") forState:UIControlStateNormal];
    [self.forceRemoteStartStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.forceRemoteStartStopButton.titleLabel.font = [UIFont systemFontOfSize:14];

    
    // 初始化Wave
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    
    // 设置同步开关效果
    self.mySwitch.completionOn = ^{
//        NSLog(@"Animation On");
    };
    
    self.mySwitch.completionOff = ^{
//        NSLog(@"Animation Off");
    };
    
    self.mySwitch.animationElementsOn =
    @[
      @{ APLElementView: self.remoteSync,
         APLElementKeyPath: @"textColor",
         APLElementToValue: [UIColor whiteColor] },
      ];
    
    self.mySwitch.animationElementsOff =
    @[
      @{ APLElementView: self.remoteSync,
         APLElementKeyPath: @"textColor",
         APLElementToValue: RGB_Alpha(31, 183, 252, 1) },
      ];
    
    self.mySwitch.completionOn = ^{
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    };
    
    self.mySwitch.completionOff = ^{
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    };
    
    
    //set the title
    self.title = NSLocalizedString(@"Monitor",@"");
    
    self.controlMode.text = NSLocalizedString(@"Local Control",@"");
    self.statusOfRecord.text = NSLocalizedString(@"Status Of Record",@"");
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    self.WeAreRecording = NO;
    self.InitialBuffer = NO;
    self.remoteNotification = NO;
    self.isRemoteFunctionOn = NO;
    self.mySwitch.on = NO;
    self.isStopByButton = NO;
    self.remoteStartStop = NO;
    self.forceStartStopTrigger = NO;
    self.remoteBuffer = NO;
    self.remoteStartStopButton.enabled=NO;
    self.forceRemoteStartStopButton.enabled=NO;
    self.isWaitingForceTriggered = NO;
    self.isForceTriggered = NO;
    
    self.angleX=0; self.angleY=0; self.angleZ=0;
    
    [self initializeRecordParameters];
    [self loadQueryUpdate];
}

- (void)initializeRecordParameters
{
    // ------ Read the contents of file from iCloud Drive on background thread so that main thread is not blocked -----------
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Record Parameters",@"Setting Folder"];
        NSURL *url = [self queryUbiquityFileURL:destDir fileName:@"status.txt"];
        APLDocument *document = [APLDocument alloc];
        
        if (url) {
            [document readFromURL:url error:nil];
        }

        NSString *contents = [[NSString alloc] initWithData:document.data encoding:NSUTF8StringEncoding];
        
        if ([contents isEqualToString:@""]) {
            
            self.userSamplingRate = 100.0;
            self.triggerThreshold = 5.0;
            self.bufferLength = 60.0;
            self.recordLength = 60.0;
            
        } else {
            
            self.arr = [contents componentsSeparatedByString:@";"];
            if (self.arr.count==9) {
                self.userSamplingRate = ([self.arr objectAtIndex:1] != nil)?[[self.arr objectAtIndex:1] floatValue]:100.0;
                self.triggerThreshold = ([self.arr objectAtIndex:3] != nil)?[[self.arr objectAtIndex:3] floatValue]:5.0;
                self.bufferLength = ([self.arr objectAtIndex:5] != nil)?[[self.arr objectAtIndex:5] floatValue]:60.0;
                self.recordLength = ([self.arr objectAtIndex:7] != nil)?[[self.arr objectAtIndex:7] floatValue]:60.0;
            }
        }
        
    });
}

- (void)setupMultisectorControl{
    self.multisectorControl.frame = CGRectMake(24, (self.view.frame.size.height-self.multisectorControl.frame.size.height)/2, self.view.frame.size.width*0.5, self.view.frame.size.width*0.5);
    [self.multisectorControl addTarget:self action:@selector(multisectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIColor *blueColor = RGB_Alpha(31, 183, 252, 1);
    
    APLSAMultisectorSector *sector1 = [APLSAMultisectorSector sectorWithColor:blueColor maxValue:16.0];
    
    sector1.tag = 0;
    sector1.endValue = 1.0;
    
    [self.multisectorControl addSector:sector1];
    
    [self updateDataView];
}

- (void)multisectorValueChanged:(id)sender{
    [self updateDataView];
}

- (void)updateDataView{
//    for(SAMultisectorSector *sector in self.multisectorControl.sectors){
//        NSString *startValue = [NSString stringWithFormat:@"%.0f", sector.startValue];
//        NSString *endValue = [NSString stringWithFormat:@"%.0f", sector.endValue];
//        if(sector.tag == 0){
//            self.waitStartLable.text = startValue;
//            self.waitEndLable.text = endValue;
//        }
//        if(sector.tag == 1){
//            self.distanceStartLable.text = startValue;
//            self.distanceEndLable.text = endValue;
//        }
//        if(sector.tag == 2){
//            self.priceStartLable.text = startValue;
//            self.priceEndLable.text = endValue;
//        }
//    }
}


-(IBAction)changeSwitch:(id)sender{
    
    if (self.mySwitch.on) {
        
        self.isRemoteFunctionOn = YES;
        
        self.bufferButton.hidden = YES;
        self.recordButton.hidden = YES;
        
        self.remoteStartStopButton.enabled = YES;
        self.forceRemoteStartStopButton.enabled = YES;
        
        self.serverCheckDate = [NSDate date];
        
        self.controlMode.text = NSLocalizedString(@"Group Control","");
        
        [self startQueryUpdate];
        
    } else {
        
        self.isRemoteFunctionOn = NO;
        
        self.bufferButton.hidden = NO;
        self.recordButton.hidden = NO;
        
        self.remoteStartStopButton.enabled=NO;
        self.forceRemoteStartStopButton.enabled=NO;
        
        self.controlMode.text = NSLocalizedString(@"Local Control","");
        
        [self stopQueryUpdate];
    }
}


-(IBAction)bufferButton:(UIButton *)sender
{
    [self initializeRecordParameters];
    
    // Force Stop Seismic Record By Button
    if (self.WeAreRecording) {
        self.isStopByButton = YES;
        self.recordButton.enabled=YES;
        self.halo.radius = 0;
        
    } else {
        
        if (self.InitialBuffer) {
            self.InitialBuffer=NO;
            self.recordButton.enabled=YES;
            self.bufferRecord=nil; self.seismicRecord=nil;
            [self.bufferButton setTitle:NSLocalizedString(@"Start Buffer","") forState:UIControlStateNormal];
            self.recordInfo.text = @"";
            self.remoteNotification = NO;
            self.halo.radius = 0;
            
        } else {
            self.InitialBuffer=YES;
            self.recordButton.enabled=NO;
            [self.bufferButton setTitle:NSLocalizedString(@"Stop Buffer","") forState:UIControlStateNormal];
            self.recordInfo.text = NSLocalizedString(@"Buffering","");
            self.startBufferDate = [NSDate date];
            
        }
    }
}


- (IBAction)recordButton:(UIButton *)sender {
    
    [self initializeRecordParameters];
    
    if (self.WeAreRecording){
        [self stopRecording];
        [self fileUploadToDeviceAndServer];
        self.halo.radius = 0;
    }else{
        [self startRecording];
        self.halo.radius = 60;
    }
}


- (IBAction)startRemoteStartStop:(UIButton *)sender {
    
        if (!self.remoteStartStop) {
            
            self.isWaitingForceTriggered = YES;
            self.isForceTriggered = NO;
            [self setRemoteStartNotification];
            
        } else if (self.remoteStartStop) {

            self.isWaitingForceTriggered = NO;
            [self setRemoteStopNotification];
            
            if (self.isForceTriggered) {
                self.WeAreRecording = NO;
                self.isForceTriggered = NO;
            }
        }
}


- (IBAction)forceStartStopRemotely:(UIButton *)sender {
    
    if (self.WeAreRecording){
        
        [self setForceRemoteStopNotification];
        
    } else {
        
        [self setForceRemoteStartNotification];
    }
}

#pragma mark - Prepare for observing changes in Dropbox folder

// -------------------------------- Prepare for Remote Notification by observing changes in iCloud Drive folder ----------------------------------

- (void)setForceRemoteStartNotification
{
    NSString *folderName1 = @"Supporting Files";
    NSString *folderName2 = @"Force Remote Start Info";
    
    NSDate *date = [NSDate date];
    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice] name],[self.dateFormatter stringFromDate:date].description,folderName2];
    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Start info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
    
    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
}

- (void)setForceRemoteStopNotification
{
    NSString *folderName1 = @"Supporting Files";
    NSString *folderName2 = @"Force Remote Stop Info";
    
    NSDate *date = [NSDate date];
    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Stopped info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
    
    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
}


- (void)setRemoteStartNotification
{
    NSString *folderName1 = @"Supporting Files";
    NSString *folderName2 = @"Remote Start Info";
    
    NSDate *date = [NSDate date];
    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Start info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];

    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
    
    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
}

- (void)setRemoteStopNotification
{
    NSString *folderName1 = @"Supporting Files";
    NSString *folderName2 = @"Remote Stop Info";
    
    NSDate *date = [NSDate date];
    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Stopped info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
    
    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
}

- (void)setTriggeredInfoNotification
{
    NSString *folderName1 = @"Supporting Files";
    NSString *folderName2 = @"Triggered Info";
    
    NSDate *date = [NSDate date];
    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
    NSString *messageString = [NSString stringWithFormat:@"Device Triggered info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
    
    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
}

- (void)startUpdatesWithSliderValue:(int)sliderValue
{
    float accelerometerMin;
    if (!self.userSamplingRate) {
        accelerometerMin = 0.01;
    } else {
        accelerometerMin = 1/self.userSamplingRate;
    }
    
    NSTimeInterval delta = 0.005;
    NSTimeInterval updateInterval = accelerometerMin + delta * sliderValue;

    self.notificationStartDate = [NSDate date];
    self.dBFileSystemReleaseDate = [NSDate date];
    CMMotionManager *mManager = [(APLAppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    
    
    if ([mManager isAccelerometerAvailable] == YES) {
        [mManager setAccelerometerUpdateInterval:updateInterval];
        [mManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
                    if ([mManager isDeviceMotionAvailable]) {
                        [mManager setDeviceMotionUpdateInterval:updateInterval];
                        [mManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
                 
                            self.angleX = motion.attitude.pitch*180/M_PI;
                            self.angleY = motion.attitude.roll*180/M_PI;
                            self.angleZ = motion.attitude.yaw*180/M_PI;
                    
                AccelerationRecords *acc = [[AccelerationRecords alloc] initWithDataX:accelerometerData.acceleration.x*1000 withY:accelerometerData.acceleration.y*1000 withZ:accelerometerData.acceleration.z*1000 withThetaX:self.angleX withThetaY:self.angleY withThetaZ:self.angleZ];
                    
            
         // constantly notify server about state of app
            [self notifyServerAboutStateOfApp];
                    
 
#pragma mark - Prepare for Remote Notifications
            
            if (self.isRemoteFunctionOn) {
//                NSTimeInterval serverCheckTimeElapsed = fabs([self.serverCheckDate timeIntervalSinceNow]);
//                if (serverCheckTimeElapsed>1.0) {
//                    [self checkIfRemoteStarted];
////                    [self unRegisterAllDBFileSystemForMemoryRelease];
//                
//                    self.serverCheckDate = [NSDate date];
//                    
//                    // Update Record Parameters if any Changes are there
//                    [self initializeRecordParameters];
//                    
//                }

            }

#pragma mark - Initial Buffer
            
            if (self.InitialBuffer || self.remoteBuffer) {
                
                if (!self.bufferRecord) {
                    self.bufferRecord = [[BufferRecords alloc] initWithData:acc];
                    [self.bufferRecord checkTriggerValue:acc WithRemoteSyncStatus:self.isRemoteFunctionOn WithTriggerThreshold:self.triggerThreshold];
                } else {
                    [self.bufferRecord addAcceleros:acc];
                    [self.bufferRecord checkTriggerValue:acc WithRemoteSyncStatus:self.isRemoteFunctionOn WithTriggerThreshold:self.triggerThreshold];
                }
                
                self.endBufferDate = [NSDate date];
                [self.bufferRecord checkBufferTimeWithStartTime:self.startBufferDate WithEndTime:self.endBufferDate WithAccelerationRecords:acc WithBufferLength:self.bufferLength];
                
                if (self.bufferRecord.bufferTimeLimitExceeded) {
                    self.recordedBufferDate = [NSDate date];
                }
            }
            
 
#pragma mark - Triggered/Not Triggered
            
            if (self.bufferButton.isEnabled == YES) {
                if (self.bufferRecord.AreWeTriggered || self.seismicRecord.AreWeTriggered || self.remoteNotification)
                {
                    self.bufferRecord.AreWeTriggered = NO;
//                    self.remoteNotification = NO;
                    self.InitialBuffer = NO;
                    self.remoteBuffer = NO;
                    self.WeAreRecording = YES;
                    self.startRecordDate = [NSDate date];
                    [self.seismicRecord checkEventOfRecordingForAllActiveDevices:[NSDate date]];
                    [self.bufferButton setTitle:NSLocalizedString(@"Stop Record","") forState:UIControlStateNormal];
                    self.halo.radius = 60;
                    
                    if (self.isRemoteFunctionOn && self.isWaitingForceTriggered) {
                        self.isWaitingForceTriggered = NO;
                        self.isForceTriggered = YES;
                        [self setTriggeredInfoNotification];
                    }
                }
            }
            
            
#pragma mark - Record Datas
            
            if (self.WeAreRecording) {
                
                self.recordInfo.text = NSLocalizedString(@"Recording","");
                
                if (filename == nil) {
                    filename = [NSString stringWithFormat:@"%@.txt", [self.dateFormatter stringFromDate:self.startRecordDate].description];
                    
                    NSString *startedRecord = NSLocalizedString(@"Started Recording at:",@"");
                    self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", startedRecord, [self.dateFormatter stringFromDate:self.startRecordDate].description];
                }
        
                if (!self.seismicRecord) {
                    self.seismicRecord = [[SeismicRecords alloc] initWithData:acc];
                    [self.seismicRecord checkTriggerValue:acc WithRemoteSyncStatus:self.isRemoteFunctionOn WithTriggerThreshold:self.triggerThreshold];
                } else {
                    [self.seismicRecord addAcceleros:acc];
                    [self.seismicRecord checkTriggerValue:acc WithRemoteSyncStatus:self.isRemoteFunctionOn WithTriggerThreshold:self.triggerThreshold];
                }
                self.endRecordDate = [NSDate date];
                
                if (self.bufferButton.isEnabled==YES) {
                    [self.seismicRecord checkRecordTimeWithStartTime:self.startRecordDate WithEndTime:self.endRecordDate WithRecordTime:self.recordLength];
                }
                

#pragma mark - Check for Record Time to stop/Continue Record
                
                [self calculateTimeOfRecord];
                if (self.seismicRecord.recordingStopped || self.timeOfRecord>300) {
                    
                    [self stopRecording];
                    [self fileUploadToDeviceAndServer];
                    
                    if (self.recordButton.isEnabled==YES && self.WeAreRecording==NO) {
                        // Only for manual mode of recording
                        [self startRecording];          // Continue recording unless user force stop by pressing button
                    }
                    
                } else if (!self.seismicRecord.recordingStopped) {
                 // continue Recording
                    self.WeAreRecording = YES;
                    self.InitialBuffer = NO;
                }
                
                // Force Stop Seismic Record By Button
                if (self.isStopByButton) {
                    [self stopRecording];
                    [self fileUploadToDeviceAndServer];
                    self.isStopByButton = NO;
                    self.InitialBuffer = NO;
                    [self.bufferButton setTitle:NSLocalizedString(@"Start Buffer","") forState:UIControlStateNormal];
                    self.recordInfo.text = @"";
                    self.bufferRecord = nil; self.seismicRecord = nil;
                    }
                }
            }];
        }
        }];
    }
    
    self.updateIntervalLabel.text = [NSString stringWithFormat:@"%.3f", updateInterval];
    self.recordInfo.text = @"";
}

#pragma mark - Notify about state of App

// ----------------------------------- Get Status Info: running status, battery status, memory consumption status --------------------
         
- (void)notifyServerAboutStateOfApp {
   
    NSTimeInterval nowTimeElapsed = fabs([self.notificationStartDate timeIntervalSinceNow]);
    if (nowTimeElapsed>1800) {
        
        // Memory Usage Info
        struct task_basic_info info;
        mach_msg_type_number_t size = sizeof(info);
        kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
        if( kerr == KERN_SUCCESS ) {
            // Do Nothing
        } else {
            // Do Nothing
        }
        
        NSDate *date = [NSDate date];
        NSString *statusFilename = [NSString stringWithFormat:@"%@.txt",[self.dateFormatter stringFromDate:date].description];
        NSString *deviceName = [[UIDevice currentDevice]name];
        NSString *folder = [NSString stringWithFormat:@"/%@/%@",@"Status Info",deviceName];
        
        
        // Check Battery level
        UIDevice *myDevice = [UIDevice currentDevice];
        [myDevice setBatteryMonitoringEnabled:YES];
        float batteryLevel = [myDevice batteryLevel];
        
        NSString *messageString = [NSString stringWithFormat:@"Motion Graphs Application is currently running on device \n Memory in use (in MB): %u \n Battery Level: %f",info.resident_size/(1024*1024), batteryLevel*100];
        
        NSString *destDir = [NSString stringWithFormat:@"/%@",folder];

//        APLCloudFile *file =
        [self saveToiCloud:destDir fileName:statusFilename filePath:nil fileContent:messageString];
        
//        DBFile *file = [[DBFilesystem sharedFilesystem]createFile:newPath error:nil];
//        [file writeString:messageString error:nil];
        
        // Reset the notification start time
        self.notificationStartDate = [NSDate date];
    }
}

// -------------------------------------------------------------------------------------------------------------------------------

- (void)unRegisterAllDBFileSystemForMemoryRelease
{
    // iCloud未替换
    
//    NSTimeInterval nowTimeElapsed = fabs([self.dBFileSystemReleaseDate timeIntervalSinceNow]);
//    if (nowTimeElapsed>10) {
//    [[DBFilesystem sharedFilesystem]removeObserver:self];
//        
//        // Reset Release Check Date
//        self.dBFileSystemReleaseDate = [NSDate date];
//    }
}


- (void)startRecording
{
    self.WeAreRecording = YES;
    self.startRecordDate = [NSDate date];
    self.bufferButton.enabled = NO;
    [self.recordButton setTitle:NSLocalizedString(@"Stop Record","") forState:UIControlStateNormal];
}
         
         
- (void)stopRecording
{
    self.WeAreRecording = NO;
    self.remoteNotification = NO;
    
    if (self.bufferButton.isEnabled) {

        // Reset start buffer date for new buffer
        self.startBufferDate = [NSDate date];
        self.InitialBuffer = YES;
        [self.bufferButton setTitle:NSLocalizedString(@"Stop Buffer","") forState:UIControlStateNormal];
        self.recordInfo.text = NSLocalizedString(@"Buffering","");
        
    } else {
        
        self.bufferButton.enabled = YES;
        self.InitialBuffer = NO;
        self.recordInfo.text = @"";
        [self.bufferButton setTitle:NSLocalizedString(@"Start Buffer","") forState:UIControlStateNormal];
        [self.recordButton setTitle:NSLocalizedString(@"Start Record","") forState:UIControlStateNormal];
    }
    
    NSString *stoppedRecord = NSLocalizedString(@"Stopped Recording at:",@"");
    self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", stoppedRecord, [self.dateFormatter stringFromDate:self.endRecordDate].description];
//    NSLog(@"Stopped Recording");

    if (!self.bufferRecord.bufferStringArray) {
        self.bufferRecord.bufferStringArray = [[NSMutableArray alloc] initWithObjects:self.bufferRecord, nil];
    } else {
        [self.bufferRecord.bufferStringArray addObject:self.bufferRecord];
    }
    
    if (!self.seismicRecord.seismicStringArray) {
        self.seismicRecord.seismicStringArray = [[NSMutableArray alloc] initWithObjects:self.seismicRecord,nil];
    } else {
        [self.seismicRecord.seismicStringArray addObject:self.seismicRecord];
    }
    
}

- (void)calculateTimeOfRecord
{
    if (self.bufferButton.isEnabled) {
        // Total time of Record
        if (self.bufferRecord.bufferTimeLimitExceeded == YES) {
            if (!self.bufferLength) {
                self.bufferLength = self.bufferRecord.bufferLength;
            }
            self.timeOfRecord = [self.endRecordDate timeIntervalSinceDate:self.recordedBufferDate] + self.bufferLength;
        } else {
            self.timeOfRecord = [self.endRecordDate timeIntervalSinceDate:self.startBufferDate];
        }
        
    } else {
        self.timeOfRecord = [self.endRecordDate timeIntervalSinceDate:self.startRecordDate];
    }
    
    //NSLog(@"time of record %f",self.timeOfRecord);
}


- (void)fileUploadToDeviceAndServer
{
    dataString = [NSMutableString string];
    
    for (NSString *bufferRecordData in self.bufferRecord.bufferStringArray) {
        [dataString appendString:[NSString stringWithFormat:@"%@",bufferRecordData]];
    }
    for (NSString *seismicRecordData in self.seismicRecord.seismicStringArray) {
        [dataString appendString:[NSString stringWithFormat:@"%@",seismicRecordData]];
    }
    
    [self.asdvc separateAccAndGyroRecords];
    [self.asdvc performFFTAnalysis];
    [self.asdvc emptyRecordArrays];
    
    [dataString appendString:[NSString stringWithFormat:@"\n Summary of Record\n"]];
    [dataString appendString:[NSString stringWithFormat:@"\n\u2022 Recorded Device:%@ ",[[UIDevice currentDevice]name]]];
    [dataString appendString:[NSString stringWithFormat:@"\n\u2022 Recorded Date/Time:%@ ",[self.filename substringWithRange:NSMakeRange(0, 23)]]];
    [dataString appendString:[NSString stringWithFormat:@"\n\u2022 Recorded Period:%f secs",self.timeOfRecord]];
    [dataString appendString:[NSString stringWithFormat:@"\n\u2022 PGA Value:%f Gal",self.seismicRecord.maxPGA]];
    
    for (NSString *locationData in self.seismicRecord.locationArray) {
        [dataString appendString:[NSString stringWithFormat:@"%@",locationData]];
    }

    [dataString appendString:[NSString stringWithFormat:@" \n\u2022 Record Parameters:\n userSamplingRate: %f Hz \n triggerThreshold: %f Gal \n bufferLength: %f  secs\n recordLength: %f secs",self.userSamplingRate,self.triggerThreshold,self.bufferLength,self.recordLength]];
    [dataString appendString:[NSString stringWithFormat:@"\n\n\u2022 Actual Sampling Rate; %f",(self.seismicRecord.acceleros.count+self.bufferRecord.acceleros.count)/self.timeOfRecord]];
    
    
    // ------------------- Creating Date wise subfolders for data management -----------------------------
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSInteger yearFromRecord = [[self.filename substringWithRange:NSMakeRange(0, 4)] integerValue];
    NSInteger monthFromRecord = [[self.filename substringWithRange:NSMakeRange(5, 7)] integerValue];
    NSInteger dayFromRecord = [[self.filename substringWithRange:NSMakeRange(8, 10)] integerValue];
    
    if (!(self.year == yearFromRecord)) {
        self.year = yearFromRecord;
        yearFolder = [NSString stringWithFormat:@"/%@/%@", deviceName, [self.filename substringWithRange:NSMakeRange(0, 4)]];
    }
    
    if (!(self.month == monthFromRecord)) {
        self.month = monthFromRecord;
        monthFolder = [NSString stringWithFormat:@"%@/%@", yearFolder, [self.filename substringWithRange:NSMakeRange(0, 7)]];
    }
    
    if (!(self.day == dayFromRecord)) {
        
//        if (self.uploadSummary == YES) {
//            
//            NSString *destDirSummary = [NSString stringWithFormat:@"/%@/%@",@"Recorded Data",dayFolder];
//            NSString *fileNameTmp = @"summary.txt";
//            
//            [self saveToiCloud:destDirSummary fileName:fileNameTmp filePath:nil fileContent:self.recordSummary];
//        }
        
        self.day = dayFromRecord;
        dayFolder = [NSString stringWithFormat:@"%@/%@",monthFolder,[self.filename substringWithRange:NSMakeRange(0, 10)]];
        self.isInTheSameDayFolder = NO;
        self.uploadSummary = NO;
        
    } else {
        self.isInTheSameDayFolder = YES;
    }
    
    // ---------------------------------------------------------------------------------------------------
    
    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Recorded Data",dayFolder];
    [self saveToiCloud:destDir fileName:filename filePath:nil fileContent:dataString];
    
    // write to local app sandbox (only if triggered)
    if (self.seismicRecord.maxPGA>self.triggerThreshold) {
        NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *localPath = [localDir stringByAppendingPathComponent:filename];
        NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Triggered Data",dayFolder];
        [self saveToiCloud:destDir fileName:filename filePath:localPath fileContent:dataString];
    }
    
    // ------------------------------------------------------------------------------------------------------
    
    // Create a summary file
    
    if (!self.isInTheSameDayFolder) {
        
        self.recordSummary = @"";
        self.recordSummary = [self.recordSummary stringByAppendingString:@"Summary of Record\n"];
        self.recordSummary = [self.recordSummary stringByAppendingString:@"Date/Time                         max PGA      SR          Dom Fx       Dom Fy      Dom Fz       AMPx       AMPy       AMPz \n\n"];
        self.uploadSummary = YES;
    }
    
    self.recordSummary = [self.recordSummary stringByAppendingString:[NSString stringWithFormat:@"%@; %15.3f; %10.3f; %10.3f; %10.3f; %10.3f; %10.3f; %10.3f; %10.3f \n", [self.dateFormatter stringFromDate:[NSDate date]], self.seismicRecord.maxPGA, (self.seismicRecord.acceleros.count+self.bufferRecord.acceleros.count)/self.timeOfRecord, self.asdvc.dominantFrequencyX, self.asdvc.dominantFrequencyY, self.asdvc.dominantFrequencyZ, self.asdvc.FFTXmax, self.asdvc.FFTYmax, self.asdvc.FFTZmax]];
    
    // Now empty the buffer and acceleration records
    self.seismicRecord=nil; self.seismicRecord.seismicStringArray=nil;
    self.bufferRecord=nil; self.bufferRecord.bufferStringArray=nil;
    
    // Empty the string filename so that a new recording could be allocated
    filename=nil;
    
}

// --------------------------------------- Observe for changes in iCloud Drive Folder for remote notification ---------------------------------

-(void)checkIfRemoteStarted
{
    
    // iCLoud未替换
    
//    NSString *destDirStart = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Remote Start Info"];
//    DBPath *newPathStart = [[DBPath root]childPath:destDirStart];
//    
//    __unsafe_unretained typeof(self) weakSelf = self;
//    
//    // Check these lines of code on Background thread so that Main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[DBFilesystem sharedFilesystem] addObserver:weakSelf forPathAndChildren:newPathStart block:^() {
//            dispatch_async(dispatch_get_main_queue(), ^{
//            
//                    weakSelf.forceStartStopTrigger = YES;
//                
//                    if (!weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
//                            weakSelf.forceStartStopTrigger=NO;
//                            weakSelf.remoteStartStop = YES;
//                            weakSelf.remoteBuffer = YES;
//                            [weakSelf.bufferButton setTitle:@"Stop Buffer" forState:UIControlStateNormal];
//                            [weakSelf.remoteStartStopButton setTitle:@"Remote Stop" forState:UIControlStateNormal];
//                            weakSelf.recordInfo.text = @"Buffering";
//                            weakSelf.startBufferDate = [NSDate date];
//                            weakSelf.recordButton.enabled=NO;
//                        }
//            });
//        }];
//    });
//    
//    
//    NSString *destDirStop = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Remote Stop Info"];
//    DBPath *newPathStop = [[DBPath root]childPath:destDirStop];
//    
//    
//    // Check these lines of code on Background thread so that Main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[DBFilesystem sharedFilesystem] addObserver:weakSelf forPathAndChildren:newPathStop block:^() {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                weakSelf.forceStartStopTrigger = YES;
//                
//                if (weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
//                    weakSelf.forceStartStopTrigger=NO;
//                    weakSelf.remoteStartStop=NO;
//                    
//                    if (weakSelf.WeAreRecording) {
//                        [weakSelf stopRecording];
//                        [weakSelf fileUploadToDeviceAndServer];
//                    }
//                    
//                    weakSelf.remoteBuffer = NO;
//                    weakSelf.WeAreRecording=NO;
//                    weakSelf.InitialBuffer=NO;
//                    [weakSelf.bufferButton setTitle:@"Start Buffer" forState:UIControlStateNormal];
//                    [weakSelf.remoteStartStopButton setTitle:@"Remote Start" forState:UIControlStateNormal];
//                    weakSelf.recordInfo.text = @"Sampling";
//                    weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
//                    weakSelf.recordButton.enabled=YES;
//                }
//            });
//        }];
//    });
//    
//    
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Triggered Info"];
//    DBPath *newPath = [[DBPath root]childPath:destDir];
//    
//    // Check these lines of code on Background thread so that Main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[DBFilesystem sharedFilesystem] addObserver:weakSelf forPathAndChildren:newPath block:^() {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if (!weakSelf.recordButton.enabled) {
//                    weakSelf.remoteNotification = YES;
//                }
//            });
//        }];
//    });
//    
//    
//    NSString *destDirForceRemoteStart = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Force Remote Start Info"];
//    DBPath *newPathForceRemoteStart = [[DBPath root]childPath:destDirForceRemoteStart];
//    
//    // Check these lines of code on Background thread so that Main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[DBFilesystem sharedFilesystem] addObserver:weakSelf forPathAndChildren:newPathForceRemoteStart block:^() {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                weakSelf.forceStartStopTrigger = YES;
//                
//                if (!weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
//                    weakSelf.forceStartStopTrigger=NO;
//                    weakSelf.remoteStartStop = YES;
//                    [weakSelf startRecording];
//                    [weakSelf.forceRemoteStartStopButton setTitle:@"Force Remote Stop" forState:UIControlStateNormal];
//                }
//                
//            });
//        }];
//    });
//    
//    NSString *destDirForceRemoteStop = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Force Remote Stop Info"];
//    DBPath *newPathForceRemoteStop = [[DBPath root]childPath:destDirForceRemoteStop];
//    
//    
//    // Check these lines of code on Background thread so that Main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [[DBFilesystem sharedFilesystem] addObserver:weakSelf forPathAndChildren:newPathForceRemoteStop block:^() {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                weakSelf.forceStartStopTrigger = YES;
//                
//                if (weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
//                    weakSelf.forceStartStopTrigger=NO;
//                    weakSelf.remoteStartStop=NO;
//                    
//                    if (weakSelf.WeAreRecording) {
//                        [weakSelf stopRecording];
//                        [weakSelf fileUploadToDeviceAndServer];
//                    }
//                    
//                    weakSelf.remoteBuffer = NO;
//                    weakSelf.WeAreRecording=NO;
//                    weakSelf.InitialBuffer=NO;
//                    [weakSelf.bufferButton setTitle:@"Start Buffer" forState:UIControlStateNormal];
//                    [weakSelf.forceRemoteStartStopButton setTitle:@"Force Remote Start" forState:UIControlStateNormal];
//                    weakSelf.recordInfo.text = @"Sampling";
//                    weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
//                    weakSelf.recordButton.enabled=YES;
//                }
//            
//            });
//        }];
//    });
    
    
   // [[DBFilesystem sharedFilesystem]removeObserver:self];
}

// --------------------------------------------------------------------------------------------------------------------------------


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"appsandboxtableview"]) {
        if ([segue.destinationViewController isKindOfClass:[AppSandboxViewController class]]) {
//            NSLog(@"Linked To AppSandboxTable View");
        }
    }
}


- (void)updateMeters
{
    if (self.WeAreRecording==NO) {
        CGFloat normalizedValue = 0.0;
        [self.waveformView updateWithLevel:normalizedValue];
    } else {
        CGFloat normalizedValue = sqrt(pow(self.angleX/180*M_PI, 2)+pow(self.angleY/180*M_PI, 2)+pow(self.angleZ/180*M_PI, 2))*0.2+0.8;
        [self.waveformView updateWithLevel:normalizedValue];
    }

    
    // 计算差值失败，以后再研究
//    self.lastNormalizedValue = normalizedValue;
}


#pragma mark - iCloud Drive

/*
 取得云端存储文件的地址
 destinationDiractory 目标文件夹，如果云端不存在，则创建一个文件夹
 return 地址
 */

- (NSURL *)getUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName {

    //取得Documents目录
    _destinationUrl = [_rootUrl URLByAppendingPathComponent:@"Documents"];
    _destinationUrl = [_destinationUrl URLByAppendingPathComponent:destinationDiractory];

    if (_destinationUrl) {
        if ([_manager fileExistsAtPath:[_destinationUrl path]] == NO)
        {
//            NSLog(@"iCloud Documents directory does not exist");
            //创建M路径
            [_manager createDirectoryAtURL:_destinationUrl withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
//            NSLog(@"iCloud Documents directory exist");
        }
    }
    
    //取得最终地址
    _destinationUrl = [_destinationUrl URLByAppendingPathComponent:fileName];
    
    return _destinationUrl;
}


- (void)saveToiCloud:(NSString *)destinationDiractory fileName:(NSString *)fileName filePath:(NSString *)filePath fileContent:(NSString *)fileContent
{
    NSString *fileUrl = [NSString stringWithFormat:@"%@",fileName];
    NSURL *url = [self getUbiquityFileURL:destinationDiractory fileName:fileUrl];
//    NSString *fileNameString = fileName;
    
    if (url) {
        
        _document = [[APLDocument alloc] initWithFileURL:url];
        _document.data = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!filePath) {
            
        }
        
        [_document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
//                NSLog(@"创建文档成功.");
                _document.data = nil;
            } else {
//                NSLog(@"创建文档失败.");
                // write to local app sandbox (only if triggered)
                if (self.seismicRecord.maxPGA>self.triggerThreshold) {
                    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
                    [fileContent writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
            }
        }];
    }
}


- (NSURL *)queryUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName {
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL];
    //取得Documents目录
    url = [url URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:destinationDiractory];
    
    if ([manager fileExistsAtPath:[url path]] == NO)
    {
//        NSLog(@"iCloud Documents directory does not exist？");
    } else {
//        NSLog(@"iCloud Documents directory exist？");
    }
    
    //取得最终地址
    url = [url URLByAppendingPathComponent:fileName];
    
    return url;
}

//从iCloud上加载所有文档信息
- (void)loadQueryUpdate
{
    // Remote Start Info
    self.remoteStartQuery = [[NSMetadataQuery alloc] init];
    [self.remoteStartQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSString *remoteStartFilePattern = [NSString stringWithFormat:@"*[Remote Start Info].txt"];
    [self.remoteStartQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                                         NSMetadataItemFSNameKey, remoteStartFilePattern]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteStartInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.remoteStartQuery];
    
    
    // Remote Stop Info
    self.remoteStopQuery = [[NSMetadataQuery alloc] init];
    [self.remoteStopQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSString *remoteStopFilePattern = [NSString stringWithFormat:@"*[Remote Stop Info].txt"];
    [self.remoteStopQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                                         NSMetadataItemFSNameKey, remoteStopFilePattern]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteStopInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.remoteStopQuery];
    
    
    // Force Remote Start Info
    self.forceRemoteStartQuery = [[NSMetadataQuery alloc] init];
    [self.forceRemoteStartQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSString *forceRemoteStartFilePattern = [NSString stringWithFormat:@"*[Force Remote Start Info].txt"];
    [self.forceRemoteStartQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                                        NSMetadataItemFSNameKey, forceRemoteStartFilePattern]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRemoteStartInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.forceRemoteStartQuery];
    
    
    // Force Remote Stop Info
    self.forceRemoteStopQuery = [[NSMetadataQuery alloc] init];
    [self.forceRemoteStopQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSString *forceRemoteStopFilePattern = [NSString stringWithFormat:@"*[Force Remote Stop Info].txt"];
    [self.forceRemoteStopQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                                              NSMetadataItemFSNameKey, forceRemoteStopFilePattern]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRemoteStopInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.forceRemoteStopQuery];
    
    // Triggered Info
    self.triggeredInfoQuery = [[NSMetadataQuery alloc] init];
    [self.triggeredInfoQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSString *triggeredInfoFilePattern = [NSString stringWithFormat:@"*[Triggered Info].txt"];
    [self.triggeredInfoQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
                                             NSMetadataItemFSNameKey, triggeredInfoFilePattern]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggeredInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.triggeredInfoQuery];
}

// 查询更新
- (void)remoteStartInfoDidUpdate:(NSNotification *)notification
{
    [self.remoteStartQuery stopQuery];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    weakSelf.forceStartStopTrigger = YES;
    
    if (!weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
        weakSelf.forceStartStopTrigger=NO;
        weakSelf.remoteStartStop = YES;
        weakSelf.remoteBuffer = YES;
//        [weakSelf.bufferButton setTitle:NSLocalizedString(@"Stop Record","") forState:UIControlStateNormal];
        [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Stop Buffer","") forState:UIControlStateNormal];
        weakSelf.recordInfo.text = NSLocalizedString(@"Buffering","");
        weakSelf.startBufferDate = [NSDate date];
//        weakSelf.recordButton.enabled=NO;
        
        self.halo.radius = 60;
        
//        [self.triggeredInfoQuery startQuery];
    }
    
//    NSLog(@"我是remoteStartInfoDidUpdate");
}

- (void)remoteStopInfoDidUpdate:(NSNotification *)notification
{
    [self.remoteStartQuery startQuery];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    weakSelf.forceStartStopTrigger = YES;
    
    if (weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
        weakSelf.forceStartStopTrigger=NO;
        weakSelf.remoteStartStop=NO;
        
        weakSelf.recordInfo.text = @"";
        self.halo.radius = 0;
        
        weakSelf.remoteBuffer = NO;
        weakSelf.WeAreRecording = NO;
        weakSelf.InitialBuffer = NO;
        //        [weakSelf.bufferButton setTitle:NSLocalizedString(@"Start Buffer","") forState:UIControlStateNormal];
        [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Remote Buffer","") forState:UIControlStateNormal];
        weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
        //            weakSelf.recordButton.enabled=YES;
        self.statusOfRecord.text = NSLocalizedString(@"Status Of Record",@"");
        
        if (self.isForceTriggered) {
            self.WeAreRecording = NO;
            self.isForceTriggered = NO;
            
            NSString *stoppedRecord = NSLocalizedString(@"Stopped Recording at:",@"");
            self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", stoppedRecord, [self.dateFormatter stringFromDate:self.endRecordDate].description];
//            NSLog(@"Stopped Recording");
        }
        
        if (weakSelf.WeAreRecording) {
            [weakSelf stopRecording];
            [weakSelf fileUploadToDeviceAndServer];
        }

    }
    
    self.forceRemoteStartStopButton.userInteractionEnabled = YES;
    self.forceRemoteStartStopButton.backgroundColor = RGB_Alpha(31, 183, 252, 1);
    [self.forceRemoteStartStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
//    NSLog(@"我是remoteStopInfoDidUpdate");
}

- (void)forceRemoteStartInfoDidUpdate:(NSNotification *)notification
{
    [self.forceRemoteStartQuery stopQuery];
    
    self.remoteStartStopButton.userInteractionEnabled = NO;
    self.remoteStartStopButton.backgroundColor = [UIColor darkGrayColor];
    [self.remoteStartStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    weakSelf.forceStartStopTrigger = YES;
    
    // 目前判断远程记录的条件有weakSelf.remoteStartStop，但是weakSelf.remoteStartStop只在预警开始时候被设定为YES，预警结束则设定为NO，所以造成了预警开始后，无法人为的操作远程记录。
//    if (!weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
    if (weakSelf.forceStartStopTrigger) {
        weakSelf.forceStartStopTrigger = NO;
        weakSelf.remoteStartStop = YES;
        [weakSelf startRecording];
        [weakSelf.forceRemoteStartStopButton setTitle:NSLocalizedString(@"Stop Record","") forState:
         UIControlStateNormal];
        weakSelf.recordInfo.text = NSLocalizedString(@"Recording","");
        
        self.halo.radius = 60;
    }
    
//    NSLog(@"我是forceRemoteStartInfoDidUpdate");
}

- (void)forceRemoteStopInfoDidUpdate:(NSNotification *)notification
{
    [self.forceRemoteStartQuery startQuery];
    [self.remoteStartQuery startQuery];
    
    self.remoteStartStopButton.userInteractionEnabled = YES;
    self.remoteStartStopButton.backgroundColor = RGB_Alpha(31, 183, 252, 1);
    [self.remoteStartStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    weakSelf.forceStartStopTrigger = YES;
    
    if (weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
        weakSelf.forceStartStopTrigger=NO;
        weakSelf.remoteStartStop=NO;
        
        if (weakSelf.WeAreRecording) {
            [weakSelf stopRecording];
            [weakSelf fileUploadToDeviceAndServer];
        }
        
        weakSelf.remoteBuffer = NO;
        weakSelf.WeAreRecording = NO;
        weakSelf.InitialBuffer = NO;
//        [weakSelf.bufferButton setTitle:NSLocalizedString(@"Start Buffer","") forState:UIControlStateNormal];
        [weakSelf.forceRemoteStartStopButton setTitle:NSLocalizedString(@"Remote Record","") forState:UIControlStateNormal];
        weakSelf.recordInfo.text = @"";
        weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
//        weakSelf.recordButton.enabled=YES;
        self.statusOfRecord.text = NSLocalizedString(@"Status Of Record",@"");
        
        self.halo.radius = 0;

        [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Remote Buffer","") forState:UIControlStateNormal];
        
        if (self.isForceTriggered) {
            self.WeAreRecording = NO;
            self.isForceTriggered = NO;
            
            NSString *stoppedRecord = NSLocalizedString(@"Stopped Recording at:",@"");
            self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", stoppedRecord, [self.dateFormatter stringFromDate:self.endRecordDate].description];
//            NSLog(@"Stopped Recording");
        }
    }

//    NSLog(@"我是forceRemoteStopInfoDidUpdate");
}

- (void)triggeredInfoDidUpdate:(NSNotification *)notification
{
//    [self.triggeredInfoQuery stopQuery];
    
//    __unsafe_unretained typeof(self) weakSelf = self;
    
//    if (!weakSelf.recordButton.enabled) {
        self.WeAreRecording = YES;
        self.isForceTriggered = YES;
        self.startRecordDate = [NSDate date];
        [self.seismicRecord checkEventOfRecordingForAllActiveDevices:[NSDate date]];
        [self.bufferButton setTitle:NSLocalizedString(@"Stop Record","") forState:UIControlStateNormal];
        self.recordInfo.text = NSLocalizedString(@"Recording","");
        
        self.halo.radius = 60;
//    }
    
    self.forceRemoteStartStopButton.userInteractionEnabled = NO;
    self.forceRemoteStartStopButton.backgroundColor = [UIColor darkGrayColor];
    [self.forceRemoteStartStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
//    NSLog(@"我是triggeredInfoDidUpdate");
}


- (void)startQueryUpdate
{
    [self.remoteStartQuery startQuery];
    [self.remoteStopQuery startQuery];
    [self.forceRemoteStartQuery startQuery];
    [self.forceRemoteStopQuery startQuery];
    [self.triggeredInfoQuery startQuery];
}


- (void)stopQueryUpdate
{
    [self.remoteStartQuery stopQuery];
    [self.remoteStopQuery stopQuery];
    [self.forceRemoteStartQuery stopQuery];
    [self.forceRemoteStopQuery stopQuery];
    [self.triggeredInfoQuery stopQuery];
}

    // ---------------------------------------------------------------------------------------

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
