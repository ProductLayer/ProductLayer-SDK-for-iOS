//
//  ReviewTableViewController.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "ReviewTableViewController.h"

#import "ReviewTableViewCell.h"
#import "UIViewTags.h"
#import "WriteReviewViewController.h"
#import "DTBlockFunctions.h"
#import "DTSidePanelController.h"
#import "UIViewController+DTSidePanelController.h"
#import "AppSettings.h"

#import "DTProgressHUD.h"

#import "ProductLayer.h"

@interface ReviewTableViewController ()
@property (nonatomic) bool isLoading;
@end

@implementation ReviewTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _isLoading = NO;
    }
    return self;
}

- (void) reloadReviews{
    if(_isLoading) return;
    
    if(!_gtin){
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(writeReview)];
    }
    
    if(_gtin || _userNickname){
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    _isLoading = YES;
    _locale = [AppSettings currentAppLocale];
    [[PLYServer sharedServer] performSearchForReviewWithGTIN:_gtin
                                   withLanguage:_locale.localeIdentifier
                           fromUserWithNickname:_userNickname
                                     withRating:0
                                        orderBy:@"pl-id_asc"
                                           page:0
                                 recordsPerPage:20
                                     completion:^(id result, NSError *error) {
                                         if(error) {
                                             DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                                 
                                                 if(error.code == 404){
                                                     // Reviews from user.
                                                     if(_userNickname){
                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No reviews found" message:[NSString stringWithFormat:@"There are no reviews from %@ available!",_userNickname] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                         [alert show];
                                                     }
                                                     // Reviews for product
                                                     else {
                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No reviews found" message:@"There are no reviews for the product available! Be the first to write a review!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                         [alert show];
                                                     }
                                                 } else {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Reviews Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                     [alert show];
                                                 }
                                             });
                                         } else {
                                             DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                                 
                                                 _reviews = result;
                                                 
                                                 [self.tableView reloadData];
                                                 
                                                 _isLoading = NO;
                                             });
                                         }
                                         
                                         DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                             [_hud hide];
                                         });
                                     }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.sidePanelController;
    _sidebarButton.action = @selector(toggleLeftPanel:);
}

- (void) writeReview{
    [self performSegueWithIdentifier:@"writeReview" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //Changing Tint Color!
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
                                                                        green:190.0/255.0
                                                                         blue:68.0/255.0
                                                                        alpha:1.0];
    
    [self reloadReviews];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_reviews count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewTableViewCell" forIndexPath:indexPath];
    
    [cell setReview:[_reviews objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"writeReview"] && ![self checkIfLoggedInAndShowLoginView:YES])
	{
        return NO;
    }
    
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"writeReview"])
	{
		WriteReviewViewController *writeReview = (WriteReviewViewController *)segue.destinationViewController;
		writeReview.gtin = _gtin;
        writeReview.gtinTextField.enabled = NO;
	}
}

@end
