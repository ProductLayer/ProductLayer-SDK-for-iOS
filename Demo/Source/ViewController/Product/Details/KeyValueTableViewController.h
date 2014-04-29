//
//  KeyValueTableViewController.h
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyValueTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *elements;
@property (nonatomic, strong) NSMutableDictionary *groupedElements;

@end
