//
//  UserDetailsViewController.h
//  PL
//
//  Created by René Swoboda on 02/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class UserTableViewCell;
@class PLYUser;

@interface UserDetailsViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UserTableViewCell *userDetailsCell;

@property (nonatomic, strong) PLYUser *user;

@end
