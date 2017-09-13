//
//  APLCloud.h
//  MotionGraphs
//
//  Created by Msm on 13/09/2017.
//
//

#import <Foundation/Foundation.h>

@interface APLCloud : NSObject

- (NSURL *)getUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName;
- (void)saveToiCloud:(NSString *)destinationDiractory fileName:(NSString *)fileName filePath:(NSString *)filePath fileContent:(NSString *)fileContent;
- (NSURL *)queryUbiquityFileURL:(NSString *)destinationDiractory fileName:(NSString *)fileName;
- (void)loadQueryUpdate;


@end
