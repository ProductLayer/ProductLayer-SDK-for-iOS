//
//  DTCodeScannerPreviewView.m
//  TagScan
//
//  Created by Oliver Drobnik on 8/21/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "DTCodeScannerPreviewView.h"
#import "DTVideoPreviewView.h"
#import "DTCodeScannerOverlayView.h"

#import <AVFoundation/AVFoundation.h>

@implementation DTCodeScannerPreviewView


- (void)_setup
{
	DTVideoPreviewView *videoView = [[DTVideoPreviewView alloc] initWithFrame:self.bounds];
	self.videoView = videoView;
	[self insertSubview:videoView atIndex:0];
	
	DTCodeScannerOverlayView *overlayView = [[DTCodeScannerOverlayView alloc] initWithFrame:self.bounds];
	self.overlayView = overlayView;
	[self insertSubview:overlayView aboveSubview:videoView];
	
	// fill the entire screen, without this we get empty areas at the long sides
	[self.videoView.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
	// set to portrait mode
	if ([[self.videoView.previewLayer connection] isVideoOrientationSupported])
	{
		[[self.videoView.previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
	}

	self.clipsToBounds = YES;
	self.backgroundColor = [UIColor blackColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	 {
		 [self _setup];
    }
    return self;
}

- (void)awakeFromNib
{
	[self _setup];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// calculate factor to scale video video
	CGSize videoSize = [self _currentVideoInputSize];
	CGFloat factor = self.bounds.size.width / videoSize.width;
	
	CGRect videoFrame =  CGRectMake(_videoOffset.width, _videoOffset.height, roundf(videoSize.width * factor), roundf(videoSize.height * factor));

	if (CGRectGetMaxX(videoFrame) < CGRectGetMaxX(self.bounds))
	{
		// too far right, shift left
		videoFrame.origin.x = CGRectGetMaxX(self.bounds) - videoFrame.size.width;
	}
	else if (CGRectGetMinX(videoFrame) > 0)
	{
		// too far left, zero
		videoFrame.origin.x = 0;
	}
	
	if (CGRectGetMaxY(videoFrame) < CGRectGetMaxY(self.bounds))
	{
		// too far up, shift down
		videoFrame.origin.y = CGRectGetMaxY(self.bounds) - videoFrame.size.height;
	}
	else if (CGRectGetMinY(videoFrame) > 0)
	{
		// too far down, shift up
		videoFrame.origin.y = 0;
	}
	
	self.videoView.frame = videoFrame;
	
	[self _updateRectOfInterest];
}

#pragma mark - Helpers

- (AVCaptureDevice *)_captureDevice
{
	NSArray *inputs = [[self.videoView.previewLayer session] inputs];
	
	for (AVCaptureInput *input in inputs)
	{
		if ([input isKindOfClass:[AVCaptureDeviceInput class]])
		{
			return [(AVCaptureDeviceInput *)input device];
		}
	}
	
	// nothing found
	NSLog(@"No input device found!");
	
	return nil;
}

- (AVCaptureMetadataOutput *)_metadataOutput
{
	NSArray *outputs = [[self.videoView.previewLayer session] outputs];
	
	// find first meta data output
	for (AVCaptureOutput *output in outputs)
	{
		if ([output isKindOfClass:[AVCaptureMetadataOutput class]])
		{
			return (AVCaptureMetadataOutput *)output;
		}
	}
	
	// nothing found
	NSLog(@"No metadata output found!");

	return nil;
}

- (CGSize)_currentVideoInputSize
{
	AVCaptureDevice *device = [self _captureDevice];
	CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription);
	
	AVCaptureVideoOrientation orientation = [[self.videoView.previewLayer connection] videoOrientation];
	
	if (orientation == AVCaptureVideoOrientationPortrait || orientation == AVCaptureVideoOrientationPortraitUpsideDown)
	{
		return CGSizeMake(dimensions.height, dimensions.width);
	}
	
	return CGSizeMake(dimensions.width, dimensions.height);
}

- (void)_updateRectOfInterest
{
	_overlayView.scanRegion = self.bounds;
	
	
	CGRect translatedBox = [_videoView convertRect:_overlayView.scanRegion fromView:_overlayView];
	
	// update meta data scan rect
	CGRect metadataRect = [_videoView.previewLayer metadataOutputRectOfInterestForRect:translatedBox];
	[[self _metadataOutput] setRectOfInterest:metadataRect];
	
	// update focus point
	CGPoint scanCenter = CGPointMake(CGRectGetMidX(translatedBox), CGRectGetMidY(translatedBox));
	CGPoint focusPoint = [_videoView.previewLayer captureDevicePointOfInterestForPoint:scanCenter];
	
	// set exposure and focus point
	AVCaptureDevice *device = [self _captureDevice];
	
	NSError *error;
	if ([device lockForConfiguration:&error])
	{
		if ([device isFocusPointOfInterestSupported])
		{
			[device setFocusPointOfInterest:focusPoint];
		}
		
		if ([device isExposurePointOfInterestSupported])
		{
			[device setExposurePointOfInterest:focusPoint];
		}
		
		[device unlockForConfiguration];
	}
	else
	{
		NSLog(@"Cannot lock cam device, %@", [error localizedDescription]);
	}
}

- (CGRect)_videoFrameForOffset:(CGSize)offset
{
	// calculate factor to scale video video
	CGSize videoSize = [self _currentVideoInputSize];
	CGFloat factor = self.bounds.size.width / videoSize.width;
	
	CGRect videoFrame =  CGRectMake(offset.width, offset.height, roundf(videoSize.width * factor), roundf(videoSize.height * factor));
	
	if (CGRectGetMaxX(videoFrame) < CGRectGetMaxX(self.bounds))
	{
		// too far right, shift left
		videoFrame.origin.x = CGRectGetMaxX(self.bounds) - videoFrame.size.width;
	}
	else if (CGRectGetMinX(videoFrame) > 0)
	{
		// too far left, zero
		videoFrame.origin.x = 0;
	}
	
	if (CGRectGetMaxY(videoFrame) < CGRectGetMaxY(self.bounds))
	{
		// too far up, shift down
		videoFrame.origin.y = CGRectGetMaxY(self.bounds) - videoFrame.size.height;
	}
	else if (CGRectGetMinY(videoFrame) > 0)
	{
		// too far down, shift up
		videoFrame.origin.y = 0;
	}
	
	return videoFrame;
}

#pragma mark - Properties

- (void)setVideoOffset:(CGSize)videoOffset
{
	CGRect newFrame = [self _videoFrameForOffset:videoOffset];
	
	// limit offset to actually possible value
	CGSize newOffset = CGSizeMake(newFrame.origin.x, newFrame.origin.y);
	
	if (CGSizeEqualToSize(newOffset, _videoOffset))
	{
		return;
	}
	
	_videoOffset = newOffset;
	
	[self setNeedsLayout];
}

@end
