//
//  SearchUserTableViewController.m
//  PL
//
//  Created by René Swoboda on 01/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "SearchUserTableViewController.h"
#import "SWRevealViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailsViewController.h"

#import "UIViewTags.h"

#import "PLYServer.h"
#import "PLYUser.h"

#import "DTBlockFunctions.h"

@interface SearchUserTableViewController ()

@end

@implementation SearchUserTableViewController

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
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
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
    return [_users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    [cell setUser:_users[indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUserDetails"])
	{
		UserDetailsViewController *detailsVC = segue.destinationViewController;
		detailsVC.user = [((UserTableViewCell *)sender) user];
	}
}


#pragma mark - search

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Search user
    [[PLYServer sharedPLYServer] performUserSearch:searchBar.text completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                _users = result;
				
				[self.tableView reloadData];
			});
		}
	}];
}

- (void) loadFollowerFromUser:(PLYUser *)_user{
    [[PLYServer sharedPLYServer] getFollowerFromUser:_user.nickname page:[NSNumber numberWithInt:0] recordsPerPage:[NSNumber numberWithInt:50] completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load follower Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                _users = result;
				
				[self.tableView reloadData];
			});
		}
	}];
}

- (void) loadFollowingFromUser:(PLYUser *)_user{
    [[PLYServer sharedPLYServer] getFollowingFromUser:_user.nickname page:[NSNumber numberWithInt:0] recordsPerPage:[NSNumber numberWithInt:50] completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load following Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                _users = result;
				
				[self.tableView reloadData];
			});
		}
	}];
}

@end
