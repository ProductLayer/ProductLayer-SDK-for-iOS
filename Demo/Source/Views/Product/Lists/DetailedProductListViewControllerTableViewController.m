//
//  DetailedProductListViewControllerTableViewController.m
//  PL
//
//  Created by René Swoboda on 05/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "DetailedProductListViewControllerTableViewController.h"

#import "ProductListTableViewCell.h"
#import "ProductViewController.h"
#import "ListItemTableCell.h"

#import "DTBlockFunctions.h"

#import "PLYList.h"
#import "PLYListItem.h"

@interface DetailedProductListViewControllerTableViewController ()

@end

@implementation DetailedProductListViewControllerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 2;
    }
    // Return the number of rows in the section.
    return [_list.listItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            ProductListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListDetailsTableCell" forIndexPath:indexPath];
            
            [cell setList:_list];
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SharingTableCell" forIndexPath:indexPath];
            
            return cell;
        }
    } else {
        ListItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListItemTableCell" forIndexPath:indexPath];
    
        [cell setListItem:[_list.listItems objectAtIndex:indexPath.row]];
        
        return cell;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PLYListItem *listItem = [_list.listItems objectAtIndex:indexPath.row];
        
        
        [[PLYServer sharedServer] deleteProductWithGTIN:listItem.GTIN fromListWithId:_list.Id completion:^(id result, NSError *error) {
            if (error)
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't be deleted!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    // Delete the row from the data source
                    [_list.listItems removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                });
            }
        }];
    }
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0){
        // hide date picker row
        return 127.0f;
    } else if (indexPath.section == 0 && indexPath.row == 1){
        return 44.0f;
    }
    
    return 70.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"loadProductInfo"])
	{
		ProductViewController *vc = segue.destinationViewController;
		[vc setProduct:[((ListItemTableCell *)sender) getProduct]];
	}
    
    
}

@end
