//
//  PLYSearchableTableViewController.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYSearchableTableViewController.h"

#import <DTFoundation/DTLog.h>

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

#pragma mark - Public Methods

- (NSArray *)currentSearchTerms
{
	NSString *searchText = self.searchController.searchBar.text;
	
	if ([searchText length])
	{
		return [searchText componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	}
	
	return nil;
}

#pragma mark - Helpers

- (BOOL)_text:(NSString *)text containsAllTerms:(NSArray *)terms
{
	for (NSString *oneTerm in terms)
	{
		if (![oneTerm length])
		{
			// ignore null string
			continue;
		}
		
		NSRange range = [text rangeOfString:oneTerm options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
		
		if (range.location == NSNotFound)
		{
			return NO;
		}
	}
	
	return YES;
}

- (NSAttributedString *)_attributedStringForText:(NSString *)text withSearchTermsMarked:(NSArray *)terms
{
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
	NSRange range = NSMakeRange(0, [attributedString length]);
	
	// workaround for TextKit bug not showing underlines
	[attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
	
	for (NSString *oneTerm in terms)
	{
		if (![oneTerm length])
		{
			// ignore null string
			continue;
		}
		
		range = NSMakeRange(0, [attributedString length]);
		
		while (range.location != NSNotFound)
		{
			range = [text rangeOfString:oneTerm options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch range:range];
			
			if (range.location != NSNotFound)
			{
				[attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
				
				range = NSMakeRange(range.location + range.length, [attributedString length] - (range.location + range.length));
			}
		}
	}
	
	return [attributedString copy];
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
