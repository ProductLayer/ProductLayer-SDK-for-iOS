//
//  PLEditProductViewControllerTableViewController.m
//  ProductLayer
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYEditProductViewController.h"
#import "PLYTextFieldTableViewCell.h"
#import "ProductLayerUI.h"

#import "DTBlockFunctions.h"
#import "NSString+DTPaths.h"


@interface PLYEditProductViewController () <PLYFormValidationDelegate, PLYCategoryPickerViewControllerDelegate, PLYBrandPickerViewControllerDelegate, PLYBrandOwnerPickerViewControllerDelegate>

@end

@implementation PLYEditProductViewController
{
	PLYTextField *_nameField;
	
	NSString *_brandName;
	NSString *_brandOwner;
	NSString *_selectedCategoryKey;
	NSArray *_categories;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	[self.tableView registerClass:[PLYTextFieldTableViewCell class] forCellReuseIdentifier:@"PLYTextFieldTableViewCell"];
	[self.tableView registerClass:[PLYBrandedTableViewCell class] forCellReuseIdentifier:@"PLYBrandedTableViewCell"];
	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"EDIT_PRODUCT_TITLE", @"UI", @"Title for VC for editing products");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updatedCategories:) name:PLYServerDidUpdateProductCategoriesNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    [self _updateCategory];
	
	self.saveButtonItem.enabled = [self _saveIsPossible];
}

#pragma mark - Helpers

- (void)_updateCategoryForKey:(NSString *)key
{

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    
    NSString *path = [self.productLayerServer localizedCategoryPathForKey:key];
    
    if (path)
    {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    if (!path)
    {
        path = key;
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    cell.textLabel.text = path;
}

- (void)_updateCategory
{
    if (_selectedCategoryKey)
    {
        [self _updateCategoryForKey:_selectedCategoryKey];
    }
    else
    {
        [self _updateCategoryForKey:@"pl-prod-cat-uncategorized"];
    }
}

- (void)_configureProductNameCell:(UITableViewCell *)cell
{
	PLYTextFieldTableViewCell *nameCell = (PLYTextFieldTableViewCell *)cell;
	_nameField = [nameCell textField];
	_nameField.placeholder = @"ACME Productname";
	
	if ([_product.name length])
	{
		_nameField.text = _product.name;
		_nameField.validator = [PLYContentsDidChangeValidator validatorWithDelegate:self originalContents:_product.name];
	}
	else
	{
		_nameField.validator = [PLYNonEmptyValidator validatorWithDelegate:self];
	}
}

- (void)_configureBrandNameCell:(UITableViewCell *)cell
{
	if ([_brandName length])
	{
		cell.textLabel.text = _brandName;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textLabel.text = @"Unknown";
		cell.textLabel.textColor = [UIColor grayColor];
	}
}

- (void)_configureBrandOwnerCell:(UITableViewCell *)cell
{
	if ([_brandOwner length])
	{
		cell.textLabel.text = _brandOwner;
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textLabel.text = @"Unknown";
		cell.textLabel.textColor = [UIColor grayColor];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
 	 	case 0:
		{
			return PLYLocalizedStringFromTable(@"EDIT_PRODUCT_SECTION_TITLE", @"UI", @"Title for section containing product name");
		}
			
		case 1:
		{
			return PLYLocalizedStringFromTable(@"EDIT_PRODUCT_SECTION_BRAND", @"UI", @"Title for section containing product brand name");
		}
			
		case 2:
		{
			return PLYLocalizedStringFromTable(@"EDIT_PRODUCT_SECTION_BRAND_OWNER", @"UI", @"Title for section containing product brand owner name");
		}
			
		case 3:
		{
			return PLYLocalizedStringFromTable(@"EDIT_PRODUCT_SECTION_CATEGORY", @"UI", @"Title for section containing product category name");
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
		case 1:
		{
			PLYBrandPickerViewController *brandPicker = [PLYBrandPickerViewController new];
			brandPicker.selectedBrandName = _brandName;
			brandPicker.selectedBrandOwnerName = _brandOwner;
			brandPicker.GTIN = _product.GTIN;
			brandPicker.delegate = self;
			[self.navigationController pushViewController:brandPicker animated:YES];
			
			break;
		}
		
		case 2:
		{
			PLYBrandOwnerPickerViewController *brandPicker = [PLYBrandOwnerPickerViewController new];
			brandPicker.selectedBrandOwnerName = _brandOwner;
			brandPicker.GTIN = _product.GTIN;
			brandPicker.delegate = self;
			[self.navigationController pushViewController:brandPicker animated:YES];
			
			break;		}
		
		case 3:
		{
			PLYCategoryPickerViewController *categories = [[PLYCategoryPickerViewController alloc] init];
			categories.selectedCategoryKey = _selectedCategoryKey;
			categories.delegate = self;
			[self.navigationController pushViewController:categories animated:YES];
			
			break;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
	  case 0:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLYTextFieldTableViewCell" forIndexPath:indexPath];
			[self _configureProductNameCell:cell];
			
			return cell;
		}
			
		case 1:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLYBrandedTableViewCell" forIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[self _configureBrandNameCell:cell];
			
			return cell;
		}

		case 2:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLYBrandedTableViewCell" forIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			[self _configureBrandOwnerCell:cell];
			
			return cell;
		}
			
		case 3:
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLYBrandedTableViewCell" forIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
	}
	
	// should never get here
	return nil;
}



- (void)performAsyncSaveOperationWithCompletion:(void(^)(NSError *))completion
{
	BOOL isNewProduct = NO;
	
	
	PLYProduct *saveProduct = [PLYProduct new];
	saveProduct.name = _product.name;
	saveProduct.brandName = _product.brandName;
	saveProduct.brandOwner = _product.brandOwner;
	saveProduct.GTIN = _product.GTIN;
	saveProduct.language = _product.language;
	saveProduct.category = _selectedCategoryKey;
	
	if ([_nameField.validator isValid])
	{
		saveProduct.name = _nameField.text;
		
		if (![saveProduct.language isEqualToString:_nameField.usedInputLanguage])
		{
			isNewProduct = YES;
			saveProduct.language = _nameField.usedInputLanguage;
		}
	}
	
	if ([_brandName length])
	{
		saveProduct.brandName = _brandName;
	}
	
	if ([_brandOwner length])
	{
		saveProduct.brandOwner = _brandOwner;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		
		__block PLYProduct *existingProduct = nil;
		
		[self.productLayerServer performSearchForGTIN:saveProduct.GTIN language:saveProduct.language completion:^(id result, NSError *error) {
			
			if (result)
			{
				PLYProduct *product = [result firstObject];
				
				// make sure that the language of existing item EXACTLY matches
				if ([product.language isEqualToString:saveProduct.language])
				{
					existingProduct = product;
				}
			}
			
			dispatch_semaphore_signal(sema);
		}];
		
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		
		if (!existingProduct && !_product.name)
		{
			// this is a dummy product and so we make this into the new language
			existingProduct = _product;
		}
		
		if (existingProduct && existingProduct.Id)
		{
			saveProduct.Id = existingProduct.Id;
			
			[self.productLayerServer updateProduct:saveProduct completion:^(id result, NSError *error) {
				completion(error);
			}];
		}
		else
		{
			[self.productLayerServer createProduct:saveProduct completion:^(id result, NSError *error) {
				completion(error);
			}];
		}
	});
}

- (BOOL)_saveIsPossible
{
	BOOL didChange = NO;
	
	if ([_nameField.validator isValid])
	{
		didChange = YES;
	}
	
	if (_brandName && ![_brandName isEqualToString:_product.brandName])
	{
		didChange = YES;
	}
	
	if (_brandOwner && ![_brandOwner isEqualToString:_product.brandOwner])
	{
		didChange = YES;
	}
	
	if (_selectedCategoryKey && ![_selectedCategoryKey isEqualToString:_product.category])
	{
		didChange = YES;
	}
	
	return didChange;
}

- (NSString *)titleForErrorDialog
{
	return @"Error Updating Product Information";
}

#pragma mark - PLYFormValidationDelegate

- (void)validityDidChange:(PLYFormValidator *)validator
{
	self.saveButtonItem.enabled = [self _saveIsPossible];
}

#pragma mark - PLYCategoryPickerViewControllerDelegate

- (void)categoryPicker:(PLYCategoryPickerViewController *)categoryPicker didSelectCategoryWithKey:(NSString *)key
{
	if ([key isEqualToString:_selectedCategoryKey])
	{
		return;
	}
	
	_selectedCategoryKey = key;
	
	[self.navigationController popViewControllerAnimated:YES];
	
	// viewWillAppear updates the shown category
}

#pragma mark - PLYBrandPickerViewControllerDelegate

- (void)brandPickerDidSelect:(PLYBrandPickerViewController *)brandPicker
{
	_brandName = brandPicker.selectedBrandName;
	_brandOwner = brandPicker.selectedBrandOwnerName;
	
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1],
														  [NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PLYBrandOwnerPickerViewControllerDelegate

- (void)brandOwnerPickerDidSelect:(PLYBrandOwnerPickerViewController *)brandOwnerPicker
{
	_brandOwner = brandOwnerPicker.selectedBrandOwnerName;
	
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
	
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Properties

- (void)setProduct:(PLYProduct *)product
{
	_product = [product copy];
	
	if ([_product.GTIN isEqualToString:_product.name])
	{
		_product.name = nil;
	}
	
	_brandName = _product.brandName;
	_brandOwner = _product.brandOwner;
	
	if (_product.category)
	{
		_selectedCategoryKey = _product.category;
	}
}

#pragma mark - Notifications
- (void)_updatedCategories:(NSNotification *)notification
{
    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
        [self _updateCategory];
    });
}

@end
