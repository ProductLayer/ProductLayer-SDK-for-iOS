//
//  KeyValueTableViewController.h
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@interface KeyValueTableViewController : ProductLayerViewController

@property (nonatomic, strong) NSDictionary *elements;
@property (nonatomic, strong) NSMutableDictionary *groupedElements;

@end
