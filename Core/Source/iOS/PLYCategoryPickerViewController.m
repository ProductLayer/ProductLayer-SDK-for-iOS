//
//  PLYCategoryPickerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 11/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@import DTFoundation;

#import "PLYCategoryPickerViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayerSDK.h"

@import UIKit;

#define CELL_IDENTIFIER @"Identifier"

@interface PLYCategoryPickerViewController () <UISearchResultsUpdating>
@end

@implementation PLYCategoryPickerViewController
{
	//NSArray *_filteredKeys;
	NSArray *_categories;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// use normal cells
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
		
	self.navigationItem.title = PLYLocalizedStringFromTable(@"PLY_CATEGORIES_TITLE", @"UI", @"Title of the view controller showing brands");
	self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updatedCategories:) name:PLYServerDidUpdateProductCategoriesNotification object:nil];
}

- (void)dealloc
{
    [self.searchController.view removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self _updateCategoriesAndSelectCurrent:true];

	
	// workaround for iPhone 6+ bug
	if (self.traitCollection.displayScale==3)
	{
		CGSize windowSize = [UIScreen mainScreen].bounds.size;
		CGSize viewSize = self.view.bounds.size;
		
		if (viewSize.width < windowSize.width)
		{
			UITraitCollection *collection = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
			[self _setupForTraitCollection:collection];
		}
		else
		{
			[self _setupForTraitCollection:self.traitCollection];
		}
	}
	else
	{
		[self _setupForTraitCollection:self.traitCollection];
	}
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		[self.searchController.searchBar resignFirstResponder];
	} completion:NULL];
}

- (void)_setupForTraitCollection:(UITraitCollection *)collection
{
	if (collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && (collection.userInterfaceIdiom == UIUserInterfaceIdiomPad && self.popoverPresentationController!=nil))
	{
		// only hide nav bar if inside popover presentation
		[self.navigationController setNavigationBarHidden:YES];
	}
	else
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[self _setupForTraitCollection:newCollection];
}

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	[self _updateCategoriesAndSelectCurrent:!searchController.isActive && !self.isBeingDismissed];
}

#pragma mark - Helpers

- (void)_updateCategoriesAndSelectCurrent:(BOOL)selectCurrent
{
	_categories = [self.productLayerServer categoriesMatchingSearch:self.searchController.searchBar.text];

	[self.tableView reloadData];
	
	if (selectCurrent)
	{
		[self _selectRowForCategoryKey:_selectedCategoryKey animated:YES];
	}
}

- (void)_selectRowForCategoryKey:(NSString *)key animated:(BOOL)animated
{
	if (!key)
	{
		return;
	}
	
	for (NSUInteger index=0; index < [_categories count]; index++)
	{
		PLYCategory *category = _categories[index];
		
		if ([category.key isEqualToString:key])
		{
			// need next run loop or else the inset is not set yet from presentation
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
			});
			break;
		}
	}
}

- (NSString *)_currentLanguage
{
	return [[NSLocale preferredLanguages] firstObject];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.indentationWidth = 10.0;
	
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[cell setSelectedBackgroundView:bgColorView];
	
	cell.textLabel.highlightedTextColor = [UIColor whiteColor];
 
	PLYCategory *category = _categories[indexPath.row];
	
    cell.textLabel.attributedText	= [self _attributedStringForText:category.localizedName withSearchTermsMarked:[self currentSearchTerms]];
        cell.indentationLevel = category.level - 1;
        
        if (cell.indentationLevel==0)
        {
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
        }
        else if (cell.indentationLevel==1)
        {
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
        }
        else
        {
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        }
		
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	//}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PLYCategory *category = _categories[indexPath.row];

	if (self.searchController.isActive)
	{
		self.selectedCategoryKey = category.key;
		
		[self.searchController setActive:NO];
	}
	else
	{
		self.selectedCategoryKey = category.key;
	}
	
	if ([_delegate respondsToSelector:@selector(categoryPicker:didSelectCategoryWithKey:)])
	{
		[_delegate categoryPicker:self didSelectCategoryWithKey:self.selectedCategoryKey];
	}
}

#pragma mark - Notifications

- (void)_updatedCategories:(NSNotification *)notification
{
    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		 [self _updateCategoriesAndSelectCurrent:true];
    });
}

@end
