//
//  SocialFeedViewController.m
//  PL
//
//  Created by René Swoboda on 08/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "SocialFeedViewController.h"

#import "ProductLayer.h"
#import "ProductImageCollectionViewCell.h"
#import "ProductViewController.h"

#import "DTBlockFunctions.h"
#import "DTLog.h"
#import "DTProgressHUD.h"

typedef enum : NSUInteger {
    LandscapeCell,
    PortraitCell,
    SquareCell,
    SquareOrPortraitCell,
    SquareOrLandscapeCell,
    AllTypesAllowed
} CellType;

@interface SocialFeedViewController ()

@end

@implementation SocialFeedViewController{
    NSMutableArray *sizeArray;
}

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
    
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(78, 78);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //Changing Tint Color!
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
                                                                        green:190.0/255.0
                                                                         blue:68.0/255.0
                                                                        alpha:1.0];

    [self loadSocialFeed];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    id feed = [_socialFeeds objectAtIndex:indexPath.row];
    int score = 0;
    CellType type = AllTypesAllowed;
    
    if([feed isKindOfClass:[PLYImage class]]){
        score = [((PLYImage *)feed).votingScore intValue];
        
        if(((PLYImage *)feed).width > ((PLYImage *)feed).height){
            type = SquareOrLandscapeCell;
        } else {
            type = SquareOrPortraitCell;
        }
    } else if([feed isKindOfClass:[PLYReview class]]){
        score = [((PLYReview *)feed).votingScore intValue];
        type = LandscapeCell;
    }
    
    switch (type) {
        case LandscapeCell:
            return CGSizeMake(2, 1);
        case PortraitCell:
            return CGSizeMake(1, 2);
        case SquareCell:
            if(score > 4){
                return CGSizeMake(2, 2);
            }
            return CGSizeMake(1, 1);
        case SquareOrLandscapeCell:
            if(score > 4){
                return CGSizeMake(2, 2);
            } else if(score > 0){
                return CGSizeMake(2, 1);
            }
            return CGSizeMake(1, 1);
        case SquareOrPortraitCell:
            if(score > 4){
                return CGSizeMake(2, 2);
            } else if(score > 0){
                return CGSizeMake(1, 2);
            }
            return CGSizeMake(1, 1);
        case AllTypesAllowed:
            if(score > 4){
                return CGSizeMake(2, 2);
            } else if(score > 2){
                return CGSizeMake(2, 1);
            } else if(score > 0){
                return CGSizeMake(1, 2);
            }
            return CGSizeMake(1, 1);
        default:
            break;
    }
    
    return CGSizeMake(1, 1);
}

- (UIEdgeInsets) insetsForItemAtIndexPath:(NSIndexPath *)indexPath{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showProductDetails"])
	{
        ProductViewController *PVC = (ProductViewController *)segue.destinationViewController;
        [PVC loadProductWithGTIN:((ProductImageCollectionViewCell *)sender).imageMetadata.gtin];
	}
}


#pragma mark - UICollectionViewDataDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_socialFeeds count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    id feed = [_socialFeeds objectAtIndex:indexPath.row];
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    
    if([feed isKindOfClass:[PLYImage class]]){
        ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PictureGridView" forIndexPath:indexPath];
        
        CGSize blockSize = [self blockSizeForItemAtIndexPath:indexPath];
        [cell loadImageForMetadata:feed withSize:CGSizeMake((blockSize.width*layout.blockPixels.width + (blockSize.width-1)*8)*[UIScreen mainScreen].scale, (blockSize.height*layout.blockPixels.height + (blockSize.height-1)*8)*[UIScreen mainScreen].scale) crop:true];
        
        return cell;
    }
    
    return nil;
}

- (void) loadSocialFeed{
    
    // Loading the DTProgressHUD on application launch causing the following debug message:
    // Application windows are expected to have a root view controller at the end of application launch
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    // TODO: Load all social Feeds (Images, Reviews, Opinions, ...)
    [[PLYServer sharedServer] getLastUploadedImagesWithPage:0 andRPP:20 completion:^(id result, NSError *error) {
        
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
            
            if([result isKindOfClass:PLYErrorResponse.class]){
                NSArray *errors = [((PLYErrorResponse *)result) errors];
                
                for(PLYErrorMessage *errorMessage in errors){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[errorMessage message] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            } else {
                _socialFeeds = result;
			
                [self.collectionView reloadData];
            }
		});
	}];
}

@end
