//
//  FFTGraphViewController.m
//  MotionGraphs
//
//  Created by Ashish Shrestha on 5/20/15.
//
//

#import "FFTGraphViewController.h"

#define RGB_Alpha(r, g, b, alp) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: alp]
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255. green:(g)/255. blue:(b)/255. alpha: 1]

@interface FFTGraphViewController ()

@property (strong,nonatomic) IBOutlet UIButton *xDataButton;
@property (strong,nonatomic) UIButton *xDataButton02;
@property (strong,nonatomic) UIButton *yDataButton02;
@property (strong,nonatomic) UIButton *zDataButton02;

@property (strong,nonatomic) NSNumber *xData;
@property (strong,nonatomic) NSNumber *yData;

@end

@implementation FFTGraphViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the title
    self.title=@"FFT Plot";
    
    graph = [CPTXYGraph alloc];
    
    // Set XYZ Button
    [self setXYZButton];
    
    [self drawFFTPlot:self.fftArrayX];
}

- (IBAction)plotAlongDeviceXDirection:(UIButton *)sender
{
    [graph removeFromSuperlayer];
    [self drawFFTPlot:self.fftArrayX];
    
    self.xDataButton02.backgroundColor = RGB(31, 183, 252);
    self.yDataButton02.backgroundColor = [UIColor darkGrayColor];
    self.zDataButton02.backgroundColor = [UIColor darkGrayColor];
}

- (IBAction)plotAlongDeviceYDirection:(UIButton *)sender
{
    [graph removeFromSuperlayer];
    [self drawFFTPlot:self.fftArrayY];
    
    self.xDataButton02.backgroundColor = [UIColor darkGrayColor];
    self.yDataButton02.backgroundColor = RGB(31, 183, 252);
    self.zDataButton02.backgroundColor = [UIColor darkGrayColor];
}

- (IBAction)plotAlongDeviceZDirection:(UIButton *)sender
{
    [graph removeFromSuperlayer];
    [self drawFFTPlot:self.fftArrayZ];

    self.xDataButton02.backgroundColor = [UIColor darkGrayColor];
    self.yDataButton02.backgroundColor = [UIColor darkGrayColor];
    self.zDataButton02.backgroundColor = RGB(31, 183, 252);
}


- (void)drawFFTPlot:(NSMutableArray *)fftArray
{
    self.xData = nil;
    self.scatterPlotData = [NSMutableArray array];
    float k = 0;
    
    for ( NSUInteger i = 0; i < fftArray.count; i++ ) {
        k = i+1;
        self.xData = [NSNumber numberWithDouble:(k/fftArray.count)*self.samplingRate/2.0];
        self.yData = fftArray[i];
        [self.scatterPlotData addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.xData, @"x", self.yData, @"y", nil]];
    }
    
    // We need a hostview, you can create one in IB (and create an outlet) or just do this
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.2)];
    [self.view addSubview:hostingView];
    
    // Initialize a CPTXYGraph object and add to hostView
    graph = [[CPTXYGraph alloc] initWithFrame:hostingView.bounds];
    hostingView.hostedGraph = graph;
    
    // Set padding for plot area
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
    
    // Set Graph Styles
//    graph.plotAreaFrame.borderWidth     = 0.0f;
//    graph.plotAreaFrame.cornerRadius    = 0.0f;
//    graph.plotAreaFrame.masksToBorder   = YES;
    
    // Padding Set Up
    graph.paddingLeft   = 0.0f;
    graph.paddingRight  = 0.0f;
    graph.paddingTop    = 0.0f;
    graph.paddingBottom = 0.0f;
    
    graph.plotAreaFrame.paddingLeft   = 36.0f;
    graph.plotAreaFrame.paddingTop    = 8.0f;
    graph.plotAreaFrame.paddingRight  = 8.0f;
    graph.plotAreaFrame.paddingBottom = [UIScreen mainScreen].bounds.size.height*0.05;
    
    // Set up Y-axis Range
    CGFloat min = MAXFLOAT;
    CGFloat max = -MAXFLOAT;
    
    for(int i=0;i<fftArray.count;i++) {
        NSNumber* number = fftArray[i];
        if([number floatValue] < min)
            min = [number floatValue];
        
        if([number floatValue] > max)
            max = [number floatValue];
    }
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xScaleType = CPTScaleTypeLog;
    plotSpace.yScaleType = CPTScaleTypeLinear;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0.0] length:[NSNumber numberWithFloat:fabs(max)]];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0.05] length:[NSNumber numberWithFloat:50.0]];
    //plotSpace.allowsUserInteraction = YES;
    
    // set text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor colorWithComponentRed:0.5f green:0.5f blue:0.5f alpha:1.0f];
    textStyle.fontSize             = 9.0f;
    textStyle.textAlignment        = CPTTextAlignmentCenter;
    
    // set line style
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor            = [CPTColor colorWithComponentRed:0.788f green:0.792f blue:0.792f alpha:1.0f];
    lineStyle.lineWidth            = 1.0f;

    
    // Configuring the X - axes
    CPTXYAxisSet *axisSet         = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *x                  = axisSet.xAxis;
    x.axisLineStyle               = lineStyle;
    x.majorTickLineStyle          = lineStyle;
    x.minorTickLineStyle          = lineStyle;
    x.majorIntervalLength         = [NSNumber numberWithFloat:5.0f];
    x.orthogonalPosition          = [NSNumber numberWithFloat:0.0f];
    x.minorTickLength             = 5.0f;
    x.majorTickLength             = 9.0f;
    x.labelTextStyle              = textStyle;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.preferredNumberOfMajorTicks = 5.0f;
    x.minorTicksPerInterval       = 10.0f;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    
    // Configuring the Y - axes
    CPTXYAxis *y                  = axisSet.yAxis;
    y.axisLineStyle               = lineStyle;
    y.majorTickLineStyle          = lineStyle;
    y.minorTickLineStyle          = lineStyle;
    y.majorTickLength             = 9.0f;
    y.minorTickLength             = 5.0f;
    y.majorIntervalLength         = [NSNumber numberWithFloat:(fabs(min)+fabs(max))/6.0];
//    y.majorIntervalLength         = [NSNumber numberWithFloat:5.0f];
    y.orthogonalPosition          = [NSNumber numberWithFloat:0.0f];
    lineStyle.lineWidth           = 0.5f;
    y.majorGridLineStyle          = lineStyle;
    y.labelTextStyle              = textStyle;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.preferredNumberOfMajorTicks = 5.0;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    
    // Set Axes Title
    [self setAxesTitle];
    
    // Create a scatter plot and set its data source
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    scatterPlot.identifier      = @"data source";
    scatterPlot.dataSource      = self;
    
    // Set plot line style
    CPTMutableLineStyle *graphlineStyle = [scatterPlot.dataLineStyle mutableCopy];
    graphlineStyle.lineWidth = 1.0;
    if (fftArray==self.fftArrayX) {
        graphlineStyle.lineColor = [CPTColor blueColor];
    }
    if (fftArray==self.fftArrayY) {
        graphlineStyle.lineColor = [CPTColor orangeColor];
    }
    if (fftArray==self.fftArrayZ) {
        graphlineStyle.lineColor = [CPTColor redColor];
    }
    
    scatterPlot.dataLineStyle = graphlineStyle;
    
    // add to plot
    [graph addPlot:scatterPlot toPlotSpace:plotSpace];
    [graph.defaultPlotSpace scaleToFitPlots:[graph allPlots]];
}


// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plotnumberOfRecords.identifier;
    
    if ( [identifier isEqualToString:@"data source"] ) {
        numRecords = self.scatterPlotData.count;
    }
    
    return numRecords;
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;
    
    if ( [identifier isEqualToString:@"data source"] ) {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                num = [[self.scatterPlotData objectAtIndex:index] valueForKey:@"x"];
                break;
            case CPTScatterPlotFieldY:
                num = [[self.scatterPlotData objectAtIndex:index] valueForKey:@"y"];
                break;
        }
    }
    
    return num;
}

- (void)setAxesTitle
{
    UILabel *xAxesLabel = [[UILabel alloc]initWithFrame:CGRectMake(48, [UIScreen mainScreen].bounds.size.height*0.16, 100, 16)];
    xAxesLabel.text = NSLocalizedString(@"Frequency (Hz)","");
    xAxesLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0];
    xAxesLabel.font = [UIFont systemFontOfSize:9.0f];
    [self.view addSubview:xAxesLabel];
    
    UILabel *yAxesLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 32, 100, 16)];
    yAxesLabel.text = NSLocalizedString(@"Amplitude (gal/Hz)","");
    yAxesLabel.transform=CGAffineTransformMakeRotation( ( -90 * M_PI ) / 180 );
    yAxesLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0];
    yAxesLabel.font = [UIFont systemFontOfSize:9.0f];
    [self.view addSubview:yAxesLabel];
}

- (void)setXYZButton
{
    self.xDataButton02 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.xDataButton02 setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*0.08, [UIScreen mainScreen].bounds.size.height*0.2, [UIScreen mainScreen].bounds.size.width*0.27, [UIScreen mainScreen].bounds.size.width*0.07)];
    self.xDataButton02.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width*0.05;;
    self.xDataButton02.backgroundColor = RGB(31, 183, 252);
    [self.xDataButton02 setTitle:NSLocalizedString(@"X Direction","") forState:UIControlStateNormal];
    [self.xDataButton02 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.xDataButton02.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.xDataButton02 addTarget:self action:@selector(plotAlongDeviceXDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.xDataButton02];
    
    self.yDataButton02 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.yDataButton02 setFrame:CGRectMake((self.view.frame.size.width-self.xDataButton02.frame.size.width)/2, [UIScreen mainScreen].bounds.size.height*0.2, self.xDataButton02.frame.size.width, self.xDataButton02.frame.size.height)];
    self.yDataButton02.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width*0.05;
    self.yDataButton02.backgroundColor = [UIColor darkGrayColor];
    [self.yDataButton02 setTitle:NSLocalizedString(@"Y Direction","") forState:UIControlStateNormal];
    [self.yDataButton02 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.yDataButton02.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.yDataButton02 addTarget:self action:@selector(plotAlongDeviceYDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.yDataButton02];
    
    self.zDataButton02 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.zDataButton02 setFrame:CGRectMake(self.view.frame.size.width-self.xDataButton02.frame.size.width-[UIScreen mainScreen].bounds.size.width*0.08, [UIScreen mainScreen].bounds.size.height*0.2, self.xDataButton02.frame.size.width, self.xDataButton02.frame.size.height)];
    self.zDataButton02.layer.cornerRadius = [UIScreen mainScreen].bounds.size.width*0.05;
    self.zDataButton02.backgroundColor = [UIColor darkGrayColor];
    [self.zDataButton02 setTitle:NSLocalizedString(@"Z Direction","") forState:UIControlStateNormal];
    [self.zDataButton02 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.zDataButton02.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.zDataButton02 addTarget:self action:@selector(plotAlongDeviceZDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.zDataButton02];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
