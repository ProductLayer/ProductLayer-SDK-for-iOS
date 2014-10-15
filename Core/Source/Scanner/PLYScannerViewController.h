//
//  PLYScannerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 15/10/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYScannerViewController;

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
 Delegate that gets informed about scanned barcodes
 */
@property (nonatomic, weak) IBOutlet id <PLYScannerViewControllerDelegate> delegate;

/**
 @name Taking Pictures
 */

/**
 Captures a still image from the scanner view
 @param completion A block that gets called asynchronously with the captured `UIImage`
 */
- (void)captureStillImageAsynchronously:(void (^)(UIImage *image))completion;

@end
