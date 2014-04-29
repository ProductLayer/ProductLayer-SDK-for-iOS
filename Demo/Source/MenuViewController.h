//
//  MenuViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController

- (IBAction)unwindToMenu:(UIStoryboardSegue *)unwindSegue;
- (IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue;

@end
