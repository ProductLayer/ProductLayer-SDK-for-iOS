//
//  PLYGuidedInputViewController.h
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYGuidedInputViewController;

/**
 Protocol for delegates of PLYGuidedInputViewController
 */
@protocol PLYGuidedInputViewControllerDelegate <NSObject>

@optional
/**
 The input should be saved
 @param guidedInputViewController The sender of the message
 */
- (void)guidedInputViewControllerDidSave:(PLYGuidedInputViewController *)guidedInputViewController;

/**
 The input should be cancelled
 @param guidedInputViewController The sender of the message
 */
- (void)guidedInputViewControllerDidCancel:(PLYGuidedInputViewController *)guidedInputViewController;

@end

/**
 View controller for allowing guided text input
 */
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
