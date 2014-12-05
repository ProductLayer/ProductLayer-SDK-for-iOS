//
//  PLYTextView.h
//  PL
//
//  Created by Oliver Drobnik on 28/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

/**
 A text field that keeps track of the input language used
 */
@interface PLYTextView : UITextView

/**
 The language last used for input
 */
@property (nonatomic, readonly) NSString *usedInputLanguage;

@end
