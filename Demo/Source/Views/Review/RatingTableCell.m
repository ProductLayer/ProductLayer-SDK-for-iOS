//
//  RatingTableCell.m
//  PL
//
//  Created by René Swoboda on 07/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "RatingTableCell.h"

@implementation RatingTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) ratingChanged:(id)sender{
    if([sender isEqual:_OneStarButton]){
        _rating = 1;
        
        [_OneStarButton setSelected:YES];
        [_TwoStarButton setSelected:NO];
        [_ThreeStarButton setSelected:NO];
        [_FourStarButton setSelected:NO];
        [_FiveStarButton setSelected:NO];
    } else if([sender isEqual:_TwoStarButton]){
        _rating = 2;
        
        [_OneStarButton setSelected:YES];
        [_TwoStarButton setSelected:YES];
        [_ThreeStarButton setSelected:NO];
        [_FourStarButton setSelected:NO];
        [_FiveStarButton setSelected:NO];
    } else if([sender isEqual:_ThreeStarButton]){
        _rating = 3;
        
        [_OneStarButton setSelected:YES];
        [_TwoStarButton setSelected:YES];
        [_ThreeStarButton setSelected:YES];
        [_FourStarButton setSelected:NO];
        [_FiveStarButton setSelected:NO];
    } else if([sender isEqual:_FourStarButton]){
        _rating = 4;
        
        [_OneStarButton setSelected:YES];
        [_TwoStarButton setSelected:YES];
        [_ThreeStarButton setSelected:YES];
        [_FourStarButton setSelected:YES];
        [_FiveStarButton setSelected:NO];
    } else if([sender isEqual:_FiveStarButton]){
        _rating = 5;
        
        [_OneStarButton setSelected:YES];
        [_TwoStarButton setSelected:YES];
        [_ThreeStarButton setSelected:YES];
        [_FourStarButton setSelected:YES];
        [_FiveStarButton setSelected:YES];
    }
}

@end
