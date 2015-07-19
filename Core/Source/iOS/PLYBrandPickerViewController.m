//
//  PLYBrandPickerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 21/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYBrandPickerViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayerSDK.h"

#define CELL_IDENTIFIER @"Identifier"


@interface PLYBrandPickerViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation PLYBrandPickerViewController
{
	NSString *_selectedBrandName;
	NSString *_selectedBrandOwnerName;
	
	NSArray *_knownBrandNames;
	NSArray *_filteredKnownBrandNames;
	
	NSArray *_likelyBrands;
	NSArray *_filteredLikelyBrands;
	
	NSString *_creatingBrandName;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.navigationItem.title = PLYLocalizedStringFromTable(@"PLY_BRANDS_TITLE", @"UI", @"Title of the view controller showing brands");

	self.tableView.tableHeaderView = self.searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.searchBar.text = _selectedBrandName;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[self _updateBrandsFromServer];
	});
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// hide keyboard before view disappears
	[_searchBar resignFirstResponder];
}

#pragma mark - Helpers

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

- (NSArray *)currentSearchTerms
{
	NSString *searchText = self.searchBar.text;
	return [searchText componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
}

- (void)_updateBrandsFromServer
{
	dispatch_semaphore_t sema = dispatch_semaphore_create(0);
	
	
	[self.productLayerServer brandsWithCompletion:^(NSArray *result, NSError *error) {
		
		if ([result isKindOfClass:[NSDictionary class]])
		{
			NSDictionary *dict = (NSDictionary *)result;
			result = dict[@"pl-values"];
		}
		
		NSMutableArray *tmpArray = [result mutableCopy];
		[tmpArray removeObject:@""];
		
		_knownBrandNames = [tmpArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
		
		dispatch_semaphore_signal(sema);
	}];
	
	dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	
	if (_GTIN)
	{
		[self.productLayerServer recommendedBrandOwnersForGTIN:_GTIN completion:^(id result, NSError *error) {
			
			NSMutableArray *tmpArray = [NSMutableArray array];
			
			for (PLYBrandOwner *owner in result)
			{
				for (PLYBrand *brand in owner.brands)
				{
					[tmpArray addObject:@{@"owner": owner.name, @"brand": brand.name}];
				}
			}
			
			_likelyBrands = [tmpArray copy];
			
			dispatch_semaphore_signal(sema);
		}];
		
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		[self _updateFilter];
		
		BOOL filtered = [self.searchBar.text length]>0;
		NSIndexPath *indexPath = [self _indexPathForSelectRowForBrandOwnerName:_selectedBrandOwnerName brandName:_selectedBrandName filtered:filtered];
		
		if (!indexPath && [_selectedBrandName length])
		{
			_creatingBrandName = _selectedBrandName;
			indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		}
		
		[self.tableView reloadData];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
		});
	});
}

- (NSArray *)_filteredBrandsFromArray:(NSArray *)array withTerms:(NSArray *)terms
{
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	for (NSDictionary *oneBrand in array)
	{
		NSString *brandName;
		
		if ([oneBrand isKindOfClass:[NSDictionary class]])
		{
			brandName = oneBrand[@"brand"];
		}
		else
		{
			brandName = (NSString *)oneBrand;
		}
		
		if ([self _text:brandName containsAllTerms:terms])
		{
			[tmpArray addObject:oneBrand];
		}
	}
	
	return [tmpArray copy];
}


- (void)_updateFilter
{
	NSArray *searchTerms = [self currentSearchTerms];
	
	if ([searchTerms count])
	{
		_filteredLikelyBrands = [self _filteredBrandsFromArray:_likelyBrands withTerms:searchTerms];
		_filteredKnownBrandNames = [self _filteredBrandsFromArray:_knownBrandNames withTerms:searchTerms];
	}
	else
	{
		_filteredLikelyBrands = nil;
		_filteredKnownBrandNames = nil;
	}
}

- (NSIndexPath *)_indexPathForSelectRowForBrandOwnerName:(NSString *)brandOwnerName brandName:(NSString *)brandName filtered:(BOOL)filtered
{
	__block NSIndexPath *indexPath;
	
	NSArray *likelyBrands = filtered?_filteredLikelyBrands:_likelyBrands;
	NSArray *knownBrandNames = filtered?_filteredKnownBrandNames:_knownBrandNames;
	
	if (!brandOwnerName)
	{
		brandOwnerName = @"";
	}
	
	[likelyBrands enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger row, BOOL *stop) {
		NSString *brand = dict[@"brand"];
		NSString *owner = dict[@"owner"];
		
		if ([owner isEqualToString:@"unknown"])
		{
			owner = @"";
		}
		
		if ([brand isEqualToString:brandName] && [owner isEqualToString:brandOwnerName])
		{
			indexPath = [NSIndexPath indexPathForRow:row inSection:1];
			*stop = YES;
		}
	}];
	
	if (!indexPath)
	{
		[knownBrandNames enumerateObjectsUsingBlock:^(NSString *brand, NSUInteger row, BOOL *stop) {
			if ([brand isEqualToString:brandName])
			{
				indexPath = [NSIndexPath indexPathForRow:row inSection:2];
				
				*stop = YES;
			}
		}];
	}
	
	return indexPath;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSArray *)_arrayForSection:(NSInteger)section
{
	if (section==1)
	{
		if ([self.searchBar.text length])
		{
			return _filteredLikelyBrands;
		}
		
		return _likelyBrands;
	}
	
	if (section==2)
	{
		if ([self.searchBar.text length])
		{
			return _filteredKnownBrandNames;
		}
		
		return _knownBrandNames;
	}
	
	return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!section)
	{
		if ([_creatingBrandName length])
		{
			return 1;
		}
		
		return 0;
	}

	NSArray *array = [self _arrayForSection:section];

	return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSUInteger rows = [self tableView:tableView numberOfRowsInSection:section];
	
	if (!rows)
	{
		return nil;
	}
	
	switch (section)
	{
		case 0:
		{
			return  PLYLocalizedStringFromTable(@"PLY_CREATE_BRAND", @"UI", @"Title of section for creating a new brand");
		}

		case 1:
		{
			return  PLYLocalizedStringFromTable(@"PLY_LIKELY_BRANDS", @"UI", @"Title of section containing likely brands");
		}

		case 2:
		{
			return  PLYLocalizedStringFromTable(@"PLY_KNOWN_BRANDS", @"UI", @"Title of section containing known brands");
		}
	}
	
	return nil;
}


- (void)_configureCell:(UITableViewCell *)cell forBrand:(id)brand
{
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[cell setSelectedBackgroundView:bgColorView];
	
	NSString *brandName;
	NSString *ownerName;
	
	if ([brand isKindOfClass:[NSDictionary class]])
	{
		brandName = brand[@"brand"];
		ownerName = brand[@"owner"];
		
		if ([ownerName isEqualToString:@"unknown"])
		{
			ownerName = nil;
		}
	}
	else if ([brand isKindOfClass:[NSString class]])
	{
		brandName = brand;
	}
	
	if ([self.searchBar.text length])
	{
		cell.textLabel.attributedText	= [self _attributedStringForText:brandName withSearchTermsMarked:[self currentSearchTerms]];
	}
	else
	{
		cell.textLabel.text = brandName;
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumScaleFactor = 0.5;
	
	cell.detailTextLabel.text = ownerName;
	cell.detailTextLabel.textColor = [UIColor grayColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil]; //[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
	
	cell.imageView.image = nil;
	
	if (!indexPath.section)
	{;
		NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:20]};
		NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:_creatingBrandName attributes:attributes];
		cell.textLabel.attributedText = attribString;
		
		cell.imageView.image = [UIImage imageNamed:@"brand"];
		
		// set product layer color as background
		UIView *bgColorView = [[UIView alloc] init];
		bgColorView.backgroundColor = PLYBrandColor();
		[cell setSelectedBackgroundView:bgColorView];
		
		return cell;
	}
	
	NSArray *array = [self _arrayForSection:indexPath.section];
	[self _configureCell:cell forBrand:array[indexPath.row]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!indexPath.section)
	{
		NSString *trimmedText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		_selectedBrandName = trimmedText;
		_selectedBrandOwnerName = nil;
	}
	else
	{
		NSArray *array = [self _arrayForSection:indexPath.section];
		
		id brand = array[indexPath.row];
		
		if ([brand isKindOfClass:[NSDictionary class]])
		{
			_selectedBrandName = brand[@"brand"];
			_selectedBrandOwnerName = brand[@"owner"];
			
			if ([_selectedBrandOwnerName isEqualToString:@"unknown"])
			{
				_selectedBrandOwnerName = nil;
			}
		}
		else if ([brand isKindOfClass:[NSString class]])
		{
			_selectedBrandName = brand;
			_selectedBrandOwnerName = nil;
		}
	}
	
	if ([_delegate respondsToSelector:@selector(brandPickerDidSelect:)])
	{
		[_delegate brandPickerDidSelect:self];
	}
}

#pragma mark - Properties

- (UISearchBar *)searchBar
{
	if (!_searchBar)
	{
		_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 44.0)];
		_searchBar.delegate = self;
		_searchBar.placeholder = @"Brand";
		_searchBar.returnKeyType = UIReturnKeyDone;
	}
	
	return _searchBar;
}

#pragma mark - UISearchBarDelegate

- (void)_delayedUpdate
{
	_creatingBrandName = self.searchBar.text;
	[self _updateFilter];
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_delayedUpdate) object:nil];
	[self performSelector:@selector(_delayedUpdate) withObject:nil afterDelay:0.25];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *trimmedText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if ([trimmedText length])
	{
		if ([_delegate respondsToSelector:@selector(brandPickerDidSelect:)])
		{
			_selectedBrandName = trimmedText;
			_selectedBrandOwnerName = nil;
			
			[_delegate brandPickerDidSelect:self];
		}
	}
}

@end
