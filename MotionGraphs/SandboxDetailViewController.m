//
//  SandboxDetailViewController.m
//  MotionGraphs
//
//  Created by Msm on 23/05/2017.
//
//

#import "SandboxDetailViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"
#import <MessageUI/MessageUI.h>
#import "APLSegmentedControl.h"
#import "FFTGraphViewController.h"
#import "AccGraphViewController.h"
#import "RotationGraphViewController.h"
#import "MapViewController.h"
#import <MapKit/MapKit.h>

#define _allowAppearance    NO

@interface SandboxDetailViewController ()
<MFMailComposeViewControllerDelegate, UITextViewDelegate, APLSegmentedControlDelegate>

@property (strong,nonatomic) IBOutlet UITextView *detailAppSandboxTextView;
@property BOOL completedFirstSync;

@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UILabel *pgaLabel;

@property (weak, nonatomic) IBOutlet UILabel *samplingRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *triggerThresholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *bufferLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLengthLabel;

@property (weak, nonatomic) IBOutlet UILabel *gisLabel;
@property (weak, nonatomic) IBOutlet UILabel *actualSamplingRateLabel;

@property (weak, nonatomic) IBOutlet UIButton *sendMailButton;
@property (weak, nonatomic) IBOutlet UIButton *dropboxShareButton;
@property (weak, nonatomic) IBOutlet UIButton *fftPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *accPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *rotationPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *locationPlot;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet APLSegmentedControl *control;
@property (strong, nonatomic) IBOutlet UIView *graphicsvc;

@property (strong, nonatomic) AccGraphViewController *agvc;
@property (strong, nonatomic) RotationGraphViewController *rgvc;
@property (strong, nonatomic) FFTGraphViewController *fgvc;

@property (strong,nonatomic) NSMutableArray *recordSeparatedArray;
@property (strong,nonatomic) NSMutableArray *accRecordCollectionX;
@property (strong,nonatomic) NSMutableArray *accRecordCollectionY;
@property (strong,nonatomic) NSMutableArray *accRecordCollectionZ;
@property (strong,nonatomic) NSMutableArray *gyroRecordCollectionX;
@property (strong,nonatomic) NSMutableArray *gyroRecordCollectionY;
@property (strong,nonatomic) NSMutableArray *gyroRecordCollectionZ;

@property (strong,nonatomic) NSMutableArray *correctedAccRecordCollectionX;
@property (strong,nonatomic) NSMutableArray *correctedAccRecordCollectionY;
@property (strong,nonatomic) NSMutableArray *correctedAccRecordCollectionZ;
@property (strong,nonatomic) NSMutableArray *correctedGyroRecordCollectionX;
@property (strong,nonatomic) NSMutableArray *correctedGyroRecordCollectionY;
@property (strong,nonatomic) NSMutableArray *correctedGyroRecordCollectionZ;

@property (strong,nonatomic) NSMutableArray *fftX;
@property (strong,nonatomic) NSMutableArray *fftY;
@property (strong,nonatomic) NSMutableArray *fftZ;


@property (nonatomic) float meanAccX, meanAccY, meanAccZ, sumOfAccArrayX, sumOfAccArrayY, sumOfAccArrayZ, meanGyroX, meanGyroY, meanGyroZ, sumOfGyroArrayX, sumOfGyroArrayY, sumOfGyroArrayZ;
@property (nonatomic) double samplingRate;
@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation SandboxDetailViewController

+ (void)load
{
    if (!_allowAppearance) {
        return;
    }
    
    [[APLSegmentedControl appearance] setBackgroundColor:[UIColor clearColor]];
    [[APLSegmentedControl appearance] setTintColor:[UIColor clearColor]];
    [[APLSegmentedControl appearance] setHairlineColor:[UIColor blackColor]];
    
    [[APLSegmentedControl appearance] setSelectionIndicatorHeight:2.5];
    [[APLSegmentedControl appearance] setAnimationDuration:0.125];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:14.0]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] performSelector:@selector(sendEmail:)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(sendEmail:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendEmail:)];
    
    // ------------------------ Get Recorded location Coordinates ------------------------------------
    
    NSString *string1 = self.appRecordData;
    NSRange matchDevice;
    NSRange matchDate;
    NSRange matchPeriod;
    NSRange matchLongitude;
    NSRange matchLatitude;
    NSRange matchPGAValue;
    
    NSRange matchSamplingRate;
    NSRange matchTriggerThreshold;
    NSRange matchBufferLength;
    NSRange matchRecordLength;
    
    NSRange matchActualSamplingRate;
    
    
    matchDevice = [string1 rangeOfString: @"Recorded Device:"];
    matchDate = [string1 rangeOfString: @"Recorded Date/Time:"];
    matchPeriod = [string1 rangeOfString: @"Recorded Period:"];
    matchLongitude = [string1 rangeOfString: @"longitude:"];
    matchLatitude = [string1 rangeOfString: @"latitude:"];
    matchPGAValue = [string1 rangeOfString: @"PGA Value:"];
    
    matchSamplingRate = [string1 rangeOfString: @"userSamplingRate:"];
    matchTriggerThreshold = [string1 rangeOfString: @"triggerThreshold:"];
    matchBufferLength = [string1 rangeOfString: @"bufferLength:"];
    matchRecordLength = [string1 rangeOfString: @"recordLength:"];
    
    matchActualSamplingRate = [string1 rangeOfString: @"Actual Sampling Rate;"];
    
    
    NSString *device = [string1 substringWithRange: NSMakeRange (matchDevice.location+16, (matchDate.location-4)-(matchDevice.location+16))];
    
    NSString *date = [string1 substringWithRange: NSMakeRange (matchDate.location+19, 23)];
    NSString *date02 = [date stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    NSString *period = [string1 substringWithRange: NSMakeRange (matchPeriod.location+16, (matchPGAValue.location-3)-(matchPeriod.location+16))];
    NSString *period02 = [period stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    NSString *pga = [string1 substringWithRange: NSMakeRange (matchPGAValue.location+10, (matchLongitude.location-3)-(matchPGAValue.location+10))];
    NSString *pga02 = [pga stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    
    NSString *longitude = [string1 substringWithRange: NSMakeRange (matchLongitude.location+10, 10)];
    NSString *longitude02 = [NSString stringWithFormat:@"%f", [longitude doubleValue]];
    
    NSString *latitude = [string1 substringWithRange: NSMakeRange (matchLatitude.location+9, 10)];
    NSString *latitude02 = [NSString stringWithFormat:@"%f", [latitude doubleValue]];
    
    NSString *pgaValue = [string1 substringWithRange: NSMakeRange (matchPGAValue.location+10, 8)];
    NSString *pgaValue02 = [NSString stringWithFormat:@"%.3f", [pgaValue doubleValue]];
    
    
    NSString *samplingRate = [string1 substringWithRange: NSMakeRange (matchSamplingRate.location+18, (matchTriggerThreshold.location-3)-(matchSamplingRate.location+18))];
    NSString *samplingRate02 = [samplingRate stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    NSString *triggerThreshold = [string1 substringWithRange: NSMakeRange (matchTriggerThreshold.location+18, (matchBufferLength.location-3)-(matchTriggerThreshold.location+18))];
    NSString *triggerThreshold02 = [triggerThreshold stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    NSString *bufferLength = [string1 substringWithRange: NSMakeRange (matchBufferLength.location+14, (matchRecordLength.location-2)-(matchBufferLength.location+14))];
    NSString *bufferLength02 = [bufferLength stringByReplacingOccurrencesOfString:@"  " withString:@"\n"];
    
    NSString *recordLength = [string1 substringWithRange: NSMakeRange (matchRecordLength.location+14, (matchActualSamplingRate.location-4)-(matchRecordLength.location+14))];
    NSString *recordLength02 = [recordLength stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    NSString *actualSamplingRate = [string1 substringWithRange: NSMakeRange (matchActualSamplingRate.location+22, 8)];
    
    // ------------------------------------------------------------------------------------------------
    
    
    // 初始化Label
    self.deviceLabel.text = [NSString stringWithFormat:@"%@", device];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@", date02];
    self.dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.periodLabel.text = [NSString stringWithFormat:@"%@", period02];
    self.pgaLabel.text = [NSString stringWithFormat:@"%@", pga02];
    
    NSString *longitudeStr = NSLocalizedString(@"longitude","");
    NSString *latitudeStr = NSLocalizedString(@"latitude","");
    self.gisLabel.text = [NSString stringWithFormat:@"%@: %@  |  %@: %@", longitudeStr, longitude02, latitudeStr, latitude02];
    self.gisLabel.textAlignment = NSTextAlignmentCenter;
    
    self.samplingRateLabel.text = [NSString stringWithFormat:@"%@", samplingRate02];
    self.triggerThresholdLabel.text = [NSString stringWithFormat:@"%@", triggerThreshold02];
    self.bufferLengthLabel.text = [NSString stringWithFormat:@"%@", bufferLength02];
    self.recordLengthLabel.text = [NSString stringWithFormat:@"%@", recordLength02];
    
    NSString *actualSamplingRateStr = NSLocalizedString(@"Actual Sampling Rate","");
    self.actualSamplingRateLabel.text = [NSString stringWithFormat:@"%@ : %@", actualSamplingRateStr, actualSamplingRate];
    
    
    // 初始化地图
    self.mapView.mapType = MKMapTypeHybrid;
    
//    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D coordinateObtained;
    coordinateObtained.latitude = [latitude02 doubleValue];
    coordinateObtained.longitude = [longitude02 doubleValue];
    
    MKCoordinateSpan span = {.latitudeDelta = 0.00001, .longitudeDelta = 0.00001};
    MKCoordinateRegion region = {coordinateObtained, span};
    MKPointAnnotation *pointAttonation = [[MKPointAnnotation alloc] init];
    pointAttonation.coordinate = coordinateObtained;
    
    pointAttonation.title = [NSString stringWithFormat:@"PGA Recorded:%@", pgaValue02];
    
    [self.mapView addAnnotation:pointAttonation];
    [self.mapView setRegion:region];
    
    self.completedFirstSync=YES;
    self.detailAppSandboxTextView.delegate = self;
    
    self.detailAppSandboxTextView.layer.borderWidth = 1.0f;
    self.detailAppSandboxTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.detailAppSandboxTextView.layer.cornerRadius = 8;
    
    [self separateAccAndGyroRecords];
    [self showAnalysisButtonInUserInterface];
    NSRange summaryStart;
    summaryStart = [self.appRecordData rangeOfString: @"Summary of Record"];
    NSString *recordSummary = [self.appRecordData substringWithRange: NSMakeRange (summaryStart.location, self.appRecordData.length-summaryStart.location)];
    self.detailAppSandboxTextView.text = recordSummary;
    
    
    // 分段选择器
    _menuItems = @[[@"ACC" uppercaseString], [@"GYRO" uppercaseString], [@"FFT" uppercaseString]];
    
    _control.items = _menuItems;
    _control.backgroundColor = [UIColor whiteColor];
    _control.tintColor = [UIColor blackColor];
    _control.font = [UIFont systemFontOfSize:14.0];
    _control.delegate = self;
    _control.selectedSegmentIndex = 0;
    _control.bouncySelectionIndicator = YES;
    [_control addTarget:self action:@selector(selectedSegment:) forControlEvents:UIControlEventValueChanged];
    
    
    // 初始化曲线viewController
    
    self.graphicsvc.backgroundColor = [UIColor whiteColor];
    
    self.agvc = [AccGraphViewController alloc];
    self.rgvc = [RotationGraphViewController alloc];
    self.fgvc = [FFTGraphViewController alloc];
    
    self.agvc.accArrayX = self.correctedAccRecordCollectionX;
    self.agvc.accArrayY = self.correctedAccRecordCollectionY;
    self.agvc.accArrayZ = self.correctedAccRecordCollectionZ;
    self.agvc.samplingRate = self.samplingRate;
    
    [self.graphicsvc addSubview:self.agvc.view];
}

- (void)separateAccAndGyroRecords {
    
    self.recordSeparatedArray = [[NSMutableArray alloc]initWithArray:[self.appRecordData componentsSeparatedByString:@";"]];
    self.samplingRate = [[self.recordSeparatedArray lastObject]doubleValue];
    
    for (int i=1; i<self.recordSeparatedArray.count-1; i=i+7) {
        if (!self.accRecordCollectionX) {
            self.accRecordCollectionX = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i], nil];
        }else{
            [self.accRecordCollectionX addObject:[self.recordSeparatedArray objectAtIndex:i]];
        }
        
        if (!self.accRecordCollectionY) {
            self.accRecordCollectionY = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i+1], nil];
        }else{
            [self.accRecordCollectionY addObject:[self.recordSeparatedArray objectAtIndex:i+1]];
        }
        
        if (!self.accRecordCollectionZ) {
            self.accRecordCollectionZ = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i+2], nil];
        }else{
            [self.accRecordCollectionZ addObject:[self.recordSeparatedArray objectAtIndex:i+2]];
        }
        
        if (!self.gyroRecordCollectionX) {
            self.gyroRecordCollectionX = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i+3], nil];
        }else{
            [self.gyroRecordCollectionX addObject:[self.recordSeparatedArray objectAtIndex:i+3]];
        }
        
        if (!self.gyroRecordCollectionY) {
            self.gyroRecordCollectionY = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i+4], nil];
        }else{
            [self.gyroRecordCollectionY addObject:[self.recordSeparatedArray objectAtIndex:i+4]];
        }
        
        if (!self.gyroRecordCollectionZ) {
            self.gyroRecordCollectionZ = [[NSMutableArray alloc]initWithObjects:self.recordSeparatedArray[i+5], nil];
        }else{
            [self.gyroRecordCollectionZ addObject:[self.recordSeparatedArray objectAtIndex:i+5]];
        }
    }
    
    // Remove the Constant AccData and GyroGata for calibration of measurement
    // Sum of elements of acc Array and gyro Array
    
    for (int i=0; i<self.accRecordCollectionX.count; i++) {
        self.sumOfAccArrayX += [self.accRecordCollectionX[i] floatValue];
        self.sumOfAccArrayY += [self.accRecordCollectionY[i] floatValue];
        self.sumOfAccArrayZ += [self.accRecordCollectionZ[i] floatValue];
        self.sumOfGyroArrayX += [self.gyroRecordCollectionX[i] floatValue];
        self.sumOfGyroArrayY += [self.gyroRecordCollectionY[i] floatValue];
        self.sumOfGyroArrayZ += [self.gyroRecordCollectionZ[i] floatValue];
    }
    self.meanAccX = self.sumOfAccArrayX/self.accRecordCollectionX.count;
    self.meanAccY = self.sumOfAccArrayY/self.accRecordCollectionY.count;
    self.meanAccZ = self.sumOfAccArrayZ/self.accRecordCollectionZ.count;
    self.meanGyroX = self.sumOfGyroArrayX/self.gyroRecordCollectionX.count;
    self.meanGyroY = self.sumOfGyroArrayY/self.gyroRecordCollectionY.count;
    self.meanGyroZ = self.sumOfGyroArrayZ/self.gyroRecordCollectionZ.count;
    
    
    for (int i=0; i<self.accRecordCollectionX.count; i++) {
        if (!self.correctedAccRecordCollectionX) {
            self.correctedAccRecordCollectionX = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.accRecordCollectionX[i] floatValue]-self.meanAccX], nil];
        }else{
            [self.correctedAccRecordCollectionX addObject:[NSNumber numberWithFloat:[self.accRecordCollectionX[i] floatValue]-self.meanAccX]];
        }
        
        if (!self.correctedAccRecordCollectionY) {
            self.correctedAccRecordCollectionY = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.accRecordCollectionY[i] floatValue]-self.meanAccY], nil];
        }else{
            [self.correctedAccRecordCollectionY addObject:[NSNumber numberWithFloat:[self.accRecordCollectionY[i] floatValue]-self.meanAccY]];
        }
        
        if (!self.correctedAccRecordCollectionZ) {
            self.correctedAccRecordCollectionZ = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.accRecordCollectionZ[i] floatValue]-self.meanAccZ], nil];
        }else{
            [self.correctedAccRecordCollectionZ addObject:[NSNumber numberWithFloat:[self.accRecordCollectionZ[i] floatValue]-self.meanAccZ]];
        }
        
        if (!self.correctedGyroRecordCollectionX) {
            self.correctedGyroRecordCollectionX = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.gyroRecordCollectionX[i] floatValue]-self.meanGyroX], nil];
        }else{
            [self.correctedGyroRecordCollectionX addObject:[NSNumber numberWithFloat:[self.gyroRecordCollectionX[i] floatValue]-self.meanGyroX]];
        }
        
        if (!self.correctedGyroRecordCollectionY) {
            self.correctedGyroRecordCollectionY = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.gyroRecordCollectionY[i] floatValue]-self.meanGyroY], nil];
        }else{
            [self.correctedGyroRecordCollectionY addObject:[NSNumber numberWithFloat:[self.gyroRecordCollectionY[i] floatValue]-self.meanGyroY]];
        }
        
        if (!self.correctedGyroRecordCollectionZ) {
            self.correctedGyroRecordCollectionZ = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:[self.gyroRecordCollectionZ[i] floatValue]-self.meanGyroZ], nil];
        }else{
            [self.correctedGyroRecordCollectionZ addObject:[NSNumber numberWithFloat:[self.gyroRecordCollectionZ[i] floatValue]-self.meanGyroZ]];
        }
    }
}


- (IBAction)sendEmail:(UIButton *)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        //email subject
        NSString *subject = @"send mail test";
        
        
        //email body
        NSString *body = self.appRecordData;
        
        
        //recipients
        NSArray *recipients = [NSArray arrayWithObjects:@"ashishduwaju@gmail.com",nil];
        
        //create the MFMailComposeViewController
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc]init];
        composer.mailComposeDelegate = self;
        
        [composer setSubject:subject];
        [composer setMessageBody:body isHTML:NO];
        [composer setToRecipients:recipients];
        
        //get the filepath from resources
        NSString *filepath = [[NSBundle mainBundle]pathForResource:@"logo" ofType:@"png"];
        
        //read the file using NSData
        NSData *fileData = [NSData dataWithContentsOfFile:filepath];
        
        NSString *mimeType = @"image/png";
        
        if (fileData !=nil) {
            //add attachment
            [composer addAttachmentData:fileData mimeType:mimeType fileName:filepath];
        }
        
        
        //present it on the screen
        [self presentViewController:composer animated:YES completion:NULL];
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Your device doesnt support the composer sheet" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate methods


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail Cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail Saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail Sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail Sent Failure: %@", [error localizedDescription]);
            break;
            
        default:
            break;
    }
    
    //close the Mail Interface
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (IBAction)btnUploadFileTapped:(UIButton *)sender {
    
    //Link To Dropbox 上传到Dropbox，此功能已去除
//    if (![[DBAccountManager sharedManager]linkedAccount]) {
//        [[DBAccountManager sharedManager]linkFromController:self];
//    }
//    
//    if (self.completedFirstSync==NO) {
//        DBAccount *account = [[DBAccountManager sharedManager]linkedAccount];
//        if (account) {
//            DBFilesystem *filesystem = [[DBFilesystem alloc]initWithAccount:account];
//            [DBFilesystem setSharedFilesystem:filesystem];
//        }
//    }
//    
//    NSString *deviceName = [[UIDevice currentDevice]name];
//    
//    // Upload file to Dropbox
//    NSString *destDir = [NSString stringWithFormat:@"%@/%@/%@",@"Recorded Data",deviceName, self.fileNameToPass];
//    
//    DBPath *newPath = [[DBPath root]childPath:destDir];
//    DBFile *file = [[DBFilesystem sharedFilesystem]createFile:newPath error:nil];
//    [file writeString:self.appRecordData error:nil];
    
}


- (void)performFFTAnalysis {
    
    self.fftX=nil; self.fftY=nil; self.fftZ=nil;
    
    //setup
    
    float samplesPerSecond = self.samplingRate; // sampling rate
    float recordedSamples = self.accRecordCollectionX.count;
    UInt32 log2N          = log2f(recordedSamples); // samples @ power of 2
    UInt32 N              = (1 << log2N);
    
    NSLog(@"maxSamples: %f",recordedSamples);
    NSLog(@"no of samples for FFT: %u",(unsigned int)N);
    
    
    FFTSetup FFTSettings  = vDSP_create_fftsetup(log2N, kFFTRadix2);
    COMPLEX_SPLIT FFTDataX;
    COMPLEX_SPLIT FFTDataY;
    COMPLEX_SPLIT FFTDataZ;
    
    
    FFTDataX.realp         = (float *) malloc(sizeof(float) * N/2);
    FFTDataX.imagp         = (float *) malloc(sizeof(float) * N/2);
    memset(FFTDataX.imagp, 0, N/2 * sizeof(float));
    
    FFTDataY.realp         = (float *) malloc(sizeof(float) * N/2);
    FFTDataY.imagp         = (float *) malloc(sizeof(float) * N/2);
    memset(FFTDataY.imagp, 0, N/2 * sizeof(float));
    
    FFTDataZ.realp         = (float *) malloc(sizeof(float) * N/2);
    FFTDataZ.imagp         = (float *) malloc(sizeof(float) * N/2);
    memset(FFTDataZ.imagp, 0, N/2 * sizeof(float));
    
    //store array values to float
    
    float *acceloDataX = malloc(sizeof(float)*recordedSamples);
    float *acceloDataY = malloc(sizeof(float)*recordedSamples);
    float *acceloDataZ = malloc(sizeof(float)*recordedSamples);
    
    
    for (int i=0; i < recordedSamples; i++) {
        acceloDataX[i] = [[self.correctedAccRecordCollectionX objectAtIndex:i]floatValue];
        acceloDataY[i] = [[self.correctedAccRecordCollectionY objectAtIndex:i]floatValue];
        acceloDataZ[i] = [[self.correctedAccRecordCollectionZ objectAtIndex:i]floatValue];
    }
    
    // Converting data in in_real into split complex form
    
    vDSP_ctoz((DSPComplex *)acceloDataX, 2, &FFTDataX, 1, N/2);
    vDSP_ctoz((DSPComplex *)acceloDataY, 2, &FFTDataY, 1, N/2);
    vDSP_ctoz((DSPComplex *)acceloDataZ, 2, &FFTDataZ, 1, N/2);
    
    //NSLog(@"split form: %p",&FFTDataX);
    
    
    // Doing the FFT
    vDSP_fft_zrip(FFTSettings, &FFTDataX, 1, log2N, FFT_FORWARD);
    vDSP_fft_zrip(FFTSettings, &FFTDataY, 1, log2N, FFT_FORWARD);
    vDSP_fft_zrip(FFTSettings, &FFTDataZ, 1, log2N, FFT_FORWARD);
    
    // At this point, FFTData.realp is an array of  FFT values (N/2).
    
    //appropriate scaling
    float scale = (float) 1.0/(2.0);
    vDSP_vsmul(FFTDataX.realp, 1 ,&scale, FFTDataX.realp, 1, N/2);
    vDSP_vsmul(FFTDataX.imagp, 1 ,&scale, FFTDataX.imagp, 1, N/2);
    
    vDSP_vsmul(FFTDataY.realp, 1 ,&scale, FFTDataY.realp, 1, N/2);
    vDSP_vsmul(FFTDataY.imagp, 1 ,&scale, FFTDataY.imagp, 1, N/2);
    
    vDSP_vsmul(FFTDataZ.realp, 1 ,&scale, FFTDataZ.realp, 1, N/2);
    vDSP_vsmul(FFTDataZ.imagp, 1 ,&scale, FFTDataZ.imagp, 1, N/2);
    
    
    self.FFTXmax=0;
    self.FFTYmax=0;
    self.FFTZmax=0;
    
    self.dominantFrequencyX=0;
    self.dominantFrequencyY=0;
    self.dominantFrequencyZ=0;
    
    for (int i=0; i<N/2; i++) {
        
        float hz = ((float)i/(float)N)*samplesPerSecond;
        
        //compute power
        float powerX = FFTDataX.realp[i]*FFTDataX.realp[i]+FFTDataX.imagp[i]*FFTDataX.imagp[i];
        float powerY = FFTDataY.realp[i]*FFTDataY.realp[i]+FFTDataY.imagp[i]*FFTDataY.imagp[i];
        float powerZ = FFTDataZ.realp[i]*FFTDataZ.realp[i]+FFTDataZ.imagp[i]*FFTDataZ.imagp[i];
        
        //compute magnitude
        float magnitudeX = sqrtf(powerX)*2/N;
        float magnitudeY = sqrtf(powerY)*2/N;
        float magnitudeZ = sqrtf(powerZ)*2/N;
        
        
        //store fft magnitudes in an array
        NSString *fftXData = [NSString stringWithFormat:@"%f \n",magnitudeX];
        if (!self.fftX) {
            self.fftX = [[NSMutableArray alloc]initWithObjects:fftXData, nil];
        }else{
            [self.fftX addObject:fftXData];
        }
        
        NSString *fftYData = [NSString stringWithFormat:@"%f \n",magnitudeY];
        if (!self.fftY) {
            self.fftY = [[NSMutableArray alloc]initWithObjects:fftYData, nil];
        }else{
            [self.fftY addObject:fftYData];
        }
        
        NSString *fftZData = [NSString stringWithFormat:@"%f \n",magnitudeZ];
        if (!self.fftZ) {
            self.fftZ = [[NSMutableArray alloc]initWithObjects:fftZData, nil];
        }else{
            [self.fftZ addObject:fftZData];
        }
        
        if (i>0) {                             // Neglecting 1st FFT Amplitude
            //maximum amplitude
            if (self.FFTXmax<magnitudeX) {
                self.FFTXmax=magnitudeX;
                self.dominantFrequencyX=hz;
            }
            if (self.FFTYmax<magnitudeY) {
                self.FFTYmax=magnitudeY;
                self.dominantFrequencyY=hz;
            }
            
            if (self.FFTZmax<magnitudeZ) {
                self.FFTZmax=magnitudeZ;
                self.dominantFrequencyZ=hz;
            }
        }
        
    }
    
    // Cleanup -----------
    // We should do this only when We're done doing FFTs.
    vDSP_destroy_fftsetup(FFTSettings);
    free(acceloDataX);
    free(acceloDataY);
    free(acceloDataZ);
    
}

-(void)emptyRecordArrays
{
    // Empty Record Arrays
    self.recordSeparatedArray = nil;
    self.accRecordCollectionX=nil; self.accRecordCollectionY=nil; self.accRecordCollectionZ=nil;
    self.gyroRecordCollectionX=nil; self.gyroRecordCollectionY=nil; self.gyroRecordCollectionZ=nil;
    self.correctedAccRecordCollectionX=nil; self.correctedAccRecordCollectionY = nil; self.correctedAccRecordCollectionZ = nil;
    self.correctedGyroRecordCollectionX=nil; self.correctedGyroRecordCollectionY=nil; self.correctedGyroRecordCollectionZ=nil;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showFFTGraph"]) {
        if ([segue.destinationViewController isKindOfClass:[FFTGraphViewController class]]) {
            
            [self performFFTAnalysis];
            
            NSLog(@"Linked To FFT Graph View");
            FFTGraphViewController *fgvc = segue.destinationViewController;
            fgvc.fftArrayX = self.fftX;
            fgvc.fftArrayY = self.fftY;
            fgvc.fftArrayZ = self.fftZ;
            fgvc.samplingRate = self.samplingRate;
            
        }
    }
    
    if ([segue.identifier isEqualToString:@"showAccGraph"]) {
        if ([segue.destinationViewController isKindOfClass:[AccGraphViewController class]]) {
            NSLog(@"Linked To Acceleration Graph View");
            
            AccGraphViewController *agvc = segue.destinationViewController;
            agvc.accArrayX = self.correctedAccRecordCollectionX;
            agvc.accArrayY = self.correctedAccRecordCollectionY;
            agvc.accArrayZ = self.correctedAccRecordCollectionZ;
            agvc.samplingRate = self.samplingRate;
            
        }
    }
    
    if ([segue.identifier isEqualToString:@"showRotationPlot"]) {
        if ([segue.destinationViewController isKindOfClass:[RotationGraphViewController class]]) {
            NSLog(@"Linked To Rotation Graph View");
            
            RotationGraphViewController *rgvc = segue.destinationViewController;
            rgvc.gyroArrayX = self.gyroRecordCollectionX;
            rgvc.gyroArrayY = self.gyroRecordCollectionY;
            rgvc.gyroArrayZ = self.gyroRecordCollectionZ;
            rgvc.samplingRate = self.samplingRate;
            
        }
    }
    
    if ([segue.identifier isEqualToString:@"mapViewSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            NSLog(@"Linked To Map View");
            
            // ------------------------ Get Recorded location Coordinates ------------------------------------
            NSString *string1 = self.appRecordData;
            NSRange matchLongitude;
            NSRange matchLatitude;
            NSRange matchPGAValue;
            matchLongitude = [string1 rangeOfString: @"longitude:"];  // Find the string named "longitude:" and set its starting location index
            matchLatitude = [string1 rangeOfString: @"latitude:"];    // Find the string named "longitude:" and set its starting location index
            matchPGAValue = [string1 rangeOfString: @"PGA Value:"];   // Find the string named "PGA Value:" and set its starting location index
            
            NSString *longitude = [string1 substringWithRange: NSMakeRange (matchLongitude.location+10, 12)];   // 12 - the no. of digits of longitude value
            NSString *latitude = [string1 substringWithRange: NSMakeRange (matchLatitude.location+9, 11)];      // 11 - the no. of digits of latitude value
            NSString *pgaValue = [string1 substringWithRange: NSMakeRange (matchPGAValue.location+10, 10)];      // 10 - the no. of digits of PGA value
            // ------------------------------------------------------------------------------------------------
            
            MapViewController *mvc = segue.destinationViewController;
            mvc.latitudeValue = latitude;
            mvc.longitudeValue = longitude;
            mvc.pgaValue = pgaValue;
        }
    }
    
}

// -------------------- Show Analysis Button in View ---------------------------

- (void)showAnalysisButtonInUserInterface{
    self.sendMailButton.hidden = NO;
    self.dropboxShareButton.hidden = NO;
    self.accPlotButton.hidden = NO;
    self.rotationPlotButton.hidden = NO;
    self.fftPlotButton.hidden = NO;
    self.locationPlot.hidden = NO;
}

// ------------------------------------------------------------------------------------

- (void)textViewDidChange:(UITextView *)textView{
    
    // Remove Keyboard from View by pressing the return key
    [textView resignFirstResponder];
}

// ------------------------------------------------------------------------------------

- (void)selectedSegment:(APLSegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case 0:
            
            [self.agvc removeFromParentViewController];
            [self.rgvc removeFromParentViewController];
            [self.fgvc removeFromParentViewController];
            
            self.agvc.accArrayX = self.correctedAccRecordCollectionX;
            self.agvc.accArrayY = self.correctedAccRecordCollectionY;
            self.agvc.accArrayZ = self.correctedAccRecordCollectionZ;
            self.agvc.samplingRate = self.samplingRate;
            
            [self.graphicsvc addSubview:self.agvc.view];
            
            break;
            
        case 1:
            
            [self.agvc removeFromParentViewController];
            [self.rgvc removeFromParentViewController];
            [self.fgvc removeFromParentViewController];
            
            self.rgvc.gyroArrayX = self.gyroRecordCollectionX;
            self.rgvc.gyroArrayY = self.gyroRecordCollectionY;
            self.rgvc.gyroArrayZ = self.gyroRecordCollectionZ;
            self.rgvc.samplingRate = self.samplingRate;
            
            [self.graphicsvc addSubview:self.rgvc.view];
            
            break;
            
        case 2:
            
            [self.agvc removeFromParentViewController];
            [self.rgvc removeFromParentViewController];
            [self.fgvc removeFromParentViewController];
            
            [self performFFTAnalysis];
            
            self.fgvc.fftArrayX = self.fftX;
            self.fgvc.fftArrayY = self.fftY;
            self.fgvc.fftArrayZ = self.fftZ;
            self.fgvc.samplingRate = self.samplingRate;
            
            [self.graphicsvc addSubview:self.fgvc.view];
            
            break;
            
        default:
            break;
    }
}


#pragma mark - UIBarPositioningDelegate Methods

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}


-(void)viewDidDisappear:(BOOL)animated
{
    // [DBFilesystem setSharedFilesystem:nil];
}


@end
