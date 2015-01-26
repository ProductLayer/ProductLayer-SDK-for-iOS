//
//  PLYModalTableViewController.h
//  ProdlyApp
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A table view controller that is meant to be presented modally as it will handle a save and a cancel button
 */
@interface PLYModalTableViewController : UITableViewController


/**
 The save button, exposed read-only so that subclasses can disable it
 */
@property (nonatomic, readonly) UIBarButtonItem *saveButtonItem;


/**
 Subclasses override this method to perform the save operation. At the end of the asynchronous operation you call the completion handler and pass success `YES` if successful to dismiss the view controller or `NO` to restore the cancel and save buttons.
 @param completion The completion block you need to call when the async operation is finished. Pass `nil` if it was successful or the error object
 */
- (void)performAsyncSaveOperationWithCompletion:(void(^)(NSError *))completion;


/**
 If there is an error to be shown this is the title presented above the error message
 @returns The title to display as title for an error dialog
 */
- (NSString *)titleForErrorDialog;

@end
