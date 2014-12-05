//
//  ReviewTableViewController.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@interface ReviewTableViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addReviewButton;

@property (nonatomic, copy) NSString *gtin;
@property (nonatomic, copy) NSString *userNickname;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSMutableArray *reviews;

- (void) reloadReviews;

@end
