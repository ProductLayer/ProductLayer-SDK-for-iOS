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

- (void) setStringListAndSort:(NSArray *)stringList sortByLocalizedString:(BOOL)localizedSort{
    BOOL reverseSort = NO;
    
    if(localizedSort){
        self.stringList = [stringList sortedArrayUsingFunction:sortByLocalizedString
                                                   context:&reverseSort];
    } else {
        self.stringList = [stringList sortedArrayUsingFunction:sortByString
                                                       context:&reverseSort];
    }
}

NSInteger sortByString(NSString *firstString, NSString *secondString, void *reverse)
{
    NSComparisonResult comparison = [firstString localizedCaseInsensitiveCompare:secondString];
    
    if (*(BOOL *)reverse == YES) {
        return 0 - comparison;
    }
    return comparison;
}

NSInteger sortByLocalizedString(NSString *firstString, NSString *secondString, void *reverse)
{
    NSString *firstLocalizedString = NSLocalizedString(firstString, @"");
    NSString *secondLocalizedString = NSLocalizedString(secondString, @"");
    
    NSComparisonResult comparison = [firstLocalizedString localizedCaseInsensitiveCompare:secondLocalizedString];
    
    if (*(BOOL *)reverse == YES) {
        return 0 - comparison;
    }
    return comparison;
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
