#import <UIKit/UIKit.h>
#import <ESCObservable/ESCObservable.h>

@protocol ESCGradientSliderObserver

- (void)sliderValueDidChange:(CGFloat)sliderValue;

@end

@interface ESCGradientSlider : UIView<ESCObservable>

- (void)setStartColor:(UIColor *)startColor;
- (void)setEndColor:(UIColor *)endColor;
- (void)setSliderValue:(CGFloat)sliderValue;

@end
