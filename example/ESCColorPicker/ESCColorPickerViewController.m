#import "ESCColorPickerViewController.h"
#import "ESCColorPickerView.h"
#import "ESCColorPickerModel.h"
#import "ESCColorPickerPresenter.h"

@interface ESCColorPickerViewController()

@property ESCColorPickerPresenter *presenter;

@end

@implementation ESCColorPickerViewController

- (void)loadView {
    [super loadView];
	self.view.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
	
	CGRect contentRect = self.view.bounds;
	if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7) {
		CGRect statusBarFrame = [self.view convertRect:[[UIApplication sharedApplication] statusBarFrame] fromView:self.view.window];
		contentRect = UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(CGRectGetHeight(statusBarFrame), 0.0, 0.0, 0.0));
	}
	ESCColorPickerView *colorPickerView = [[ESCColorPickerView alloc] initWithFrame:contentRect];
	colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:colorPickerView];
	
	ESCColorPickerModel *colorPickerModel = [[ESCColorPickerModel alloc] init];
	
	self.presenter = [[ESCColorPickerPresenter alloc] initWithView:colorPickerView model:colorPickerModel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
