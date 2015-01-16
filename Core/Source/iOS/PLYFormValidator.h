//
//  PLYFormValidator.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//


@class PLYFormValidator;

/**
 Protocol to inform delegate of a PLYFormValidator about changes in the text content validity
 */
@protocol PLYFormValidationDelegate <NSObject>

/**
 The validity of the text contents have changed
 @param validator The sender of the message
 */
- (void)validityDidChange:(PLYFormValidator *)validator;

@end


/**
 Root class of specialized validators that observe a UIControl's state and change their own isValid state based on
 */
@interface PLYFormValidator : NSObject

/**
 Convenience constructor
 @param delegate The delegate to inform about changes in validity
 */
+ (instancetype)validatorWithDelegate:(id<PLYFormValidationDelegate>)delegate;

/**
 Reference to the control this is attached to
 */
@property (nonatomic, weak) UIControl *control;

/**
 A delegate (e.g. the form) to inform when the validty state changed
 */
@property (nonatomic, weak) IBOutlet id<PLYFormValidationDelegate> delegate;


/**
 The latest validity state
 */
@property (nonatomic, assign, getter=isValid) BOOL valid;

/**
 Validates the control contents and changes the isValid state
 */
- (void)validate;

@end
