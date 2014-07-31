//
//  OpineTableViewCell.h
//  PL
//
//  Created by René Swoboda on 30/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLYOpine;

@interface OpineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;


@property (nonatomic, strong) PLYOpine *opine;

@end
