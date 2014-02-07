#import "ESCObserversProxy.h"
#import <objc/runtime.h>

@interface ESCObserverWeakWrapper : NSObject

+ (id)weakWrapperWithTarget:(id)target;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL selector;
@property (nonatomic) SEL forwardToSelector;

@end

@implementation ESCObserverWeakWrapper

+ (id)weakWrapperWithTarget:(id)target {
	ESCObserverWeakWrapper *wrapper = [[self alloc] init];
	wrapper.target = target;
	return wrapper;
}

+ (id)weakWrapperWithTarget:(id)target selector:(SEL)selector forwardToSelector:(SEL)forwardToSelector {
	ESCObserverWeakWrapper *wrapper = [[self alloc] init];
	wrapper.target = target;
	wrapper.selector = selector;
	wrapper.forwardToSelector = forwardToSelector;
	return wrapper;
}

- (BOOL)isEqual:(ESCObserverWeakWrapper *)object
{
    BOOL equalTargets = [self.target isEqual:object.target];
    BOOL equalSelectors = YES;
    BOOL equalForwardToSelectors = YES;
    
    if (self.selector && object.selector) {
        equalSelectors = [NSStringFromSelector(self.selector) isEqualToString:NSStringFromSelector(object.selector)];
    }
    
    if (self.forwardToSelector && object.forwardToSelector) {
        equalForwardToSelectors = [NSStringFromSelector(self.forwardToSelector) isEqualToString:NSStringFromSelector(object.forwardToSelector)];
    }
    
    return equalTargets && equalSelectors && equalForwardToSelectors;
}

@end

@interface ESCObserversProxy()

@property (nonatomic) NSSet *escObservers;
@property (nonatomic) NSSet *escObserverProtocols;

@end

@implementation ESCObserversProxy

- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol {
	if (self.escObserverProtocols) {
		self.escObserverProtocols = [self.escObserverProtocols setByAddingObject:observerProtocol];
	} else {
		self.escObserverProtocols = [NSSet setWithObject:observerProtocol];
	}
}

- (void)escAddObserver:(id)observer {
	[self escAddWrappedObserver:[ESCObserverWeakWrapper weakWrapperWithTarget:observer]];
}

- (void)escAddObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)observerSelector {
    if (observerSelector == NULL) {
        [self raiseExceptionWithMessage:@"Attempt to forward selector to NULL"];
    }
    [self descriptionForSelector:selector];
    [self escAddWrappedObserver:[ESCObserverWeakWrapper weakWrapperWithTarget:observer selector:selector forwardToSelector:observerSelector]];
}

- (void)escAddWrappedObserver:(ESCObserverWeakWrapper *)wrappedObserver {
	if (!self.escObservers) {
		self.escObservers = [NSSet setWithObject:wrappedObserver];
	} else {
		self.escObservers = [self.escObservers setByAddingObject:wrappedObserver];
	}
}

- (void)escRemoveObserver:(id)observer {
	NSMutableSet *observers = [NSMutableSet setWithSet:self.escObservers];
	for (ESCObserverWeakWrapper *observerWrapper in self.escObservers) {
		if (observerWrapper.target == observer) {
			[observers removeObject:observerWrapper];
		}
	}
	self.escObservers = observers;
}

- (void)escRemoveObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector {
	NSMutableSet *observers = [NSMutableSet setWithSet:self.escObservers];
	for (ESCObserverWeakWrapper *observerWrapper in self.escObservers) {
		if (observerWrapper.target == observer && sel_isEqual(observerWrapper.selector, selector) && sel_isEqual(observerWrapper.forwardToSelector, forwardSelector)) {
			[observers removeObject:observerWrapper];
		}
	}
	self.escObservers = observers;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
	if ([self.escObserverProtocols count] == 0) {
        [self raiseExceptionWithMessage:[NSString stringWithFormat:@"This observable has not registered any protocols.  Cannot find method signature for %@", NSStringFromSelector(selector)]];
	}

    struct objc_method_description description = [self descriptionForSelector:selector];
	return [NSMethodSignature signatureWithObjCTypes:description.types];
}

- (struct objc_method_description)descriptionForSelector:(SEL)selector {
    struct objc_method_description description;
    for (Protocol *protocol in self.escObserverProtocols) {
        description = protocol_getMethodDescription(protocol, selector, NO, YES);
        if (description.name == NULL) {
            description = protocol_getMethodDescription(protocol, selector, YES, YES);
        }
        if (description.name) {
            break;
        }
    }
    if (description.name == NULL) {
        [self raiseExceptionWithMessage:[NSString stringWithFormat:@"Selector (%@) does not exist on any registered observer protocol", NSStringFromSelector(selector)]];
    }
    return description;
}

- (void)raiseExceptionWithMessage:(NSString *)message {
    [[NSException exceptionWithName:@"ESCObservableException" reason:message userInfo:nil] raise];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
	BOOL cleanUpObservers = NO;
	for (ESCObserverWeakWrapper *observer in self.escObservers) {
		if (!observer.target) {
			cleanUpObservers = YES;
		} else if (observer.selector == NULL && [observer.target respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:observer.target];
		} else if (sel_isEqual(observer.selector, invocation.selector)) {
            SEL originalSelector = invocation.selector;
            invocation.selector = observer.forwardToSelector;
            [invocation invokeWithTarget:observer.target];
            invocation.selector = originalSelector;
        }
	}
	if (cleanUpObservers) {
		[self cleanUpObservers];
	}
}

- (void)cleanUpObservers {
	NSSet *validObservers = [NSSet set];
	for (ESCObserverWeakWrapper *observer in self.escObservers) {
		if (observer.target != nil) {
			validObservers = [validObservers setByAddingObject:observer];
		}
	}
	self.escObservers = validObservers;
}

@end
