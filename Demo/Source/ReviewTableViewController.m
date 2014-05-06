//
//  ReviewTableViewController.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ReviewTableViewController.h"

#import "ReviewTableViewCell.h"
#import "SWRevealViewController.h"
#import "UIViewTags.h"
#import "WriteReviewViewController.h"
#import "DTBlockFunctions.h"
#import "AppSettings.h"

@interface ReviewTableViewController ()
@property (nonatomic) bool isLoading;
@end

@implementation ReviewTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _isLoading = false;
    }
    return self;
}

- (void) reloadReviews{
    if(_isLoading) return;
    
    _isLoading = true;
    [[PLYServer sharedPLYServer] performSearchForReviewWithGTIN:_gtin
                                   withLanguage:_locale.localeIdentifier
                           fromUserWithNickname:_userNickname
                                     withRating:nil
                                        orderBy:@"pl-id_asc"
                                           page:[NSNumber numberWithInt:0]
                                 recordsPerPage:[NSNumber numberWithInt:20]
                                     completion:^(id result, NSError *error) {
                                         DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                             
                                             _reviews = result;
                                             
                                             [self.tableView reloadData];
                                             
                                             _isLoading = false;
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
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    if(!_gtin){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if(_gtin || _userNickname){
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self reloadReviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"writeReview"])
	{
		WriteReviewViewController *writeReview = (WriteReviewViewController *)segue.destinationViewController;
		writeReview.gtin = _gtin;
        writeReview.gtinTextField.enabled = false;
	}
	/*else if ([[segue identifier] isEqualToString:@"viewFullReview"])
	{
		UINavigationController *navController = segue.destinationViewController;
		EditProductViewController *vc = (EditProductViewController *)[navController topViewController];
		vc.navigationItem.title = @"Add New Product";
		vc.gtin = _gtinForEditingProduct;
	}*/
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

@end
