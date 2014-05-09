//
//  EditProductViewController.m
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "EditProductViewController.h"
#import "DTBlockFunctions.h"
#import "PLYProduct.h"

#import "AppSettings.h"

@implementation EditProductViewController

- (void)viewDidLoad
{
	[self.gtinTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.productNameTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.vendorTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.categoryTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    [self.localeTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    
    _localePicker._delegate = self;
	
	[self _updateSaveButtonStatus];
    
    NSLocale *locale = [AppSettings currentAppLocale];
    [[PLYServer sharedPLYServer] getCategoriesForLocale:locale.localeIdentifier completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Creation Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				_categories = result;
				
				[self.categoryPicker reloadAllComponents];
			});
		}
	}];
    
    [self updateView];
}

- (void) updateView{
    if(_product){
        self.gtinTextField.text = _product.gtin;
        self.gtinTextField.enabled = false;
    
        self.productNameTextfield.text = _product.name;
        self.vendorTextField.text = _product.brandName;
        self.categoryTextField.text = _product.category;
    
        self.localeTextField.text = _product.language;
    }
}

- (void) setProduct:(PLYProduct *)product{
    _product = product;
    
    [self updateView];
}

- (void)_updateSaveButtonStatus
{
	if (![self.gtinTextField.text length])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	if (![self.productNameTextfield.text length])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark - Actions


- (void)textFieldChanged:(id)sender
{
	[self _updateSaveButtonStatus];
}

- (IBAction)save:(id)sender
{
	if(!_product){
        _product = [[PLYProduct alloc] init];;
    }
        
	_product.gtin = self.gtinTextField.text;

	NSString *name = self.productNameTextfield.text;
	if ([name length])
	{
		_product.name = name;
	}
	
	NSString *vendor = self.vendorTextField.text;
	if ([vendor length])
	{
		_product.brandName = vendor;
	}

	NSString *category = self.categoryTextField.text;
	if ([category length])
	{
        _product.category = [[_categories allKeys] objectAtIndex:[_categoryPicker selectedRowInComponent:0]];
	}
	
	_product.language = [_localePicker.selectedLocale localeIdentifier];

    // Insert Product
    if(_product.Id == nil) {
        [[PLYServer sharedPLYServer] createProductWithGTIN:_product.gtin dictionary:[_product getDictionary] completion:^(id result, NSError *error) {
		
            if (error)
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Creation Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    if([result isKindOfClass:PLYProduct.class]){
                        [_delegate productUpdated:result];
                    }
                    
                    [self cancel:self];
                });
            }
        }];
    }
    // Update product
    else {
        [[PLYServer sharedPLYServer] updateProductWithGTIN:_product.gtin dictionary:[_product getDictionary] completion:^(id result, NSError *error) {
            
            if (error)
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Update Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    if([result isKindOfClass:PLYProduct.class]){
                        [_delegate productUpdated:result];
                    }
                    
                    [self cancel:self];
                });
            }
        }];
    }
}

- (IBAction) cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 4 && self.categoryPickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 4 && self.categoryPickerIsShowing == YES){
        return 177.0f;
    }
    
    if (indexPath.section == 0 && indexPath.row == 6 && self.localePickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 6 && self.localePickerIsShowing == YES){
        return 177.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3){
        if (self.categoryPickerIsShowing){
            [self hideCategoryPickerCell];
        }else {
            [self showCategoryPickerCell];
            
            if(self.localePickerIsShowing){
                [self hideLocalePickerCell];
            }
        }
    }
    
    if (indexPath.row == 5 && [_product Id] == nil){
        if (self.localePickerIsShowing){
            [self hideLocalePickerCell];
        }else {
            [self showLocalePickerCell];
            
            if(self.categoryPickerIsShowing){
                [self hideCategoryPickerCell];
            }
        }
    }
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
    if (pickerView == _categoryPicker) {
        return [_categories count];
    }

    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker) {
        return [self getCategoryValueforIndex:row];
    }
    
    return @"";
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if (pickerView == _categoryPicker) {
        [self.categoryTextField setText:[self getCategoryValueforIndex:row]];
    }
}

-(NSString *) getCategoryValueforIndex:(NSInteger)index{
    NSString *key = [[_categories allKeys] objectAtIndex:index];
    id value = ((NSString *)[_categories objectForKey:key]);
    
    if([value isEqual:[NSNull null]] || value == nil || [value isEqualToString:@"TBL"]){
        return key;
    }
    
    return value;
}

#pragma mark - Hide & Show Locale Picker

- (void)showCategoryPickerCell {
    self.categoryPickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.categoryPicker.hidden = NO;
    self.categoryPicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.categoryPicker.alpha = 1.0f;
    }];
}

- (void)hideCategoryPickerCell {
    self.categoryPickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.categoryPicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.categoryPicker.hidden = YES;
                     }];
}

- (void)showLocalePickerCell {
    self.localePickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.localePicker.hidden = NO;
    self.localePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.localePicker.alpha = 1.0f;
    }];
}

- (void)hideLocalePickerCell {
    self.localePickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.localePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.localePicker.hidden = YES;
                     }];
}

#pragma mark - Locale Picker Delegate

- (void) localeSelected:(NSLocale *)_locale{
    [_localeTextField setText:[_locale displayNameForKey:NSLocaleIdentifier value:_locale.localeIdentifier]];
}

#pragma mark -
#pragma mark unwind

- (IBAction)unwindFromEditProduct:(UIStoryboardSegue *)unwindSegue{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
