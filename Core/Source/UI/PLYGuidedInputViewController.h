//
//  PLYGuidedInputViewController.h
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYGuidedInputViewController;

@protocol PLYGuidedInputViewControllerDelegate <NSObject>

@optional
/**
 The input should be saved
 */
- (void)guidedInputViewControllerDidSave:(PLYGuidedInputViewController *)guidedInputViewController;

/**
 The input should be cancelled
 */
- (void)guidedInputViewControllerDidCancel:(PLYGuidedInputViewController *)guidedInputViewController;

@end


@interface PLYGuidedInputViewController : UIViewController

/**
 The label text of the receiver
 */
@property (nonatomic, copy) NSString *label;

/**
 The entered text of the receiver
 */
@property (nonatomic, copy) NSString *text;

/**
 The placeholder text of the receiver
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 the language last used if text was entered
 */
@property (nonatomic, copy) NSString *language;

/**
 The delegate of the receiver to be informed of the result
 */
@property (nonatomic, weak) id <PLYGuidedInputViewControllerDelegate> delegate;

@end
