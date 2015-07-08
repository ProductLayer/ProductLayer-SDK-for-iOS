//
//  DTOpineComposeViewController.h
//  HungryScanner
//
//  Created by Oliver Drobnik on 23/10/14.
//  Copyright (c) 2014 Product Layer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLYOpineComposeViewController, PLYOpine;


/**
 Protocol to inform the delegate of PLYOpineComposeViewController about activities
 */
@protocol PLYOpineComposeViewControllerDelegate <NSObject>

@optional

/**
 Informs the delegate that the user tapped the save button
 @param opineComposeViewController The sender of the message
 @param opine The finished opine
 */
- (void)opineComposeViewController:(PLYOpineComposeViewController *)opineComposeViewController didFinishWithOpine:(PLYOpine *)opine;

/**
 Informs the delegate that the user tapped the cancel button
 @param opineComposeViewController The sender of the message
 */
- (void)opineComposeViewControllerDidCancel:(PLYOpineComposeViewController *)opineComposeViewController;

@end


/**
 The standard view controller for composing an opine. If you set a delegate it is responsible for dismissing the composer.
 */
@interface PLYOpineComposeViewController : UIViewController

/**
 Designated initializer with opional opine to fill values with
 @param opine An opine that contains the initial values for the view controller
 */
- (instancetype)initWithOpine:(PLYOpine *)opine;


/**
 @name Properties
 */

/**
 Sets up the VC with the contents of an opine
 */
@property (nonatomic, copy) PLYOpine *opine;


/**
 The product name to write above the text view. If it is `nil` the label is not shown
 */
@property (nonatomic, copy) NSString *productName;

/**
 The delegate for the compose view controller
 */
@property (nonatomic, weak) id<PLYOpineComposeViewControllerDelegate> delegate;


@end
