//
//  PLYCategoryPickerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 11/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYCategoryPickerViewController.h"
#import "PLYServer.h"
#import "DTLog.h"

#import <ProductLayer/ProductLayer.h>

#define CELL_IDENTIFIER @"Identifier"

// category cache
NSDictionary *_categoryDictionary = nil;
NSArray *_sortedKeys = nil;

@interface PLYCategoryPickerViewController () <UISearchResultsUpdating>
@end

@implementation PLYCategoryPickerViewController
{
	NSArray *_filteredKeys;
	UISearchController *_searchController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSAssert(self.server, @"No PLYServer set");
	
	NSString *language = [[NSLocale currentLocale] localeIdentifier];
	[self.server getCategoriesForLocale:language completion:^(id result, NSError *error) {
		
		if (!result)
		{
			DTLogError(@"Error loading categories from server: %@", error);
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self _updateCategories:result];
		});
	}];
	
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
	
	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	_searchController.searchResultsUpdater = self;
	_searchController.searchBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 44.0); // need frame or else it is invisible
	_searchController.dimsBackgroundDuringPresentation = NO;
	self.tableView.tableHeaderView = _searchController.searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// workaround for iPhone 6+ bug
	if (self.traitCollection.displayScale==3)
	{
		CGSize windowSize = [UIScreen mainScreen].bounds.size;
		CGSize viewSize = self.view.bounds.size;
		
		if (viewSize.width < windowSize.width)
		{
			UITraitCollection *collection = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
			[self _setupForTraitCollection:collection];
			return;
		}
	}
	
	[self _setupForTraitCollection:self.traitCollection];
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:NO];
}

- (void)_setupForTraitCollection:(UITraitCollection *)collection
{
	if (collection.horizontalSizeClass == UIUserInterfaceSizeClassRegular || collection.userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
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

- (void)_updateCategories:(NSDictionary *)categories
{
	// if there was no change, don't do anything
	if ([_categoryDictionary isEqualToDictionary:categories])
	{
		return;
	}
	
	_sortedKeys = [categories keysSortedByValueWithOptions:0 usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
		
		return [obj1 localizedStandardCompare:obj2];
	}];
	
	_categoryDictionary = [categories copy];
	
	[self.tableView reloadData];
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:YES];
}

- (BOOL)_text:(NSString *)text containsAllTerms:(NSArray *)terms
{
	for (NSString *oneTerm in terms)
	{
		if (![oneTerm length])
		{
			// ignore null string
			continue;
		}
		
		NSRange range = [text rangeOfString:oneTerm options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
		
		if (range.location == NSNotFound)
		{
			return NO;
		}
	}
	
	return YES;
}

- (void)_updateFilter
{
	NSArray *searchTerms = [self _currentSearchTerms];
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	for (NSString *oneKey in _sortedKeys)
	{
		NSString *name = _categoryDictionary[oneKey];
		
		if ([self _text:name containsAllTerms:searchTerms])
		{
			[tmpArray addObject:oneKey];
		}
	}
	
	_filteredKeys = [tmpArray copy];
	
	[self.tableView reloadData];
}

- (NSArray *)_currentSearchTerms
{
	NSString *searchText = _searchController.searchBar.text;
	return [searchText componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
}

- (NSAttributedString *)_attributedStringForText:(NSString *)text withSearchTermsMarked:(NSArray *)terms
{
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
	NSRange range = NSMakeRange(0, [attributedString length]);
	
	// workaround for TextKit bug not showing underlines
	[attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
	
	for (NSString *oneTerm in terms)
	{
		if (![oneTerm length])
		{
			// ignore null string
			continue;
		}
		
		range = NSMakeRange(0, [attributedString length]);
		
		while (range.location != NSNotFound)
		{
			range = [text rangeOfString:oneTerm options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch range:range];
			
			if (range.location != NSNotFound)
			{
				[attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
				
				range = NSMakeRange(range.location + range.length, [attributedString length] - (range.location + range.length));
			}
		}
	}
	
	return [attributedString copy];
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
			[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
			*stop = YES;
		}
	}];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_searchController.isActive)
	{
		return [_filteredKeys count];
	}
	
	return [_sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
	
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
	}
	
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[cell setSelectedBackgroundView:bgColorView];
 
	if (_searchController.isActive)
	{
		NSString *key = _filteredKeys[indexPath.row];
		NSString *categoryName = _categoryDictionary[key];
		
		cell.textLabel.attributedText	= [self _attributedStringForText:categoryName withSearchTermsMarked:[self _currentSearchTerms]];
	}
	else
	{
		NSString *key = _sortedKeys[indexPath.row];
		cell.textLabel.text = _categoryDictionary[key];
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumScaleFactor = 0.5;
 
	return cell;
 }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_searchController.isActive)
	{
		self.selectedCategoryKey = _filteredKeys[indexPath.row];
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

@end
