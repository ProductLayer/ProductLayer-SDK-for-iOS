//
//  PLYGuidedInputViewController.m
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYGuidedInputViewController.h"
#import "ProductLayer.h"

@interface PLYGuidedInputViewController ()

@end

@implementation PLYGuidedInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// load view from the PL resource bundle
- (void)loadView
{
	NSBundle *resources = PLYResourceBundle();
	UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:resources];
	[nib instantiateWithOwner:self options:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
