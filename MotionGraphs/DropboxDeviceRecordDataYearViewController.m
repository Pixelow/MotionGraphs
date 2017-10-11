//
//  DropboxDeviceRecordDataYearViewController.m
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import "DropboxDeviceRecordDataYearViewController.h"
#import "DropboxDeviceRecordDataMonthViewController.h"
#import "APLDocument.h"
#import "APLManagedDocument.h"
#include <netdb.h>   // Framework required to check internet connection

#define UBIQUITY_CONTAINER_URL @"iCloud.com.saitama.MotionGraphs"

@interface DropboxDeviceRecordDataYearViewController ()
@property BOOL NetworkAvailable;
@property (strong,nonatomic) NSString *infoDataContents;
@property (strong,nonatomic) NSMutableArray *recordedDataContentsUrl;

@end

@implementation DropboxDeviceRecordDataYearViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dropboxDeviceRecordDataYearView.delegate=self;
    self.dropboxDeviceRecordDataYearView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");
    
    [self loadDocuments];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxDeviceRecordDataYearView setEditing:editing animated:animated];
}

-(NSMutableArray *)dropboxDeviceRecordDataYearList {
    if (!_dropboxDeviceRecordDataYearList) {
        _dropboxDeviceRecordDataYearList = [[NSMutableArray alloc] init];
    }
    return _dropboxDeviceRecordDataYearList;
}

-(NSMutableArray *)dropboxDeviceRecordDataYearRootList {
    if (!_dropboxDeviceRecordDataYearRootList) {
        _dropboxDeviceRecordDataYearRootList = [[NSMutableArray alloc] init];
    }
    return _dropboxDeviceRecordDataYearRootList;
}

-(NSMutableArray *)recordedDataContentsUrl {
    if (!_recordedDataContentsUrl) {
        _recordedDataContentsUrl = [[NSMutableArray alloc]init];
    }
    return _recordedDataContentsUrl;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dropboxDeviceRecordDataYearListStringToSend = [NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxDeviceListViewController, [self.dropboxDeviceRecordDataYearRootList objectAtIndex:indexPath.row]];
    self.dropboxDeviceRecordDataYearFileContents = [self childItemsInRoot:self.dropboxDeviceRecordDataYearListStringToSend.lastPathComponent];
    
    // ----------------- Check if internet connection is Available. If YES then only perform seque -----------------------------
    [self isNetworkAvailable];
    
    if (self.NetworkAvailable) {
        
        // ------------------------ Read Record String from the Specified Path --------------------------------------------
//        DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"%@",self.dropboxDeviceRecordDataYearListStringToSend]];
//        DBFile *readFile = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
//        self.infoDataContents = [readFile readString:nil];
        
        // ----------------------------------------------------------------------------------------------------------------
        
        // ----------------- Check if the string passed consists of Recorded data only ------------------------
        if ([self.checkStringForRecordedDataOnly isEqualToString:@"Recorded Data"] || [self.checkStringForRecordedDataOnly isEqualToString:@"Triggered Data"]) {
            
            // Perform seque
            [self performSegueWithIdentifier:@"dropboxDeviceRecordDataMonthViewControllerSeque" sender:self];
            
        } else {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.recordedDataContentsUrl[indexPath.row] path]]) {

                APLDocument *deviceRecord = [APLDocument alloc];
                [deviceRecord readFromURL:self.recordedDataContentsUrl[indexPath.row] error:nil];
                self.infoDataContents =  [[NSString alloc] initWithData:deviceRecord.data encoding:NSUTF8StringEncoding];
                // Do not perform seque instead present the information in alert view
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File Information" message:self.infoDataContents preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [vc presentViewController:alertController animated:YES completion:nil];
                
            } else {
                
                // Do not perform seque instead present the information in alert view
                
                NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [fileCoordinator coordinateReadingItemAtURL:self.recordedDataContentsUrl[indexPath.row]
                                                    options:NSFileCoordinatorReadingWithoutChanges
                                                      error:nil
                                                 byAccessor:^(NSURL * _Nonnull newURL)
                 {
                     NSString *contStr = [NSString stringWithContentsOfURL:newURL encoding:NSUTF8StringEncoding error:nil];
                     self.infoDataContents =  [[NSString alloc] initWithString:contStr];
                     // Do not perform seque instead present the information in alert view
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"File Information" message:self.infoDataContents preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                     [alertController addAction:ok];
                     UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                     [vc presentViewController:alertController animated:YES completion:nil];
                 }];

            }
            

        }

        // -----------------------------------------------------------------------------------------------------
        
        
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Dropbox files cannot be viewed in offline mode" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxDeviceRecordDataYearRootList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dropboxDeviceRecordDataYearRootList objectAtIndex:indexPath.row]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"dropboxDeviceRecordDataMonthViewControllerSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[DropboxDeviceRecordDataMonthViewController class]]) {
            NSLog(@"Linked To Dropbox Device Record Data Month View");
            
            DropboxDeviceRecordDataMonthViewController *ddrdmvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxDeviceRecordDataYearView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.dropboxDeviceRecordDataYearView cellForRowAtIndexPath:cellPath];
            ddrdmvc.navigationItem.title = theCell.textLabel.text;
            
            // Read the contents of Dropbox selected file on background thread so that main thread is not blocked
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSError  *error ;
//                DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@",self.dropboxDeviceRecordDataYearListStringToSend]];
//                NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//                NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//                for (DBFileInfo *info in dBArray) {
//                    [tmpArray addObject:info.path.name];
//                }
                NSMutableArray *dropboxDeviceRecordYearList = [NSMutableArray arrayWithArray:self.dropboxDeviceRecordDataYearFileContents];
                ddrdmvc.dropboxDeviceRecordDataMonthList = dropboxDeviceRecordYearList;
                ddrdmvc.dropboxDeviceRecordDataMonthParentPathName = self.dropboxDeviceRecordDataYearListStringToSend;
                ddrdmvc.rowIndexPathFromDropboxDeviceRecordDataYearViewController = self.dropboxDeviceRecordDataYearListStringToSend;
            });
        }
    }
}

#pragma mark - Check for Internet connection

-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        self.NetworkAvailable = NO;  // No Internet Connection
        return NO;
    }
    else{
        self.NetworkAvailable = YES;  // Has Internet Connection
        return YES;
    }
}


//加载所有文档信息
- (void)loadDocuments
{
    [self.dropboxDeviceRecordDataYearList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //        NSString *path = [item valueForAttribute:NSMetadataItemPathKey];
        //        NSString *contentType = [item valueForAttribute:NSMetadataItemContentTypeKey];
        //        NSString *displayName = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        [self.recordedDataContentsUrl addObject:url];
        [self createRootArray:url fileName:fileName];
    }];
}

// 产生rootPath
- (void)createRootArray:(NSURL *)url fileName:(NSString *)fileName
{
    // 判断url是否是root path
    NSURL *parentPath = [url URLByDeletingLastPathComponent];
    
    if ([parentPath.lastPathComponent isEqualToString:self.dropboxDeviceRecordDataYearParentPathName.lastPathComponent]) {
        NSLog(@"url is root path");
        [self.dropboxDeviceRecordDataYearRootList addObject:fileName];
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxDeviceRecordDataYearView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    [self.dropboxDeviceRecordDataYearList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSMetadataItem *item = obj;
        NSURL *url = [[item valueForAttribute:NSMetadataItemURLKey] URLByDeletingLastPathComponent];
        
        if ([url.pathComponents containsObject:rootPath]) {
            NSLog(@"%@属于rootPath:%@", url, rootPath);
            [childItems addObject:obj];
        } else {
            NSLog(@"%@不属于rootPath:%@", url, rootPath);
        }
    }];
    
    return childItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
