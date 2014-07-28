//
//  ProductListTableViewCell.m
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "ProductListTableViewCell.h"

#import "ProductLayer.h"

@implementation ProductListTableViewCell

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

- (void) setList:(PLYList *)list{
    if([_list isEqual:list]){
        return;
    }
    
    _list = list;
    
    [self updateCell];
}

- (void) updateCell{
    _listNameLabel.text = _list.title;
    
    if(_list.listItems && [_list.listItems count] > 0){
        _productCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)_list.listItems.count];
    } else {
        _productCountLabel.text = @"0";
    }
    
    if(_list.listType){
        _listTypeLabel.text = PLYLocalizedStringFromTable(_list.listType, @"API", @"");
    }
    
    if(_list.shareType){
        _sharingTypeLabel.text = PLYLocalizedStringFromTable(_list.shareType, @"API", @"");
    }
}

@end
