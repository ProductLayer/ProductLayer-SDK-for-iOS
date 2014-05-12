//
//  LocalePickerView.m
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "LocalePickerView.h"

#import "AppSettings.h"

@implementation LocalePickerView

- (void)awakeFromNib{
    // Init locales
    [self setDataSource:self];
    [self setDelegate:self];
    
    BOOL reverseSort = NO;
    self.languages = [AppSettings availableLocales];
    self.languages = [self.languages sortedArrayUsingFunction:localeSortByDisplayNameSettings
                                                        context:&reverseSort];
    
    _selectedLocale = [AppSettings currentAppLocale];
    [__delegate localeSelected:_selectedLocale];
    
    for(NSString *locales in self.languages){
        if([locales isEqualToString:[_selectedLocale localeIdentifier]]){
            [self selectRow:[self.languages indexOfObject:locales] inComponent:0 animated:NO];
            break;
        }
    }
}

NSInteger localeSortByDisplayNameSettings(NSString *local1String, NSString *locale2String, void *reverse)
{
    NSString *locale1 = [[NSLocale localeWithLocaleIdentifier:local1String] displayNameForKey:NSLocaleIdentifier value:local1String];
    NSString *locale2 = [[NSLocale localeWithLocaleIdentifier:locale2String] displayNameForKey:NSLocaleIdentifier value:locale2String];
    
    NSComparisonResult comparison = [locale1 localizedCaseInsensitiveCompare:locale2];
    
    if (*(BOOL *)reverse == YES) {
        return 0 - comparison;
    }
    return comparison;
}

- (void)set_delegate:(id<LocalePickerDelegate>)delegate{
    __delegate = delegate;
    
    [__delegate localeSelected:_selectedLocale];
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
    return [_languages count];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    _selectedLocale = [NSLocale localeWithLocaleIdentifier:[_languages objectAtIndex:row]];
    [__delegate localeSelected:_selectedLocale];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:[_languages objectAtIndex:row]];
    return [locale displayNameForKey:NSLocaleIdentifier value:[_languages objectAtIndex:row]];
}

@end
