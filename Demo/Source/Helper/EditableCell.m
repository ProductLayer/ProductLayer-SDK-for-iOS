//
//  EditableCell.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "EditableCell.h"

@implementation EditableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (selected)
	{
        if(self.textField){
            [self.textField becomeFirstResponder];
        } else {
            [self.textView becomeFirstResponder];
        }
	} else {
        if(self.textField){
            [self.textField resignFirstResponder];
        } else {
            [self.textView resignFirstResponder];
        }
    }
}

@end
