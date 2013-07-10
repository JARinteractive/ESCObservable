ESCObservable
=============

A framework that implements the Observer pattern.  

Advantages over using NSNotificationCenter:

* No need to remove observers on dealloc (ESCObservable uses weak references)
* Observers have a clearly defined list of possible events (defined in a protocol)
* Each event has a clearly defined list of parameters
* Send primitive types or nil as parameters
* Easy to test using mock objects

Using ESCObservable
=============

Declare Events
-------------

Events are declared in one or more protocols.

```
// An example of a protocol that might be used
@protocol ExampleObjectObserver
@optional // all methods will be treated as optional by ESCObservable regardless of the @optional keyword

- (void)testMessageWithNoParameters;
- (void)testMessageWithObjectParameter:(NSString *)string primitiveParameter:(NSInteger)integer;

@end
```

Notifying Observers
-------------

To send events you must declare what protocol(s) declare the methods you will event on. (typically in -init).  To post events just call the method on your escNotifier.

```
// ExampleObject.h
@interface ExampleObject : NSObject<ESCObservable>

@end
```

```
// ExampleObject.m
@interface ESCTestObservable()<ESCObservableInternal>

@end

@implementation ESCTestObservable

- (id)init {
	if (self = [super init]) {
		[self escRegisterObserverProtocol:@protocol(ExampleObjectObserver)];
	}
	return self;
}

- (void)sendExampleEvents {
	// send event to all observers
	[self.escNotifier testMessageWithNoParameters];

	// send event with parameters to all observers
	[self.escNotifier testMessageWithObjectParameter:@"The Answer" primitiveParameter:42];
}

@end
```