#import "ESCColorPickerView.h"
#import "ESCGradientSlider.h"
#import "ESCHueWheel.h"

#define PADDING 15.0

@interface ESCColorPickerView()<ESCObservableInternal>

@property (nonatomic) UIView *colorView;
@property (nonatomic) ESCHueWheel *hueWheel;
@property (nonatomic) ESCGradientSlider *saturationSlider;
@property (nonatomic) ESCGradientSlider *brightnessSlider;

@end

@implementation ESCColorPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self escRegisterObserverProtocol:@protocol(ESCColorPickerViewObserver)];
		
		self.hueWheel = [[ESCHueWheel alloc] init];
		[self.hueWheel escAddObserver:self forSelector:@selector(hueDidChange:)];
		[self addSubview:self.hueWheel];
		
		self.saturationSlider = [[ESCGradientSlider alloc] init];
		[self.saturationSlider escAddObserver:self forSelector:@selector(sliderValueDidChange:) forwardingToSelector:@selector(saturationDidChange:)];
		[self addSubview:self.saturationSlider];
		
		self.brightnessSlider = [[ESCGradientSlider alloc] init];
		[self.brightnessSlider escAddObserver:self forSelector:@selector(sliderValueDidChange:) forwardingToSelector:@selector(brightnessDidChange:)];
		[self addSubview:self.brightnessSlider];
		
		self.colorView = [[UIView alloc] init];
		[self addSubview:self.colorView];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect = CGRectInset(self.bounds, PADDING, PADDING);
	
	self.colorView.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(contentRect), CGRectGetWidth(self.bounds), 80.0);
	
	self.hueWheel.frame = CGRectMake(CGRectGetMinX(contentRect) + 10.0, CGRectGetMaxY(self.colorView.frame) + PADDING, CGRectGetWidth(contentRect) - 20.0, CGRectGetWidth(contentRect) - 20.0);
	self.saturationSlider.frame = CGRectMake(CGRectGetMinX(contentRect), CGRectGetMaxY(self.hueWheel.frame) + PADDING, CGRectGetWidth(contentRect), 40.0);
	self.brightnessSlider.frame = CGRectMake(CGRectGetMinX(contentRect), CGRectGetMaxY(self.saturationSlider.frame) + PADDING, CGRectGetWidth(contentRect), 40.0);
}

- (void)saturationDidChange:(CGFloat)saturation {
	[self.escNotifier saturationDidChange:saturation];
}

- (void)brightnessDidChange:(CGFloat)brightness {
	[self.escNotifier brightnessDidChange:brightness];
}

- (void)hueDidChange:(CGFloat)hue {
	[self.escNotifier hueDidChange:hue];
}

- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness {
	[self.saturationSlider setStartColor:[UIColor colorWithHue:hue saturation:0.0 brightness:brightness alpha:1.0]];
	[self.saturationSlider setEndColor:[UIColor colorWithHue:hue saturation:1.0 brightness:brightness alpha:1.0]];
	[self.saturationSlider setSliderValue:saturation];
	
	[self.brightnessSlider setStartColor:[UIColor colorWithHue:hue saturation:saturation brightness:0.0 alpha:1.0]];
	[self.brightnessSlider setEndColor:[UIColor colorWithHue:hue saturation:saturation brightness:1.0 alpha:1.0]];
	[self.brightnessSlider setSliderValue:brightness];
	
	self.colorView.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
	
}

@end
