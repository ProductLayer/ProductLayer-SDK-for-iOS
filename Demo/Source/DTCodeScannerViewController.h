//
//  DTCodeScannerViewController.h
//  TagScan
//
//  Created by Oliver Drobnik on 7/12/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCodeScannerViewController, DTScannedCode;
@class DTCodeScannerPreviewView;
@class AVCaptureDevice;

@protocol DTCodeScannerViewControllerDelegate <NSObject>

- (void)codeScanner:(DTCodeScannerViewController *)codeScanner didScanCode:(DTScannedCode *)code;

@end


@interface DTCodeScannerViewController : UIViewController
{
	AVCaptureDevice *_camera;
}

@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UIButton *whiteBalanceButton;
@property (weak, nonatomic) IBOutlet UIButton *exposureButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;

@property (nonatomic, weak) IBOutlet id <DTCodeScannerViewControllerDelegate> scanDelegate;

@property (nonatomic, weak) IBOutlet DTCodeScannerPreviewView *codeScannerPreviewView;

- (void)toggleTorch;

@end
