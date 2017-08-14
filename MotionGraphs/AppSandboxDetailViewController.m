//
//  AppSandboxDetailViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 11/13/14.
//
//

#import "AppSandboxDetailViewController.h"
#import "APLAppDelegate.h"
#import "APLGraphView.h"
#import <MessageUI/MessageUI.h>
#import "FFTGraphViewController.h"
#import "AccGraphViewController.h"
#import "RotationGraphViewController.h"
#import "MapViewController.h"

@interface AppSandboxDetailViewController ()
<MFMailComposeViewControllerDelegate, UITextViewDelegate>

@property (strong,nonatomic) IBOutlet UITextView *detailAppSandboxTextView;
@property BOOL completedFirstSync;


@property (weak, nonatomic) IBOutlet UIButton *sendMailButton;
@property (weak, nonatomic) IBOutlet UIButton *dropboxShareButton;
@property (weak, nonatomic) IBOutlet UIButton *fftPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *accPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *rotationPlotButton;
@property (weak, nonatomic) IBOutlet UIButton *locationPlot;

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


@end

@implementation AppSandboxDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.completedFirstSync=YES;
    self.detailAppSandboxTextView.delegate = self;
    
    self.detailAppSandboxTextView.layer.borderWidth = 3.0f;
    self.detailAppSandboxTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.detailAppSandboxTextView.layer.cornerRadius = 8;
    
    [self separateAccAndGyroRecords];
    [self showAnalysisButtonInUserInterface];
    NSRange summaryStart;
    summaryStart = [self.appRecordData rangeOfString: @"Summary of Record"];
    NSString *recordSummary = [self.appRecordData substringWithRange: NSMakeRange (summaryStart.location, self.appRecordData.length-summaryStart.location)];
    self.detailAppSandboxTextView.text = recordSummary;
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
    
    //Link To Dropbox
//    if (![[DBAccountManager sharedManager]linkedAccount]) {
//    [[DBAccountManager sharedManager]linkFromController:self];
//    }
//    
//    if (self.completedFirstSync==NO) {
//    DBAccount *account = [[DBAccountManager sharedManager]linkedAccount];
//    if (account) {
//        DBFilesystem *filesystem = [[DBFilesystem alloc]initWithAccount:account];
//        [DBFilesystem setSharedFilesystem:filesystem];
//    }
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


-(void)viewDidDisappear:(BOOL)animated
{
   // [DBFilesystem setSharedFilesystem:nil];
}


@end
