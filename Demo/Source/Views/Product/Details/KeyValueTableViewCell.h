//
//  KeyValueTableViewCell.h
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyValueTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *key;
@property (nonatomic, weak) IBOutlet UILabel *value;

@end
