//
//  PLYTableViewController.m
//  PL
//
//  Created by Oliver Drobnik on 11/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYTableViewController.h"
#import "PLYServer.h"

@interface PLYTableViewController ()

@end

@implementation PLYTableViewController

#pragma mark - Properties

- (PLYServer *)server
{
	if (_server)
	{
		return _server;
	}
	
	return [PLYServer sharedServer];
}

@end
