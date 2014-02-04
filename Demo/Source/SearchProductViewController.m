//
//  SearchProductViewController.m
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "SearchProductViewController.h"

#import "ProductLayer.h"
#import "DTBlockFunctions.h"

@implementation SearchProductViewController
{
	NSArray *_products;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_products count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
	
	NSDictionary *product = _products[indexPath.row];
	cell.textLabel.text = product[@"name"];
    
    NSString * vendor = product[@"vendor"];
    if(vendor && ![vendor isKindOfClass:[NSNull class]])
        cell.detailTextLabel.text = vendor;
	
	return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSLocale *locale = [NSLocale currentLocale];
	
	[self.server performSearchForName:searchBar.text language:locale.localeIdentifier completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				_products = result;
				
				[self.tableView reloadData];
			});
		}
	}];
}

@end
