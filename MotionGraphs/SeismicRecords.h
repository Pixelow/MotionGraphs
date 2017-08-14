//
//  SeismicRecords.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/24/15.
//
//

#import "BufferRecords.h"

@interface SeismicRecords : BufferRecords

@property (strong,nonatomic) NSMutableArray *seismicStringArray;
@property (nonatomic) float recordLength, maxValue;
@property (strong,nonatomic) NSMutableArray *accPGAArray;
@property (nonatomic) double eventTimeElapsed;
@property (strong,nonatomic) NSDate *eventCheckDate;


-(id)checkTriggerValue:(AccelerationRecords *)seismicAcc
                    WithRemoteSyncStatus:(BOOL)switchStatus
                    WithTriggerThreshold:(float)triggerThreshold;

-(id)checkRecordTimeWithStartTime:(NSDate *)startRecordDate
                      WithEndTime:(NSDate *)endRecordDate
                   WithRecordTime:(float)seismicRecordTime;

-(id)checkEventOfRecordingForAllActiveDevices: (NSDate *)recordingEventCheckDate;

@end
