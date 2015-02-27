//
//  PLYTextFieldTableViewCell.h
//  ProdlyApp
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYTextField.h"

/**
 A table view cell which can be used for input inline
 */
@interface PLYTextFieldTableViewCell : UITableViewCell

/**
 A text field
 */
@property (nonatomic, readonly) PLYTextField *textField;

@end
