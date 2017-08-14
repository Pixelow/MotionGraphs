//
//  RecordSettingViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 5/4/16.
//
//

#import "RecordSettingViewController.h"
#import "APLDocument.h"

#define UBIQUITY_CONTAINER_URL @"iCloud.com.saitama.MotionGraphs"

#define RGB_Alpha(r, g, b, alp) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: alp]
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: 1]

@interface RecordSettingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *samplingRatelabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderSamplingRate;
@property (weak, nonatomic) IBOutlet UILabel *labelSamplingRate;
@property (weak, nonatomic) IBOutlet UIView *samplingRateView;

@property (weak, nonatomic) IBOutlet UILabel *triggerThresholdLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderTriggerThreshold;
@property (weak, nonatomic) IBOutlet UILabel *labelTriggerThreshold;
@property (weak, nonatomic) IBOutlet UIView *triggerThresholdView;

@property (weak, nonatomic) IBOutlet UILabel *bufferLengthLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderBufferLength;
@property (weak, nonatomic) IBOutlet UILabel *labelBufferLength;
@property (weak, nonatomic) IBOutlet UIView *bufferLengthView;

@property (weak, nonatomic) IBOutlet UILabel *recordLengthLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderRecordLength;
@property (weak, nonatomic) IBOutlet UILabel *labelRecordLength;
@property (weak, nonatomic) IBOutlet UIView *recordLengthView;

@property int userSamplingRate, triggerThreshold, bufferLength, recordLength;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (strong,nonatomic) NSArray *arr;

@end

@implementation RecordSettingViewController

- (void)viewWillAppear:(BOOL)animated {
    
    // Do any additional setup after loading the view.
    
    // ------ Read the contents of file from DropBox on background thread so that main thread is not blocked -----------
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        DBPath *existingPath = [[DBPath root] childPath:[NSString stringWithFormat:@"/%@/%@/%@",@"Record Parameters",@"Setting Folder",@"status.txt"]];
        //        DBFile *readFile = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        //        NSString *contents = [readFile readString:nil];
        
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
            
            self.sliderSamplingRate.value = self.userSamplingRate;
            self.labelSamplingRate.text = [NSString stringWithFormat:@"%d Hz",self.userSamplingRate];
            self.sliderTriggerThreshold.value = self.triggerThreshold;
            self.labelTriggerThreshold.text = [NSString stringWithFormat:@"%d Gal",self.triggerThreshold];
            self.sliderBufferLength.value = self.bufferLength;
            self.labelBufferLength.text = [NSString stringWithFormat:@"%d secs",self.bufferLength];
            self.sliderRecordLength.value = self.recordLength;
            self.labelRecordLength.text = [NSString stringWithFormat:@"%d secs",self.recordLength];
            
        } else {
            
            self.arr = [contents componentsSeparatedByString:@";"];
            if (self.arr.count==9) {
                self.userSamplingRate = ([self.arr objectAtIndex:1] != nil)?[[self.arr objectAtIndex:1] floatValue]:100.0;
                self.triggerThreshold = ([self.arr objectAtIndex:3] != nil)?[[self.arr objectAtIndex:3] floatValue]:5.0;
                self.bufferLength = ([self.arr objectAtIndex:5] != nil)?[[self.arr objectAtIndex:5] floatValue]:60.0;
                self.recordLength = ([self.arr objectAtIndex:7] != nil)?[[self.arr objectAtIndex:7] floatValue]:60.0;
            }
            
            self.sliderSamplingRate.value = self.userSamplingRate;
            self.labelSamplingRate.text = [NSString stringWithFormat:@"%d Hz",self.userSamplingRate];
            self.sliderTriggerThreshold.value = self.triggerThreshold;
            self.labelTriggerThreshold.text = [NSString stringWithFormat:@"%d Gal",self.triggerThreshold];
            self.sliderBufferLength.value = self.bufferLength;
            self.labelBufferLength.text = [NSString stringWithFormat:@"%d secs",self.bufferLength];
            self.sliderRecordLength.value = self.recordLength;
            self.labelRecordLength.text = [NSString stringWithFormat:@"%d secs",self.recordLength];
        }

        
//    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the title
    self.title = NSLocalizedString(@"Cloud Settings","");
    
    // 设置样式
    self.samplingRatelabel.layer.cornerRadius = self.samplingRatelabel.frame.size.height/3;
    self.samplingRatelabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.samplingRatelabel.layer.borderWidth = 1.0;
    
    self.triggerThresholdLabel.layer.cornerRadius = self.triggerThresholdLabel.frame.size.height/3;
    self.triggerThresholdLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.triggerThresholdLabel.layer.borderWidth = 1.0;
    
    self.bufferLengthLabel.layer.cornerRadius = self.bufferLengthLabel.frame.size.height/3;
    self.bufferLengthLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.bufferLengthLabel.layer.borderWidth = 1.0;
    
    self.recordLengthLabel.layer.cornerRadius = self.recordLengthLabel.frame.size.height/3;
    self.recordLengthLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    self.recordLengthLabel.layer.borderWidth = 1.0;
    
    self.samplingRateView.layer.borderWidth = 0.2;
    self.samplingRateView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.triggerThresholdView.layer.borderWidth = 0.2;
    self.triggerThresholdView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.bufferLengthView.layer.borderWidth = 0.2;
    self.bufferLengthView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.recordLengthView.layer.borderWidth = 0.2;
    self.recordLengthView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.updateButton.layer.cornerRadius = self.updateButton.frame.size.height/2;
    self.updateButton.backgroundColor = RGB(31, 183, 252);
    [self.updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.updateButton.titleLabel.font = [UIFont systemFontOfSize:14];
}


- (IBAction)takeSamplingRateValueFromSlider:(UISlider *)sender {
    
    self.userSamplingRate = (int)roundf(sender.value);
    self.labelSamplingRate.text = [NSString stringWithFormat:@"%d Hz", (int)roundf(sender.value)];
}

- (IBAction)takeTriggerThresholdValueFromSlider:(UISlider *)sender {
    
    self.triggerThreshold = (int)roundf(sender.value);
    self.labelTriggerThreshold.text = [NSString stringWithFormat:@"%d Gal", (int)roundf(sender.value)];
}

- (IBAction)takeBufferLengthValueFromSlider:(UISlider *)sender {
    
    self.bufferLength = (int)roundf(sender.value);
    self.labelBufferLength.text = [NSString stringWithFormat:@"%d secs", (int)roundf(sender.value)];
}

- (IBAction)takeRecordLengthValueFromSlider:(UISlider *)sender {
    
    self.recordLength = (int)roundf(sender.value);
    self.labelRecordLength.text = [NSString stringWithFormat:@"%d secs", (int)roundf(sender.value)];
}

- (IBAction)updateRecordParameters:(UIButton *)sender {
    
    // ------ Read the contents of file from DropBox on background thread so that main thread is not blocked -----------
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        // 删除云端文件？
        
//        DBPath *existingPath = [[DBPath root] childPath:[NSString stringWithFormat:@"/%@/%@/%@",@"Record Parameters",@"Setting Folder",@"status.txt"]];
//        [[DBFilesystem sharedFilesystem]deletePath:existingPath error:nil];
        
        // Add delay to allow for files to be deleted and then written in Dropbox
//        double delayInSeconds = 2.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
            // Upload updated record parameter file to Dropbox
            
            NSString *messageString = [NSString stringWithFormat:@"Sampling rate ; %d;\nThreshold Level ; %d;\nBuffer Length ; %d;\nRecord Length ; %d;",self.userSamplingRate, self.triggerThreshold, self.bufferLength, self.recordLength];
            
            NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Record Parameters",@"Setting Folder"];
            [self saveToiCloud:destDir fileName:@"status.txt" filePath:nil fileContent:messageString];
            
//            DBPath *newPath = [[DBPath root]childPath:destDir];
//            DBFile *file = [[DBFilesystem sharedFilesystem]createFile:newPath error:nil];
//            [file writeString:messageString error:nil];

            
//        });
        
//    });

}


#pragma mark - iCloud Drive

/*
 取得云端存储文件的地址
 destinationDiractory 目标文件夹，如果云端不存在，则创建一个文件夹
 return 地址
 */

- (NSURL *)getUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName {
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL];
    //取得Documents目录
    url = [url URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:destinationDiractory];
    
    if ([manager fileExistsAtPath:[url path]] == NO)
    {
        NSLog(@"iCloud Documents directory does not exist");
        //创建M路径
        [manager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"iCloud Documents directory exist");
    }
    
    //取得最终地址
    url = [url URLByAppendingPathComponent:fileName];
    
    return url;
}

- (void)saveToiCloud:(NSString *)destinationDiractory fileName:(NSString *)fileName filePath:(NSString *)filePath fileContent:(NSString *)fileContent
{
    NSString *fileUrl = [NSString stringWithFormat:@"%@",fileName];
    NSURL *url = [self getUbiquityFileURL:destinationDiractory fileName:fileUrl];
    //    NSString *fileNameString = fileName;
    
    APLDocument *document = [[APLDocument alloc] initWithFileURL:url];
    document.data = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!filePath) {
        
    }
    
    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"创建文档成功.");
        } else {
            NSLog(@"创建文档失败.");
        }
    }];
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
        NSLog(@"iCloud Documents directory does not exist");
    } else {
        NSLog(@"iCloud Documents directory exist");
    }
    
    //取得最终地址
    url = [url URLByAppendingPathComponent:fileName];
    
    return url;
}


// ---------------------------------------------------------------------------------------


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
