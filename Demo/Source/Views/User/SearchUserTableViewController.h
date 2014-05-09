//
//  SearchUserTableViewController.h
//  PL
//
//  Created by René Swoboda on 01/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class PLYUser;

@interface SearchUserTableViewController : ProductLayerViewController

@property (weak, nonatomic)   IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) NSArray *users;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

- (void) loadFollowerFromUser:(PLYUser *)_user;
- (void) loadFollowingFromUser:(PLYUser *)_user;

@end
