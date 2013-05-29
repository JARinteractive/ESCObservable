#import <Foundation/Foundation.h>

@protocol ESCObservable

@optional
- (void)escAddObserver:(id)observer;
- (void)escAddObserver:(id)observer forSelector:(SEL)selector;
- (void)escAddObserver:(id)observer forSelector:(SEL)selector forwardingToSelector:(SEL)forwardSelector;

@end

@protocol ESCObservableInternal

@optional
- (id)escNotifier;
- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol;

@end

@interface NSObject(ESCObservable)

@end
