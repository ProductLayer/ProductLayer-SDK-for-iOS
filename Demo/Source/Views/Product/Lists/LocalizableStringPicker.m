//
//  ProductListTypePickerView.m
//  PL
//
//  Created by René Swoboda on 04/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "LocalizableStringPicker.h"

@implementation LocalizableStringPicker

- (void)awakeFromNib{
    // Init locales
    [self setDataSource:self];
    [self setDelegate:self];
}

- (void)set_delegate:(id<LocalizableStringPickerDelegate>)delegate{
    __delegate = delegate;
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated{
    [super selectRow:row inComponent:component animated:animated];
    
    _selectedString = [_stringList objectAtIndex:row];
    [__delegate localizedStringPicker:self selectedString:_selectedString];
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [_stringList count];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    _selectedString = [_stringList objectAtIndex:row];
    [__delegate localizedStringPicker:self selectedString:_selectedString];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return NSLocalizedString([_stringList objectAtIndex:row], @"");
}

@end
