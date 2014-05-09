//
//  ProductLayerViewController.m
//  PL
//
//  Created by René Swoboda on 08/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ProductLayerViewController.h"

#import "ProductLayer.h"
#import "DTAlertView.h"
#import "DTBlockFunctions.h"
#import "LoginViewController.h"

@interface ProductLayerViewController ()

@end

@implementation ProductLayerViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //Changing Tint Color!
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
                                                                        green:190.0/255.0
                                                                         blue:68.0/255.0
                                                                        alpha:1.0];
}

@end
