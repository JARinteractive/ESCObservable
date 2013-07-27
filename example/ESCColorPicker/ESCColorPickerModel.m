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
	[self updateDescription];
	[self.escNotifier colorDidChange];
}

- (void)setSaturation:(CGFloat)saturation {
	_saturation = saturation;
	[self updateDescription];
	[self.escNotifier colorDidChange];
}

- (void)setBrightness:(CGFloat)brightness {
	_brightness = brightness;
	[self updateDescription];
	[self.escNotifier colorDidChange];
}

- (void)setDescriptionFormat:(ESCColorPickerModelDescriptionFormat)descriptionFormat {
	_descriptionFormat = descriptionFormat;
	[self updateDescription];
}

- (NSString *)formattedFloat:(CGFloat)floatToFormat {
	return [NSString stringWithFormat:@"%.3f", floatToFormat];
}

- (void)updateDescription {
	if (self.descriptionFormat == ESCColorPickerModelDescriptionFormatHSB) {
		self.colorDescriptionKeys = @[@"H", @"S", @"B"];
		
		NSString *formatString = @"%.3f";
		self.colorDescriptionValues = @[[NSString stringWithFormat:formatString, self.hue],
										[NSString stringWithFormat:formatString, self.saturation],
										[NSString stringWithFormat:formatString, self.brightness]];
	} else if (self.descriptionFormat == ESCColorPickerModelDescriptionFormatRGB) {
		self.colorDescriptionKeys = @[@"R", @"G", @"B"];
		
		NSString *formatString = @"%.3f";
		UIColor *hsbColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0];
		CGFloat red, green, blue;
		[hsbColor getRed:&red green:&green blue:&blue alpha:NULL];
		self.colorDescriptionValues = @[[NSString stringWithFormat:formatString, red],
										[NSString stringWithFormat:formatString, green],
										[NSString stringWithFormat:formatString, blue]];
	} else if (self.descriptionFormat == ESCColorPickerModelDescriptionFormatRGBHex) {
		self.colorDescriptionKeys = @[@"#"];
		
		UIColor *hsbColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1.0];
		CGFloat red, green, blue;
		[hsbColor getRed:&red green:&green blue:&blue alpha:NULL];
		self.colorDescriptionValues = @[[NSString stringWithFormat:@"%02X%02X%02X", (NSUInteger)(red * 255), (NSUInteger)(green * 255), (NSUInteger)(blue * 255)]];
	}
	
	[self.escNotifier colorDescriptionDidChangeKeys:self.colorDescriptionKeys values:self.colorDescriptionValues];
}

@end
