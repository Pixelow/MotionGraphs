//
//  BufferRecords.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/24/15.
//
//

#import "AccelerationRecords.h"

@interface BufferRecords : AccelerationRecords

@property (strong,nonatomic) NSMutableArray *bufferStringArray;
@property (nonatomic) float triggerThreshold, bufferLength;
@property (nonatomic) BOOL AreWeTriggered, recordingStopped, bufferTimeLimitExceeded;
@property (strong,nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) float accCount, xsum, ysum, zsum, xmean, ymean, zmean, accPGA, maxPGA;

-(id)checkTriggerValue:(AccelerationRecords *)bufferAcc
                       WithRemoteSyncStatus:(BOOL)switchStatus
                       WithTriggerThreshold:(float)triggerThreshold;

-(id)checkBufferTimeWithStartTime:(NSDate *)startBufferDate
                      WithEndTime:(NSDate *)endBufferDate
          WithAccelerationRecords:(AccelerationRecords *)bufferAcc
                 WithBufferLength:(float)bufferLengthTime;

-(void)setTriggerNotification;

@end
