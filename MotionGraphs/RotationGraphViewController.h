//
//  RotationGraphViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/4/16.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface RotationGraphViewController : UIViewController <CPTPlotDataSource>
{
    CPTGraph *graph;
}

@property (readwrite, nonatomic) NSMutableArray *scatterPlotData;

@property (strong,nonatomic) NSMutableArray *gyroArrayX;
@property (strong,nonatomic) NSMutableArray *gyroArrayY;
@property (strong,nonatomic) NSMutableArray *gyroArrayZ;
@property (nonatomic) double samplingRate;

- (void)drawTimeHistoryPlot:(NSMutableArray *)gyroArray;

@end
