//
//  PLYViewController.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYViewController.h"
#import "ProductLayer.h"

@interface PLYViewController ()

@end

@implementation PLYViewController

+ (void) initialize
{
	// all subclasses require the resource bundle
	NSAssert(PLYResourceBundle(), @"ProductLayer.bundle cannot be found in app. This is required for the UI to work");
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.title = @"ProductLayer";
}

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
