#import <GHUnitIOS/GHUnit.h>
#import "ESCObservable.h"
#import "OCMock.h"

#pragma mark - Protocols for Observers to implement

@protocol ESCObservableTestObserver

- (void)testMessageWithNoParameters;
- (void)testMessageWithStringParameter:(NSString *)string primitiveParameter:(NSInteger)integer;

@optional
- (void)testOptionalMessageWithNoParameters;

@end

@protocol ESCObservableTestOtherObserver

- (void)testMessageOnOtherObserverProtocol;

@end

#pragma mark - Protocol to test forwarding

@protocol ESCObservableTestForwardingSelectors

- (void)forwardedString:(NSString *)string integer:(NSInteger)integer;

@end

#pragma mark - Object Used to Test the ESCObservable Category

@interface ESCTestObservable : NSObject<ESCObservable>

- (void)sendInvalidMessage;
- (void)sendTestMessageWithNoParameters;
- (void)sendTestOptionalMessageWithNoParameters;
- (void)sendTestMessageWithStringParameter:(NSString *)string primitiveParameter:(NSInteger)integer;
- (void)sendTestMessageOnOtherObserverProtocol;

@end

@interface ESCTestObservable()<ESCObservableInternal>

@end

@implementation ESCTestObservable

- (id)init {
	if (self = [super init]) {
		[self escRegisterObserverProtocol:@protocol(ESCObservableTestObserver)];
	}
	return self;
}

- (void)sendTestMessageWithNoParameters {
	[[self escNotifier] testMessageWithNoParameters];
}

- (void)sendTestOptionalMessageWithNoParameters {
	[[self escNotifier] testOptionalMessageWithNoParameters];
}

- (void)sendTestMessageWithStringParameter:(NSString *)string primitiveParameter:(NSInteger)integer {
	[[self escNotifier] testMessageWithStringParameter:string primitiveParameter:integer];
}

- (void)sendTestMessageOnOtherObserverProtocol {
	[[self escNotifier] testMessageOnOtherObserverProtocol];
}

- (void)sendInvalidMessage {
	[[self escNotifier] shouldRunOnMainThread];
}

@end

#pragma mark - Tests

@interface NSObject_ESCObservableTest : GHTestCase<ESCObservable, ESCObservableInternal>

@property (nonatomic) ESCTestObservable *testObject;
@property (nonatomic) id mockObserver1;
@property (nonatomic) id mockObserver2;
@property (nonatomic) id mockOtherObserver;

@end

@implementation NSObject_ESCObservableTest

- (void)setUp {
    [super setUp];
	
	self.testObject = [[ESCTestObservable alloc] init];
	
	self.mockObserver1 = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:self.mockObserver1];
	self.mockObserver2 = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:self.mockObserver2];
	self.mockOtherObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestOtherObserver)];
	[self.testObject escAddObserver:self.mockOtherObserver];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMessageWithoutParametersIsCalledOnObserver {
	[[self.mockObserver1 expect] testMessageWithNoParameters];
	
	[self.testObject sendTestMessageWithNoParameters];
	
	[self.mockObserver1 verify];
}

- (void)testMessageWithoutParametersIsCalledOnceOnObserver {
	__block NSInteger callCount = 0;
	[[[self.mockObserver1 stub] andDo:^(NSInvocation *invocation) {
		callCount++;
	}] testMessageWithNoParameters];
	
	[self.testObject sendTestMessageWithNoParameters];
	
	GHAssertEquals(callCount, 1, nil);
}

- (void)testMessageWithoutParametersIsCalledOnObserverMultipleTimes {
	[[self.mockObserver1 expect] testMessageWithNoParameters];
	[self.testObject sendTestMessageWithNoParameters];
	[self.mockObserver1 verify];
	
	[[self.mockObserver1 expect] testMessageWithNoParameters];
	[self.testObject sendTestMessageWithNoParameters];
	[self.mockObserver1 verify];
}

- (void)testMessageWithoutParametersIsCalledOnObservers {
	[[self.mockObserver1 expect] testMessageWithNoParameters];
	[[self.mockObserver2 expect] testMessageWithNoParameters];
	
	[self.testObject sendTestMessageWithNoParameters];
	
	[self.mockObserver1 verify];
	[self.mockObserver2 verify];
}

- (void)testOptionalMessageWithoutParametersIsCalledOnObserver {
	[[self.mockObserver1 expect] testOptionalMessageWithNoParameters];
	
	[self.testObject sendTestOptionalMessageWithNoParameters];
	
	[self.mockObserver1 verify];
}

- (void)testMessageOnOtherObserverProtocolIsCalled {
	[self.testObject escRegisterObserverProtocol:@protocol(ESCObservableTestOtherObserver)];
	[[self.mockOtherObserver expect] testMessageOnOtherObserverProtocol];
	
	[self.testObject sendTestMessageOnOtherObserverProtocol];
	
	[self.mockOtherObserver verify];
}

- (void)testOtherMethodIsNotCalledOnObserver {
	NSException *actualException = nil;
	@try {
		[self.testObject sendInvalidMessage];
	}
	@catch (NSException *exception) {
		actualException = exception;
	}
	
	GHAssertEqualStrings(actualException.name, @"ESCObservableException", nil);
}

- (void)testMessageWithParametersIsCalledOnObservers {
	NSString *expectedString = @"The Answer";
	NSInteger expectedInteger = 42;
	[[self.mockObserver1 expect] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	[[self.mockObserver2 expect] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[self.testObject sendTestMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[self.mockObserver1 verify];
	[self.mockObserver2 verify];
}

- (void)testObserversAreHeldWithWeakReferences {
	__weak id mockObserverWeakReference = nil;
	@autoreleasepool {
		id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
		[self.testObject escAddObserver:mockObserver];
		
		mockObserverWeakReference = mockObserver;
	}

	GHAssertNil(mockObserverWeakReference, nil);
}

- (void)testObserverDoesNotSlowDownDueToHoldingManyInvalidObservers {
	id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:mockObserver];
	NSDate *referenceStartDate = [NSDate date];
	[self.testObject sendTestMessageWithNoParameters];
	NSDate *referenceEndDate = [NSDate date];
	
	NSTimeInterval referenceTimeInterval = [referenceEndDate timeIntervalSinceDate:referenceStartDate];
	
	for (NSInteger i = 0; i < 1000; i++) {
		@autoreleasepool {
		id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
		[self escAddObserver:mockObserver];
		[self.testObject sendTestMessageWithNoParameters];
		}
	}
	
	NSDate *testStartDate = [NSDate date];
	[self.testObject sendTestMessageWithNoParameters];
	NSDate *testEndDate = [NSDate date];
	
	NSTimeInterval testTimeInterval = [testEndDate timeIntervalSinceDate:testStartDate];
	
	GHAssertTrue(testTimeInterval < (referenceTimeInterval * 2.0), nil);
}

- (void)testMessageWithParametersIsCalledOnObserverRegisteredOnlyForMessageWithParameters {
	id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:mockObserver forSelector:@selector(testMessageWithStringParameter:primitiveParameter:)];
	
	NSString *expectedString = @"The Answer";
	NSInteger expectedInteger = 42;
	[[mockObserver expect] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[self.testObject sendTestMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[mockObserver verify];
}

- (void)testMessageWithNoParametersIsNotCalledOnObserverRegisteredOnlyForMessageWithParameters {
	id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:mockObserver forSelector:@selector(testMessageWithNoParameters)];
	
	NSString *expectedString = @"The Answer";
	NSInteger expectedInteger = 42;
	[[mockObserver reject] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[self.testObject sendTestMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
}

- (void)testForwardedSelectorCalledOnObserverForMessageWithParameters {
	id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestForwardingSelectors)];
	[self.testObject escAddObserver:mockObserver forSelector:@selector(testMessageWithStringParameter:primitiveParameter:) forwardingToSelector:@selector(forwardedString:integer:)];
	
	NSString *expectedString = @"The Answer";
	NSInteger expectedInteger = 42;
	[[mockObserver expect] forwardedString:expectedString integer:expectedInteger];
	
	[self.testObject sendTestMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[mockObserver verify];
}

- (void)testAllObserversNotifiedWhenAddedUsingDifferentMethods {
	id mockForwardingObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestForwardingSelectors)];
	[self.testObject escAddObserver:mockForwardingObserver forSelector:@selector(testMessageWithStringParameter:primitiveParameter:) forwardingToSelector:@selector(forwardedString:integer:)];
	id mockSelectorObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:mockSelectorObserver forSelector:@selector(testMessageWithStringParameter:primitiveParameter:)];
	id mockStandardObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
	[self.testObject escAddObserver:mockStandardObserver];
	
	NSString *expectedString = @"The Answer";
	NSInteger expectedInteger = 42;
	[[mockForwardingObserver expect] forwardedString:expectedString integer:expectedInteger];
	[[mockSelectorObserver expect] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	[[mockStandardObserver expect] testMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[self.testObject sendTestMessageWithStringParameter:expectedString primitiveParameter:expectedInteger];
	
	[mockStandardObserver verify];
	[mockSelectorObserver verify];
	[mockForwardingObserver verify];
}

- (void)testWhenRegisteringSelectorThatIsNotOnTheObserverProtocolThenARuntimeExceptionIsThrown {
    id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
    NSException *actualException = nil;
    @try {
        [self.testObject escAddObserver:mockObserver forSelector:@selector(description)];
    }
    @catch (NSException *exception) {
        actualException = exception;
    }

    GHAssertEqualStrings(actualException.name, @"ESCObservableException", nil);
}

- (void)testWhenRegisteringSelectorThatIsNotOnTheObserverProtocolForwardedToSelectorThenARuntimeExceptionIsThrown {
    id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
    NSException *actualException = nil;
    @try {
        [self.testObject escAddObserver:mockObserver forSelector:@selector(description) forwardingToSelector:@selector(testMessageWithNoParameters)];
    }
    @catch (NSException *exception) {
        actualException = exception;
    }

    GHAssertEqualStrings(actualException.name, @"ESCObservableException", nil);
}

- (void)testWhenForwardingToNilSelectorAnExceptionIsThrown {
    id mockObserver = [OCMockObject niceMockForProtocol:@protocol(ESCObservableTestObserver)];
    NSException *actualException = nil;
    @try {
        [self.testObject escAddObserver:mockObserver forSelector:@selector(testMessageWithNoParameters) forwardingToSelector:nil];
    }
    @catch (NSException *exception) {
        actualException = exception;
    }

    GHAssertEqualStrings(actualException.name, @"ESCObservableException", nil);
}

@end
