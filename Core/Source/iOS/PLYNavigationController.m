//
//  PLYNavigationController.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 19/12/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYNavigationController.h"

@interface PLYNavigationController ()

@end

@implementation PLYNavigationController

- (BOOL)shouldAutorotate
{
	return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return self.topViewController.supportedInterfaceOrientations;
}

@end
