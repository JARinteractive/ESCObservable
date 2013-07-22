#import "ESCColorControlThumb.h"

@interface ESCColorControlThumb()

@end

@implementation ESCColorControlThumb

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOpacity = 0.5;
		self.layer.shadowRadius = 2.0;
		self.layer.shadowOffset = CGSizeZero;
		
		self.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0;
}

@end
