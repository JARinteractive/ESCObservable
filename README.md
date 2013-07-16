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

Project Setup
-------------
ESCObservable can be imported as a subproject in Xcode or as a .framework.  The .framework can be built using the ```Build Framework``` target.

In the build settings under ```Other Linker Flags``` add ```-ObjC``` and ```-all_load```.


Declare Events
-------------

Events are declared in one or more protocols.

```
// An example of a protocol that might be used
@protocol ExampleObjectObserver
@optional // all methods will be treated as optional by ESCObservable regardless of the @optional keyword

- (void)eventWithNoParameters;
- (void)eventWithObjectParameter:(NSString *)string primitiveParameter:(NSInteger)integer;

@end
```

Notifying Observers
-------------

To send events you must declare what protocol(s) declare the methods you will event on (typically in -init).  To post events just call the method on your escNotifier.

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
	[self.escNotifier eventWithNoParameters];

	// send event with parameters to all observers
	[self.escNotifier eventWithObjectParameter:@"The Answer" primitiveParameter:42];
}

@end
```

Observing
-------------

### Option 1 - ```-escAddObserver:```

Adding an observer using -escAddObserver: will register the object to receive all events.  If the object does not implement a method on the protocol, it will simply not be called (no crashes for unimplemented methods).

```
// ExampleObserver1.m

- (instancetype)initWithExampleObject:(ExampleObject *)exampleObject {
	if (self = [super init]) {
		[exampleObject escAddObserver:self];
	}
	return self;
}

- (void)eventWithNoParameters {
	// do stuff based on the eventWithNoParameters event
}

- (void)eventWithObjectParameter:(NSString *)string primitiveParameter:(NSInteger)integer {
	// do stuff based on the eventWithObjectParameter:primitiveParameter: event
}
```

### Option 2 - ```-escAddObserver:forSelector:``` and ```-escAddObserver:forSelector:forwardingToSelector```

Adding an observer using ```-escAddObserver:forSelector:``` or ```-escAddObserver:forSelector:forwardingToSelector``` will register the object to receive only the specified event.  If the latter is used, the forwardingToSelector will be called when the event occurs.  If using forwardToSelector, the method signatures must match.

```
// ExampleObserver2.m

- (instancetype)initWithExampleObject:(ExampleObject *)exampleObject {
	if (self = [super init]) {
		[exampleObject escAddObserver:self forSelector:@selector(eventWithNoParameters)];
		[exampleObject escAddObserver:self forSelector:@selector(eventWithObjectParameter:primitiveParameter:) forwardToSelector:@selector(forwardingExampleWithString:integer:)];
	}
	return self;
}

- (void)eventWithNoParameters {
	// do stuff based on the eventWithNoParameters event
}

- (void)forwardingExampleWithString:(NSString *)string integer:(NSInteger)integer {
	// do stuff based on the eventWithObjectParameter:primitiveParameter: event
}
```