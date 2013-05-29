#import "NSObject+ESCObservable.h"
#import "ESCObserversProxy.h"
#import <objc/runtime.h>

#define ESCObserversProxyKey @"ESCObserversProxyKey"

@interface NSObject(ESCObservableInternal)<ESCObservable, ESCObservableInternal>

@property (nonatomic) ESCObserversProxy *escObserversProxy;

@end

@implementation NSObject(ESCObservable)

- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol {
	[self.escObserversProxy escRegisterObserverProtocol:observerProtocol];
}

- (ESCObserversProxy *)escObserversProxy {
	ESCObserversProxy *observersProxy = objc_getAssociatedObject(self, ESCObserversProxyKey);
	if (!observersProxy) {
		observersProxy = [ESCObserversProxy alloc];
		[self setEscObserversProxy:observersProxy];
	}
	return observersProxy;
}

- (void)setEscObserversProxy:(ESCObserversProxy *)observersProxy {
	objc_setAssociatedObject(self, ESCObserversProxyKey, observersProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)escNotifier {
	return self.escObserversProxy;
}

- (void)escAddObserver:(id)observer {
	[self.escObserversProxy escAddObserver:observer];
}

- (void)escAddObserver:(id)observer forSelector:(SEL)selector {
	[self.escObserversProxy escAddObserver:observer forSelector:selector];
}

- (void)escAddObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardToSelector {
	[self.escObserversProxy escAddObserver:observer forSelector:selector forwardingToSelector:forwardToSelector];
}

@end
