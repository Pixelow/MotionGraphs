//
//  Common.h
//  CustomControl
//
//  Created by M on 12/31/13.
//

#import <UIKit/UIKit.h>

typedef struct{
    double radius;
    double angle;
} SAPolarCoordinate;

CGFloat toDegrees (CGFloat radians);
CGFloat toRadians (CGFloat degrees);

CGFloat segmentAngle (CGPoint startPoint, CGPoint endPoint);
CGFloat segmentLength(CGPoint startPoint, CGPoint endPoint);

CGPoint polarToDecart(CGPoint startPoint, CGFloat radius, CGFloat angle);
SAPolarCoordinate decartToPolar(CGPoint center, CGPoint point);
