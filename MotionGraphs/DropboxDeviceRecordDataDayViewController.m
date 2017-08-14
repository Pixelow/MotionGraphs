//
//  DropboxDeviceRecordDataDayViewController.m
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import "DropboxDeviceRecordDataDayViewController.h"
#import "DropboxDeviceRecordDataViewController.h"

@interface DropboxDeviceRecordDataDayViewController ()

@end

@implementation DropboxDeviceRecordDataDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dropboxDeviceRecordDataDayView.delegate=self;
    self.dropboxDeviceRecordDataDayView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");
    
    [self loadDocuments];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxDeviceRecordDataDayView setEditing:editing animated:animated];
}

-(NSMutableArray *)dropboxDeviceRecordDataDayList {
    if (!_dropboxDeviceRecordDataDayList) {
        _dropboxDeviceRecordDataDayList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordDataDayList;
}

-(NSMutableArray *)dropboxDeviceRecordDataDayRootList {
    if (!_dropboxDeviceRecordDataDayRootList) {
        _dropboxDeviceRecordDataDayRootList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordDataDayRootList;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dropboxDeviceRecordDataDayListStringToSend = [NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxDeviceRecordDataMonthViewController, [self.dropboxDeviceRecordDataDayRootList objectAtIndex:indexPath.row]];
    self.dropboxDeviceRecordDataDayFileContents = [self childItemsInRoot:self.dropboxDeviceRecordDataDayListStringToSend.lastPathComponent];
    [self performSegueWithIdentifier:@"dropboxDeviceRecordDataViewControllerSeque" sender:self];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxDeviceRecordDataDayRootList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dropboxDeviceRecordDataDayRootList objectAtIndex:indexPath.row]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"dropboxDeviceRecordDataViewControllerSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[DropboxDeviceRecordDataViewController class]]) {
            NSLog(@"Linked To Dropbox Device Record Data Day View");
            
            DropboxDeviceRecordDataViewController *ddrdvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxDeviceRecordDataDayView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.dropboxDeviceRecordDataDayView cellForRowAtIndexPath:cellPath];
            ddrdvc.navigationItem.title = theCell.textLabel.text;
            
            // Read the contents of Dropbox selected file on background thread so that main thread is not blocked
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSError  *error ;
//                DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@",self.dropboxDeviceRecordDataDayListStringToSend]];
//                NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//                NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//                for (DBFileInfo *info in dBArray) {
//                    [tmpArray addObject:info.path.name];
//                }
                
                NSMutableArray *dropboxDeviceRecordDayList = [NSMutableArray arrayWithArray:self.dropboxDeviceRecordDataDayFileContents];
                ddrdvc.dropboxDeviceRecordList = dropboxDeviceRecordDayList;
                ddrdvc.dropboxDeviceRecordParentPathName = self.dropboxDeviceRecordDataDayListStringToSend;
                ddrdvc.rowIndexPathFromDropboxDeviceRecordDataDayViewController = self.dropboxDeviceRecordDataDayListStringToSend;
            });
        }
    }
}


//加载所有文档信息
- (void)loadDocuments
{
    [self.dropboxDeviceRecordDataDayList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    
    if ([parentPath.lastPathComponent isEqualToString:self.dropboxDeviceRecordDataDayParentPathName.lastPathComponent]) {
        NSLog(@"url is root path");
        [self.dropboxDeviceRecordDataDayRootList addObject:fileName];
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxDeviceRecordDataDayView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    [self.dropboxDeviceRecordDataDayList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
