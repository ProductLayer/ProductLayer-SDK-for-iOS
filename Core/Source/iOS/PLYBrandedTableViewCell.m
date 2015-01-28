//
//  PLYBrandedTableViewCell.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 21/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYBrandedTableViewCell.h"
#import "PLYFunctions.h"

#import "DTCustomColoredAccessory.h"

@implementation PLYBrandedTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self)
	{
		[self _commonSetup];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self _commonSetup];
}

#pragma mark - Helpers

- (void)_commonSetup
{
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[self setSelectedBackgroundView:bgColorView];
	
	// set the label color for when the cell is highlighted
	[self.textLabel setHighlightedTextColor:[UIColor whiteColor]];
	[self.detailTextLabel setHighlightedTextColor:[UIColor whiteColor]];
	
	// adjust custom accessory if necessary
	[self _updateAccessoryView];
}

- (void)_updateAccessoryView
{
	if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
	{
		self.accessoryView = [DTCustomColoredAccessory accessoryWithColor:PLYBrandColor() type:DTCustomColoredAccessoryTypeRight];
		self.accessoryView.userInteractionEnabled = NO;
	}
	else
	{
		self.accessoryView = nil;
	}
}

#pragma mark - Properties

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
	super.accessoryType = accessoryType;
	[self _updateAccessoryView];
}

@end
