//
//  DropboxDeviceRecordDataDayViewController.h
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface DropboxDeviceRecordDataDayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *dropboxDeviceRecordDataDayView;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataDayList;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataDayFileContents;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataDayRootList;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataDayParentPathName;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataDayListStringToSend;
@property (strong,nonatomic) NSString *rowIndexPathFromDropboxDeviceRecordDataMonthViewController;

@end
