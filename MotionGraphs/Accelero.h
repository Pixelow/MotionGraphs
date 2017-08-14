//
//  Accelero.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "APLAppDelegate.h"

@interface Accelero : NSObject

@property (strong,nonatomic) NSString *date;
@property (strong,nonatomic) NSString *content;
@property float x;
@property float y;
@property float z;
@property float thetaX;
@property float thetaY;
@property float thetaZ;


- (id)initWithDataX:(float)x
              withY:(float)y
              withZ:(float)z
         withThetaX:(float)thetaX
         withThetaY:(float)thetaY
         withThetaZ:(float)thetaZ;

@end
