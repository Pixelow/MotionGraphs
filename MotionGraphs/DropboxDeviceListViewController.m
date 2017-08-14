//
//  DropboxRecordListViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import "DropboxDeivceListViewController.h"
#import "DropboxDeviceRecordDataYearViewController.h"

@interface DropboxDeviceListViewController ()

@end

@implementation DropboxDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dropboxDeviceListView.delegate=self;
    self.dropboxDeviceListView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");

    [self loadDocuments];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxDeviceListView setEditing:editing animated:animated];
}

-(NSMutableArray *)dropboxDeviceList{
    if (!_dropboxDeviceList) {
        _dropboxDeviceList = [[NSMutableArray alloc] init];
    }
    return _dropboxDeviceList;
}

-(NSMutableArray *)dropboxDeviceRootList{
    if (!_dropboxDeviceRootList) {
        _dropboxDeviceRootList = [[NSMutableArray alloc] init];
    }
    return _dropboxDeviceRootList;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dropboxDeviceListStringToSend = [NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxViewController, [self.dropboxDeviceRootList objectAtIndex:indexPath.row]];
    self.dropboxDeviceFileContents = [self childItemsInRoot:self.dropboxDeviceListStringToSend.lastPathComponent];
    [self performSegueWithIdentifier:@"dropboxDeviceRecordDataYearViewControllerSeque" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxDeviceRootList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    
    NSString *iCloudDriveRootPath;
    if ([[self.dropboxDeviceRootList objectAtIndex:indexPath.row] isEqualToString:@"Force Remote Stop Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Force Remote Stop Info", "");
    } else if ([[self.dropboxDeviceRootList objectAtIndex:indexPath.row] isEqualToString:@"Force Remote Start Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Force Remote Start Info", "");
    } else if ([[self.dropboxDeviceRootList objectAtIndex:indexPath.row] isEqualToString:@"Triggered Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Triggered Info", "");
    } else if ([[self.dropboxDeviceRootList objectAtIndex:indexPath.row] isEqualToString:@"Remote Stop Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Remote Stop Info", "");
    } else if ([[self.dropboxDeviceRootList objectAtIndex:indexPath.row] isEqualToString:@"Remote Start Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Remote Start Info", "");
    } else {
        iCloudDriveRootPath = [NSString stringWithFormat:@"%@", [self.dropboxDeviceRootList objectAtIndex:indexPath.row]];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", iCloudDriveRootPath];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dropboxDeviceRootList objectAtIndex:indexPath.row]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"dropboxDeviceRecordDataYearViewControllerSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[DropboxDeviceRecordDataYearViewController class]]) {
            NSLog(@"Linked To Dropbox Device Record Data Year View");
            
            DropboxDeviceRecordDataYearViewController *ddrdyvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxDeviceListView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.dropboxDeviceListView cellForRowAtIndexPath:cellPath];
            ddrdyvc.navigationItem.title = theCell.textLabel.text;
            
            // Read the contents of Dropbox selected file on background thread so that main thread is not blocked
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSError  *error ;
//                DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@",self.dropboxDeviceListStringToSend]];
//                NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//                NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//                for (DBFileInfo *info in dBArray) {
//                    [tmpArray addObject:info.path.name];
//                }
                NSMutableArray *dropboxDeviceRecordList = [NSMutableArray arrayWithArray:self.dropboxDeviceFileContents];
                ddrdyvc.dropboxDeviceRecordDataYearList = dropboxDeviceRecordList;
                ddrdyvc.rowIndexPathFromDropboxDeviceListViewController = self.dropboxDeviceListStringToSend;
                ddrdyvc.dropboxDeviceRecordDataYearParentPathName = self.dropboxDeviceListStringToSend;
                ddrdyvc.checkStringForRecordedDataOnly = self.rowIndexPathFromDropboxViewController;
            });
        }
    }
}


//加载所有文档信息
- (void)loadDocuments
{
    [self.dropboxDeviceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        //        NSString *path = [item valueForAttribute:NSMetadataItemPathKey];
        //        NSString *contentType = [item valueForAttribute:NSMetadataItemContentTypeKey];
        //        NSString *displayName = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        //        [self.iCloudDriveFileContents addObject:url];
        [self createRootArray:url fileName:fileName];
    }];
}

// 产生rootPath
- (void)createRootArray:(NSURL *)url fileName:(NSString *)fileName
{
    // 判断url是否是root path
    NSURL *parentPath = [url URLByDeletingLastPathComponent];
    
    if ([parentPath.lastPathComponent isEqualToString:self.dropboxDeviceParentPathName]) {
        NSLog(@"url is root path");
        [self.dropboxDeviceRootList addObject:fileName];
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxDeviceListView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    [self.dropboxDeviceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
