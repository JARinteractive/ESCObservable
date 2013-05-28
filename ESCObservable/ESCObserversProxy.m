#import "ESCObserversProxy.h"
#import <objc/runtime.h>

@interface ESCStandardObserverWeakWrapper : NSObject

+ (id)weakWrapperWithTarget:(id)target;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) SEL forwardToSelector;

@end

@implementation ESCStandardObserverWeakWrapper

+ (id)weakWrapperWithTarget:(id)target {
	ESCStandardObserverWeakWrapper *wrapper = [[self alloc] init];
	wrapper.target = target;
	return wrapper;
}

+ (id)weakWrapperWithTarget:(id)target selector:(SEL)selector {
	ESCStandardObserverWeakWrapper *wrapper = [[self alloc] init];
	wrapper.target = target;
	wrapper.selector = selector;
	return wrapper;
}

+ (id)weakWrapperWithTarget:(id)target selector:(SEL)selector forwardToSelector:(SEL)forwardToSelector {
	ESCStandardObserverWeakWrapper *wrapper = [[self alloc] init];
	wrapper.target = target;
	wrapper.selector = selector;
	wrapper.forwardToSelector = forwardToSelector;
	return wrapper;
}

@end

@interface ESCObserversProxy()

@property (nonatomic) NSArray *escObservers;
@property (nonatomic) NSArray *escObserverProtocols;

@end

@implementation ESCObserversProxy

- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol {
	if (!self.escObserverProtocols) {
		self.escObserverProtocols = @[observerProtocol];
	} else {
		self.escObserverProtocols = [self.escObserverProtocols arrayByAddingObject:observerProtocol];
	}
}

- (void)escAddObserver:(id)observer {
	[self escAddWrappedObserver:[ESCStandardObserverWeakWrapper weakWrapperWithTarget:observer]];
}

- (void)escAddObserver:(id)observer ofSelector:(SEL)selector {
	[self escAddWrappedObserver:[ESCStandardObserverWeakWrapper weakWrapperWithTarget:observer selector:selector]];
}

- (void)escAddObserver:(id)observer ofSelector:(SEL)selector forwardToSelector:(SEL)observerSelector {
	[self escAddWrappedObserver:[ESCStandardObserverWeakWrapper weakWrapperWithTarget:observer selector:selector forwardToSelector:observerSelector]];
}

- (void)escAddWrappedObserver:(ESCStandardObserverWeakWrapper *)wrappedObserver {
	if (!self.escObservers) {
		self.escObservers = @[wrappedObserver];
	}
	self.escObservers = [self.escObservers arrayByAddingObject:wrappedObserver];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
	struct objc_method_description description;
	for (Protocol *protocol in self.escObserverProtocols) {
		description = protocol_getMethodDescription(protocol, sel, NO, YES);
		if (description.name == NULL) {
			description = protocol_getMethodDescription(protocol, sel, YES, YES);
		}
	}
	if (description.name == NULL) {
		[[NSException exceptionWithName:@"ESCObservableException"
								 reason:[NSString stringWithFormat:@"Attempted to call method (%@) not available on any registered observer protocol", NSStringFromSelector(sel)]
							   userInfo:nil] raise];
		return nil;
	}
	return [NSMethodSignature signatureWithObjCTypes:description.types];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	BOOL cleanUpObservers = NO;
	for (ESCStandardObserverWeakWrapper *observer in self.escObservers) {
		if (!observer.target) {
			cleanUpObservers = YES;
		} else if ((observer.selector == nil || sel_isEqual(observer.selector, invocation.selector)) && ([observer.target respondsToSelector:invocation.selector] || observer.forwardToSelector != nil)) {
			if (observer.forwardToSelector != nil) {
				SEL originalSelector = invocation.selector;
				invocation.selector = observer.forwardToSelector;
				[invocation invokeWithTarget:observer.target];
				invocation.selector = originalSelector;
			} else {
				[invocation invokeWithTarget:observer.target];
			}
		}
	}
	if (cleanUpObservers) {
		[self cleanUpObservers];
	}
}

- (void)cleanUpObservers {
	NSArray *validObservers = @[];
	for (ESCStandardObserverWeakWrapper *observer in self.escObservers) {
		if (observer.target != nil) {
			validObservers = [validObservers arrayByAddingObject:observer];
		}
	}
	self.escObservers = validObservers;
}

@end
