//
//  ListItemTableCell.h
//  PL
//
//  Created by René Swoboda on 05/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLYListItem;
@class PLYProduct;

@interface ListItemTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *listNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;

@property (nonatomic, strong) PLYListItem* listItem;

- (PLYProduct *) getProduct;

@end
