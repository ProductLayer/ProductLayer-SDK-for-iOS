//
//  PLEditProductViewControllerTableViewController.m
//  ProductLayer
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYEditProductViewController.h"
#import "PLYTextFieldTableViewCell.h"
#import "ProductLayer.h"

#import "PLYNonEmptyValidator.h"
#import "PLYContentsDidChangeValidator.h"

#import "DTBlockFunctions.h"


@interface PLYEditProductViewController () <PLYFormValidationDelegate, PLYCategoryPickerViewControllerDelegate>

@end

@implementation PLYEditProductViewController
{
	PLYTextField *_nameField;
	PLYTextField *_brandField;
	PLYTextField *_brandOwnerField;
	
	NSString *_selectedCategoryKey;
	NSArray *_categories;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self.tableView registerClass:[PLYTextFieldTableViewCell class] forCellReuseIdentifier:@"PLYTextFieldTableViewCell"];
	
	self.navigationItem.title = @"Edit Product";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_selectedCategoryKey)
	{
		[self _updateCategoryForKey:_selectedCategoryKey];
	}
	else
	{
		[self _updateCategoryForKey:@"pl-prod-cat-uncategorized"];
	}
}

#pragma mark - Helpers

- (NSString *)_pathOfCategories:(NSArray *)categories forKey:(NSString *)key
{
	for (PLYCategory *category in categories)
	{
		if ([category.key isEqualToString:key])
		{
			return category.localizedName;
		}
		
		// search through sub categories
		
		NSString *subPath = [self _pathOfCategories:category.subCategories forKey:key];
		
		if (subPath)
		{
			// sub-category matches, append with slash
			return [[category.localizedName stringByAppendingString:@" / "] stringByAppendingString:subPath];
		}
	}
	
	return nil;
}

- (void)_updateCategoryForKey:(NSString *)key
{
	void (^block)() = ^ {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
			
			NSString *path = [self _pathOfCategories:_categories forKey:key];
			
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
		});
	};
	
	
	if (!_categories)
	{
		[self.productLayerServer categoriesWithLanguage:nil completion:^(id result, NSError *error) {
			if (result)
			{
				_categories = result;
				block();
			}
		}];
	}
	else
	{
		block();
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
			return @"Title";
		}
			
		case 1:
		{
			return @"Brand";
		}
			
		case 2:
		{
			return @"Brand Owner";
		}
			
		case 3:
		{
			return @"Category";
		}
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 3)
	{
		PLYCategoryPickerViewController *categories = [[PLYCategoryPickerViewController alloc] init];
		categories.selectedCategoryKey = _selectedCategoryKey;
		categories.delegate = self;
		[self.navigationController pushViewController:categories animated:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 3)
	{
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// set product layer color as background
		UIView *bgColorView = [[UIView alloc] init];
		bgColorView.backgroundColor = PLYBrandColor();
		[cell setSelectedBackgroundView:bgColorView];
		
		cell.textLabel.highlightedTextColor = [UIColor whiteColor];
		
		return cell;
	}
	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLYTextFieldTableViewCell" forIndexPath:indexPath];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	
	switch (indexPath.section)
	{
	  case 0:
		{
			_nameField = [(PLYTextFieldTableViewCell *)cell textField];
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
			
			break;
		}
			
		case 1:
		{
			_brandField = [(PLYTextFieldTableViewCell *)cell textField];
			_brandField.placeholder = @"ACME";

			if ([_product.brandName length])
			{
				_brandField.text = _product.brandName;
				_brandField.validator = [PLYContentsDidChangeValidator validatorWithDelegate:self originalContents:_product.brandName];
			}
			else
			{
				_brandField.validator = [PLYNonEmptyValidator validatorWithDelegate:self];
			}

			break;
		}
			
		case 2:
		{
			_brandOwnerField = [(PLYTextFieldTableViewCell *)cell textField];
			_brandOwnerField.placeholder = @"ACME Corporation LTD";
			
			if ([_product.brandOwner length])
			{
				_brandOwnerField.text = _product.brandOwner;
				_brandOwnerField.validator = [PLYContentsDidChangeValidator validatorWithDelegate:self originalContents:_product.brandOwner];
			}
			else
			{
				_brandOwnerField.validator = [PLYNonEmptyValidator validatorWithDelegate:self];
			}
			
			break;
		}
	}
	
	return cell;
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
	
	if ([_brandField.validator isValid])
	{
		saveProduct.brandName = _brandField.text;
	}
	
	if ([_brandOwnerField.validator isValid])
	{
		saveProduct.brandOwner = _brandOwnerField.text;
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
		
		if (existingProduct)
		{
			saveProduct.Id = existingProduct.Id;
			
			[self.productLayerServer updateProduct:saveProduct completion:^(id result, NSError *error) {
				completion(error);
			}];
		}
		else
		{
			if (!_product.name)
			{
				// dummy
			}
			
			
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
	
	if ([_brandField.validator isValid])
	{
		didChange = YES;
	}
	
	if ([_brandOwnerField.validator isValid])
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
	//[self _updateCategoryForKey:key];
	
	self.saveButtonItem.enabled = [self _saveIsPossible];
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
	
	if (_product.category)
	{
		_selectedCategoryKey = _product.category;
	}
}

@end
