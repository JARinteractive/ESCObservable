//  Copyright (c) 2013 Escappe. All rights reserved.
#import "ESCAppDelegate.h"
#import "ESCColorPickerViewController.h"

@implementation ESCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
	self.window.rootViewController = [[ESCColorPickerViewController alloc] init];
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
