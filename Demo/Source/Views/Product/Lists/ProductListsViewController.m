//
//  ProductListsViewController.m
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "ProductListsViewController.h"
#import "ProductListTableViewCell.h"
#import "ProductLayer.h"
#import "UIViewTags.h"
#import "DTBlockFunctions.h"
#import "AppSettings.h"
#import "DTProgressHUD.h"
#import "DetailedProductListViewControllerTableViewController.h"
#import "UIViewController+DTSidePanelController.h"
#import "DTSidePanelController.h"

@interface ProductListsViewController ()

@end

@implementation ProductListsViewController {
    NSMutableArray *_productLists;
    
    PLYUser *_user;
    NSString *_type;
    
    DTProgressHUD *_hud;
    
    unsigned long _runningOperations;
    
    int failedOperations;
    int successfullOperations;
}

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
    
    if(_addProductView) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self action:@selector(addProductToLists)];
        [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
        [self.tableView setEditing:YES animated:NO];
    } else {
        if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
            [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
        }
        
        // Set the side bar button action. When it's tapped, it'll show up the sidebar.
        _sidebarButton.target = self.sidePanelController;
        _sidebarButton.action = @selector(toggleLeftPanel:);
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(_user || _type){
        [self loadProductListsForUser:_user andType:_type];
    }
}

- (void) loadProductListsForUser:(PLYUser *)user andType:(NSString *)type{
    _user = user;
    _type = type;
    
    [[PLYServer sharedServer] performSearchForProductListFromUser:user andListType:type page:nil recordsPerPage:nil completion:^(id result, NSError *error) {
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Lists Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				_productLists = result;
				
				[self.tableView reloadData];
			});
		}
	}];
}

- (void) addProductToLists{
    _runningOperations = [_productLists count];
    failedOperations = 0;
    successfullOperations = 0;
    
    _hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    
    [_hud showWithText:@"saving" progressType:HUDProgressTypePie];
    
    for(PLYList *list in _productLists){
        
        [[PLYServer sharedServer] updateProductList:list completion:^(id result, NSError *error) {
            if (error)
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    failedOperations ++;

                    [self dismissIfAllOperationFinished];
                });
            }
            else
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    // Delete the row from the data source
                    successfullOperations ++;
                    
                    [self dismissIfAllOperationFinished];
                    [list setValuesForKeysWithDictionary:[result dictionaryRepresentation]];
                });
            }
        }];
    }
}

- (void) dismissIfAllOperationFinished{
    _runningOperations --;
    
    if(_runningOperations == 0){
        if(failedOperations == 0){
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Lists Error" message:@"Couldn't save all lists." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
            [self.tableView reloadData];
        }
        [_hud setProgress:1.0f];
        [_hud hideAfterDelay:1.0f];
    } else {
        float progress = (float)(successfullOperations + failedOperations) / (float)(successfullOperations + failedOperations + _runningOperations);
        [_hud setProgress:progress];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_productLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListTableViewCell *cell;
    PLYList *list = [_productLists objectAtIndex:indexPath.row];
    
    if (_addProductView){
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddProductToListTableViewCell" forIndexPath:indexPath];
        
        [cell setSelected:NO];
        
        if(list.listItems){
            for(PLYListItem *item in list.listItems){
                if([item.gtin isEqualToString:_product.gtin]){
                    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    break;
                }
            }
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProductListTableViewCell" forIndexPath:indexPath];
    }
    
    [cell setList:list];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PLYList *list = [_productLists objectAtIndex:indexPath.row];
        
        [[PLYServer sharedServer] deleteProductListWithId:list.Id completion:^(id result, NSError *error) {
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
                    [_productLists removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                });
            }
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_addProductView){
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_addProductView){
        PLYList *list = [_productLists objectAtIndex:indexPath.row];
        
        PLYListItem *listItem = [[PLYListItem alloc] init];
        listItem.gtin = _product.gtin;
        listItem.qty = [NSNumber numberWithInt:1];
        
        if(!list.listItems){
            list.listItems = [NSMutableArray arrayWithCapacity:1];
        }
        
        [list.listItems addObject:listItem];
        
        // Reload Row
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_addProductView){
        PLYList *list = [_productLists objectAtIndex:indexPath.row];
        
        
        for(PLYListItem *item in list.listItems){
            if([item.gtin isEqualToString:_product.gtin]){
                [list.listItems removeObject:item];
                break;
            }
        }
        
        // Reload Row
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"loadProductListDetails"])
	{
		DetailedProductListViewControllerTableViewController *vc = segue.destinationViewController;
		vc.navigationItem.title = @"List Details";
		[vc setList:[(ProductListTableViewCell *)sender list]];
	}
    
    
}

@end
