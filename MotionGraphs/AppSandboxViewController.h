//
//  AppSandboxViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 11/13/14.
//
//

#import <UIKit/UIKit.h>
#import "SeismicRecords.h"

@interface AppSandboxViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myAppSandboxTableView;
@property (strong,nonatomic) NSString *appSandboxRecordNeedToSend;
@property (strong,nonatomic) NSMutableArray *fileContents;

@end
