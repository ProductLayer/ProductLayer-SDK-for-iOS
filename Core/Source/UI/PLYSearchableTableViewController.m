//
//  PLYSearchableTableViewController.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYSearchableTableViewController.h"
#import "DTLog.h"

@interface PLYSearchableTableViewController ()

@end

@implementation PLYSearchableTableViewController
{
	UISearchController *_searchController;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.tableHeaderView = self.searchController.searchBar;
}

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [NSException raise:@"DTAbstractClassException" format:@"You tried to call %@ on an abstract class %@",  NSStringFromSelector(_cmd), NSStringFromClass([self class])];
}

#pragma mark - Properties

- (UISearchController *)searchController
{
	if (!_searchController)
	{
		_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
		_searchController.searchResultsUpdater = (id)self;
		_searchController.searchBar.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 44.0); // need frame or else it is invisible
		_searchController.dimsBackgroundDuringPresentation = NO;
	}
	
	return _searchController;
}

@end
