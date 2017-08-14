//
//  APLWGS84TOGCJ02.h
//  MotionGraphs
//
//  Created by Msm on 23/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface APLWGS84TOGCJ02 : NSObject

//判断是否已经超出中国范围
+(BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
+(BOOL)isLocationInChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end
