//
//  PLYTextField.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYFormValidator.h"

/**
 A text field that has a PLYFormValidator attached for validating contents
 */
@interface PLYTextField : UITextField

/**
 An object that validates the text field contents after every change
 */
@property (nonatomic, strong) IBOutlet PLYFormValidator *validator;

/**
 The language last used for input
 */
@property (nonatomic, readonly) NSString *usedInputLanguage;

@end
