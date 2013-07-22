#import <UIKit/UIKit.h>
#import <ESCObservable/ESCObservable.h>

@protocol ESCHueWheelObserver

- (void)hueDidChange:(CGFloat)hue;

@end

@interface ESCHueWheel : UIView<ESCObservable>

- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness;

@end
