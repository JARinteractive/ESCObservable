#import "ESCGradientSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "ESCColorControlThumb.h"

@interface ESCGradientSlider()<ESCObservableInternal, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) CAGradientLayer *gradientLayer;
@property (nonatomic) ESCColorControlThumb *thumb;
@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGFloat touchOffsetX;

@end

@implementation ESCGradientSlider

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self escRegisterObserverProtocol:@protocol(ESCGradientSliderObserver)];
		self.gradientLayer.colors = @[(id)[UIColor blueColor].CGColor, (id)[UIColor greenColor].CGColor];
		self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
		self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
		self.gradientLayer.cornerRadius = 4.0;
		
		self.thumb = [[ESCColorControlThumb alloc] init];
		self.thumb.userInteractionEnabled = NO;
		[self addSubview:self.thumb];
		
		self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
		self.panGestureRecognizer.delegate = self;
		[self addGestureRecognizer:self.panGestureRecognizer];
    }
    return self;
}

- (void)panGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
	self.sliderValue = [panGestureRecognizer locationInView:self].x / CGRectGetWidth(self.bounds);
	[self.escNotifier sliderValueDidChange:self.sliderValue];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGFloat touchLocationOnThumb = [touch locationInView:self.thumb].x;
	return touchLocationOnThumb > -40.0 && touchLocationOnThumb < CGRectGetMaxX(self.thumb.bounds) + 40.0;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat thumbWidth = 6.0;
	self.thumb.center = CGPointMake(CGRectGetWidth(self.bounds) * self.sliderValue, CGRectGetMidY(self.bounds));
	self.thumb.bounds = CGRectMake(0.0, 0.0, thumbWidth, CGRectGetHeight(self.bounds) + 10.0);
}

- (void)setStartColor:(UIColor *)startColor {
	self.gradientLayer.colors = @[(id)startColor.CGColor, self.gradientLayer.colors[1]];
}

- (void)setEndColor:(UIColor *)endColor {
	self.gradientLayer.colors = @[self.gradientLayer.colors[0], (id)endColor.CGColor];
}

- (void)setSliderValue:(CGFloat)sliderValue {
	_sliderValue = MAX(MIN(sliderValue, 1.0), 0.0);
	[self setNeedsLayout];
}

- (CAGradientLayer *)gradientLayer {
	return (CAGradientLayer *)self.layer;
}

+ (Class)layerClass {
	return [CAGradientLayer class];
}

@end
