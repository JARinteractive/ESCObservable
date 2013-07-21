//  Copyright (c) 2013 Escappe. All rights reserved.

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "ESCColorPickerModel.h"

@interface ESCColorPickerModelTest : XCTestCase

@property (nonatomic) ESCColorPickerModel *testObject;
@property (nonatomic) id mockObserver;

@end

@implementation ESCColorPickerModelTest

- (void)setUp {
    [super setUp];
	
	self.testObject = [[ESCColorPickerModel alloc] init];
	self.testObject.hue = 0.2;
	self.testObject.saturation = 0.3;
	self.testObject.brightness = 0.4;
	self.mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCColorPickerModelObserver)];
	[self.testObject escAddObserver:self.mockObserver];
}

- (void)testModelSendsEventForHueChange {
	[[[self.mockObserver expect] andDo:^(NSInvocation *invocation) {
		XCTAssertEquals(self.testObject.hue, 0.76f, @"Hue should be set correctly before event is fired");
	}] colorDidChange];
	
	self.testObject.hue = 0.76;
	
	[self.mockObserver verify];
}

- (void)testModelSendsEventForSaturationChange {
	[[[self.mockObserver expect] andDo:^(NSInvocation *invocation) {
		XCTAssertEquals(self.testObject.saturation, 0.52f, @"Saturation should be set correctly before event is fired");
	}] colorDidChange];
	
	self.testObject.saturation = 0.52;
	
	[self.mockObserver verify];
}

- (void)testModelSendsEventForBrightnessChange {
	[[[self.mockObserver expect] andDo:^(NSInvocation *invocation) {
		XCTAssertEquals(self.testObject.brightness, 0.23f, @"Brightness should be set correctly before event is fired");
	}] colorDidChange];
	
	self.testObject.brightness = 0.23;
	
	[self.mockObserver verify];
}

@end
