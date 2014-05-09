//
//  RatingTableCell.h
//  PL
//
//  Created by René Swoboda on 07/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *OneStarButton;
@property (nonatomic, weak) IBOutlet UIButton *TwoStarButton;
@property (nonatomic, weak) IBOutlet UIButton *ThreeStarButton;
@property (nonatomic, weak) IBOutlet UIButton *FourStarButton;
@property (nonatomic, weak) IBOutlet UIButton *FiveStarButton;

@property (nonatomic) int rating;

- (IBAction) ratingChanged:(id)sender;

@end
