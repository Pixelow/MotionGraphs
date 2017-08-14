//
//  APLPulsingHaloLayer.h
//
//  Created by M on 8/5/17.


#import <QuartzCore/QuartzCore.h>


@interface APLPulsingHaloLayer : CALayer

@property (nonatomic, assign) CGFloat radius;                   // default:60pt
@property (nonatomic, assign) NSTimeInterval animationDuration; // default:3s
@property (nonatomic, assign) NSTimeInterval pulseInterval; // default is 0s

@end
