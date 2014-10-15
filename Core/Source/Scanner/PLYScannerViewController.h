//
//  PLYScannerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 15/10/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYScannerViewController;

@protocol PLYScannerViewControllerDelegate <NSObject>

@optional
- (void)scanner:(PLYScannerViewController *)scanner didScanGTIN:(NSString *)GTIN;

@end



/**
 Barcode Scanner optimized for scanning GTIN barcodes.
 **/
@interface PLYScannerViewController : UIViewController

/**
 Delegate that gets informed about scanned barcodes
 */
@property (nonatomic, weak) IBOutlet id <PLYScannerViewControllerDelegate> delegate;


@end
