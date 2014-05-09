//
//  SearchProductViewController.m
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "SearchProductViewController.h"
#import "ProductViewController.h"

#import "ProductLayer.h"
#import "DTBlockFunctions.h"

#import "PLYProduct.h"
#import "ProductTableViewCell.h"
#import "AppSettings.h"

#import "UIViewTags.h"

@implementation SearchProductViewController
{
	NSArray *_productsWithAppLocale;
    NSMutableArray *_productsOtherLocale;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return [NSString stringWithFormat:@"With your locale: %@", [AppSettings currentAppLocale].localeIdentifier];
    }
    
    return @"All found products";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [_productsWithAppLocale count];
    }
    
    return [_productsOtherLocale count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
	
    PLYProduct *product;
    
    if(indexPath.section == 0)
        product = _productsWithAppLocale[indexPath.row];
    else
        product = _productsOtherLocale[indexPath.row];
	
    [cell setProduct:product];
	
	return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Search with my locale
	NSLocale *locale = [AppSettings currentAppLocale];
	[[PLYServer sharedPLYServer] performSearchForName:searchBar.text language:locale.localeIdentifier completion:^(id result, NSError *error) {
		
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
				_productsWithAppLocale = result;
				
				[self.tableView reloadData];
			});
		}
	}];
    
    // Search with no locale
    [[PLYServer sharedPLYServer] performSearchForName:searchBar.text language:nil completion:^(id result, NSError *error) {
		
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
                _productsOtherLocale = [NSMutableArray arrayWithCapacity:[result count]];
                for(PLYProduct *product in result){
                    // only add products which have a different locale than the app locale
                    if(![product.language isEqualToString:locale.localeIdentifier]){
                        [_productsOtherLocale addObject:product];
                    }
                }
				
				[self.tableView reloadData];
			});
		}
	}];
}

-(void) prepareForSegue:(UIStoryboardSegue *) segue sender: (id) sender
{
    if( [segue.identifier isEqualToString:@"showProduct"]) {
        ProductViewController *PVC = (ProductViewController *)segue.destinationViewController;
        
        [PVC setProduct:((ProductTableViewCell *)sender).product];
    }
}

@end
