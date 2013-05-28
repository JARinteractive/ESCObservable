#import <Foundation/Foundation.h>

@protocol ESCObservable

@optional
- (void)escAddObserver:(id)observer;
- (void)escAddObserver:(id)observer ofSelector:(SEL)selector;
- (void)escAddObserver:(id)observer ofSelector:(SEL)selector forwardToSelector:(SEL)forwardToSelector;

@end

@protocol ESCObservableInternal

@optional
- (id)escObservers;
- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol;

@end

@interface NSObject(ESCObservable)

@end
