//
//  PLYVideoPreviewView.h
//  ProductLayer SDK
//
//  Created by Oliver Drobnik on 8/20/13.
//  Copyright (c) 2013 ProductLayer. All rights reserved.
//

@class AVCaptureVideoPreviewLayer;

/**
 This wraps an `AVCaptureVideoPreviewLayer` so that it plays nicely with UIKit frame animations and auto layout.
 */
@interface PLYVideoPreviewView : UIView

/**
 Accessor to the receiver's main layer
 */
@property (readonly) AVCaptureVideoPreviewLayer *previewLayer;

@end
