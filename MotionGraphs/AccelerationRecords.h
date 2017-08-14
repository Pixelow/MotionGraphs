//
//  AccelerationRecords.h
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/28/14.
//
//

#import "Accelero.h"
#import <CoreLocation/CoreLocation.h>

@interface AccelerationRecords : Accelero

@property (strong,nonatomic) NSMutableArray *acceleros;
@property (strong,nonatomic) NSMutableArray *locationArray;
@property (strong,nonatomic) NSString *name;
@property (strong, nonatomic) NSString *latitudeLabel;
@property (strong, nonatomic) NSString *longitudeLabel;
@property (strong, nonatomic) NSString *addressLabel;

@property (nonatomic) CLLocationCoordinate2D myCoordinate;

-(void) addAcceleros:(Accelero *)acc;
-(void) removeAcceleros:(Accelero *)acc;
- (id) initWithData:(Accelero *)acc;

@end
