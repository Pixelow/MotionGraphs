//
//  SeismicRecords.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/24/15.
//
//

#import "SeismicRecords.h"

@implementation SeismicRecords


-(NSMutableArray *)seismicStringArray
{
    NSMutableArray *stringArray = [[NSMutableArray alloc]init];
    if (self.acceleros.count) {
        for (Accelero *acc in self.acceleros) {
            [stringArray addObject:acc.content];
        }
    }
    return stringArray;
}


-(float)recordLength
{
    _recordLength = 60.0;       // seismic record Length set to 60 secs
    return _recordLength;
}


-(id)checkTriggerValue:(AccelerationRecords *)seismicAcc WithRemoteSyncStatus:(BOOL)switchStatus WithTriggerThreshold:(float)triggerThreshold
{
    if (!triggerThreshold) {
        triggerThreshold = self.triggerThreshold;
    }
    
    self.accCount=self.acceleros.count;
    
    self.xmean = self.xsum+(seismicAcc.x/self.accCount);
    self.ymean = self.ysum+(seismicAcc.y/self.accCount);
    self.zmean = self.zsum+(seismicAcc.z/self.accCount);
    
    self.xsum = self.xmean*(self.accCount/(self.accCount+1));
    self.ysum = self.ymean*(self.accCount/(self.accCount+1));
    self.zsum = self.zmean*(self.accCount/(self.accCount+1));
    
   // self.accPGA = sqrt((seismicAcc.x-self.xmean)*(seismicAcc.x-self.xmean)+(seismicAcc.y-self.ymean)*(seismicAcc.y-self.ymean)+(seismicAcc.z-self.zmean)*(seismicAcc.z-self.zmean));
    
    self.accPGA = sqrt((seismicAcc.x-self.xmean)*(seismicAcc.x-self.xmean)+(seismicAcc.y-self.ymean)*(seismicAcc.y-self.ymean));
    
    if (self.accPGA>self.maxPGA) {
        self.maxPGA = self.accPGA;
    }
    
    
    if (self.accPGA>triggerThreshold) {
        self.AreWeTriggered = YES;
        }else{
        self.AreWeTriggered = NO;
    }
    
#pragma mark - Algorithm for checking the condition of still recording in all devices
    
    // ------------------------------- Implementing remote trigger function ----------------------
    
    if (switchStatus==TRUE) {
    
        if (!self.accPGAArray) {
            self.accPGAArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:self.accPGA], nil];
        }else{
            [self.accPGAArray addObject:[NSNumber numberWithFloat:self.accPGA]];
        }
        
        NSTimeInterval serverCheckTimeElapsed = fabs([self.eventCheckDate timeIntervalSinceNow]);

        if (serverCheckTimeElapsed>1.0) {

            for (NSString * max in self.accPGAArray) {
                float currentValue=[max floatValue];
                if (fabs(currentValue) > self.maxValue) {
                    self.maxValue=fabs(currentValue);
                }
            }
            if (self.maxValue>triggerThreshold) {
                
                // Set Notification for Remote Triggered
                [self setTriggerNotification];
            }
            self.eventCheckDate = [NSDate date];
            self.maxValue=0;
            self.accPGAArray=nil;
        }
    }
     
    return self;
}


-(id)checkRecordTimeWithStartTime:(NSDate *)startRecordDate WithEndTime:(NSDate *)endRecordDate WithRecordTime:(float)seismicRecordTime
{
    if (!seismicRecordTime) {
        seismicRecordTime=self.recordLength;
    }
    
    double recordTimeElapsed = fabs([startRecordDate timeIntervalSinceDate:endRecordDate]);

    if (recordTimeElapsed>seismicRecordTime)
    {
        self.recordingStopped = YES;
    }else{
        self.recordingStopped = NO;
    }
    return self;
}


-(id)checkEventOfRecordingForAllActiveDevices:(NSDate *)recordingEventCheckDate
{
    self.eventCheckDate = recordingEventCheckDate;
    return self;
}


@end
