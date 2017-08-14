//
//  MapViewController.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/13/16.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "APLAppDelegate.h"

@interface MapViewController : UIViewController

@property (strong,nonatomic) NSString *latitudeValue;
@property (strong,nonatomic) NSString *longitudeValue;
@property (strong,nonatomic) NSString *pgaValue;
@end
