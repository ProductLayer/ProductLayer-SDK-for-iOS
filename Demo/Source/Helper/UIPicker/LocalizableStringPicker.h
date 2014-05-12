//
//  ProductListTypePickerView.h
//  PL
//
//  Created by René Swoboda on 04/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalizableStringPicker;

@protocol LocalizableStringPickerDelegate <NSObject>

- (void) localizedStringPicker:(LocalizableStringPicker *)_picker selectedString:(NSString *)_string;

@end

@interface LocalizableStringPicker : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *stringList;
@property (nonatomic, strong) NSString *selectedString;

@property (nonatomic, weak) id<LocalizableStringPickerDelegate> _delegate;

@end
