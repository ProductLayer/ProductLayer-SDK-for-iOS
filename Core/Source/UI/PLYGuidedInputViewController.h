//
//  PLYGuidedInputViewController.h
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@interface PLYGuidedInputViewController : UIViewController

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;

// the language last used if text was entered
@property (nonatomic, copy) NSString *language;

@end
