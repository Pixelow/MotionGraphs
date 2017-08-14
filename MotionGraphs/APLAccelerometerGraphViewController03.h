//
//  APLAccelerometerGraphViewController03.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 12/15/14.
//
//

#import "APLGraphViewController.h"
#import <UIKit/UIKit.h>
#import <MacTypes.h>
#import <stdio.h>
#import <Accelerate/Accelerate.h>

@interface APLAccelerometerGraphViewController03 : APLGraphViewController

@property (strong,nonatomic) NSString *filename;
@property (strong,nonatomic) NSMutableString *dataString;
@property (strong,nonatomic) NSString *dayFolder;
@property (strong,nonatomic) NSString *monthFolder;
@property (strong,nonatomic) NSString *yearFolder;
@property (strong,nonatomic) NSString *recordSummary;

- (IBAction)bufferButton:(UIButton *)sender;

@end
