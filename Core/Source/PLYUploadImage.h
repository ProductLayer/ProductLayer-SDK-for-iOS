//
//  PLYUploadImage.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 11/01/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYImage.h"

/**
 Variant of PLYImage that also contains the image data for uploading
 */
@interface PLYUploadImage : PLYImage

/**
 The NSData representation of the image to upload
 */
@property (nonatomic, copy) NSData *imageData;

@end
