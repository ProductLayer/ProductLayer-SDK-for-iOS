//
//  ProductListTypePickerView.m
//  PL
//
//  Created by René Swoboda on 04/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "LocalizableStringPicker.h"
#import "ProductLayer.h"

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

- (void) setStringListAndSort:(NSArray *)stringList sortByLocalizedString:(BOOL)localizedSort
{
    if(localizedSort)
	 {
		 self.stringList = [stringList sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
			 
			 NSString *localizedObj1 = PLYLocalizedStringFromTable(obj1, @"API", @"");
			 NSString *localizedObj2 = PLYLocalizedStringFromTable(obj2, @"API", @"");
			 
			 return [localizedObj1 localizedCaseInsensitiveCompare:localizedObj2];
		 }];
    }
	 else
	 {
		 self.stringList = [stringList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
    return PLYLocalizedStringFromTable([_stringList objectAtIndex:row], @"API", @"");
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        [tView setFont:[UIFont boldSystemFontOfSize:12]];
    }
    // Fill the label text here
    [tView setText:[self pickerView:pickerView titleForRow:row forComponent:component]];
    
    return tView;
}

@end
