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

- (void)testModelSendsDescriptionEventWhenColorChanges {
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"H", @"S", @"B"] values:@[@"0.500", @"0.300", @"0.400"]];
	self.testObject.hue = 0.5;
	[self.mockObserver verify];
	
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"H", @"S", @"B"] values:@[@"0.500", @"0.600", @"0.400"]];
	self.testObject.saturation = 0.6;
	[self.mockObserver verify];
	
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"H", @"S", @"B"] values:@[@"0.500", @"0.600", @"0.129"]];
	self.testObject.brightness = 0.129;
	[self.mockObserver verify];
}

- (void)testModelSendsDescriptionEventWhenColorFormatChanges {
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"R", @"G", @"B"] values:@[@"0.376", @"0.400", @"0.280"]];
	self.testObject.descriptionFormat = ESCColorPickerModelDescriptionFormatRGB;
	[self.mockObserver verify];
	
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"#"] values:@[@"5F6647"]];
	self.testObject.descriptionFormat = ESCColorPickerModelDescriptionFormatRGBHex;
	[self.mockObserver verify];
	
	[[self.mockObserver expect] colorDescriptionDidChangeKeys:@[@"H", @"S", @"B"] values:@[@"0.200", @"0.300", @"0.400"]];
	self.testObject.descriptionFormat = ESCColorPickerModelDescriptionFormatHSB;
	[self.mockObserver verify];
}

@end
