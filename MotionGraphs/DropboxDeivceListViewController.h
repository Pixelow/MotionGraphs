//
//  DropboxRecordListViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface DropboxDeviceListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak,nonatomic) IBOutlet UITableView *dropboxDeviceListView;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceList;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceFileContents;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRootList;
@property (strong,nonatomic) NSString *dropboxDeviceParentPathName;
@property (strong,nonatomic) NSString *dropboxDeviceListStringToSend;
@property (strong,nonatomic) NSString *rowIndexPathFromDropboxViewController;

@end
