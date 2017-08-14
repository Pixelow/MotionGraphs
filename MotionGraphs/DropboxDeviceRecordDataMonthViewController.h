//
//  DropboxDeviceRecordDataMonthViewController.h
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface DropboxDeviceRecordDataMonthViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *dropboxDeviceRecordDataMonthView;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataMonthList;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataMonthFileContents;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataMonthRootList;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataMonthParentPathName;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataMonthListStringToSend;
@property (strong,nonatomic) NSString *rowIndexPathFromDropboxDeviceRecordDataYearViewController;

@end
