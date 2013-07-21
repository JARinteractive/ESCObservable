#import "ESCColorPickerModel.h"

@interface ESCColorPickerModel()<ESCObservableInternal>

@end

@implementation ESCColorPickerModel

- (id)init {
    if (self = [super init]) {
		[self escRegisterObserverProtocol:@protocol(ESCColorPickerModelObserver)];
		self.hue = 0.24;
		self.saturation = 0.75;
		self.brightness = 0.86;
    }
    return self;
}

- (void)setHue:(CGFloat)hue {
	_hue = hue;
	[self.escNotifier colorDidChange];
}

- (void)setSaturation:(CGFloat)saturation {
	_saturation = saturation;
	[self.escNotifier colorDidChange];
}

- (void)setBrightness:(CGFloat)brightness {
	_brightness = brightness;
	[self.escNotifier colorDidChange];
}

@end
