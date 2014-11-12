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
#import "NSString+DTPaths.h"

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
	
	// use normal cells
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
	
	// setup search controller
	_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
	_searchController.searchResultsUpdater = self;
	_searchController.searchBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 44.0); // need frame or else it is invisible
	_searchController.dimsBackgroundDuringPresentation = NO;
	
	self.tableView.tableHeaderView = _searchController.searchBar;
	
	// load last category list we had
	[self _loadCategoriesFromCache];
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
		}
		else
		{
			[self _setupForTraitCollection:self.traitCollection];
		}
	}
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _updateCategoriesFromServer];
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
	
	// remove NULL values from dictionary
	NSMutableDictionary *cleanDictionary = [NSMutableDictionary dictionary];
	
	for (NSString *oneKey in [categories allKeys])
	{
		if ([categories[oneKey] isKindOfClass:[NSString class]])
		{
			cleanDictionary[oneKey] = categories[oneKey];
		}
		else
		{
			NSString *language = [[NSLocale currentLocale] localeIdentifier];
			DTLogError(@"Category '%@' has invalid value in language '%@'! Ignoring it.", oneKey, language);
		}
	}
	
	_sortedKeys = [cleanDictionary keysSortedByValueWithOptions:0 usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
		
		return [obj1 localizedStandardCompare:obj2];
	}];
	
	_categoryDictionary = [cleanDictionary copy];
	
	[self.tableView reloadData];
	
	[self _selectRowForCategoryKey:_selectedCategoryKey animated:YES];
}

- (void)_setupDefaultCategories
{
	NSArray *categories = [NSMutableArray arrayWithObjects:
								  @"pl-prod-cat-magazines",
								  @"pl-prod-cat-books",
								  @"pl-prod-cat-books-children_and_teenagers",
								  @"pl-prod-cat-books-comics_and_picturestories",
								  @"pl-prod-cat-books-computer_and_internet",
								  @"pl-prod-cat-books-economy_investments",
								  @"pl-prod-cat-books-health_mind_and_body",
								  @"pl-prod-cat-books-mystery_suspense",
								  @"pl-prod-cat-books-novel_stories",
								  @"pl-prod-cat-books-religious_spirituality",
								  @"pl-prod-cat-books-romance",
								  @"pl-prod-cat-books-sciencefiction_and_fantasy",
								  @"pl-prod-cat-clothes",
								  @"pl-prod-cat-clothes-jeans",
								  @"pl-prod-cat-clothes-pants",
								  @"pl-prod-cat-clothes-shirts",
								  @"pl-prod-cat-clothes-suites",
								  @"pl-prod-cat-clothes-underwear",
								  @"pl-prod-cat-drinks",
								  @"pl-prod-cat-drinks-alcoholic",
								  @"pl-prod-cat-drinks-non_alcoholic",
								  @"pl-prod-cat-electronic",
								  @"pl-prod-cat-electronic-camera",
								  @"pl-prod-cat-electronic-computer",
								  @"pl-prod-cat-electronic-computer-notebook",
								  @"pl-prod-cat-electronic-computer-tablet",
								  @"pl-prod-cat-electronic-computer-systems",
								  @"pl-prod-cat-electronic-computer-components",
								  @"pl-prod-cat-electronic-computer-audio",
								  @"pl-prod-cat-electronic-computer-video",
								  @"pl-prod-cat-electronic-computer-mainboard",
								  @"pl-prod-cat-electronic-computer-monitor",
								  @"pl-prod-cat-electronic-computer-network",
								  @"pl-prod-cat-electronic-computer-cpu",
								  @"pl-prod-cat-electronic-computer-ram",
								  @"pl-prod-cat-electronic-computer-storage",
								  @"pl-prod-cat-electronic-computer-graphic_card",
								  @"pl-prod-cat-electronic-computer-input_device",
								  @"pl-prod-cat-electronic-computer-cable",
								  @"pl-prod-cat-electronic-phones",
								  @"pl-prod-cat-electronic-tv",
								  @"pl-prod-cat-electronic-wearables",
								  @"pl-prod-cat-electronic-printer_and_scanner",
								  @"pl-prod-cat-electronic-printer_and_scanner-3dprinter",
								  @"pl-prod-cat-electronic-printer_and_scanner-scanner",
								  @"pl-prod-cat-electronic-printer_and_scanner-printer",
								  @"pl-prod-cat-electronic-printer_and_scanner-barcode_printer",
								  @"pl-prod-cat-electronic-printer_and_scanner-barcode_scanner",
								  @"pl-prod-cat-electronic-printer_and_scanner-scanner_accessories",
								  @"pl-prod-cat-electronic-printer_and_scanner-printer_accessories",
								  @"pl-prod-cat-food",
								  @"pl-prod-cat-food-dairy",
								  @"pl-prod-cat-food-fruit",
								  @"pl-prod-cat-food-grains",
								  @"pl-prod-cat-food-meat",
								  @"pl-prod-cat-food-sweets",
								  @"pl-prod-cat-food-vegetables",
								  @"pl-prod-cat-food-instant_meal",
								  @"pl-prod-cat-health_and_personal_care",
								  @"pl-prod-cat-health_and_personal_care-beauty",
								  @"pl-prod-cat-home_and_kitchen",
								  @"pl-prod-cat-industrial_and_scientific",
								  @"pl-prod-cat-others", nil];
	
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
	
	for (NSString *oneKey in categories)
	{
		NSString *text = PLYLocalizedStringFromTable(oneKey, @"API", @"Product Category Key");
		tmpDict[oneKey] = text;
	}
	
	[self _updateCategories:tmpDict];
	[self _saveCategoriesInCache];
}

- (void)_saveCategoriesInCache
{
	NSString *path = [[NSString cachesPath] stringByAppendingString:@"ProductCategories.plist"];
	[_categoryDictionary writeToFile:path atomically:YES];
}

- (void)_loadCategoriesFromCache
{
	NSString *path = [[NSString cachesPath] stringByAppendingString:@"ProductCategories.plist"];
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	if (dictionary)
	{
		[self _updateCategories:dictionary];
	}
	else
	{
		[self _setupDefaultCategories];
	}
}

- (void)_updateCategoriesFromServer
{
	NSString *language = [[NSLocale currentLocale] localeIdentifier];
	[self.productLayerServer getCategoriesForLocale:language completion:^(id result, NSError *error) {
		if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == kCFURLErrorNotConnectedToInternet)
		{
			// no Internet
			return;
		}
		
		if (!result)
		{
			DTLogError(@"Error loading categories from server: %@", error);
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self _updateCategories:result];
			[self _saveCategoriesInCache];
		});
	}];
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
