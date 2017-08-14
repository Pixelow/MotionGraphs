//
//  APLViralSwitch.h
//  ViralSwitch
//
//  Created by M on 06/10/14.
//

#import <UIKit/UIKit.h>

/** @constant APLViralSwitch APLElementView View animated alongside the switch */
FOUNDATION_EXPORT NSString *const APLElementView;
/** @constant APLViralSwitch APLElementView Key-path for the animated view property */
FOUNDATION_EXPORT NSString *const APLElementKeyPath;
/** @constant APLViralSwitch APLElementView Starting point for the animated view */
FOUNDATION_EXPORT NSString *const APLElementFromValue;
/** @constant APLViralSwitch APLElementView End point for the animated view */
FOUNDATION_EXPORT NSString *const APLElementToValue;

/** APLViralSwitch
 *
 * UISwitch subclass that 'infects' the parent view with the onTintColor when the switch is turned on
 */
@interface APLViralSwitch : UISwitch

/**-----------------------------------------------------------------------------
 * @name APLViralSwitch Properties
 * -----------------------------------------------------------------------------
 */

/** Animation duration
 *
 * Holds the duration of the animation. Can be set via UIAppearance proxy
 */
@property (nonatomic, assign) NSTimeInterval animationDuration UI_APPEARANCE_SELECTOR;

/** Views animated when the switch is turned on
 *
 * Holds an array of dictionaries with the following structure:
 * @{
 *  APLElementView: someView,
 *  APLElementKeyPath: @"alpha",
 *  APLElementFromValue: @0,
 *  APLElementToValue: @1
 * }
 */
@property (nonatomic, strong) NSArray *animationElementsOn;

/** Views animated when the switch is turned off
 *
 * Holds an array of dictionaries with the following structure:
 * @{
 *  APLElementView: someView,
 *  APLElementKeyPath: @"alpha",
 *  APLElementFromValue: @0,
 *  APLElementToValue: @1
 * }
 */
@property (nonatomic, strong) NSArray *animationElementsOff;

/** Animation 'on' completion
 *
 * Block called when the animation from 'off' to 'on' is completed
 */
@property (nonatomic, copy) void (^completionOn)();

/** Animation 'off' completion
 *
 * Block called when the animation from 'on' to 'off' is completed
 */
@property (nonatomic, copy) void (^completionOff)();

@end
