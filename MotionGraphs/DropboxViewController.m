//
//  DropboxViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import "DropboxViewController.h"
#import "DropboxDeivceListViewController.h"

@interface DropboxViewController ()

@property (strong, nonatomic) NSMutableDictionary *files;
@property (strong, nonatomic) NSMetadataQuery *query;

@end

@implementation DropboxViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.query startQuery];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dropboxView.delegate=self;
    self.dropboxView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"Cloud","");
    
    // Read the contents of file from DropBox on background thread so that main thread is not blocked
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSError  *error ;
//        DBPath  *path =  [DBPath root];
//        NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//        NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//        for (DBFileInfo *info in dBArray) {
//            [tmpArray addObject:info.path.name];
//        }
//        self.iCloudDriveFileContents = [NSMutableArray arrayWithArray:tmpArray];
//    });
    [self loadDocuments];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.dropboxView setEditing:editing animated:animated];
}

-(NSMutableArray *)iCloudDriveFileContents {
    if (!_iCloudDriveFileContents) {
        _iCloudDriveFileContents = [[NSMutableArray alloc] init];
    }
    return _iCloudDriveFileContents;
}

-(NSMutableArray *)iCloudDriveRootPaths {
    if (!_iCloudDriveRootPaths) {
        _iCloudDriveRootPaths = [[NSMutableArray alloc] init];
    }
    return _iCloudDriveRootPaths;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.iCloudDriveFileContentStringToSend = [self.iCloudDriveRootPaths objectAtIndex:indexPath.row];
    self.iCloudDriveFileContents = [self childItemsInRoot:self.iCloudDriveFileContentStringToSend];
    [self performSegueWithIdentifier:@"dropboxDeviceListViewcontrollerSeque" sender:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iCloudDriveRootPaths count];
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
    if ([[self.iCloudDriveRootPaths objectAtIndex:indexPath.row] isEqualToString:@"Triggered Data"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Triggered Data", "");
    } else if ([[self.iCloudDriveRootPaths objectAtIndex:indexPath.row] isEqualToString:@"Recorded Data"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Recorded Data", "");
    } else if ([[self.iCloudDriveRootPaths objectAtIndex:indexPath.row] isEqualToString:@"Status Info"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Status Info", "");
    } else if ([[self.iCloudDriveRootPaths objectAtIndex:indexPath.row] isEqualToString:@"Supporting Files"]) {
        iCloudDriveRootPath = NSLocalizedString(@"Supporting Files", "");
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", iCloudDriveRootPath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"dropboxDeviceListViewcontrollerSeque"]) {
        if ([segue.destinationViewController isKindOfClass:[DropboxDeviceListViewController class]]) {
            NSLog(@"Linked To DropboxRecordList View");
            
            DropboxDeviceListViewController *ddlvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.dropboxView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.dropboxView cellForRowAtIndexPath:cellPath];
            ddlvc.navigationItem.title = theCell.textLabel.text;
        
            // Read the contents of Dropbox selected file on background thread so that main thread is not blocked
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSError  *error ;
//                DBPath  *path =  [[DBPath root]childPath:[NSString stringWithFormat:@"/%@",self.iCloudDriveFileContentStringToSend]];
//                NSArray  *dBArray = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
//                NSMutableArray  *tmpArray =  [[NSMutableArray alloc]initWithCapacity:[dBArray count]];
//                for (DBFileInfo *info in dBArray) {
//                    [tmpArray addObject:info.path.name];
//                }
                NSMutableArray *dropboxDeviceList = [NSMutableArray arrayWithArray:self.iCloudDriveFileContents];
                ddlvc.dropboxDeviceList = dropboxDeviceList;
                ddlvc.dropboxDeviceParentPathName = self.iCloudDriveFileContentStringToSend;
                ddlvc.rowIndexPathFromDropboxViewController = self.iCloudDriveFileContentStringToSend;
            });
        }
    }
}


//从iCloud上加载所有文档信息
- (void)loadDocuments
{
    if (!self.query) {
        self.query = [[NSMetadataQuery alloc] init];
        self.query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        
        //注意查询状态是通过通知的形式告诉监听对象的
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataFromiCloudDriveQueryFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];//数据获取完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataFromiCloudDriveDidUpdate:) name:NSMetadataQueryDidUpdateNotification object:self.query];//查询更新通知
    }
    //开始查询
    [self.query startQuery];
}

// 数据获取完成的通知调用
- (void)metadataFromiCloudDriveQueryFinish:(NSNotification *)notification
{
    NSLog(@"数据获取成功！");
    NSArray *items = self.query.results;//查询结果集
    self.files = [NSMutableDictionary dictionary];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
//        NSString *path = [item valueForAttribute:NSMetadataItemPathKey];
//        NSString *contentType = [item valueForAttribute:NSMetadataItemContentTypeKey];
//        NSString *displayName = [item valueForAttribute:NSMetadataItemDisplayNameKey];
//        [self.iCloudDriveFileContents addObject:url];
        [self createRootArray:url fileName:fileName];
    }];
    [self.query stopQuery];
}

// 查询更新
- (void)metadataFromiCloudDriveDidUpdate:(NSNotification *)notification
{
//    [self.query stopQuery];
}

- (void)createRootArray:(NSURL *)url fileName:(NSString *)fileName
{
    // 判断url是否是root path
    NSURL *parentPath = [url URLByDeletingLastPathComponent];
    
    if ([parentPath.lastPathComponent isEqualToString:@"Documents"]) {
        NSLog(@"url is root path");
        if ([self.iCloudDriveRootPaths containsObject:fileName]) {
            
        } else {
            [self.iCloudDriveRootPaths addObject:fileName];
        }
    } else {
        NSLog(@"url is not root path");
    }
    [_dropboxView reloadData];
}

- (NSMutableArray *)childItemsInRoot:(NSString *)rootPath
{
    NSMutableArray *childItems = [[NSMutableArray alloc] init];
    
    NSArray *items = self.query.results;
    self.files = [NSMutableDictionary dictionary];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSMetadataItem *item = obj;
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
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
