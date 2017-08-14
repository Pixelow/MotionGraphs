//
//  DropboxDeviceRecordDataViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import "DropboxDeviceRecordDataViewController.h"
#import "SandboxDetailViewController.h"
#import "RecordSettingViewController.h"
#import "APLDocument.h"
#include <netdb.h>   // Framework required to check internet connection

@interface DropboxDeviceRecordDataViewController ()

@property BOOL NetworkAvailable;
@property (strong,nonatomic) NSString *recordedDataContent;
@property (strong,nonatomic) NSMutableArray *recordedDataContentsUrl;

@end

@implementation DropboxDeviceRecordDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dropboxDeviceRecordView.delegate=self;
    self.dropboxDeviceRecordView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");
    
    [self loadDocuments];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxDeviceRecordView setEditing:editing animated:animated];
}

-(NSMutableArray *)dropboxDeviceRecordList {
    if (!_dropboxDeviceRecordList) {
        _dropboxDeviceRecordList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordList;
}

-(NSMutableArray *)dropboxDeviceRecordRootList {
    if (!_dropboxDeviceRecordRootList) {
        _dropboxDeviceRecordRootList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordRootList;
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
    self.dropboxDeviceRecordListStringToSend = [NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxDeviceRecordDataDayViewController, [self.dropboxDeviceRecordRootList.reverseObjectEnumerator.allObjects objectAtIndex:indexPath.row]];
    
    // ----------------- Check if internet connection is Available. If YES then only perform seque -----------------------------
    [self isNetworkAvailable];
    
    if (self.NetworkAvailable) {
        
        // ------------------------ Read Record String from the Specified Path --------------------------------------------
        //        DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"%@",self.dropboxDeviceRecordListStringToSend]];
        //        DBFile *readFile = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
        //        self.recordedDataContents = [readFile readString:nil];
        // ----------------------------------------------------------------------------------------------------------------
        
        // Perform seque
        [self performSegueWithIdentifier:@"detailRecordDataSeque" sender:self];
        
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Dropbox files cannot be viewed in offline mode" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
    // -----------------------------------------------------------------------------------------------------
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxDeviceRecordRootList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dropboxDeviceRecordRootList.reverseObjectEnumerator.allObjects objectAtIndex:indexPath.row]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"detailRecordDataSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[SandboxDetailViewController class]]) {
            NSLog(@"Linked To Detail RecordData View");
            
            SandboxDetailViewController *asdvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxDeviceRecordView indexPathForSelectedRow];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[self.recordedDataContentsUrl[cellPath.row] path]]) {
                
                APLDocument *dropboxDeviceRecord = [APLDocument alloc];
                
                NSURL *correctUrl = [[self.recordedDataContentsUrl[cellPath.row] URLByDeletingLastPathComponent] URLByAppendingPathComponent:[self.dropboxDeviceRecordRootList.reverseObjectEnumerator.allObjects objectAtIndex:cellPath.row]];
                
                [dropboxDeviceRecord readFromURL:correctUrl error:nil];
                self.recordedDataContent = [[NSString alloc] initWithData:dropboxDeviceRecord.data encoding:NSUTF8StringEncoding];
                
                UITableViewCell *theCell = [self.dropboxDeviceRecordView cellForRowAtIndexPath:cellPath];
                asdvc.navigationItem.title = theCell.textLabel.text;
                asdvc.appRecordData = self.recordedDataContent;
                asdvc.fileNameToPass = self.dropboxDeviceRecordListStringToSend;
                
            } else {
                
                // Do not perform seque instead present the information in alert view
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notice" message:@"Please download from the iCloud Drive App first." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [vc presentViewController:alertController animated:YES completion:nil];
                
            }
            

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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        // iCloud未替换
        
        //Remove data individually from dropbox using table view
        
        //        DBPath *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxDeviceRecordDataDayViewController, [self.dropboxDeviceRecordList objectAtIndex:self.dropboxDeviceRecordList.count-indexPath.row-1]]];
        //        [[DBFilesystem sharedFilesystem]deletePath:path error:nil];
        
        //Remove cell
        
        [self.dropboxDeviceRecordList removeObjectAtIndex:self.dropboxDeviceRecordList.count-indexPath.row-1];
        [self.dropboxDeviceRecordView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.dropboxDeviceRecordView reloadData];
        
    }
}


//加载所有文档信息
- (void)loadDocuments
{
    [self.dropboxDeviceRecordList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //        NSString *path = [item valueForAttribute:NSMetadataItemPathKey];
        //        NSString *contentType = [item valueForAttribute:NSMetadataItemContentTypeKey];
        //        NSString *displayName = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        //        [self.iCloudDriveFileContents addObject:url];
        
        [self.recordedDataContentsUrl addObject:url];
        [self createRootArray:url fileName:fileName];
    }];
}

// 产生rootPath
- (void)createRootArray:(NSURL *)url fileName:(NSString *)fileName
{
    // 判断url是否是root path
    NSURL *parentPath = [url URLByDeletingLastPathComponent];
    
    if ([parentPath.lastPathComponent isEqualToString:self.dropboxDeviceRecordParentPathName.lastPathComponent]) {
        NSLog(@"url is root path");
        [self.dropboxDeviceRecordRootList addObject:fileName];
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxDeviceRecordView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    [self.dropboxDeviceRecordList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
