//
//  DTCodeScannerPreviewView.h
//  TagScan
//
//  Created by Oliver Drobnik on 8/21/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTVideoPreviewView;
@class DTCodeScannerOverlayView;

@interface DTCodeScannerPreviewView : UIView

/**
 The view that has the live video preview
 */
@property (nonatomic, strong) DTVideoPreviewView *videoView;

/**
 The scan target overlay on top of the videoView
 */
@property (nonatomic, strong) DTCodeScannerOverlayView *overlayView;

/**
 Adjustment for the video preview
 */
@property (nonatomic, assign) CGSize videoOffset;

@end
