//
//  PLYAVFoundationFunctions.h
//  ProductLayer SDK
//
//  Created by Oliver Drobnik on 11/12/13.
//  Copyright (c) 2013 ProductLayer. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// helper function to convert interface orienation to correct video capture orientation
AVCaptureVideoOrientation
   PLYAVCaptureVideoOrientationForUIInterfaceOrientation(
                           UIInterfaceOrientation interfaceOrientation);

// creates a CGPath for the cornder of a barcode object
CGPathRef PLYAVMetadataMachineReadableCodeObjectCreatePathForCorners(
                               AVCaptureVideoPreviewLayer *previewLayer,
                    AVMetadataMachineReadableCodeObject *barcodeObject);
