#import <Foundation/Foundation.h>
#import <ESCObservable/ESCObservable.h>

@protocol ESCColorPickerModelObserver

- (void)colorDidChange;

@end

@interface ESCColorPickerModel : NSObject<ESCObservable>

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;

@end
