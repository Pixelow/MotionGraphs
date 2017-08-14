//
//  APLSAMultisectorControl.h
//  CustomControl
//
//  Created by M on 12/31/13.
//

#import <UIKit/UIKit.h>
#import "APLSAMath.h"

@class APLSAMultisectorSector;


@interface APLSAMultisectorControl : UIControl

@property (strong, nonatomic, readonly) NSArray *sectors;

@property (nonatomic, readwrite) double sectorsRadius;
@property (nonatomic, readwrite) double startAngle;
@property (nonatomic, readwrite) double minCircleMarkerRadius;
@property (nonatomic, readwrite) double maxCircleMarkerRadius;

- (void)addSector:(APLSAMultisectorSector *)sector;
- (void)removeSector:(APLSAMultisectorSector *)sector;
- (void)removeAllSectors;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end



@interface APLSAMultisectorSector : NSObject

@property (strong, nonatomic) UIColor *color;

@property (nonatomic, readwrite) double minValue;
@property (nonatomic, readwrite) double maxValue;

@property (nonatomic, readwrite) double startValue;
@property (nonatomic, readwrite) double endValue;

@property (nonatomic, readwrite) NSInteger tag;

- (instancetype) init;

+ (instancetype) sector;
+ (instancetype) sectorWithColor:(UIColor *)color;
+ (instancetype) sectorWithColor:(UIColor *)color maxValue:(double)maxValue;
+ (instancetype) sectorWithColor:(UIColor *)color minValue:(double)minValue maxValue:(double)maxValue;

@end
