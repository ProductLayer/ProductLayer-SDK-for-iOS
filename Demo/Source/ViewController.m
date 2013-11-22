//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ViewController.h"
#import "ProductLayer.h"
#import "ProductLayerConfig.h"
	

@interface ViewController ()

@end

@implementation ViewController
{
	PLYServer *_server;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_server = [[PLYServer alloc] initWithHostURL:PLY_ENDPOINT_URL];

	[_server performSearchForGTIN:@"123" language:@"de" completion:^(id result, NSError *error) {
		
		if (result)
		{
			NSLog(@"%@", result);
		}
		else
		{
			NSLog(@"%@", error);
		}
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
