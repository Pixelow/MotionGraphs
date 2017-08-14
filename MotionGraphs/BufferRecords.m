//
//  BufferRecords.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/24/15.
//
//

#import "BufferRecords.h"
#import "APLDocument.h"

#define UBIQUITY_CONTAINER_URL @"iCloud.com.saitama.MotionGraphs"

@implementation BufferRecords

-(NSDateFormatter *)dateFormatter
{
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    return _dateFormatter;
}


-(NSMutableArray *)bufferStringArray
{
    NSMutableArray *stringArray = [[NSMutableArray alloc]init];
    if (self.acceleros.count) {
        for (Accelero *acc in self.acceleros) {
            [stringArray addObject:acc.content];
        }
    }
    return stringArray;
}


-(float)triggerThreshold
{
    _triggerThreshold = 20;   // trigger Threshold set to 15 gal
    return _triggerThreshold;
}

-(float)bufferLength
{
    _bufferLength = 60.0;       // buffer Length set to 60 secs
    return _bufferLength;
}


-(id)checkTriggerValue:(AccelerationRecords *)bufferAcc WithRemoteSyncStatus:(BOOL)switchStatus WithTriggerThreshold:(float)triggerThreshold
{
    if (!triggerThreshold) {
        triggerThreshold = self.triggerThreshold;
    }
    
    self.accCount=self.acceleros.count;
    
    self.xmean = self.xsum+(bufferAcc.x/self.accCount);
    self.ymean = self.ysum+(bufferAcc.y/self.accCount);
    self.zmean = self.zsum+(bufferAcc.z/self.accCount);
    
    self.xsum = self.xmean*(self.accCount/(self.accCount+1));
    self.ysum = self.ymean*(self.accCount/(self.accCount+1));
    self.zsum = self.zmean*(self.accCount/(self.accCount+1));
    
    //self.accPGA = sqrt((bufferAcc.x-self.xmean)*(bufferAcc.x-self.xmean)+(bufferAcc.y-self.ymean)*(bufferAcc.y-self.ymean)+(bufferAcc.z-self.zmean)*(bufferAcc.z-self.zmean));
    
    self.accPGA = sqrt((bufferAcc.x-self.xmean)*(bufferAcc.x-self.xmean)+(bufferAcc.y-self.ymean)*(bufferAcc.y-self.ymean));
    
    if (self.accPGA>self.maxPGA) {
        self.maxPGA = self.accPGA;
    }
    
    if (self.accPGA>triggerThreshold) {
        
        self.AreWeTriggered = YES;
        
        // Set Notification for Remote Triggered
        if (switchStatus==TRUE) {
            [self setTriggerNotification];
        }
        
        self.accCount=0; self.accPGA=0;
        self.xsum=0; self.ysum=0; self.zsum=0;
        
    }else{
        
        self.AreWeTriggered = NO;
    }
    
    return self;
}


-(id)checkBufferTimeWithStartTime:(NSDate *)startBufferDate WithEndTime:(NSDate *)endBufferDate WithAccelerationRecords:(AccelerationRecords *)bufferAcc WithBufferLength:(float)bufferLengthTime
{
    if (!bufferLengthTime) {
        bufferLengthTime=self.bufferLength;
    }
    
    double bufferTimeElapsed = fabs([startBufferDate timeIntervalSinceDate:endBufferDate]);
    if(bufferTimeElapsed>bufferLengthTime)
    {
        self.bufferTimeLimitExceeded = YES;
        [self removeAcceleros:bufferAcc];
    }
    
    return self;
}



-(void)setTriggerNotification
{
//    NSDate *date = [NSDate date];
//    NSString *notificationFilename = [NSString stringWithFormat:@"%@ at %@.txt",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//    NSString *messageString = [NSString stringWithFormat:@"Device Triggered info: %@ \n %@",[[UIDevice currentDevice]name],[self.dateFormatter stringFromDate:date].description];
//    
//    // Upload file to Dropbox
//   // NSString *folderName = @"Triggered Info";
//    NSString *destDir = [NSString stringWithFormat:@"/%@/%@",@"Supporting Files",@"Triggered Info"];
//    
//    [self saveToiCloud:destDir fileName:notificationFilename filePath:nil fileContent:messageString];
    
    
//    DBPath *newPath = [[DBPath root]childPath:destDir];
//    DBFile *file = [[DBFilesystem sharedFilesystem]createFile:newPath error:nil];
//    [file writeString:messageString error:nil];
}

#pragma mark - iCloud Drive

/*
 取得云端存储文件的地址
 destinationDiractory 目标文件夹，如果云端不存在，则创建一个文件夹
 return 地址
 */

- (NSURL *)getUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName {
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL];
    //取得Documents目录
    url = [url URLByAppendingPathComponent:@"Documents"];
    url = [url URLByAppendingPathComponent:destinationDiractory];
    
    if ([manager fileExistsAtPath:[url path]] == NO)
    {
        NSLog(@"iCloud Documents directory does not exist");
        //创建M路径
        [manager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"iCloud Documents directory exist");
    }
    
    //取得最终地址
    url = [url URLByAppendingPathComponent:fileName];
    
    return url;
}


- (void)saveToiCloud:(NSString *)destinationDiractory fileName:(NSString *)fileName filePath:(NSString *)filePath fileContent:(NSString *)fileContent
{
    NSString *fileUrl = [NSString stringWithFormat:@"%@",fileName];
    NSURL *url = [self getUbiquityFileURL:destinationDiractory fileName:fileUrl];
    //    NSString *fileNameString = fileName;
    
    APLDocument *document = [[APLDocument alloc] initWithFileURL:url];
    document.data = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!filePath) {
        
    }
    
    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"创建文档成功.");
        } else {
            NSLog(@"创建文档失败.");
        }
    }];
}


@end
