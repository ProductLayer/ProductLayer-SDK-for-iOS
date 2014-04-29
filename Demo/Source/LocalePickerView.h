//
//  LocalePickerView.h
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocalePickerDelegate <NSObject>

- (void) localeSelected:(NSLocale *)_locale;

@end

@interface LocalePickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) NSLocale *selectedLocale;

@property (nonatomic, weak) id<LocalePickerDelegate> _delegate;

@end
