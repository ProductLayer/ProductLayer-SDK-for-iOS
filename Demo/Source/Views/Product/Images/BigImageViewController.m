//
//  BigImageViewController.m
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "BigImageViewController.h"

#import "DTImageCache.h"
#import "DTDownloadCache.h"
#import "DTLog.h"
#import "DTBlockFunctions.h"
#import "DTProgressHUD.h"

#import "PLYServer.h"

@interface BigImageViewController () {
    PLYImage *metadata;
}

@end

@implementation BigImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [self reloadImage];
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_setImage:(UIImage *)image
{
    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
        self.imageView.image = image;
    });
}

- (void)updateView{
    [_votingScoreLabel setText:[NSString stringWithFormat:@"%d (up=%lu, down=%lu)",[metadata.votingScore intValue], (unsigned long)[metadata.upVoter count], (unsigned long)[metadata.downVoter count]]];
}

- (void) setImageMetadata:(PLYImage *)imageMetadata{
    if(metadata != nil && [metadata.Id isEqualToString:imageMetadata.Id]){
        return;
    }
    
    metadata = imageMetadata;
    
    [self reloadImage];
    [self updateView];
}

- (void) reloadImage{
    // check if image view have been initialized.
    if(_imageView == nil){
        return;
    }
    
    CGSize imageSize = CGSizeMake(_imageView.frame.size.width*[[UIScreen mainScreen] scale], _imageView.frame.size.height*[[UIScreen mainScreen] scale]);
    NSURL *imageUrl = [NSURL URLWithString:[metadata getUrlForWidth:imageSize.width andHeight:imageSize.height crop:false]];
    
	NSString *imageIdentifier = [imageUrl lastPathComponent];
	
	// check if we have a thumbnail
	
	DTImageCache *imageCache = [DTImageCache sharedCache];
    
    NSString *variantIdentifier = [NSString stringWithFormat:@"%.0fx%.0f_%d",imageSize.width,imageSize.height,true];
    
	UIImage *image = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:variantIdentifier];
    
	if (image)
	{
		[self _setImage:image];
		
		return;
	}
	
	// need to load it
	image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageUrl option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
		
		if (error)
		{
			DTLogError(@"Error loading image %@", [error localizedDescription]);
		}
		else
		{
			[imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:variantIdentifier];
            
            [self _setImage:image];
		}
	}];
	
	if (image)
	{
        [self _setImage:image];
	}
}

- (IBAction) upVoteImage:(id)sender{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    
    [_hud showWithText:@"saving" progressType:HUDProgressTypeInfinite];
    
    [[PLYServer sharedServer] upVoteImageWithId:metadata.fileId andGTIN:metadata.GTIN completion:^(id result, NSError *error) {
        
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                [_hud hide];
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Up-Vote Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                metadata = result;
                [self updateView];

                [_hud showWithText:[NSString stringWithFormat:@"Voting score: %d", [metadata.votingScore intValue]] image:[UIImage imageNamed:@"up_vote.png"]];
                [_hud hideAfterDelay:2.0f];
			});
		}
	}];
}

- (IBAction) downVoteImage:(id)sender{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    
    [_hud showWithText:@"saving" progressType:HUDProgressTypeInfinite];
    
    [[PLYServer sharedServer] downVoteImageWithId:metadata.fileId andGTIN:metadata.GTIN completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                [_hud hide];
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Down-Vote Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                metadata = result;
                [self updateView];
                
                [_hud showWithText:[NSString stringWithFormat:@"Voting score: %d", [metadata.votingScore intValue]] image:[UIImage imageNamed:@"down_vote.png"]];
                [_hud hideAfterDelay:2.0f];
			});
		}
	}];
}

@end
