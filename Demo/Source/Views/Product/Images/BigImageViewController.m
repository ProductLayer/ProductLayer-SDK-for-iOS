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

#import "PLYServer.h"

@interface BigImageViewController () {
    PLYProductImage *metadata;
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
    [_votingScoreLabel setText:[NSString stringWithFormat:@"%d (up=%lu, down=%lu)",[metadata.votingScore intValue], (unsigned long)[metadata.upVoters count], (unsigned long)[metadata.downVoters count]]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) setImageMetadata:(PLYProductImage *)imageMetadata{
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
    [[PLYServer sharedPLYServer] upVoteImageWithId:metadata.fileId andGTIN:metadata.gtin completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Up-Vote Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                metadata = result;
                [self updateView];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You up-voted the image!" message:[NSString stringWithFormat:@"New image score is: %d", [metadata.votingScore intValue]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
	}];
}

- (IBAction) downVoteImage:(id)sender{
    [[PLYServer sharedPLYServer] downVoteImageWithId:metadata.fileId andGTIN:metadata.gtin completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Down-Vote Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                metadata = result;
                [self updateView];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You down-voted the image!" message:[NSString stringWithFormat:@"New image score is: %d", [metadata.votingScore intValue]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
	}];
}

@end
