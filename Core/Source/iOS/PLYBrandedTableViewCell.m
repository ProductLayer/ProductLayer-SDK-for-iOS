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

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// set product layer color as background
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = PLYBrandColor();
	[self setSelectedBackgroundView:bgColorView];
	
	[self.textLabel setHighlightedTextColor:[UIColor whiteColor]];
	[self.detailTextLabel setHighlightedTextColor:[UIColor whiteColor]];
	
	[self _updateAccessoryView];
}

#pragma mark - Helpers

- (void)_updateAccessoryView
{
	if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
	{
		self.accessoryView = [DTCustomColoredAccessory accessoryWithColor:PLYBrandColor() type:DTCustomColoredAccessoryTypeRight];
	}
}


#pragma mark - Properties

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
	super.accessoryType = accessoryType;
	[self _updateAccessoryView];
}

@end
