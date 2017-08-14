//
//  DropboxViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/5/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface DropboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak,nonatomic) IBOutlet UITableView *dropboxView;
@property (strong,nonatomic) NSMutableArray *iCloudDriveFileContents;
@property (strong,nonatomic) NSMutableArray *iCloudDriveRootPaths;
@property (strong,nonatomic) NSString *iCloudDriveFileContentStringToSend;


@end
