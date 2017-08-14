//
//  AppSandboxDetailViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 11/13/14.
//
//

#import <UIKit/UIKit.h>
#import <MacTypes.h>
#import <stdio.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

@interface AppSandboxDetailViewController : UIViewController

@property (strong,nonatomic) NSString *appRecordData;
@property (strong,nonatomic) NSString *fileNameToPass;
@property (nonatomic) float FFTXmax, FFTYmax, FFTZmax, dominantFrequencyX, dominantFrequencyY, dominantFrequencyZ;

-(void)separateAccAndGyroRecords;
-(void)performFFTAnalysis;
-(void)emptyRecordArrays;

@end
