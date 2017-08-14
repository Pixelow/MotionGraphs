//
//  SandboxDetailViewController.h
//  MotionGraphs
//
//  Created by Msm on 23/05/2017.
//
//

#import <UIKit/UIKit.h>
#import <MacTypes.h>
#import <stdio.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

@interface SandboxDetailViewController : UIViewController

@property (strong,nonatomic) NSString *appRecordData;
@property (strong,nonatomic) NSString *fileNameToPass;
@property (nonatomic) float FFTXmax, FFTYmax, FFTZmax, dominantFrequencyX, dominantFrequencyY, dominantFrequencyZ;

- (void)separateAccAndGyroRecords;
- (void)performFFTAnalysis;
- (void)emptyRecordArrays;

@end
