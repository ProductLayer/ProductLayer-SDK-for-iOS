//
//  KeyValueTableViewCell.m
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "KeyValueTableViewCell.h"

@implementation KeyValueTableViewCell

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

@end
