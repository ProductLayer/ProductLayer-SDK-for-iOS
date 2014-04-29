//
//  ReviewTableViewController.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLYServer.h"

@interface ReviewTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addReviewButton;

@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSMutableArray *reviews;

- (void) reloadReviews;

@end
