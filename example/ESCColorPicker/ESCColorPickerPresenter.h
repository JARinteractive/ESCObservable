#import <Foundation/Foundation.h>
#import "ESCColorPickerView.h"
#import "ESCColorPickerModel.h"

@interface ESCColorPickerPresenter : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithView:(ESCColorPickerView *)view model:(ESCColorPickerModel *)model;

@end
