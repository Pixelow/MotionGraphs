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
#import "AVObject.h"
#import <AVOSCloudLiveQuery/AVOSCloudLiveQuery.h>
#import "AVQuery.h"
#import "sys/utsname.h"

#define UBIQUITY_CONTAINER_URL @"iCloud.com.saitama.MotionGraphs"

#define GROUPCONTROL_CLASSNAME @"SeismologicalBureau_GroupControl"
#define FORCEREMOTESTART_CLASSNAME @"SeismologicalBureau_ForceRemoteStart"
#define FORCEREMOTESTOP_CLASSNAME @"SeismologicalBureau_ForceRemoteStop"
#define REMOTESTART_CLASSNAME @"SeismologicalBureau_RemoteStart"
#define REMOTESTOP_CLASSNAME @"SeismologicalBureau_RemoteStop"
#define TRIGGERED_CLASSNAME @"SeismologicalBureau_Triggered"

#define RGB_Alpha(r, g, b, alp) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: alp]
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: 1]

@interface APLAccelerometerGraphViewController03 () <UITableViewDelegate, UITableViewDataSource,AVLiveQueryDelegate>

@property (strong,nonatomic) BufferRecords *bufferRecord;
@property (strong,nonatomic) SeismicRecords *seismicRecord;
//@property (strong,nonatomic) AccelerationRecords *accelerationRecord;
@property (strong,nonatomic) AppSandboxDetailViewController *asdvc;
@property BOOL InitialBuffer, WeAreRecording, remoteNotification, isRemoteFunctionOn, isStopByButton, remoteStartStop, remoteBuffer, forceStartStopTrigger, isInTheSameDayFolder, uploadSummary, isWaitingForceTriggered, isForceTriggered;

@property (weak, nonatomic) IBOutlet UIView *whiteView;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *blueIIView;
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
@property (strong, nonatomic) AVLiveQuery *remoteStartQuery;
@property (strong, nonatomic) AVLiveQuery *remoteStopQuery;
@property (strong, nonatomic) AVLiveQuery *forceRemoteStartQuery;
@property (strong, nonatomic) AVLiveQuery *forceRemoteStopQuery;
@property (strong, nonatomic) AVLiveQuery *triggeredInfoQuery;

@property (strong, nonatomic) AVLiveQuery *doingLiveQuery;
@property (strong, nonatomic) NSMutableArray *blueIIArray;
@property (strong, nonatomic) NSString *objectId;

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
    
    //滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.336, self.view.frame.size.width, self.view.frame.size.height*0.2)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = FALSE;
    self.scrollView.showsHorizontalScrollIndicator = FALSE;
    [self.view addSubview:self.scrollView];
    
    self.blueView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.2);
    self.remoteSync.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.07);
    self.remoteNote.frame = CGRectMake(0, self.view.frame.size.height*0.054, self.view.frame.size.width, self.view.frame.size.height*0.06);
    self.mySwitch.frame = CGRectMake((self.view.frame.size.width-self.mySwitch.frame.size.width)/2.0, self.view.frame.size.height*0.124, self.view.frame.size.width, self.view.frame.size.height*0.06);
    
    self.blueIIView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.frame.size.width, self.view.frame.size.height*0.2)];
    self.blueIIView.delegate = self;
    self.blueIIView.dataSource = self;
    self.blueIIView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.scrollView addSubview:self.blueView];
    [self.scrollView addSubview:self.blueIIView];
    
    CGRect contentRect = CGRectMake(0, self.view.frame.size.height*0.336, self.view.frame.size.width*2.0, self.view.frame.size.height*0.2);
    self.scrollView.contentSize = contentRect.size;
    //
    
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
    
//    [self loadQueryUpdate];
    [self initLiveQueryList];
    [self updateTableView];
}

- (void)initLiveQueryList {
    //liveQuery
    NSString *deviceName = [UIDevice currentDevice].name;
    NSString *deviceType = [self getDeviceName];
    NSString *device = [NSString stringWithFormat:@"%@'s %@", deviceName, deviceType];
    
    AVQuery *doingQuery = [AVQuery queryWithClassName:GROUPCONTROL_CLASSNAME];
    [doingQuery whereKey:@"device" equalTo:device];
    [doingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        /* Doing list did fetch. */
        if (![objects count]) {
            AVObject *groupControl = [AVObject objectWithClassName:GROUPCONTROL_CLASSNAME];
            groupControl[@"state"] = @"Local";
            groupControl[@"device"] = device;
            [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                /* Saved. */
                self.objectId = groupControl[@"objectId"];
                [self liveQueryObserver];
                [self updateTableView];
            }];
        } else {
            [self liveQueryObserver];
            for (AVObject *obj in objects) {
                self.objectId = obj[@"objectId"];
            }
            AVObject *groupControl = [AVObject objectWithClassName:GROUPCONTROL_CLASSNAME objectId:self.objectId];
            groupControl[@"state"] = @"Local";
            [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                /* Saved. */
                [self updateTableView];
            }];
        }
    }];
}

- (void)updateTableView {
    AVQuery *doingQuery = [AVQuery queryWithClassName:GROUPCONTROL_CLASSNAME];
    [doingQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        /* Doing list did fetch. */
        if ([objects count]) {
            self.blueIIArray = [[NSMutableArray alloc] initWithArray:objects];
            [self.blueIIView reloadData];
        }
    }];
}

- (void)liveQueryObserver {
    AVQuery *doingQuery = [AVQuery queryWithClassName:GROUPCONTROL_CLASSNAME];
    self.doingLiveQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.doingLiveQuery.delegate = self;
    [self.doingLiveQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
}

#pragma mark - LiveQuery delegate methods
- (void)liveQuery:(AVLiveQuery *)liveQuery objectDidCreate:(id)object {
    if (liveQuery == self.doingLiveQuery) {
        /* A new doing task did create. */
        [self updateTableView];
    } else if (liveQuery == self.remoteStartQuery) {
        __unsafe_unretained typeof(self) weakSelf = self;
        weakSelf.forceStartStopTrigger = YES;
        
        if (!weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
            self.halo.radius = 60;
            weakSelf.forceStartStopTrigger=NO;
            weakSelf.remoteStartStop = YES;
            weakSelf.remoteBuffer = YES;
            [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Stop Buffer","") forState:UIControlStateNormal];
            weakSelf.recordInfo.text = NSLocalizedString(@"Buffering","");
            weakSelf.startBufferDate = [NSDate date];
        }
    } else if (liveQuery == self.remoteStopQuery) {
        __unsafe_unretained typeof(self) weakSelf = self;
        weakSelf.forceStartStopTrigger = YES;
        
        if (weakSelf.remoteStartStop && weakSelf.forceStartStopTrigger) {
            self.halo.radius = 0;
            weakSelf.forceStartStopTrigger=NO;
            weakSelf.remoteStartStop=NO;
            weakSelf.recordInfo.text = @"";
            weakSelf.remoteBuffer = NO;
            weakSelf.WeAreRecording = NO;
            weakSelf.InitialBuffer = NO;
            [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Remote Buffer","") forState:UIControlStateNormal];
            weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
            self.statusOfRecord.text = NSLocalizedString(@"Status Of Record",@"");
            
            if (self.isForceTriggered) {
                self.WeAreRecording = NO;
                self.isForceTriggered = NO;
                NSString *stoppedRecord = NSLocalizedString(@"Stopped Recording at:",@"");
                self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", stoppedRecord, [self.dateFormatter stringFromDate:self.endRecordDate].description];
            }
            
            if (weakSelf.WeAreRecording) {
                [weakSelf stopRecording];
                [weakSelf fileUploadToDeviceAndServer];
            }
        }
        
        self.forceRemoteStartStopButton.userInteractionEnabled = YES;
        self.forceRemoteStartStopButton.backgroundColor = RGB_Alpha(31, 183, 252, 1);
        [self.forceRemoteStartStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else if (liveQuery == self.forceRemoteStartQuery) {
        self.remoteStartStopButton.userInteractionEnabled = NO;
        self.remoteStartStopButton.backgroundColor = [UIColor darkGrayColor];
        [self.remoteStartStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        weakSelf.forceStartStopTrigger = YES;
        
        if (weakSelf.forceStartStopTrigger) {
            weakSelf.forceStartStopTrigger = NO;
            weakSelf.remoteStartStop = YES;
            [weakSelf startRecording];
            [weakSelf.forceRemoteStartStopButton setTitle:NSLocalizedString(@"Stop Record","") forState:
             UIControlStateNormal];
            weakSelf.recordInfo.text = NSLocalizedString(@"Recording","");
            self.halo.radius = 60;
        }
    } else if (liveQuery == self.forceRemoteStopQuery) {
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
            [weakSelf.forceRemoteStartStopButton setTitle:NSLocalizedString(@"Remote Record","") forState:UIControlStateNormal];
            weakSelf.recordInfo.text = @"";
            weakSelf.bufferRecord = nil; weakSelf.seismicRecord = nil;
            self.statusOfRecord.text = NSLocalizedString(@"Status Of Record",@"");
            self.halo.radius = 0;
            [weakSelf.remoteStartStopButton setTitle:NSLocalizedString(@"Remote Buffer","") forState:UIControlStateNormal];
            
            if (self.isForceTriggered) {
                self.WeAreRecording = NO;
                self.isForceTriggered = NO;
                
                NSString *stoppedRecord = NSLocalizedString(@"Stopped Recording at:",@"");
                self.statusOfRecord.text = [NSString stringWithFormat:@"%@ \n %@", stoppedRecord, [self.dateFormatter stringFromDate:self.endRecordDate].description];
            }
        }
    } else if (liveQuery == self.triggeredInfoQuery) {
        self.WeAreRecording = YES;
        self.isForceTriggered = YES;
        self.startRecordDate = [NSDate date];
        [self.seismicRecord checkEventOfRecordingForAllActiveDevices:[NSDate date]];
        [self.bufferButton setTitle:NSLocalizedString(@"Stop Record","") forState:UIControlStateNormal];
        self.recordInfo.text = NSLocalizedString(@"Recording","");
        self.halo.radius = 60;
        self.forceRemoteStartStopButton.userInteractionEnabled = NO;
        self.forceRemoteStartStopButton.backgroundColor = [UIColor darkGrayColor];
        [self.forceRemoteStartStopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)liveQuery:(AVLiveQuery *)liveQuery objectDidUpdate:(id)object updatedKeys:(NSArray<NSString *> *)updatedKeys {
    for (NSString *key in updatedKeys) {
        NSLog(@"%@: %@", key, object[key]);
        [self updateTableView];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.blueIIArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell (with reversing the order of elements - the most recent file at top of table view )
    
    AVObject *obj = self.blueIIArray[indexPath.row];
    NSString *state = obj[@"state"];
    NSString *device = obj[@"device"];
    cell.textLabel.text = device;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text = state;
    cell.detailTextLabel.textColor = [state isEqual:@"Local"]?[UIColor lightGrayColor]:RGB(31, 183, 252);
    cell.detailTextLabel.font= [UIFont systemFontOfSize:12];

    return cell;
}

//
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
        
//        [self startQueryUpdate];
        [self loadQueryUpdate];
        
        //liveQuery
        AVObject *groupControl = [AVObject objectWithClassName:GROUPCONTROL_CLASSNAME objectId:self.objectId];
        groupControl[@"state"] = @"Remote";
        [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            /* Saved. */
        }];
        
    } else {
        self.isRemoteFunctionOn = NO;
        self.bufferButton.hidden = NO;
        self.recordButton.hidden = NO;
        self.remoteStartStopButton.enabled=NO;
        self.forceRemoteStartStopButton.enabled=NO;
        self.controlMode.text = NSLocalizedString(@"Local Control","");
        
        [self stopQueryUpdate];
        
        //liveQuery
        AVObject *groupControl = [AVObject objectWithClassName:GROUPCONTROL_CLASSNAME objectId:self.objectId];
        groupControl[@"state"] = @"Local";
        [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            /* Saved. */
        }];
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
//    iCloud Drive
//    NSString *folderName1 = @"Supporting Files";
//    NSString *folderName2 = @"Force Remote Start Info";
//
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice] name],[self.dateFormatter stringFromDate:date].description,folderName2];
//    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Start info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
//
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    // LiveQuery
    AVObject *groupControl = [AVObject objectWithClassName:FORCEREMOTESTART_CLASSNAME];
    [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /* Saved. */
    }];
}

- (void)setForceRemoteStopNotification
{
//    iCloud Drive
//    NSString *folderName1 = @"Supporting Files";
//    NSString *folderName2 = @"Force Remote Stop Info";
//
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
//    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Stopped info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
//
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    // LiveQuery
    AVObject *groupControl = [AVObject objectWithClassName:FORCEREMOTESTOP_CLASSNAME];
    [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /* Saved. */
    }];
}

- (void)setRemoteStartNotification
{
//    iCloud Drive
//    NSString *folderName1 = @"Supporting Files";
//    NSString *folderName2 = @"Remote Start Info";
//
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
//    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Start info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
//
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    // LiveQuery
    AVObject *groupControl = [AVObject objectWithClassName:REMOTESTART_CLASSNAME];
    [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /* Saved. */
    }];
}

- (void)setRemoteStopNotification
{
//    iCloud Drive
//    NSString *folderName1 = @"Supporting Files";
//    NSString *folderName2 = @"Remote Stop Info";
//
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
//    NSString *messageString = [NSString stringWithFormat:@"Device Remotely Stopped info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
//
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    // LiveQuery
    AVObject *groupControl = [AVObject objectWithClassName:REMOTESTOP_CLASSNAME];
    [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /* Saved. */
    }];
}

- (void)setTriggeredInfoNotification
{
//    iCloud Drive
//    NSString *folderName1 = @"Supporting Files";
//    NSString *folderName2 = @"Triggered Info";
//
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@[%@].txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description,folderName2];
//    NSString *messageString = [NSString stringWithFormat:@"Device Triggered info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",folderName1,folderName2];
//
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    // LiveQuery
    AVObject *groupControl = [AVObject objectWithClassName:TRIGGERED_CLASSNAME];
    [groupControl saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        /* Saved. */
    }];
}

//
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
//LiveQuery
- (void)loadQueryUpdate
{
    // Remote Start Info
//    self.remoteStartQuery = [[NSMetadataQuery alloc] init];
//    [self.remoteStartQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//
//    NSString *remoteStartFilePattern = [NSString stringWithFormat:@"*[Remote Start Info].txt"];
//    [self.remoteStartQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                                         NSMetadataItemFSNameKey, remoteStartFilePattern]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteStartInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.remoteStartQuery];
    AVQuery *doingQuery = [AVQuery queryWithClassName:REMOTESTART_CLASSNAME];
    self.remoteStartQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.remoteStartQuery.delegate = self;
    [self.remoteStartQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    // Remote Stop Info
//    self.remoteStopQuery = [[NSMetadataQuery alloc] init];
//    [self.remoteStopQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//
//    NSString *remoteStopFilePattern = [NSString stringWithFormat:@"*[Remote Stop Info].txt"];
//    [self.remoteStopQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                                         NSMetadataItemFSNameKey, remoteStopFilePattern]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteStopInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.remoteStopQuery];
    doingQuery = [AVQuery queryWithClassName:REMOTESTOP_CLASSNAME];
    self.remoteStopQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.remoteStopQuery.delegate = self;
    [self.remoteStopQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    // Force Remote Start Info
//    self.forceRemoteStartQuery = [[NSMetadataQuery alloc] init];
//    [self.forceRemoteStartQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//
//    NSString *forceRemoteStartFilePattern = [NSString stringWithFormat:@"*[Force Remote Start Info].txt"];
//    [self.forceRemoteStartQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                                        NSMetadataItemFSNameKey, forceRemoteStartFilePattern]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRemoteStartInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.forceRemoteStartQuery];
    doingQuery = [AVQuery queryWithClassName:FORCEREMOTESTART_CLASSNAME];
    self.forceRemoteStartQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.forceRemoteStartQuery.delegate = self;
    [self.forceRemoteStartQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    
    // Force Remote Stop Info
//    self.forceRemoteStopQuery = [[NSMetadataQuery alloc] init];
//    [self.forceRemoteStopQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//
//    NSString *forceRemoteStopFilePattern = [NSString stringWithFormat:@"*[Force Remote Stop Info].txt"];
//    [self.forceRemoteStopQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                                              NSMetadataItemFSNameKey, forceRemoteStopFilePattern]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRemoteStopInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.forceRemoteStopQuery];
    doingQuery = [AVQuery queryWithClassName:FORCEREMOTESTOP_CLASSNAME];
    self.forceRemoteStopQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.forceRemoteStopQuery.delegate = self;
    [self.forceRemoteStopQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    // Triggered Info
//    self.triggeredInfoQuery = [[NSMetadataQuery alloc] init];
//    [self.triggeredInfoQuery setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
//
//    NSString *triggeredInfoFilePattern = [NSString stringWithFormat:@"*[Triggered Info].txt"];
//    [self.triggeredInfoQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@",
//                                             NSMetadataItemFSNameKey, triggeredInfoFilePattern]];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggeredInfoDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.triggeredInfoQuery];
    doingQuery = [AVQuery queryWithClassName:TRIGGERED_CLASSNAME];
    self.triggeredInfoQuery = [[AVLiveQuery alloc] initWithQuery:doingQuery];
    self.triggeredInfoQuery.delegate = self;
    [self.triggeredInfoQuery subscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
}

// 查询更新
- (void)remoteStartInfoDidUpdate:(NSNotification *)notification
{
//    [self.remoteStartQuery stopQuery];
    
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
//    [self.remoteStartQuery startQuery];
    
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
//    [self.forceRemoteStartQuery stopQuery];
    
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
//    [self.forceRemoteStartQuery startQuery];
//    [self.remoteStartQuery startQuery];
    
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

//
- (void)startQueryUpdate
{
//    [self.remoteStartQuery startQuery];
//    [self.remoteStopQuery startQuery];
//    [self.forceRemoteStartQuery startQuery];
//    [self.forceRemoteStopQuery startQuery];
//    [self.triggeredInfoQuery startQuery];
}


- (void)stopQueryUpdate
{
//    [self.remoteStartQuery stopQuery];
//    [self.remoteStopQuery stopQuery];
//    [self.forceRemoteStartQuery stopQuery];
//    [self.forceRemoteStopQuery stopQuery];
//    [self.triggeredInfoQuery stopQuery];
    
    [self.remoteStartQuery unsubscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    [self.remoteStopQuery unsubscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    [self.forceRemoteStartQuery unsubscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    [self.forceRemoteStopQuery unsubscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
    
    [self.triggeredInfoQuery unsubscribeWithCallback:^(BOOL succeeded, NSError * _Nonnull error) {
        /* Subscribed. */
    }];
}

    // ---------------------------------------------------------------------------------------

// 获取设备型号然后手动转化为对应名称
- (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";

    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])    return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])    return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])     return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])     return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])     return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])     return @"iPad Pro 10.5 inch (Cellular)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])    return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])    return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])    return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

    // ---------------------------------------------------------------------------------------

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
