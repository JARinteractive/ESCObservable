#import <Foundation/Foundation.h>

#define ESCSuppressIncompleteImplementationWarnings @optional

@protocol ESCObservable
ESCSuppressIncompleteImplementationWarnings

/// Add observer to be notified on all selectors
- (void)escAddObserver:(id)observer;
/// Remove observer from notifications of all selectors
- (void)escRemoveObserver:(id)observer;

/// Add observer for a specific selector
- (void)escAddObserver:(id)observer forSelector:(SEL)selector;
/// Remove observer for a specific selector
- (void)escRemoveObserver:(id)observer forSelector:(SEL)selector;
/// Add observer for a specific selector and forward messages to a specific selector
- (void)escAddObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector;
/// Remove observer for a specific selector and forwarding selector
- (void)escRemoveObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector;

@end

@protocol ESCObservableInternal<ESCObservable>
ESCSuppressIncompleteImplementationWarnings

/// call methods on this object to notify all observers on the called selector
- (id)escNotifier;
/// register a protocol that defines the selectors that the object notifies with
- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol;

@end

/// NSObject, OCMockObject, and all subclasses are already observable. Use this function to make other classes observable (such as a NSProxy subclass).
void escMakeClassObservable(Class aClass);
