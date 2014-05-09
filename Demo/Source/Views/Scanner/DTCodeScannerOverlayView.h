//
//  DTCoreScannerView.h
//  TagScan
//
//  Created by Oliver Drobnik on 7/12/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTCodeScannerOverlayView : UIView

@property (nonatomic, assign) CGRect scanRegion;

@property (nonatomic, assign) BOOL showRecognizedBox;

/**
 If set to `YES` then the scanning red scanning line transforms is morphed into a green box
 */
- (void)setShowRecognizedBox:(BOOL)showRecognizedBox animated:(BOOL)animated;

@end
