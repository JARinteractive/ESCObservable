#import <Foundation/Foundation.h>

@interface ESCObserversProxy : NSProxy

- (void)escAddObserver:(id)observer;
- (void)escAddObserver:(id)observer ofSelector:(SEL)selector;
- (void)escAddObserver:(id)observer ofSelector:(SEL)selector forwardToSelector:(SEL)observerSelector;
- (void)escRegisterObserverProtocol:(Protocol *)observerProtocol;

@end
