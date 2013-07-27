#import "ESCColorPickerPresenter.h"

@interface ESCColorPickerPresenter()<ESCColorPickerModelObserver, ESCColorPickerViewObserver>

@property (nonatomic) ESCColorPickerModel *model;
@property (nonatomic) ESCColorPickerView *view;

@end

@implementation ESCColorPickerPresenter

- (instancetype)initWithView:(ESCColorPickerView *)view model:(ESCColorPickerModel *)model {
    if (self = [super init]) {
		self.model = model;
		[self.model escAddObserver:self];
		
		self.view = view;
		[self.view escAddObserver:self];
		
		[self colorDidChange];
		[self.view setColorDescriptionKeys:self.model.colorDescriptionKeys values:self.model.colorDescriptionValues];
    }
    return self;
}

- (void)colorDidChange {
	[self.view setHue:self.model.hue
		   saturation:self.model.saturation
		   brightness:self.model.brightness];
}

- (void)hueDidChange:(CGFloat)hue {
	self.model.hue = hue;
}

- (void)saturationDidChange:(CGFloat)saturation {
	self.model.saturation = saturation;
}

- (void)brightnessDidChange:(CGFloat)brightness {
	self.model.brightness = brightness;
}

- (void)colorDescriptionDidChangeKeys:(NSArray *)keys values:(NSArray *)values {
	[self.view setColorDescriptionKeys:keys values:values];
}

- (void)colorDescriptionTapped {
	self.model.descriptionFormat = (self.model.descriptionFormat + 1) % 3;
}

@end
