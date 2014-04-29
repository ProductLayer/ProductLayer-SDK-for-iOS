//
//  ProductViewController.m
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ProductViewController.h"
#import "DTBlockFunctions.h"
#import "DTDownloadCache.h"
#import "DTImageCache.h"
#import "DTLog.h"
#import "ReviewTableViewController.h"
#import "ProductImageViewController.h"
#import "KeyValueTableViewController.h"
#import "EditProductViewController.h"

#import "UIViewTags.h"

@interface ProductViewController ()

@end

@implementation ProductViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
    
    [self updateView];
}

- (void) setProduct:(PLYProduct *)product{
    _product = product;
    
    [self updateView];
}

- (void) updateView{
    [_productName setText:_product.name];
    [_productBrand setText:_product.brandName];
    
    [self loadMainImage];
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMainImage{
    NSString *gtin = _product.gtin;
    
    if (!gtin)
	{
		return;
	}
	
	[[PLYServer sharedPLYServer] getImagesForGTIN:gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            NSArray *images = result;
            
            if(images != nil && images.count > 0){
                
                PLYProductImage *imageMeta = images[0];
                
                int imageSize = _productImage.frame.size.width*2;
                
                NSURL *imageURL = [NSURL URLWithString:[imageMeta getUrlForWidth:imageSize andHeight:imageSize crop:@"true"]];
                
                NSString *imageIdentifier = [imageURL lastPathComponent];
                NSLog(@"imageIdentifier : %@", imageIdentifier);
                
                // check if we have a cached version
                DTImageCache *imageCache = [DTImageCache sharedCache];
                
                // TODO: We should also have the width and height as parameter, otherwise we could receive an image which has not the correct size.
                UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
                
                if (thumbnail)
                {
                    [_productImage setImage:thumbnail];
                    
                    return;
                }
                
                // need to load it
                UIImage *image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
                    
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        if (error)
                        {
                            DTLogError(@"Error loading image %@", [error localizedDescription]);
                        }
                        else
                        {
                            [imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:nil];
                        
                            [_productImage setImage:image];
                        }
                    });
                }];
                
                if (image)
                {
                    [_productImage setImage:image];
                }
                
            }
		});
	}];
}

- (void) updateButtons{
    if(_product.nutritious == nil || [_product.nutritious count] == 0){
        [_productNutritious setUserInteractionEnabled:NO];
    } else {
        [_productNutritious setUserInteractionEnabled:YES];
    }
    
    if(_product.characteristics == nil || [_product.characteristics count] == 0){
        [_productCharacteristics setUserInteractionEnabled:NO];
    } else {
        [_productCharacteristics setUserInteractionEnabled:YES];
    }
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProductReviews"])
	{
		ReviewTableViewController *reviewVC = (ReviewTableViewController *)segue.destinationViewController;
        reviewVC.navigationItem.title = _product.name;
		reviewVC.gtin = _product.gtin;
	}
	else if ([[segue identifier] isEqualToString:@"showProductImages"])
	{
        ProductImageViewController *imageVC = (ProductImageViewController *)segue.destinationViewController;
		imageVC.navigationItem.title = _product.name;
		[imageVC loadImagesFromGtin:_product.gtin];
	} else if ([[segue identifier] isEqualToString:@"showProductCharacteristics"])
	{
        KeyValueTableViewController *charVC = (KeyValueTableViewController *)segue.destinationViewController;
		charVC.navigationItem.title = @"Characteristics";
		[charVC setElements:_product.characteristics];
	} else if ([[segue identifier] isEqualToString:@"showProductNutritious"])
	{
        KeyValueTableViewController *nutrVC = (KeyValueTableViewController *)segue.destinationViewController;
        nutrVC.navigationItem.title = @"Nutritious";
		[nutrVC setElements:_product.nutritious];
	} else if ([[segue identifier] isEqualToString:@"editProduct"])
	{
        UINavigationController *navController = segue.destinationViewController;
		EditProductViewController *editVC = (EditProductViewController *)[navController topViewController];
        editVC.navigationItem.title = @"Edit Product";
		[editVC setProduct:_product];
	}
}


@end
