//
//  UserDetailsViewController.m
//  PL
//
//  Created by René Swoboda on 02/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
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

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (([identifier isEqualToString:@"showFollowerFromUser"] || [identifier isEqualToString:@"showFollowingFromUser"]) && ![self checkIfLoggedInAndShowLoginView:YES])
	{
        return NO;
    }
    
    return YES;
}

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
