//
//  RecordHistoryViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/7/14.
//
//

#import "RecordHistoryViewController.h"
#import "APLAppDelegate.h"

#define APP_Key = @"8eyw7qxeokggonv";
#define APP_SECRET = @"4anf1wr5ttrwu64";

NSString *todaysDate;
NSString *todaysTime;


@interface RecordHistoryViewController () <DBRestClientDelegate>

@property (strong,nonatomic) DBRestClient *restClient;
@end

@implementation RecordHistoryViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom Initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _recordHistory2.text= _recordText;
    
    DBSession *dbSession = [[DBSession alloc]initWithAppKey:@"8eyw7qxeokggonv" appSecret:@"4anf1wr5ttrwu64" root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    self.restClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    // Write a file to the local documents directory
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    todaysDate = [dateformatter stringFromDate:[NSDate date]];
    
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc]init];
    [timeformatter setDateFormat:@"hh:mm:ss"];
    todaysTime = [timeformatter stringFromDate:[NSDate date]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnUploadFileTapped:(id)sender
{
    if (![[DBSession sharedSession]isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
    }
    
    NSString *text = _recordText;
    //  NSString *filename = @"recorded datas.txt";
    NSString *filename;
    filename = [NSString stringWithFormat:@"[%@] [%@] .txt", todaysDate, todaysTime];
    
    NSString *deviceName = [[UIDevice currentDevice]name];
    
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    
    [text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Upload file to Dropbox
    
    
    // NSString *destDir = @"/deviceName";
    NSString *destDir = [NSString stringWithFormat:@"/%@",deviceName];
    
    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    // [self.restClient loadMetadata:@"/deviceName"];
    [self.restClient loadMetadata:[NSString stringWithFormat:@"/%@",deviceName]];
    
}

-(void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File Uploaded Successfully to path: %@", metadata.path);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File Uploaded Successfully" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File Upload Failed With error: %@", error);
}

// Listing Folders on dropBox

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error Loading Metadata: %@", error);
}


@end
