#import <Foundation/Foundation.h>

#define ESCSuppressIncompleteImplementationWarnings @optional

@protocol ESCObservable
ESCSuppressIncompleteImplementationWarnings

- (void)escAddObserver:(id)observer;
- (void)escRemoveObserver:(id)observer;

- (void)escAddObserver:(id)observer forSelector:(SEL)selector;
- (void)escRemoveObserver:(id)observer forSelector:(SEL)selector;
- (void)escAddObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector;
- (void)escRemoveObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector;

@end

@protocol ESCObservableInternal<ESCObservable>
ESCSuppressIncompleteImplementationWarnings

- (id)escNotifier;
- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol;

@end

/**
 NSObject, OCMockObject, and all subclasses are already observable. Use this function to make other classes observable (such as a NSProxy subclass).
 @param aClass the Class to add the observable functionality to
 */
void escMakeClassObservable(Class aClass);
