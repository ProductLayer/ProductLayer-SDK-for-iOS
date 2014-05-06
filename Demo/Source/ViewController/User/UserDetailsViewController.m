//
//  UserDetailsViewController.m
//  PL
//
//  Created by René Swoboda on 02/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "UserDetailsViewController.h"

#import "UserTableViewCell.h"
#import "PLYUser.h"

#import "ReviewTableViewController.h"
#import "SearchUserTableViewController.h"

@interface UserDetailsViewController ()

@end

@implementation UserDetailsViewController

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
    
    [self updateView];
}

- (void) setUser:(PLYUser *)user{
    _user = user;
    
    [self updateView];
}

- (void) updateView{
    if(_user){
        [_userDetailsCell setUser:_user];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
    if ([[segue identifier] isEqualToString:@"showReviewsFromUser"])
	{
		ReviewTableViewController *reviewVC = (ReviewTableViewController *)segue.destinationViewController;
		reviewVC.userNickname = _user.nickname;
        [reviewVC reloadReviews];
	} else if ([[segue identifier] isEqualToString:@"showFollowerFromUser"])
	{
		SearchUserTableViewController *searchVC = (SearchUserTableViewController *)segue.destinationViewController;
		[searchVC loadFollowerFromUser:_user];
	} else if ([[segue identifier] isEqualToString:@"showFollowingFromUser"])
	{
		SearchUserTableViewController *searchVC = (SearchUserTableViewController *)segue.destinationViewController;
		[searchVC loadFollowingFromUser:_user];
	}
}


@end
