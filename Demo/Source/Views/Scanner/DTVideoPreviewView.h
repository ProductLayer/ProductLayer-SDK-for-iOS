//
//  DTCodeScannerPreviewView.h
//  TagScan
//
//  Created by Oliver Drobnik on 8/20/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

@class AVCaptureVideoPreviewLayer;

/**
 This wraps an `AVCaptureVideoPreviewLayer` so that it plays nicely with UIKit frame animations and auto layout.
 */

@interface DTVideoPreviewView : UIView

/**
 Accessor to the receiver's main layer
 */
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end
