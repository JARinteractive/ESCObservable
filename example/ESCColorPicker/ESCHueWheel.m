#import "ESCHueWheel.h"
#import "ESCColorControlThumb.h"

@interface ESCHueWheel()<ESCObservableInternal, UIGestureRecognizerDelegate>

@property (nonatomic) UIView *wheel;
@property (nonatomic) UIView *wheelCenter;
@property (nonatomic) UIView *wheelCenterBorder;
@property (nonatomic) NSArray *colorSwatchViews;
@property (nonatomic) UIView *thumb;
@property (nonatomic) CGFloat hue;
@property (nonatomic, readonly) CGFloat angle;

@property (nonatomic) CGFloat relativeTouchAngle;

@end

@implementation ESCHueWheel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self escRegisterObserverProtocol:@protocol(ESCHueWheelObserver)];
		
		self.wheel = [[UIView alloc] init];
		self.wheel.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
		self.wheel.clipsToBounds = YES;
		[self addSubview:self.wheel];
		
		NSInteger numberOfSwatches = 12;
		NSMutableArray *colorSwatchViews = [NSMutableArray arrayWithCapacity:numberOfSwatches];
		for (NSInteger i = 0; i < numberOfSwatches; i++) {
			UIView *colorSwatchView = [[UIView alloc] init];
			colorSwatchView.layer.shouldRasterize = YES;
			colorSwatchView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
			[colorSwatchViews addObject:colorSwatchView];
			[self.wheel addSubview:colorSwatchView];
		}
		self.colorSwatchViews = colorSwatchViews;
		
		self.wheelCenterBorder = [[UIView alloc] init];
		self.wheelCenterBorder.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		self.wheelCenterBorder.layer.shadowColor = [UIColor blackColor].CGColor;
		self.wheelCenterBorder.layer.shadowOpacity = 0.5;
		self.wheelCenterBorder.layer.shadowRadius = 2.0;
		self.wheelCenterBorder.layer.shadowOffset = CGSizeZero;
		[self addSubview:self.wheelCenterBorder];
		
		self.thumb = [[UIView alloc] init];
		self.thumb.layer.borderColor = self.wheelCenterBorder.backgroundColor.CGColor;
		self.thumb.layer.borderWidth = 3.0;
		self.thumb.layer.shouldRasterize = YES;
		self.thumb.layer.rasterizationScale = [[UIScreen mainScreen] scale];
		[self.wheelCenterBorder addSubview:self.thumb];
		
		self.wheelCenter = [[UIView alloc] init];
		self.wheelCenter.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[self.wheelCenterBorder addSubview:self.wheelCenter];
		
		UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
		panGestureRecognizer.delegate = self;
		[self addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void)panGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint touchLocation = [panGestureRecognizer locationInView:self.wheel];
	touchLocation.x -= CGRectGetMidX(self.wheel.bounds);
	touchLocation.y -= CGRectGetMidY(self.wheel.bounds);
	CGFloat touchAngle = atan(touchLocation.y / touchLocation.x);
	touchAngle += touchLocation.x < 0.0 ? M_PI : 0.0;
	if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
		self.relativeTouchAngle = self.angle - touchAngle;
	} else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
		CGFloat hue = (touchAngle + self.relativeTouchAngle + M_PI_2) / (M_PI * 2);
		hue = fmod(hue + 1.0, 1.0); //correct if hue is negative
		self.hue = hue;
		[self.escNotifier hueDidChange:self.hue];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return CGRectContainsPoint(CGRectInset(self.thumb.bounds, -20.0, -20.0), [touch locationInView:self.thumb]);
}

- (void)setHue:(CGFloat)hue {
	_hue = hue;
	[self setNeedsLayout];
}

- (CGFloat)angle {
	return self.hue * 2 * M_PI - M_PI_2;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.wheel.frame = CGRectInset(self.bounds, 5.0, 5.0);
	CGFloat radius = CGRectGetWidth(self.wheel.frame) / 2.0;
	self.wheel.layer.cornerRadius = radius;
	
	self.wheelCenterBorder.frame = CGRectInset(self.bounds, 35.0, 35.0);
	self.wheelCenterBorder.layer.cornerRadius = CGRectGetWidth(self.wheelCenterBorder.frame) / 2.0;
	self.wheelCenter.frame = CGRectInset(self.wheelCenterBorder.bounds, 3.0, 3.0);
	self.wheelCenter.layer.cornerRadius = CGRectGetWidth(self.wheelCenter.frame) / 2.0;
	
	NSInteger i = 0;
	CGFloat colorSwatchRadius = radius - ((radius - CGRectGetWidth(self.wheelCenter.frame) / 2.0)) / 2.0;
	for (UIView *colorSwatchView in self.colorSwatchViews) {
		CGFloat angle = (CGFloat)i / [self.colorSwatchViews count] * 2 * M_PI - M_PI_2;
		CGFloat x = cos(angle) * colorSwatchRadius + CGRectGetMidX(self.wheel.bounds);
		CGFloat y = sin(angle) * colorSwatchRadius + CGRectGetMidY(self.wheel.bounds);
		colorSwatchView.center = CGPointMake(x, y);
		colorSwatchView.bounds = CGRectMake(0.0, 0.0, 36.0, 10.0);
		colorSwatchView.transform = CGAffineTransformMakeRotation(angle);
		i++;
	}
	
	CGFloat thumbRadius = CGRectGetWidth(self.wheelCenterBorder.frame) / 2.0 + 10.0;
	CGFloat x = cos(self.angle) * thumbRadius + CGRectGetMidX(self.wheelCenterBorder.bounds);
	CGFloat y = sin(self.angle) * thumbRadius + CGRectGetMidY(self.wheelCenterBorder.bounds);
	self.thumb.center = CGPointMake(x, y);
	self.thumb.bounds = CGRectMake(0.0, 0.0, 16.0, 64.0);
	self.thumb.transform = CGAffineTransformMakeRotation(self.angle + M_PI_2);
	self.thumb.layer.cornerRadius = 16.0;
}

- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness {
	UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
	self.wheelCenter.backgroundColor = color;
	self.thumb.backgroundColor = color;
	
	NSInteger i = 0;
	for (UIView *colorSwatchView in self.colorSwatchViews) {
		colorSwatchView.backgroundColor = [UIColor colorWithHue:(CGFloat)i / [self.colorSwatchViews count] saturation:saturation brightness:brightness alpha:1.0];
		i++;
	}
	
	self.hue = hue;
}

@end
