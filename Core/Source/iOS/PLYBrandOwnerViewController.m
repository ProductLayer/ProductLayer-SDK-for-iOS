//
//  PLYBrandOwnerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

#define CELL_IDENTIFIER @"Identifier"


@interface PLYBrandOwnerViewController ()

@end

@implementation PLYBrandOwnerViewController
{
	NSArray *_brands;
	NSArray *_filteredSections;
	NSArray *_filteredIndexPaths;
	
	NSString *_selectedBrandName;
	NSString *_selectedBrandOwnerName;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// use normal cells
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
	
	self.navigationItem.prompt = @"Adding new brands not implemented yet!";
	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"PLY_BRANDS_TITLE", @"UI", @"Title of the view controller showing brands");
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
	else
	{
		[self _setupForTraitCollection:self.traitCollection];
	}
	
	[self _selectRowForBrandOwnerName:_selectedBrandOwnerName brandName:_selectedBrandName animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!_GTIN)
	{
		return;
	}
	
	[self _updateBrandsFromServer];
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

#pragma mark - Helpers

- (void)_updateBrandsFromServer
{
	[self.productLayerServer getRecommendedBrandOwnersForGTIN:_GTIN completion:^(id result, NSError *error) {
		
		if (error)
		{
			NSLog(@"%@", [error localizedDescription]);
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_brands = result;
			[self.tableView reloadData];
			
			[self _selectRowForBrandOwnerName:_selectedBrandOwnerName brandName:_selectedBrandName animated:YES];
		});
	}];
}

- (void)_updateFilter
{
	NSArray *searchTerms = [self currentSearchTerms];
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	NSMutableArray *tmpSections = [NSMutableArray array];
	
	[_brands enumerateObjectsUsingBlock:^(PLYBrandOwner *brandOwner, NSUInteger section, BOOL *stop) {
		[brandOwner.brands enumerateObjectsUsingBlock:^(PLYBrand *brand, NSUInteger row, BOOL *stop) {
			
			if ([self _text:brand.name containsAllTerms:searchTerms])
			{
				NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
				[tmpArray addObject:path];
				
				NSNumber *number = @(section);
				
				if (![tmpSections containsObject:number])
				{
					[tmpSections addObject:number];
				}
			}
		}];
	}];
	
	_filteredIndexPaths = [tmpArray copy];
	_filteredSections = [tmpSections copy];
	
	[self.tableView reloadData];
}

- (void)_selectRowForBrandOwnerName:(NSString *)brandOwnerName brandName:(NSString *)brandName animated:(BOOL)animated
{
	[_brands enumerateObjectsUsingBlock:^(PLYBrandOwner  *owner, NSUInteger section, BOOL *stopSection) {
		
		if ([owner.name isEqualToString:brandOwnerName])
		{
			[owner.brands enumerateObjectsUsingBlock:^(PLYBrand *brand, NSUInteger row, BOOL *stopRow) {
				if ([brand.name isEqualToString:brandName])
				{
					[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
					*stopRow = YES;
					*stopSection = YES;
				}
			}];
		}
	}];
}

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	[self _updateFilter];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.searchController.isActive)
	{
		return [_filteredSections count];
	}
	else
	{
		return [_brands count];
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.searchController.isActive)
	{
		NSUInteger index = [_filteredSections[section] integerValue];
		PLYBrandOwner *owner = _brands[index];
		return [owner.brands count];
	}
	else
	{
		PLYBrandOwner *owner = _brands[section];
		return [owner.brands count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.searchController.isActive)
	{
		NSUInteger index = [_filteredSections[section] integerValue];
		PLYBrandOwner *owner = _brands[index];
		return owner.name;
	}
	else
	{
		PLYBrandOwner *owner = _brands[section];
		return owner.name;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
	
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
	}
	
	PLYBrandOwner *owner;
	PLYBrand *brand;
 
	if (self.searchController.isActive)
	{
		NSUInteger index = [_filteredSections[indexPath.section] integerValue];
		owner = _brands[index];
		brand = owner.brands[indexPath.row];
	}
	else
	{
		owner = _brands[indexPath.section];
		brand = owner.brands[indexPath.row];
	}

	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[cell setSelectedBackgroundView:bgColorView];
 
	if (self.searchController.isActive)
	{
		cell.textLabel.attributedText	= [self _attributedStringForText:brand.name withSearchTermsMarked:[self currentSearchTerms]];
	}
	else
	{
		cell.textLabel.text = brand.name;
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.minimumScaleFactor = 0.5;
 
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PLYBrandOwner *owner;
	PLYBrand *brand;
 
	if (self.searchController.isActive)
	{
		NSUInteger index = [_filteredSections[indexPath.section] integerValue];
		owner = _brands[index];
		brand = owner.brands[indexPath.row];
	}
	else
	{
		owner = _brands[indexPath.section];
		brand = owner.brands[indexPath.row];
	}
	
	_selectedBrandName = brand.name;
	_selectedBrandOwnerName = owner.name;

	if ([_delegate respondsToSelector:@selector(brandPickerDidChangeSelection:)])
	{
		[_delegate brandPickerDidChangeSelection:self];
	}
}

@end
