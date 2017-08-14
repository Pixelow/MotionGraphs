//
//  DropboxDeviceRecordDataMonthViewController.m
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import "DropboxDeviceRecordDataMonthViewController.h"
#import "DropboxDeviceRecordDataDayViewController.h"

@interface DropboxDeviceRecordDataMonthViewController ()

@end

@implementation DropboxDeviceRecordDataMonthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dropboxDeviceRecordDataMonthView.delegate=self;
    self.dropboxDeviceRecordDataMonthView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");
    
    [self loadDocuments];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxDeviceRecordDataMonthView setEditing:editing animated:animated];
}

-(NSMutableArray *)dropboxDeviceRecordDataMonthList {
    if (!_dropboxDeviceRecordDataMonthList) {
        _dropboxDeviceRecordDataMonthList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordDataMonthList;
}

-(NSMutableArray *)dropboxDeviceRecordDataMonthRootList {
    if (!_dropboxDeviceRecordDataMonthRootList) {
        _dropboxDeviceRecordDataMonthRootList = [[NSMutableArray alloc]init];
    }
    return _dropboxDeviceRecordDataMonthRootList;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dropboxDeviceRecordDataMonthListStringToSend = [NSString stringWithFormat:@"/%@/%@",self.rowIndexPathFromDropboxDeviceRecordDataYearViewController, [self.dropboxDeviceRecordDataMonthRootList objectAtIndex:indexPath.row]];
    self.dropboxDeviceRecordDataMonthFileContents = [self childItemsInRoot:self.dropboxDeviceRecordDataMonthListStringToSend.lastPathComponent];
    [self performSegueWithIdentifier:@"dropboxDeviceRecordDataDayViewControllerSeque" sender:self];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropboxDeviceRecordDataMonthRootList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.dropboxDeviceRecordDataMonthRootList objectAtIndex:indexPath.row]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"dropboxDeviceRecordDataDayViewControllerSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[DropboxDeviceRecordDataDayViewController class]]) {
            NSLog(@"Linked To Dropbox Device Record Data Day View");
            
            DropboxDeviceRecordDataDayViewController *ddrddvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxDeviceRecordDataMonthView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.dropboxDeviceRecordDataMonthView cellForRowAtIndexPath:cellPath];
            ddrddvc.navigationItem.title = theCell.textLabel.text;
            
            // Read the contents of Dropbox selected file on background thread so that main thread is not blocked
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSError  *error ;
//                DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@",self.dropboxDeviceRecordDataMonthListStringToSend]];
//                NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//                NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//                for (DBFileInfo *info in dBArray) {
//                    [tmpArray addObject:info.path.name];
//                }

                NSMutableArray *dropboxDeviceRecordMonthList = [NSMutableArray arrayWithArray:self.dropboxDeviceRecordDataMonthFileContents];
                ddrddvc.dropboxDeviceRecordDataDayList = dropboxDeviceRecordMonthList;
                ddrddvc.dropboxDeviceRecordDataDayParentPathName = self.dropboxDeviceRecordDataMonthListStringToSend;
                ddrddvc.rowIndexPathFromDropboxDeviceRecordDataMonthViewController = self.dropboxDeviceRecordDataMonthListStringToSend;
            });
        }
    }
}


//加载所有文档信息
- (void)loadDocuments
{
    [self.dropboxDeviceRecordDataMonthList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    
    if ([parentPath.lastPathComponent isEqualToString:self.dropboxDeviceRecordDataMonthParentPathName.lastPathComponent]) {
        NSLog(@"url is root path");
        [self.dropboxDeviceRecordDataMonthRootList addObject:fileName];
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxDeviceRecordDataMonthView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    [self.dropboxDeviceRecordDataMonthList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
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
