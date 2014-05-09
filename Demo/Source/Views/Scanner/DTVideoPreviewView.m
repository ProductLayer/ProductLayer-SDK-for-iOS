//
//  DTCodeScannerPreviewView.m
//  TagScan
//
//  Created by Oliver Drobnik on 8/20/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "DTVideoPreviewView.h"

#import <AVFoundation/AVFoundation.h>

@implementation DTVideoPreviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	 {
		 self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

#pragma mark - Properties
- (AVCaptureVideoPreviewLayer *)previewLayer
{
	return (AVCaptureVideoPreviewLayer *)self.layer;
}

@end
