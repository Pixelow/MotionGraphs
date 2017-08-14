//
//  AccelerationRecords.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 10/28/14.
//
//

#import "AccelerationRecords.h"
#import "APLWGS84TOGCJ02.h"

@interface AccelerationRecords() <CLLocationManagerDelegate>

@end

@implementation AccelerationRecords
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

-(NSMutableArray *)acceleros
{
    if (!_acceleros) {
        NSMutableArray *acc=[[NSMutableArray alloc]init];
        return acc;
    }else{
        return _acceleros;
    }
}

-(void)addAcceleros:(Accelero *)acc
{
    if (!self.acceleros) {
        self.acceleros = [[NSMutableArray alloc]init];
        [self.acceleros addObject:acc];
    }else{
        [self.acceleros addObject:acc];
    }
    
}

-(void)removeAcceleros:(Accelero *)acc
{
    [self.acceleros removeObjectAtIndex:0];
    
}

- (id) initWithData:(Accelero *)acc
{
    self = [super init];
    if (self) {
        self.acceleros = [NSMutableArray arrayWithObject:acc];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
        NSString *startTime = [dateFormatter stringFromDate:[NSDate date]];
        self.name = startTime.description;
    }
    return self;
}

-(NSMutableArray *)locationArray
{
    [self myCoordinate];
    NSMutableArray *locationArray = [[NSMutableArray alloc]initWithObjects:self.longitudeLabel, self.latitudeLabel, self.addressLabel, nil];
    return locationArray;
}

-(CLLocationCoordinate2D)myCoordinate
{
    //--------------------------- Initialize Location Updates --------------------------------
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    // ---------------------------------------------------------------------------------------
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    if ([APLWGS84TOGCJ02 isLocationInChina:coordinate]) {
        
        coordinate = [APLWGS84TOGCJ02 transformFromWGSToGCJ:coordinate];
        
        self.longitudeLabel = [NSString stringWithFormat:@"\n\u2022 longitude:%.8f",coordinate.longitude];
        self.latitudeLabel = [NSString stringWithFormat:@"\n\u2022 latitude:%.8f \n",coordinate.latitude];
        
        // Reverse Geocoding
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                placemark = [placemarks lastObject];
                self.addressLabel = [NSString stringWithFormat:@"\n address: %@ %@\n %@ %@\n %@\n %@\n \n",
                                     placemark.subThoroughfare, placemark.thoroughfare,
                                     placemark.postalCode, placemark.locality,
                                     placemark.administrativeArea,
                                     placemark.country];
                
            } else {
                self.addressLabel = [NSString stringWithFormat:@"address:No Internet Connection available to fetch address \n \n"];
            }
        }];
        
        return coordinate;
        
    } else {
        
        self.longitudeLabel = [NSString stringWithFormat:@"\n\u2022 longitude:%.8f",coordinate.longitude];
        self.latitudeLabel = [NSString stringWithFormat:@"\n\u2022 latitude:%.8f \n",coordinate.latitude];
        
        // Reverse Geocoding
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                placemark = [placemarks lastObject];
                self.addressLabel = [NSString stringWithFormat:@"\n address: %@ %@\n %@ %@\n %@\n %@\n \n",
                                     placemark.subThoroughfare, placemark.thoroughfare,
                                     placemark.postalCode, placemark.locality,
                                     placemark.administrativeArea,
                                     placemark.country];
                
            } else {
                self.addressLabel = [NSString stringWithFormat:@"address:No Internet Connection available to fetch address \n \n"];
            }
        }];
        
        return coordinate;
    }
}

@end
