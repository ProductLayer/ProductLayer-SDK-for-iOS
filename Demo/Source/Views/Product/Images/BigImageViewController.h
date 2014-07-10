//
//  BigImageViewController.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLYImage.h"

@interface BigImageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *votingScoreLabel;

- (void) setImageMetadata:(PLYImage *)imageMetadata;

- (IBAction) upVoteImage:(id)sender;
- (IBAction) downVoteImage:(id)sender;

@end
