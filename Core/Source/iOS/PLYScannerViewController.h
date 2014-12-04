//
//  PLYScannerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 15/10/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYScannerViewController;
@class PLYVideoPreviewView;
@class PLYVideoPreviewInterestBox;

/**
 Protocol for informing a delegate about events in a PLYScannerViewController
 */
@protocol PLYScannerViewControllerDelegate <NSObject>

@optional
/**
 Delegate method that gets informed about scanned GTINs
 @param scanner The scanner view controller sending the message
 @param GTIN The scanned GTIN
 */
- (void)scanner:(PLYScannerViewController *)scanner didScanGTIN:(NSString *)GTIN;

@end



/**
 Barcode Scanner optimized for scanning GTIN barcodes.
 **/
@interface PLYScannerViewController : UIViewController

/**
 @name Properties
 */

/**
 If the barcode scan function is active
*/
@property (nonatomic, assign, getter=isScannerActive) BOOL scannerActive;

/**
 The preview for the live video
 */
@property (nonatomic, readonly) PLYVideoPreviewView *videoPreview;

/**
 The scan focus box in which barcodes are recognized.
*/
@property (nonatomic, strong) IBOutlet PLYVideoPreviewInterestBox *scannerInterestBox;

/**
 Delegate that gets informed about scanned barcodes
 */
@property (nonatomic, weak) IBOutlet id <PLYScannerViewControllerDelegate> delegate;


/**
 A button for toggling the torch so that the receiver can show/hide the button based on the capability of the selected camera
 */
@property (weak, nonatomic) IBOutlet UIButton *toggleTorchButton;

/**
 @name Taking Pictures
 */

/**
 Captures a still image from the scanner view
 @param completion A block that gets called asynchronously with the captured `UIImage`
 */
- (void)captureStillImageAsynchronously:(void (^)(UIImage *image))completion;

/**
 @name Actions
 */

/**
 Action to connect to a flash light button
 @param sender The sender of the action
 */
- (IBAction)toggleTorch:(UIButton *)sender;

@end
