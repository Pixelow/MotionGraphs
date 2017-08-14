//
//  DropboxDeviceRecordDataYearViewController.h
//  MotionGraphs
//
//  Created by Amir Sohail on 7/20/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"


@interface DropboxDeviceRecordDataYearViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *dropboxDeviceRecordDataYearView;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataYearList;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataYearFileContents;
@property (strong,nonatomic) NSMutableArray *dropboxDeviceRecordDataYearRootList;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataYearParentPathName;
@property (strong,nonatomic) NSString *dropboxDeviceRecordDataYearListStringToSend;
@property (strong,nonatomic) NSString *rowIndexPathFromDropboxDeviceListViewController;
@property (strong,nonatomic) NSString *checkStringForRecordedDataOnly;

@end
