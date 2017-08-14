//
//  AppSandboxViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 11/13/14.
//
//

#import "AppSandboxViewController.h"
#import "SandboxDetailViewController.h"

@interface AppSandboxViewController () <UIAlertViewDelegate>

@end

@implementation AppSandboxViewController

@synthesize myAppSandboxTableView, fileContents;

- (void)viewWillAppear:(BOOL)animated {
    [self loadData];
    [myAppSandboxTableView reloadData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    myAppSandboxTableView.backgroundColor = [UIColor whiteColor];
    
    self.myAppSandboxTableView.delegate=self;
    self.myAppSandboxTableView.dataSource=self;
    
    //set the title
    self.title = NSLocalizedString(@"SandBox","");
    
    // Do any additional setup after loading the view.
    
    // 读取初始数据
    [self loadData];
    
    // 下拉刷新（也不需要）
//    [self setupRefresh];
}

- (void)loadData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    fileContents = [[NSMutableArray alloc]initWithArray:[[NSFileManager defaultManager]contentsOfDirectoryAtPath:documentDirectory error:nil]];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [myAppSandboxTableView setEditing:editing animated:animated];
}


- (NSMutableArray *)fileContents{
    if (!fileContents) {
        fileContents = [[NSMutableArray alloc]init];
    }
    return fileContents;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.appSandboxRecordNeedToSend = [fileContents.reverseObjectEnumerator.allObjects objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"detailappsandboxseque" sender:self];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fileContents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell (with reversing the order of elements - the most recent file at top of table view )
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[fileContents.reverseObjectEnumerator.allObjects objectAtIndex:indexPath.row]];
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"detailappsandboxseque"]) {
        if ([segue.destinationViewController isKindOfClass:[SandboxDetailViewController class]]) {
            NSLog(@"Linked To SandboxDetail View");
            
            SandboxDetailViewController *asdvc = segue.destinationViewController;
            
            NSIndexPath *cellPath = [self.myAppSandboxTableView indexPathForSelectedRow];
            UITableViewCell *theCell = [self.myAppSandboxTableView cellForRowAtIndexPath:cellPath];
            asdvc.navigationItem.title = theCell.textLabel.text;
            
            // Read the contents of app sandbox selected file.
            NSError *error = nil;
            NSURL *documentsUrl = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
            NSString *contents = [NSString stringWithContentsOfURL:[documentsUrl URLByAppendingPathComponent:self.appSandboxRecordNeedToSend] encoding:NSUTF8StringEncoding error:&error];
           // NSLog(@"contents: %@",contents);
            
            asdvc.appRecordData = contents;
            asdvc.fileNameToPass = self.appSandboxRecordNeedToSend;
            
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        //Remove data individually from sandbox using table view

        NSString *fileName = [fileContents objectAtIndex:fileContents.count-indexPath.row-1];
        NSString *path;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.appSandboxRecordNeedToSend];
        path = [path stringByAppendingPathComponent:fileName];
        NSError *error;
        
        //Remove cell
        
        [fileContents removeObjectAtIndex:fileContents.count-indexPath.row-1];
        [myAppSandboxTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [myAppSandboxTableView reloadData];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
            {
                NSLog(@"Delete file error: %@", error);
            }
        }
        
    }
}


- (IBAction)deleteSandboxFiles:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Empty App SandBox!!" message:@"Do you really want to delete all files ?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        // Delete all the files in sandbox
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        NSFileManager *filemgr = [[NSFileManager alloc]init];
        NSError *error = nil;
        NSArray *directoryContents = [filemgr contentsOfDirectoryAtPath:documentDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath= [documentDirectory stringByAppendingPathComponent:path];
                [filemgr removeItemAtPath:fullPath error:&error];
                
                [self loadData];
                [myAppSandboxTableView reloadData];
            }
        }
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc presentViewController:alertController animated:YES completion:nil];
    
}


// -------------------- 下拉刷新（暂不需要） ---------------------------

-(void)setupRefresh
{
    // 1.添加刷新控件
    UIRefreshControl *control=[[UIRefreshControl alloc] init];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在加载数据..."];
    [control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.myAppSandboxTableView addSubview:control];
    
    // 2.马上进入刷新状态，并不会触发UIControlEventValueChanged事件
    [control beginRefreshing];
    
    // 3.加载数据
    [self refreshStateChange:control];
}

-(void)refreshStateChange:(UIRefreshControl *)control
{
    [self loadData];
    [myAppSandboxTableView reloadData];
    // 4.结束刷新
    [control endRefreshing];
}

@end
