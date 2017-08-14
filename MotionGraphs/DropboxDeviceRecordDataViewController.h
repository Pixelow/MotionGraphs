//
//  DropboxDeviceRecordDataViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface DropboxDeviceRecordDataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak,nonatomic) IBOutlet UITableView *dropboxDeviceRecordView;

@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordList;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordFileContents;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordRootList;
@property (strong,nonatomic) NSString *dropboxDeviceRecordParentPathName;
@property (strong,nonatomic) NSString *dropboxDeviceRecordListStringToSend;
@property (strong,nonatomic) NSString *rowIndexPathFromDropboxDeviceRecordDataDayViewController;

@end
