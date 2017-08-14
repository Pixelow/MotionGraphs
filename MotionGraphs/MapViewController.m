//
//  MapViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 4/13/16.
//
//

#import "MapViewController.h"

@interface MapViewController ()
@property (strong,nonatomic) MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
//    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 320)];
    self.mapView.mapType = MKMapTypeHybrid;
    
    CLLocationCoordinate2D coordinateObtained;
    coordinateObtained.latitude = [self.latitudeValue doubleValue];
    coordinateObtained.longitude = [self.longitudeValue doubleValue];
    
    MKCoordinateSpan span = {.latitudeDelta =  180.0, .longitudeDelta =  360.0};
    MKCoordinateRegion region = {coordinateObtained, span};
    MKPointAnnotation *pointAttonation = [[MKPointAnnotation alloc]init];
    pointAttonation.coordinate = coordinateObtained;
    
    pointAttonation.title = [NSString stringWithFormat:@"PGA Recorded:%@",self.pgaValue];
    
    [self.mapView addAnnotation:pointAttonation];
    [self.mapView setRegion:region];
    //[self.mapView setShowsUserLocation:YES];
    [self.view addSubview:self.mapView];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
