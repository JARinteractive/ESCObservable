#import <Foundation/Foundation.h>
#import <ESCObservable/ESCObservable.h>

@protocol ESCColorPickerModelObserver

- (void)colorDidChange;
- (void)colorDescriptionDidChangeKeys:(NSArray *)keys values:(NSArray *)values;

@end

typedef enum {
	ESCColorPickerModelDescriptionFormatHSB,
	ESCColorPickerModelDescriptionFormatRGB,
	ESCColorPickerModelDescriptionFormatRGBHex,
} ESCColorPickerModelDescriptionFormat;

@interface ESCColorPickerModel : NSObject<ESCObservable>

@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;
@property (nonatomic) CGFloat brightness;

@property (nonatomic) ESCColorPickerModelDescriptionFormat descriptionFormat;
@property (nonatomic) NSArray *colorDescriptionKeys;
@property (nonatomic) NSArray *colorDescriptionValues;

@end
