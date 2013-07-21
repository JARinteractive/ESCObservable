#import "ESCHueWheel.h"

@interface ESCHueWheel()<ESCObservableInternal>

@property (nonatomic) UIView *wheel;
@property (nonatomic) UIView *wheelCenter;

@end

@implementation ESCHueWheel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.wheel = [[UIView alloc] init];
		self.wheel.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
		[self addSubview:self.wheel];
		
		self.wheelCenter = [[UIView alloc] init];
		self.wheelCenter.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
		[self addSubview:self.wheelCenter];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.wheel.frame = CGRectInset(self.bounds, 5.0, 5.0);
	self.wheel.layer.cornerRadius = CGRectGetWidth(self.wheel.frame) / 2.0;
	
	self.wheelCenter.frame = CGRectInset(self.bounds, 35.0, 35.0);
	self.wheelCenter.layer.cornerRadius = CGRectGetWidth(self.wheelCenter.frame) / 2.0;
}

@end
