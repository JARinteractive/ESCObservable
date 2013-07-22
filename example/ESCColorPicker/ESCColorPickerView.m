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
		self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
		
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
		
		//self.colorView = [[UIView alloc] init];
		//[self addSubview:self.colorView];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect contentRect = CGRectInset(self.bounds, PADDING, PADDING);
	CGFloat sliderHeight = 40.0;
	
	self.brightnessSlider.frame = CGRectMake(CGRectGetMinX(contentRect), CGRectGetMaxY(contentRect) - sliderHeight, CGRectGetWidth(contentRect), sliderHeight);
	self.saturationSlider.frame = CGRectMake(CGRectGetMinX(contentRect), CGRectGetMinY(self.brightnessSlider.frame) - PADDING - sliderHeight, CGRectGetWidth(contentRect), sliderHeight);
	
	
	self.colorView.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(contentRect), CGRectGetWidth(self.bounds), 80.0);
	
	CGFloat hueWheelSide = CGRectGetWidth(contentRect) - 40.0;
	self.hueWheel.frame = CGRectMake(CGRectGetMidX(contentRect) - hueWheelSide / 2.0, CGRectGetMinY(self.saturationSlider.frame) - PADDING - hueWheelSide, hueWheelSide, hueWheelSide);
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
	
	[self.hueWheel setHue:hue saturation:saturation brightness:brightness];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *hitView = [super hitTest:point withEvent:event];
	if (CGRectContainsPoint(CGRectInset(self.saturationSlider.frame, -20.0, -5.0), point)) {
		hitView = self.saturationSlider;
	} else if (CGRectContainsPoint(CGRectInset(self.brightnessSlider.frame, -20.0, -5.0), point)) {
		hitView = self.brightnessSlider;
	}
	return hitView;
}

@end
