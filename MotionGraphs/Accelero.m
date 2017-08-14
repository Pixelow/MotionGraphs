//
//  Accelero.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/28/14.
//
//

#import "Accelero.h"

@implementation Accelero


- (id)initWithDataX:(float)x withY:(float)y withZ:(float)z withThetaX:(float)thetaX withThetaY:(float)thetaY withThetaZ:(float)thetaZ {
    self = [super init];
    
    if (self) {
        self.x=x;
        self.y=y;
        self.z=z;
        self.thetaX=thetaX;
        self.thetaY=thetaY;
        self.thetaZ=thetaZ;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
        self.date = [dateFormatter stringFromDate:[NSDate date]];
    }
    
    NSString *contentString = @"";
    
    contentString = [contentString stringByAppendingString:self.date.description];
    contentString = [contentString stringByAppendingString:[NSString stringWithFormat:@"; %.3f; %.3f; %.3f; %.3f; %.3f; %.3f; \n", self.x, self.y, self.z, self.thetaX, self.thetaY, self.thetaZ]];
    
    self.content = contentString;
    return self;
}


@end
