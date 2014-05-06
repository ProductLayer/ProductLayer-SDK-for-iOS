//
//  ProductListTableViewCell.h
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLYList;

@interface ProductListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *listNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *productCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *listTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *sharingTypeLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionText;

@property (nonatomic, strong) PLYList *list;

@end
