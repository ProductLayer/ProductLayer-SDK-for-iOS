//
//  PLYTextField.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

@class PLYFormValidator;


@interface PLYTextField : UITextField

/**
 An object that validates the text field contents after every change
 */
@property (nonatomic, strong) PLYFormValidator *validator;

@end
