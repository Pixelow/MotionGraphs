//
//  RecordHistoryViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/7/14.
//
//

#import <UIKit/UIKit.h>
#import "APLAccelerometerGraphViewController.h"

@interface RecordHistoryViewController : UIViewController

@property (weak,nonatomic) IBOutlet UITextView *recordHistory2;
@property (strong,nonatomic) NSString *recordText;
- (IBAction)btnUploadFileTapped:(id)sender;
@end