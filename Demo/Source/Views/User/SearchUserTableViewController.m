//
//  SearchUserTableViewController.m
//  PL
//
//  Created by René Swoboda on 01/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "SearchUserTableViewController.h"
#import "UserTableViewCell.h"
#import "UserDetailsViewController.h"
#import "DTSidePanelController.h"
#import "UIViewController+DTSidePanelController.h"

#import "UIViewTags.h"

#import "PLYServer.h"
#import "PLYUser.h"

#import "DTBlockFunctions.h"
#import "DTProgressHUD.h"

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
    _sidebarButton.target = self.getSidePanelController;
    _sidebarButton.action = @selector(showLeftPanel:);
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
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"searching" progressType:HUDProgressTypeInfinite];
    
    // Search user
    [[PLYServer sharedServer] performUserSearch:searchBar.text completion:^(id result, NSError *error) {
		
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
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}

- (void) loadFollowerFromUser:(PLYUser *)_user{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    [[PLYServer sharedServer] getFollowerFromUser:_user.nickname page:[NSNumber numberWithInt:0] recordsPerPage:[NSNumber numberWithInt:50] completion:^(id result, NSError *error) {
		
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
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}

- (void) loadFollowingFromUser:(PLYUser *)_user{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    [[PLYServer sharedServer] getFollowingFromUser:_user.nickname page:[NSNumber numberWithInt:0] recordsPerPage:[NSNumber numberWithInt:50] completion:^(id result, NSError *error) {
		
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
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}

@end
