//
//  FFTGraphViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 5/20/15.
//
//

#import <UIKit/UIKit.h>
#import "APLAppDelegate.h"

@interface FFTGraphViewController : UIViewController <CPTPlotDataSource>
{
    CPTGraph *graph;
}

@property (readwrite, nonatomic) NSMutableArray *scatterPlotData;

@property (strong,nonatomic) NSMutableArray *fftArrayX;
@property (strong,nonatomic) NSMutableArray *fftArrayY;
@property (strong,nonatomic) NSMutableArray *fftArrayZ;
@property (nonatomic) double samplingRate;

- (void)drawFFTPlot:(NSMutableArray *)fftArray;

@end
