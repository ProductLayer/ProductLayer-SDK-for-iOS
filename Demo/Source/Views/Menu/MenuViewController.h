//
//  MenuViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@interface MenuViewController : ProductLayerViewController

- (IBAction)unwindToMenu:(UIStoryboardSegue *)unwindSegue;

@end
