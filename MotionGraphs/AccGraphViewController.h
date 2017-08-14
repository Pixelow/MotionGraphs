//
//  AccGraphViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 7/10/15.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface AccGraphViewController : UIViewController <CPTPlotDataSource>
{
    CPTGraph *graph;
}

@property (readwrite, nonatomic) NSMutableArray *scatterPlotData;

@property (strong,nonatomic) NSMutableArray *accArrayX;
@property (strong,nonatomic) NSMutableArray *accArrayY;
@property (strong,nonatomic) NSMutableArray *accArrayZ;
@property (nonatomic) double samplingRate;

- (void)drawTimeHistoryPlot:(NSMutableArray *)accArray;

@end
