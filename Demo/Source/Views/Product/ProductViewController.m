//
//  ProductViewController.m
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "ProductViewController.h"

#import "DTBlockFunctions.h"
#import "DTDownloadCache.h"
#import "DTImageCache.h"
#import "DTLog.h"
#import "DTProgressHUD.h"
#import "DTAlertView.h"

#import "ReviewTableViewController.h"
#import "OpineTableViewController.h"
#import "ProductImageViewController.h"
#import "KeyValueTableViewController.h"
#import "ProductListsViewController.h"

#import "AppSettings.h"
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
    
    if(_product && _product.GTIN && !_productImage.image){
        [self loadMainImage];
    }
}

- (void) loadProductWithGTIN:(NSString *)_gtin{
    // Load product data
    
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    __weak ProductViewController *weakSelf = self;
    
    [[PLYServer sharedServer] performSearchForGTIN:_gtin language:nil completion:^(id result, NSError *error) {
        if (error)
        {
            DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't load Product" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
            });
        }
        else
        {
            DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                PLYProduct *defaultLocaleProduct;
                
                _product = nil;
                
                for(PLYProduct *product in result){
                    // Search for current locale
                    if([product.language isEqualToString:[AppSettings currentAppLocale].localeIdentifier]){
                        [self setProduct:product];

                        break;
                    } else if([product.language isEqualToString:@"en"] || [product.language rangeOfString:@"en_"].location != NSNotFound){
                        defaultLocaleProduct = product;
                    }
                }
                
                if(!_product){

                    
                    DTAlertView *alertView = [[DTAlertView alloc] initWithTitle:@"Product not found!" message:@"The product have not been found for your locale."];
                    alertView.delegate = self;
                    
                    if(defaultLocaleProduct) {
                        [alertView addButtonWithTitle:[NSString stringWithFormat:@"Show locale %@", defaultLocaleProduct.language] block:^() {
                            [[PLYServer sharedServer] logoutUserWithCompletion:^(id result, NSError *error) {
                                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                    [weakSelf setProduct:defaultLocaleProduct];
                                });
                            }];
                        }];
                    }
                    
                    [alertView addButtonWithTitle:[NSString stringWithFormat:@"Add locale %@", [AppSettings currentAppLocale].localeIdentifier] block:^() {
                        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                            
                            PLYProduct *newProduct = [[PLYProduct alloc] init];
                            [newProduct setGTIN:_gtin];
                            
                            [weakSelf setProduct:newProduct];
                            
                            [weakSelf performSegueWithIdentifier:@"editProduct" sender:nil];
                        });
                    }];
                    
                    [alertView addCancelButtonWithTitle:@"Cancel" block:^() {
                        // Do nothing here. UIAlertViewDelegate is used.
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                    
                    
                    
                    [alertView show];
                }
            });
        }
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
    }];
}

- (void) setProduct:(PLYProduct *)product{
    // Prevent unnecessary image requests
    bool loadImage = YES;
    if([product.GTIN isEqualToString:_product.GTIN]){
        loadImage = NO;
    }
    
    _product = product;
    
    [self updateView];
    
    if(loadImage){
        [self loadMainImage];
    }
}

- (void) updateView{
    if(_product.name){
        [_productName setText:_product.name];
    } else {
        [_productName setText:_product.GTIN];
    }
    
    if(_product.brandName){
        [_productBrand setText:_product.brandName];
    } else {
        [_productBrand setText:@"unknown"];
    }
    
    if(_product.language){
        [_localeLabel setText:_product.language];
    }
    
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMainImage{
    NSString *gtin = _product.GTIN;
    
    if (!gtin)
	{
		return;
	}
	
	[[PLYServer sharedServer] getImagesForGTIN:gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            NSArray *images = result;
            
            if(images != nil && images.count > 0){
                
                PLYImage *imageMeta = images[0];
                
                int imageSize = _productImage.frame.size.width*[[UIScreen mainScreen] scale];
                
                NSURL *imageURL = [NSURL URLWithString:[imageMeta getUrlForWidth:imageSize andHeight:imageSize crop:true]];
                
                NSString *imageIdentifier = [imageURL lastPathComponent];
                
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

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (([identifier isEqualToString:@"addProductToList"] || [identifier isEqualToString:@"editProduct"]) && ![self checkIfLoggedInAndShowLoginView:YES])
	{
        return NO;
    }
    
    return YES;
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showProductReviews"])
	{
		ReviewTableViewController *reviewVC = (ReviewTableViewController *)segue.destinationViewController;
        reviewVC.navigationItem.title = _product.name;
		reviewVC.gtin = _product.GTIN;
	}
    else if ([[segue identifier] isEqualToString:@"showProductOpines"])
	{
		OpineTableViewController *opineVC = (OpineTableViewController *)segue.destinationViewController;
        opineVC.navigationItem.title = _product.name;
		opineVC.parent = _product;
	}
	else if ([[segue identifier] isEqualToString:@"showProductImages"])
	{
        ProductImageViewController *imageVC = (ProductImageViewController *)segue.destinationViewController;
		imageVC.navigationItem.title = _product.name;
		[imageVC loadImagesFromGtin:_product.GTIN];
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
        editVC.delegate = self;
		[editVC setProduct:_product];
	}  else if ([[segue identifier] isEqualToString:@"addProductToList"])
	{
        UINavigationController *navController = segue.destinationViewController;
		ProductListsViewController *listVC = (ProductListsViewController *)[navController topViewController];
        listVC.navigationItem.title = @"Add to List";
        listVC.product = _product;
        listVC.addProductView = YES;
		[listVC loadProductListsForUser:[[PLYServer sharedServer] loggedInUser] andType:nil];
	}
}

#pragma mark - ProductUpdateDelegate

- (void) productUpdated:(PLYProduct *)product{
    [self setProduct:product];
}

@end
