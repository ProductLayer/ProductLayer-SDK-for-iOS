//
//  PLYCategoryPickerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 11/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYCategoryPickerViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayerSDK.h"

#import "NSString+DTPaths.h"

#import <DTFoundation/DTLog.h>
#import <DTFoundation/DTBlockFunctions.h>

@import UIKit;

#define CELL_IDENTIFIER @"Identifier"

// category cache
NSDictionary *_categoryDictionary = nil;
NSArray *_sortedKeys = nil;

@interface PLYCategoryPickerViewController () <UISearchResultsUpdating>
@end

@implementation PLYCategoryPickerViewController
{
	NSArray *_filteredKeys;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    [self _updateCategories];
    
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
	[self _updateFilter];
}

#pragma mark - Helpers

- (void)_updateCategories
{
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	for (PLYCategory *category in [self.productLayerServer categoriesMatchingSearch:@""])
	{
		tmpDict[category.key] = category;
	}
	
	
	_sortedKeys = [tmpDict keysSortedByValueWithOptions:0 usingComparator:^NSComparisonResult(PLYCategory *obj1, PLYCategory *obj2) {
		
		return [obj1.key localizedStandardCompare:obj2.key];
	}];
	
	_categoryDictionary = [tmpDict copy];
	
	[self.tableView reloadData];
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:YES];
}

- (void)_updateFilter
{
	NSArray *searchTerms = [self currentSearchTerms];
	
	if (searchTerms)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (NSString *oneKey in _sortedKeys)
		{
			PLYCategory *category = _categoryDictionary[oneKey];
			
			NSString *categoryPath = category.localizedPath;
			
			if ([self _text:categoryPath containsAllTerms:searchTerms])
			{
				[tmpArray addObject:oneKey];
			}
		}
		
		_filteredKeys = [tmpArray copy];
	}
	else
	{
		_filteredKeys = _sortedKeys;
	}
	
	[self.tableView reloadData];
}

- (void)_selectRowForCategoryKey:(NSString *)key animated:(BOOL)animated
{
	if (!key || !_sortedKeys)
	{
		return;
	}
	
	[_sortedKeys enumerateObjectsUsingBlock:^(NSString *catKey, NSUInteger idx, BOOL *stop) {
		
		if ([catKey isEqualToString:key])
		{
			// need next run loop or else the inset is not set yet from presentation
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
			});
			*stop = YES;
		}
	}];
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
	if (self.searchController.isActive)
	{
		return [_filteredKeys count];
	}
	
	return [_sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.indentationWidth = 20.0;
	
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[cell setSelectedBackgroundView:bgColorView];
	
	cell.textLabel.highlightedTextColor = [UIColor whiteColor];
 
	if (self.searchController.isActive)
	{
		NSString *key = _filteredKeys[indexPath.row];
		PLYCategory *category = _categoryDictionary[key];
		
		cell.textLabel.attributedText	= [self _attributedStringForText:category.localizedPath withSearchTermsMarked:[self currentSearchTerms]];
        cell.indentationLevel = 0;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
		
		cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
	}
	else
	{
		NSString *key = _sortedKeys[indexPath.row];
		PLYCategory *category = _categoryDictionary[key];
        NSString *categoryPath = category.localizedPath;
        
        NSArray *pathComps = [categoryPath componentsSeparatedByString:@"/"];
        categoryPath = [pathComps lastObject];
		cell.textLabel.text = categoryPath;
        cell.indentationLevel = [pathComps count] - 1;
        
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
	}
	
//	cell.textLabel.adjustsFontSizeToFitWidth = YES;
//	cell.textLabel.minimumScaleFactor = 0.5;
 
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.searchController.isActive)
	{
		self.selectedCategoryKey = _filteredKeys[indexPath.row];
		
		[self.searchController setActive:NO];
	}
	else
	{
		self.selectedCategoryKey = _sortedKeys[indexPath.row];
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
        [self _updateCategories];
    });
}

@end
