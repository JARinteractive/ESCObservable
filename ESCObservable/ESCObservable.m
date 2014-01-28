#import "ESCObservable.h"
#import "ESCObserversProxy.h"
#import <objc/runtime.h>

#define ESCObserversProxyKey @"ESCObserversProxyKey"

static ESCObserversProxy *escObserversProxy(id self) {
	ESCObserversProxy *observersProxy = objc_getAssociatedObject(self, ESCObserversProxyKey);
	if (!observersProxy) {
		observersProxy = [ESCObserversProxy alloc];
		objc_setAssociatedObject(self, ESCObserversProxyKey, observersProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return observersProxy;
}

static void escRegisterObserverProtocol(id self, SEL _cmd, Protocol *observerProtocol) {
	[escObserversProxy(self) escRegisterObserverProtocol:observerProtocol];
}

static id escNotifier(id self, SEL _cmd) {
	return escObserversProxy(self);
}

static void escAddObserver(id self, SEL _cmd, id observer) {
    [escObserversProxy(self) escAddObserver:observer];
}
static void escRemoveObserver(id self, SEL _cmd, id observer) {
    [escObserversProxy(self) escRemoveObserver:observer];
}

static void escAddObserverForSelector(id self, SEL _cmd, id observer, SEL selector) {
	[escObserversProxy(self) escAddObserver:observer forSelector:selector forwardingToSelector:selector];
}

static void escRemoveObserverForSelector(id self, SEL _cmd, id observer, SEL selector) {
	[escObserversProxy(self) escRemoveObserver:observer forSelector:selector forwardingToSelector:selector];
}

static void escAddObserverForSelectorForwardingToSelector(id self, SEL _cmd, id observer, SEL selector, SEL forwardToSelector) {
	[escObserversProxy(self) escAddObserver:observer forSelector:selector forwardingToSelector:forwardToSelector];
}

static void escRemoveObserverForSelectorForwardingToSelector(id self, SEL _cmd, id observer, SEL selector, SEL forwardToSelector) {
	[escObserversProxy(self) escRemoveObserver:observer forSelector:selector forwardingToSelector:forwardToSelector];
}

void escMakeClassObservable(Class aClass) {
	if (aClass != NULL) {
		class_addMethod(aClass, @selector(escRegisterObserverProtocol:), (IMP)escRegisterObserverProtocol, "v@:@");
		class_addMethod(aClass, @selector(escNotifier), (IMP)escNotifier, "@@:");
		class_addMethod(aClass, @selector(escAddObserver:), (IMP)escAddObserver, "v@:@");
		class_addMethod(aClass, @selector(escRemoveObserver:), (IMP)escRemoveObserver, "v@:@");
		class_addMethod(aClass, @selector(escAddObserver:forSelector:), (IMP)escAddObserverForSelector, "v@:@:");
		class_addMethod(aClass, @selector(escRemoveObserver:forSelector:), (IMP)escRemoveObserverForSelector, "v@:@:");
		class_addMethod(aClass, @selector(escAddObserver:forSelector:forwardingToSelector:), (IMP)escAddObserverForSelectorForwardingToSelector, "v@:@::");
		class_addMethod(aClass, @selector(escRemoveObserver:forSelector:forwardingToSelector:), (IMP)escRemoveObserverForSelectorForwardingToSelector, "v@:@::");
	}
}

__attribute__((constructor)) static void escObservableRuntimeSetup() {
	escMakeClassObservable([NSObject class]);
	escMakeClassObservable(objc_getClass("OCMockObject"));
	escMakeClassObservable(objc_getClass("SBLMockObject"));
}
