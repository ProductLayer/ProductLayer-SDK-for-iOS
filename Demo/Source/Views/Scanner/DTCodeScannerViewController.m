//
//  DTCodeScannerViewController.m
//  TagScan
//
//  Created by Oliver Drobnik on 7/12/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "DTCodeScannerViewController.h"
#import "DTCodeScannerOverlayView.h"
#import "DTScannedCode.h"
#import "DTVideoPreviewView.h"
#import "DTCodeScannerPreviewView.h"
#import "DTLog.h"


#import <AVFoundation/AVFoundation.h>

@interface DTCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation DTCodeScannerViewController
{
	AVCaptureSession *_captureSession;
	AVCaptureDeviceInput *_videoInput;
	AVCaptureMetadataOutput *_metaDataOutput;
	
	// captured codes
	NSMutableSet *_visibleCodes;
	NSMutableArray *_visibleShapes;
}


- (void)dealloc
{
	[_camera removeObserver:self forKeyPath:@"adjustingFocus"];
	[_camera removeObserver:self forKeyPath:@"adjustingExposure"];
	[_camera removeObserver:self forKeyPath:@"adjustingWhiteBalance"];
}

- (void)loadView
{
	[super loadView];
	
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
	[self.view addGestureRecognizer:pan];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_visibleCodes = [NSMutableSet set];
	
	// get the camera
	_camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error;
	if ([_camera lockForConfiguration:&error])
	{
		// Autofocus: Continuous
		if ([_camera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
		{
			[_camera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
		}

		// Autofocus: Restricted to Near
		if ([_camera isAutoFocusRangeRestrictionSupported])
		{
			_camera.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
		}
		
		// Exposure: Continuous
		if ([_camera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
		{
			_camera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
		}
		
		// White Balance: Continuous
		if ([_camera isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
		{
			_camera.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
		}
		
		if ([_camera isTorchModeSupported:AVCaptureTorchModeAuto])
		{
			_camera.torchMode = AVCaptureTorchModeAuto;
		}

		[_camera unlockForConfiguration];
	}
	else
	{
		DTLogError(@"Cannot lock cam device, %@", [error localizedDescription]);
	}
	
	// observe indicators
	[_camera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:NULL];
	[_camera addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:NULL];
	[_camera addObserver:self forKeyPath:@"adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:NULL];

	// connect camera to input
	_videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_camera error:&error];
	
	// Create session (use default AVCaptureSessionPresetHigh)
	_captureSession = [[AVCaptureSession alloc] init];
	
	//_captureSession.sessionPreset = AVCaptureSessionPreset640x480;
	if ([_captureSession canAddInput:_videoInput])
	{
		[_captureSession addInput:_videoInput];
	}
	
	self.codeScannerPreviewView.videoView.previewLayer.session = _captureSession;
	
	_metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
	
	if ([_captureSession canAddOutput:_metaDataOutput])
	{
		[_captureSession addOutput:_metaDataOutput];
	}
	
	dispatch_queue_t metadataQueue = dispatch_queue_create("com.cocoanetics.metadata", NULL);
	[_metaDataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
	
	_metaDataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code ];
	
	_visibleShapes = [NSMutableArray array];
	
	[self.codeScannerPreviewView setVideoOffset:CGSizeMake(0, -300)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[_captureSession startRunning];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_captureSession stopRunning];

	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)_updateIndicators
{
	UIColor *activeColor = self.view.window.tintColor;
	UIColor *inactiveColor = [UIColor grayColor];
	
	if ([_camera isAdjustingExposure])
	{
		[_exposureButton setTintColor:activeColor];
	}
	else
	{
		[_exposureButton setTintColor:inactiveColor];
	}
	
	if ([_camera isAdjustingFocus])
	{
		[_focusButton setTintColor:activeColor];
	}
	else
	{
		[_focusButton setTintColor:inactiveColor];
	}
	
	if ([_camera isAdjustingWhiteBalance])
	{
		[_whiteBalanceButton setTintColor:activeColor];
	}
	else
	{
		[_whiteBalanceButton setTintColor:inactiveColor];
	}
}

- (BOOL)shouldAutorotate
{
	return NO;
}

#pragma mark - Actions

- (void)_handlePan:(UIPanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint distance = [gesture translationInView:self.view];

		CGSize offset = self.codeScannerPreviewView.videoOffset;
		
		offset.height += distance.y;
		
		self.codeScannerPreviewView.videoOffset = offset;
		
		[gesture setTranslation:CGPointZero inView:self.view];
	}
}

- (void)toggleTorch
{
	if ([_camera hasTorch])
	{
		NSError *error;
		if ([_camera lockForConfiguration:&error])
		{
			if ([_camera isTorchActive])
			{
				[_camera setTorchMode:AVCaptureTorchModeOff];
			}
			else
			{
				[_camera setTorchModeOnWithLevel:0.5 error:&error];
			}
			
			[_camera unlockForConfiguration];
		}
		else
		{
			DTLogError(@"Cannot lock camera for configuration: %@", [error localizedDescription]);
		}
	}
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self _updateIndicators];
}

#pragma mark Barcodes

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
	dispatch_sync(dispatch_get_main_queue(), ^{
		
	NSMutableArray *reportedCodes = [NSMutableArray array];
	
	for (CAShapeLayer *shapeLayer in _visibleShapes)
	{
		[shapeLayer removeFromSuperlayer];
	}
	
	[_visibleShapes removeAllObjects];
	
	for (AVMetadataMachineReadableCodeObject *object in metadataObjects)
	{
		if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
		{
			DTScannedCode *scannedCode = [DTScannedCode scannedCodeFromMetadataObject:object];
			[reportedCodes addObject:scannedCode];
		}
	}
	
	BOOL codeDidAppear = NO;
	
	for (DTScannedCode *oneCode in _visibleCodes)
	{
		if (![reportedCodes containsObject:oneCode])
		{
			DTLogDebug(@"code disappeared: %@", oneCode);
			[_visibleCodes removeObject:oneCode];
		}
	}
	
	for (DTScannedCode *oneCode in reportedCodes)
	{
		if (![_visibleCodes containsObject:oneCode])
		{
			[_visibleCodes addObject:oneCode];
			DTLogDebug(@"code appeared: %@", oneCode);
			
			if ([_scanDelegate respondsToSelector:@selector(codeScanner:didScanCode:)])
			{
				[_scanDelegate codeScanner:self didScanCode:oneCode];
			}
			
			codeDidAppear = YES;
		}
	}
	
	if (codeDidAppear)
	{
		AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	}
	});
	
	dispatch_async(dispatch_get_main_queue(), ^{
		BOOL currentlySeeingCodes = ([_visibleCodes count]>0);
		
		[self.codeScannerPreviewView.overlayView setShowRecognizedBox:currentlySeeingCodes animated:YES];
	});
}

@end
