//
//  PLYScannerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 15/10/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYScannerViewController.h"
#import "PLYVideoPreviewView.h"
#import "PLYVideoPreviewInterestBox.h"
#import "PLYAVFoundationFunctions.h"
#import "PLYFunctions.h"

#import <DTFoundation/DTLog.h>


#import <AVFoundation/AVFoundation.h>


@interface PLYScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIButton *switchCamButton;

@end

@implementation PLYScannerViewController
{
	AVCaptureDevice *_camera;
	AVCaptureDeviceInput *_videoInput;
	AVCaptureStillImageOutput *_imageOutput;
	AVCaptureSession *_captureSession;
	PLYVideoPreviewView *_videoPreview;
	PLYVideoPreviewInterestBox *_scannerInterestBox;
	
	AVCaptureMetadataOutput *_metaDataOutput;
	dispatch_queue_t _metaDataQueue;
	
	NSMutableSet *_visibleCodes;
	NSMutableDictionary *_visibleShapes;
	
	BOOL _isDisappearing;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Internal Methods

- (void)_informUserAboutCamNotAuthorized
{
	NSString *msg = @"Access to the camera hardware has been disabled. "\
	@"This disables all related functionality in this app. "\
	@"Please enable it via device settings.";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cam Access"
																	message:msg
																  delegate:nil
													  cancelButtonTitle:@"Ok"
													  otherButtonTitles:nil];
	[alert show];
}

- (void)_informUserAboutNoCam
{
	NSString *msg = @"The current device does not have any cameras "\
	@"installed, are you running this in iOS Simulator?";
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cam Access"
																	message:msg
																  delegate:nil
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:nil];
	[alert show];
}

- (void)_setupMetadataOutput
{
	// Create a new metadata output
	_metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
	
	// GCD queue on which delegate method is called
	_metaDataQueue = dispatch_get_main_queue();
	
	// Set self as delegate, using the specified GCD queue
	[_metaDataOutput setMetadataObjectsDelegate:self
													  queue:_metaDataQueue];
	
	// Connect metadata output only if possible
	if (![_captureSession canAddOutput:_metaDataOutput]) {
		DTLogError(@"Unable to add metadata output to capture session");
		return;
	}
	
	// Connect metadata output to capture session
	[_captureSession addOutput:_metaDataOutput];
	
	// Specify to scan for supported 2D barcode types
	NSArray *barcodes2D = @[AVMetadataObjectTypeEAN13Code,
									AVMetadataObjectTypeEAN8Code,
									AVMetadataObjectTypeITF14Code,
									AVMetadataObjectTypeUPCECode,
                           AVMetadataObjectTypeCode128Code];
	NSArray *availableTypes = [_metaDataOutput
										availableMetadataObjectTypes];
	
	if (![availableTypes count]) {
		DTLogError(@"Unable to get any available metadata types, "\
				@"did you forget the addOutput: on the capture session?");
		return;
	}
	
	// Extra defensive: only adds supported types, log unsupported
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	for (NSString *oneCodeType in barcodes2D) {
		if ([availableTypes containsObject:oneCodeType]) {
			[tmpArray addObject:oneCodeType];
		}
		else {
			DTLogError(@"Weird: Code type '%@' is not reported as supported "\
					@"on this device", oneCodeType);
		}
	}
	
	if ([tmpArray count]) {
		_metaDataOutput.metadataObjectTypes = tmpArray;
	}
	
	// default is to have the scanner be active
	self.scannerActive = YES;
}

- (void)_setupCamera
{
	// get the camera
	_camera = [AVCaptureDevice
				  defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	if (!_camera)
	{
		[self _informUserAboutNoCam];
		
		return;
	}
	
	// connect camera to input
	NSError *error;
	_videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_camera
																		  error:&error];
	
	if (!_videoInput)
	{
		DTLogError(@"Error connecting video input: %@",
				[error localizedDescription]);
		return;
	}
	
	// Create session (use default AVCaptureSessionPresetHigh)
	_captureSession = [[AVCaptureSession alloc] init];
	
	if (![_captureSession canAddInput:_videoInput])
	{
		DTLogError(@"Unable to add video input to capture session");
		return;
	}
	
	[_captureSession addInput:_videoInput];
	
	// configure cam here because active format depends on capture session
	[self _configureCurrentCamera];
	
	// add still image output
	_imageOutput = [AVCaptureStillImageOutput new];
	
	// get highest res images for still images
	if ([_imageOutput respondsToSelector:@selector(isHighResolutionStillImageOutputEnabled)])
	{
		_imageOutput.highResolutionStillImageOutputEnabled = YES;
	}
	
	if (![_captureSession canAddOutput:_imageOutput])
	{
		DTLogError(@"Unable to add still image output to capture session");
		return;
	}
	
	[_captureSession addOutput:_imageOutput];
	
	// set the session to be previewed
	_videoPreview.previewLayer.session = _captureSession;
	
	// setup the barcode scanner output
	[self _setupMetadataOutput];
}

- (void)_setupCameraAfterCheckingAuthorization
{
	if (![[AVCaptureDevice class] respondsToSelector:
			@selector(authorizationStatusForMediaType:)])
	{
		// running on iOS 6, assume authorization
		[self _setupCamera];
		
		return;
	}
	
	AVAuthorizationStatus authStatus =
	[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	
	switch (authStatus)
	{
		case AVAuthorizationStatusAuthorized:
		{
			[self _setupCamera];
			
			break;
		}
			
		case AVAuthorizationStatusNotDetermined:
		{
			[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
											 completionHandler:^(BOOL granted) {
												 
												 // background thread, we want to setup on main thread
												 dispatch_async(dispatch_get_main_queue(), ^{
													 
													 if (granted)
													 {
														 [self _setupCamera];
														 
														 // need to do more setup because View Controller is already present
														 [self _setupCamSwitchButton];
														 [self _setupTorchToggleButton];
														 
														 // need to start capture session
														 [_captureSession startRunning];
														 [self _updateMetadataRectOfInterest];
													 }
													 else
													 {
														 [self _informUserAboutCamNotAuthorized];
													 }
												 });
											 }];
			
			break;
		}
			
		case AVAuthorizationStatusRestricted:
		case AVAuthorizationStatusDenied:
		{
			[self _informUserAboutCamNotAuthorized];
			
			break;
		}
	}
}

// Applies settings to the currently active camera
- (void)_configureCurrentCamera
{
	NSError *error;
	if (![_camera lockForConfiguration:&error])
	{
		DTLogError(@"Unable to lock current camera for config: %@",
				[error localizedDescription]);
		return;
	}
	
	// Get notified if subject area changes, for disabling focus lock
	_camera.subjectAreaChangeMonitoringEnabled = YES;
	
/*
	// Prevent focus bobbing
	if ([_camera isSmoothAutoFocusSupported])
	{
		_camera.smoothAutoFocusEnabled = YES;
	}
	
	// Optimal for scanning close-by barcodes
	if ([_camera isAutoFocusRangeRestrictionSupported])
	{
		_camera.autoFocusRangeRestriction =
		AVCaptureAutoFocusRangeRestrictionNear;
	}
	
	// Get more pixels to image outputs
	_camera.videoZoomFactor =
	MIN(_camera.activeFormat.videoZoomFactorUpscaleThreshold,
		 1.25);
 */
	
	// Activate low light boost if necessary
	if ([_camera isLowLightBoostSupported])
	{
		_camera.automaticallyEnablesLowLightBoostWhenAvailable = YES;
	}
	
	[_camera unlockForConfiguration];
}

// checks if there is an alternative camera to the current one
- (AVCaptureDevice *)_alternativeCamToCurrent
{
	if (!_camera)
	{
		// no current camera
		return nil;
	}
	
	NSArray *allCams = [AVCaptureDevice
							  devicesWithMediaType:AVMediaTypeVideo];
	
	for (AVCaptureDevice *oneCam in allCams)
	{
		if (oneCam != _camera)
		{
			// found an alternative!
			return oneCam;
		}
	}
	
	// no alternative cameras present
	return nil;
}

- (AVCaptureConnection *)_captureConnection
{
	for (AVCaptureConnection *connection in _imageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([port.mediaType isEqual:AVMediaTypeVideo] )
			{
				return connection;
			}
		}
	}
	
	// no connection found
	return nil;
}

// update all capture connections for the current interface orientation
- (void)_updateConnectionsForInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
	AVCaptureVideoOrientation captureOrientation =
	PLYAVCaptureVideoOrientationForUIInterfaceOrientation
	(interfaceOrientation);
	
	for (AVCaptureConnection *connection in _imageOutput.connections)
	{
		if ([connection isVideoOrientationSupported])
		{
			connection.videoOrientation = captureOrientation;
		}
	}
	
	AVCaptureConnection *con = _videoPreview.previewLayer.connection;
	
	if ([con isVideoOrientationSupported])
	{
		con.videoOrientation = captureOrientation;
	}
}

// updates the rect of interest for barcode scanning for the current interest box frame
- (void)_updateMetadataRectOfInterest
{
	// NOTE: disabled because it causes a performance hit on rotation,
	//       instead we are checking reported metadata objects bounds

	/*
	// force layout if interest box, might be delayed because of constraints
	[_scannerInterestBox layoutIfNeeded];
	
	if (!_captureSession.isRunning)
	{
		return;
	}
	
	// only set interest box, if there is a marked area
	if (_scannerInterestBox.superview == _videoPreview)
	{
		CGRect rectOfInterest = [_videoPreview.previewLayer metadataOutputRectOfInterestForRect:_scannerInterestBox.frame];
		[self _updateMetadataRectOfInterestIfChanged:rectOfInterest];
	}
	else
	{
		// no interest box defined
		[self _updateMetadataRectOfInterestIfChanged:CGRectMake(0, 0, 1, 1)];
	}
	 */
}

// configures cam switch button
- (void)_setupCamSwitchButton
{
	AVCaptureDevice *alternativeCam = [self _alternativeCamToCurrent];
	
	if (alternativeCam)
	{
		self.switchCamButton.hidden = NO;
		
		NSString *title;
		
		switch (alternativeCam.position)
		{
			case AVCaptureDevicePositionBack:
			{
				title = @"Back";
				break;
			}
				
			case AVCaptureDevicePositionFront:
			{
				title = @"Front";
				break;
			}
				
			case AVCaptureDevicePositionUnspecified:
			{
				title = @"Other";
				break;
			}
		}
		
		[self.switchCamButton setTitle:title
									 forState:UIControlStateNormal];
	}
	else
	{
		self.switchCamButton.hidden = YES;
	}
}

// configure torch button for current cam
- (void)_setupTorchToggleButton
{
	if ([_camera hasTorch])
	{
		self.toggleTorchButton.hidden = NO;
	}
	else
	{
		self.toggleTorchButton.hidden = YES;
	}
}

- (void)_updateMetadataRectOfInterestIfChanged:(CGRect)rectOfInterest
{
	if (!CGRectEqualToRect(rectOfInterest, _metaDataOutput.rectOfInterest))
	{
		_metaDataOutput.rectOfInterest = rectOfInterest;
	}
}

- (void)_setupInterestBox
{
	_scannerInterestBox = [[PLYVideoPreviewInterestBox alloc] initWithFrame:CGRectZero];
	[_videoPreview addSubview:_scannerInterestBox];
	
	// subview's left is x points from superview's left
	NSMutableArray *tmpArray = [NSMutableArray array];
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_videoPreview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
	constraint.priority = UILayoutPriorityDefaultLow;
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_videoPreview attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
	constraint.priority = UILayoutPriorityDefaultLow;
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox
															attribute:NSLayoutAttributeTop
															relatedBy:NSLayoutRelationEqual
																toItem:self.topLayoutGuide
															attribute:NSLayoutAttributeBottom
														  multiplier:1.0
															 constant:30.0];
	constraint.priority = UILayoutPriorityDefaultLow;
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_videoPreview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-30];
	constraint.priority = UILayoutPriorityDefaultLow;
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_videoPreview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
	constraint.priority = UILayoutPriorityDefaultLow;
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_videoPreview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
	[tmpArray addObject:constraint];
	
	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:_scannerInterestBox attribute:NSLayoutAttributeHeight multiplier:2.0 constant:0];
	[tmpArray addObject:constraint];

	constraint = [NSLayoutConstraint constraintWithItem:_scannerInterestBox attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:500];
	[tmpArray addObject:constraint];

	_scannerInterestBox.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:tmpArray];
}

- (void)_removeAllMarkedCodes
{
	for (NSString *oneCode in _visibleCodes)
	{
		CAShapeLayer *shape = _visibleShapes[oneCode];
		
		[shape removeFromSuperlayer];
		[_visibleShapes removeObjectForKey:oneCode];
	}
}

- (CGRect)_activeScanRectOfInterest
{
	if (_scannerInterestBox)
	{
		return [_videoPreview.previewLayer metadataOutputRectOfInterestForRect:_scannerInterestBox.frame];
	}
	
	return CGRectMake(0, 0, 1, 1);
}

#pragma mark - Public Methods

- (void)captureStillImageAsynchronously:(void (^)(UIImage *image))completion
{
	NSParameterAssert(completion);
	
	if (!_camera)
	{
		return;
	}
	
	// find correct connection
	AVCaptureConnection *videoConnection = [self _captureConnection];
	
	if (!videoConnection)
	{
		DTLogError(@"Error: No Video connection found on still image output");
		return;
	}
	
	[_imageOutput
	 captureStillImageAsynchronouslyFromConnection:videoConnection
	 completionHandler:^(CMSampleBufferRef imageSampleBuffer,
								NSError *error) {
		 
		 if (error)
		 {
			 DTLogError(@"Error capturing still image: %@",
					 [error localizedDescription]);
			 return;
		 }
		 
		 NSData *imageData = [AVCaptureStillImageOutput
									 jpegStillImageNSDataRepresentation:
									 imageSampleBuffer];
		 UIImage *image = [UIImage imageWithData:imageData];
		 
		 completion(image);
	 }];
}


#pragma mark - View Appearance

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_videoPreview = (PLYVideoPreviewView *)self.view;
	
	if (![_videoPreview isKindOfClass:[PLYVideoPreviewView class]])
	{
		// need to add on on top of root view
		_videoPreview = [[PLYVideoPreviewView alloc] initWithFrame:self.view.bounds];
		_videoPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view insertSubview:_videoPreview atIndex:0];
	}
	
	if (!_scannerInterestBox)
	{
		[self _setupInterestBox];
	}
	
	[self _setupCameraAfterCheckingAuthorization];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
											 initWithTarget:self
											 action:@selector(handleTap:)];
	[self.view addGestureRecognizer:tap];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	[center addObserver:self
				  selector:@selector(subjectChanged:)
						name:AVCaptureDeviceSubjectAreaDidChangeNotification
					 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// need to update capture and preview connections
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self _updateConnectionsForInterfaceOrientation:orientation];
	
	// start session so that we don't see a black rectangle, but video
	[_captureSession startRunning];
	
	[self _setupCamSwitchButton];
	[self _setupTorchToggleButton];
	
	_visibleCodes = [NSMutableSet new];
	_visibleShapes = [NSMutableDictionary new];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[_captureSession stopRunning];
	_isDisappearing = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	_isDisappearing = YES;
	
	// otherwise a code might get stuck
	[self _removeAllMarkedCodes];
	
	// unlock focus
	[self subjectChanged:nil];
}

- (BOOL)shouldAutorotate
{
	AVCaptureConnection *conn = _videoPreview.previewLayer.connection;
	if ([conn isVideoOrientationSupported])
	{
		return YES;
	}
	
	// prevent UI autorotation to avoid confusing the preview layer
	return NO;
}

#pragma mark - Interface Rotation

// for demonstration all orientations are supported
- (PLY_SUPPORTED_INTERFACE_ORIENTATIONS_RETURN_TYPE)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toO
										  duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toO duration:duration];
	
	// need to update capture and preview connections
	[self _updateConnectionsForInterfaceOrientation:toO];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];

	[self _updateMetadataRectOfInterest];
	
	// using size classes does not send the willRotate... any more, so we need to updated here
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self _updateConnectionsForInterfaceOrientation:orientation];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
		 fromConnection:(AVCaptureConnection *)connection
{
	// ignore metadata events if VC is being dismissed
	if (_isDisappearing || !self.isScannerActive)
	{
		return;
	}
   
	// set to take on codes that this pass of the method is reporting
	NSMutableSet *reportedCodes = [NSMutableSet set];
	
	// dictionary to count the number of occurences of a type+stringValue
	NSMutableDictionary *repCount = [NSMutableDictionary dictionary];

	// get current rect of interest
	CGRect rectOfInterest = [self _activeScanRectOfInterest];
	
	for (AVMetadataMachineReadableCodeObject *object in metadataObjects)
	{
		CGRect intersection = CGRectIntersection(object.bounds, rectOfInterest);
		if (intersection.size.width < object.bounds.size.width ||
			 intersection.size.height < object.bounds.size.height)
		{
			// ignore metadata objects outside of scanner box
			continue;
		}
		
		if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]] && object.stringValue)
		{
			NSString *code = [NSString stringWithFormat:@"%@:%@",
									object.type, object.stringValue];
			
			// get the number of times this code was reported before in this loop
			NSUInteger occurencesOfCode = [repCount[code]
													 unsignedIntegerValue] + 1;
			repCount[code] = @(occurencesOfCode);
			NSString *numberedCode = [code stringByAppendingFormat:@"-%lu",
											  (unsigned long)occurencesOfCode];
			
			// if it was not previously visible it is new
			if (![_visibleCodes containsObject:numberedCode])
			{
				DTLogDebug(@"code appeared: %@", numberedCode);
            
            NSString *code = object.stringValue;
            
            // simplistic recognition of GTIN encoded in GS1-128
            if ([object.type isEqualToString:AVMetadataObjectTypeCode128Code])
            {
               if ([code length]>=16 && ([code hasPrefix:@"01"] || [code hasPrefix:@"02"]))
               {
						if (!PLYIsValidGTIN(code))
						{
							// ignore the prefix
							code = [code substringWithRange:NSMakeRange(3, 13)];
						}
						
						if (!PLYIsValidGTIN(code))
						{
							// continue, invalid contents
							continue;
						}
               }
               else
               {
                  // ignore this Code 128
                  continue;
               }
            }
				else if ([object.type isEqualToString:AVMetadataObjectTypeUPCECode])
				{
					// expand to full UPC-A
					code = PLYUPCAFromUPCE(code);
				}
					
            if ([_delegate respondsToSelector:
                 @selector(scanner:didScanGTIN:)])
            {
               [_delegate scanner:self didScanGTIN:code];
            }
			}
			
			[reportedCodes addObject:numberedCode];
			
			// create a suitable CGPath for the barcode area
			CGPathRef path = PLYAVMetadataMachineReadableCodeObjectCreatePathForCorners(_videoPreview.previewLayer, object);
			
			// get previous shape for this code
			CAShapeLayer *shapeLayer = _visibleShapes[numberedCode];
			
			// if none found then this is a new shape
			if (!shapeLayer)
			{
				shapeLayer = [CAShapeLayer layer];
				
				// basic configuration, stays the same regardless of path
				shapeLayer.strokeColor = [UIColor greenColor].CGColor;
				shapeLayer.fillColor = [UIColor colorWithRed:0
																	green:1
																	 blue:0
																	alpha:0.25].CGColor;
				shapeLayer.lineWidth = 2;
				
				[_videoPreview.layer addSublayer:shapeLayer];
				
				// add it to shape dictionary
				_visibleShapes[numberedCode] = shapeLayer;
			}
			
			// configure shape, relative to video preview
			shapeLayer.frame = _videoPreview.bounds;
			shapeLayer.path = path;
			
			// need to release the path now
			CGPathRelease(path);
		}
		else if ([object isKindOfClass:
					 [AVMetadataFaceObject class]])
		{
			DTLogError(@"Face detection marking not implemented");
		}
	}
	
	// check which codes which we saw in previous cycle are no longer present
	for (NSString *oneCode in _visibleCodes)
	{
		if (![reportedCodes containsObject:oneCode])
		{
			DTLogDebug(@"code disappeared: %@", oneCode);
			
			CAShapeLayer *shape = _visibleShapes[oneCode];
			
			[shape removeFromSuperlayer];
			[_visibleShapes removeObjectForKey:oneCode];
		}
	}
	
	_visibleCodes = reportedCodes;
}

#pragma mark - Properties

- (void)setScannerActive:(BOOL)scannerActive
{
	if (_scannerActive != scannerActive)
	{
		_scannerActive = scannerActive;
		
		// always remove all scan shapes
		for (NSString *oneCode in _visibleCodes)
		{
			CAShapeLayer *shape = _visibleShapes[oneCode];
			
			[shape removeFromSuperlayer];
			[_visibleShapes removeObjectForKey:oneCode];
		}
	}
}


#pragma mark - Actions

- (IBAction)switchCam:(UIButton *)sender
{
	[_captureSession beginConfiguration];
	
	_camera = [self _alternativeCamToCurrent];
	
	// remove all old inputs
	for (AVCaptureDeviceInput *input in _captureSession.inputs)
	{
		[_captureSession removeInput:input];
	}
	
	// add new input
	_videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_camera
																		 error:nil];
	[_captureSession addInput:_videoInput];
	
	// there are new connections, tell them about current UI orientation
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	[self _updateConnectionsForInterfaceOrientation:orientation];
	
	[_captureSession commitConfiguration];
	
	[self _updateMetadataRectOfInterest];
	
	// configure camera after session changes
	[self _configureCurrentCamera];
	
	// update the buttons
	[self _setupCamSwitchButton];
	[self _setupTorchToggleButton];
}

- (IBAction)toggleTorch:(UIButton *)sender
{
	if ([_camera hasTorch])
	{
		BOOL torchActive = [_camera isTorchActive];
		
		// need to lock, without this there is an exception
		if ([_camera lockForConfiguration:nil])
		{
			if (torchActive)
			{
				if ([_camera isTorchModeSupported:AVCaptureTorchModeOff])
				{
					[_camera setTorchMode:AVCaptureTorchModeOff];
				}
			}
			else
			{
				if ([_camera isTorchModeSupported:AVCaptureTorchModeOn])
				{
					[_camera setTorchMode:AVCaptureTorchModeOn];
				}
			}
			
			[_camera unlockForConfiguration];
		}
	}
}

- (void)handleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateRecognized)
	{
		// require both focus point and autofocus
		if (![_camera isFocusPointOfInterestSupported] ||
			 ![_camera isFocusModeSupported:AVCaptureFocusModeAutoFocus])
		{
			DTLogInfo(@"Focus Point Not Supported by current camera");
			
			return;
		}
		
		CGPoint loc = [gesture locationInView:_videoPreview];
		CGPoint locInCapture = [_videoPreview.previewLayer
										captureDevicePointOfInterestForPoint:loc];
		
		if ([_camera lockForConfiguration:nil])
		{
			// this alone does not trigger focussing
			[_camera setFocusPointOfInterest:locInCapture];
			
			// this focusses once and then changes to locked
			[_camera setFocusMode:AVCaptureFocusModeAutoFocus];
			
			DTLogInfo(@"Focus Mode: Locked to Focus Point");
			
			[_camera unlockForConfiguration];
		}
	}
}

#pragma mark - Notifications

- (void)subjectChanged:(NSNotification *)notification
{
	// switch back to continuous auto focus mode
	if (_camera.focusMode == AVCaptureFocusModeLocked)
	{
		if ([_camera lockForConfiguration:nil])
		{
			// restore default focus point
			if ([_camera isFocusPointOfInterestSupported])
			{
				_camera.focusPointOfInterest = CGPointMake(0.5, 0.5);
			}
			
			if ([_camera isFocusModeSupported:
				  AVCaptureFocusModeContinuousAutoFocus])
			{
				[_camera
				 setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			}
			
			DTLogInfo(@"Focus Mode: Continuous");
		}
	}
}

@end
