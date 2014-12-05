//
//  ProductImageViewController.m
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductImageViewController.h"
#import "ProductImageCollectionViewCell.h"
#import "BigImageViewController.h"
#import "UIViewController+Login.h"

#import "ProductLayer.h"
#import "DTFoundation.h"
#import "DTProgressHUD.h"

@interface ProductImageViewController () <UICollectionViewDataSource>
@end

@implementation ProductImageViewController
{
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(_gtin){
        [self loadImagesFromGtin:_gtin];
    }
    
    //Changing Tint Color!
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
                                                                        green:190.0/255.0
                                                                         blue:68.0/255.0
                                                                        alpha:1.0];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PLYImage *imageData = _images[indexPath.item];
	
	ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImage" forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"collectionView: %f", collectionView.frame.size.width);
    NSLog(@"scale: %f", [UIScreen mainScreen].scale);
    
    int imageSize = floor((collectionView.frame.size.width-50)/2.0)*[UIScreen mainScreen].scale;
	[cell loadImageForMetadata:imageData withSize:CGSizeMake(imageSize, imageSize) crop:true];
	
    NSLog(@"%ld - %@", (long)indexPath.item, imageData.fileId);
    
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = CGSizeMake(floor((collectionView.frame.size.width-50)/4.0), floor((collectionView.frame.size.width-50)/4.0));
	return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    float topAndBottomSpacer = (collectionView.frame.size.height - floor((collectionView.frame.size.width-50)/4.0)*2 - 10)/2;
	return UIEdgeInsetsMake(topAndBottomSpacer, 10, topAndBottomSpacer, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void) loadLastImages{
    [[PLYServer sharedServer] getLastUploadedImagesWithPage:0 andRPP:30 completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}

- (void) loadImagesFromGtin:(NSString *)gtin{
    self.gtin = gtin;
    
    if (!_gtin)
	{
		return;
	}
	
	[[PLYServer sharedServer] getImagesForGTIN:_gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showBigImage"])
	{
		BigImageViewController *imageVC = (BigImageViewController *)segue.destinationViewController;
		[imageVC setImageMetadata:((ProductImageCollectionViewCell *)sender).imageMetadata];
	}
}

#pragma mark - Add Image

- (IBAction)addImageToProduct:(id)sender
{
    if (![self checkIfLoggedInAndShowLoginView:YES]){
        return;
    }
    
	if (![self.gtin length])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot add Image" message:@"Please scan something first, we need a GTIN to add an image to" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		
		return;
	}
    
    __weak ProductImageViewController *weakSelf = self;
    
    DTAlertView *alertView = [[DTAlertView alloc] initWithTitle:@"Choose image source!" message:nil];
    
        [alertView addButtonWithTitle:@"Take New Photo" block:^() {
            DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.delegate = (id)self;
                
                [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
            });
        }];
    
    [alertView addButtonWithTitle:@"Choose Existing Photo" block:^() {
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = (id)self;
            
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        });
    }];
    
    [alertView addCancelButtonWithTitle:@"Cancel" block:^() {
        // Nothing to do here;
    }];
    
    
    [alertView show];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"saving" progressType:HUDProgressTypeInfinite];
    
	[self dismissViewControllerAnimated:YES completion:NULL];
    
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	[[PLYServer sharedServer] uploadImageData:image forGTIN:self.gtin completion:^(id result, NSError *error) {
		if(!error && [result isKindOfClass:[PLYImage class]]){
            if(!_images){
                _images = [NSMutableArray arrayWithCapacity:1];
            }
            
            DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                [_images addObject:result];
			
                [self.collectionView reloadData];
            });
        }
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
