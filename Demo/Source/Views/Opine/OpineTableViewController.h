//
//  OpineTableViewController.h
//  PL
//
//  Created by René Swoboda on 30/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class PLYEntity;

@interface OpineTableViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addOpineButton;

@property (nonatomic, strong) PLYEntity *parent;
@property (nonatomic, copy) NSString *userNickname;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSMutableArray *opines;

- (void) reloadOpines;

@end
