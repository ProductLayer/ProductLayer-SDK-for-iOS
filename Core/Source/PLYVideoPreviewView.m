//
//  PLYVideoPreviewView.m
//  ProductLayer SDK
//
//  Created by Oliver Drobnik on 8/20/13.
//  Copyright (c) 2013 ProductLayer. All rights reserved.
//

#import "PLYVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PLYVideoPreviewView

// Designated initializer for views
- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
	
   if (self)
   {
      [self _commonSetup];
   }
	
   return self;
}

// Called when loaded from NIB file
- (void)awakeFromNib
{
   [self _commonSetup];
}

// Specifies to use the preview layer class
+ (Class)layerClass
{
	return [AVCaptureVideoPreviewLayer class];
}

// Setup to be performed when view is created in code or when loaded from NIB
- (void)_commonSetup
{
   self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
   UIViewAutoresizingFlexibleWidth;
   self.backgroundColor = [UIColor blackColor];
   
   // Default is resize aspect, we need aspect fill to avoid side bars on iPad
	[self.previewLayer
    setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

#pragma mark - Properties

// Passthrough typecast for convenient access
- (AVCaptureVideoPreviewLayer *)previewLayer
{
	return (AVCaptureVideoPreviewLayer *)self.layer;
}

@end
