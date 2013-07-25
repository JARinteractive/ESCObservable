//  Copyright (c) 2013 Escappe. All rights reserved.

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "ESCColorPickerPresenter.h"
#import "ESCColorPickerView.h"
#import "ESCColorPickerModel.h"

@interface ESCColorPickerPresenterTest : XCTestCase

@property (nonatomic) ESCColorPickerPresenter *testObject;
@property (nonatomic) id mockView;
@property (nonatomic) id mockModel;

@end

@implementation ESCColorPickerPresenterTest

- (void)setUp {
    [super setUp];
	
	self.mockView = [OCMockObject niceMockForClass:[ESCColorPickerView class]];
	[self.mockView escRegisterObserverProtocol:@protocol(ESCColorPickerViewObserver)];
	self.mockModel = [OCMockObject niceMockForClass:[ESCColorPickerModel class]];
	[self.mockModel escRegisterObserverProtocol:@protocol(ESCColorPickerModelObserver)];
	self.testObject = [[ESCColorPickerPresenter alloc] initWithView:self.mockView model:self.mockModel];
}

- (void)testWhenPresenterIsCreatedValuesAreSetOnView {
	CGFloat expectedHue = 0.41;
	CGFloat expectedSaturation = 0.29;
	CGFloat expectedBrightness = 0.53;
	NSArray *expectedKeys = @[@"key1"];
	NSArray *expectedValues = @[@"stringValue"];
	id mockView = [OCMockObject niceMockForClass:[ESCColorPickerView class]];
	id mockModel = [OCMockObject niceMockForClass:[ESCColorPickerModel class]];
	[[[mockModel stub] andReturnValue:@(expectedHue)] hue];
	[[[mockModel stub] andReturnValue:@(expectedSaturation)] saturation];
	[[[mockModel stub] andReturnValue:@(expectedBrightness)] brightness];
	[[mockView expect] setHue:expectedHue saturation:expectedSaturation brightness:expectedBrightness];
	[[[mockModel stub] andReturn:expectedKeys] colorDescriptionKeys];
	[[[mockModel stub] andReturn:expectedValues] colorDescriptionValues];
	[[mockView expect] setColorDescriptionKeys:expectedKeys values:expectedValues];
	
	(void)[[ESCColorPickerPresenter alloc] initWithView:mockView model:mockModel];
	
	[mockView verify];
}

- (void)testWhenColorChangeEventFiresThenColorIsSetOnView {
	CGFloat expectedHue = 0.42;
	CGFloat expectedSaturation = 0.23;
	CGFloat expectedBrightness = 0.52;
	[[[self.mockModel stub] andReturnValue:@(expectedHue)] hue];
	[[[self.mockModel stub] andReturnValue:@(expectedSaturation)] saturation];
	[[[self.mockModel stub] andReturnValue:@(expectedBrightness)] brightness];
	[[self.mockView expect] setHue:expectedHue saturation:expectedSaturation brightness:expectedBrightness];
	
	[[self.mockModel escNotifier] colorDidChange];
	
	[self.mockView verify];
}

- (void)testWhenHueChangeEventFiresThenHueIsSetOnModel {
	CGFloat expectedHue = 0.87;
	[[self.mockModel expect] setHue:expectedHue];
	
	[[self.mockView escNotifier] hueDidChange:expectedHue];
	
	[self.mockModel verify];
}

- (void)testWhenSaturationChangeEventFiresThenSaturationIsSetOnModel {
	CGFloat expectedSaturation = 0.12;
	[[self.mockModel expect] setSaturation:expectedSaturation];
	
	[[self.mockView escNotifier] saturationDidChange:expectedSaturation];
	
	[self.mockModel verify];
}

- (void)testWhenBrightnessChangeEventFiresThenBrightnessIsSetOnModel {
	CGFloat expectedBrightness = 0.49;
	[[self.mockModel expect] setBrightness:expectedBrightness];
	
	[[self.mockView escNotifier] brightnessDidChange:expectedBrightness];
	
	[self.mockModel verify];
}

- (void)testWhenDescriptionChangeEventFiresThenDescriptionKeysAndValuesAreSetOnView {
	NSArray *expectedKeys = @[@"key1", @"key2"];
	NSArray *expectedValues = @[@"5.0", @"stringValue"];
	[[self.mockView expect] setColorDescriptionKeys:expectedKeys values:expectedValues];
	
	[[self.mockModel escNotifier] colorDescriptionDidChangeKeys:expectedKeys values:expectedValues];
	
	[self.mockView verify];
}

@end
