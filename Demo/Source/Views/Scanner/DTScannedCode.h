//
//  DTScannedCode.h
//  TagScan
//
//  Created by Oliver Drobnik on 8/1/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

@class AVMetadataMachineReadableCodeObject;

@interface DTScannedCode : NSObject

/**
 Creates an instance of DTScannedCode of a type and code contents.
 @param type The DTScannedCodeType
 @param code The code contents
 */
- (instancetype)initWithType:(NSString *)type content:(NSString *)content;

/**
 Creates an instance of DTScannedCode based on an AV Foundation Metadata Object
 @param metadataObject The AV Foundation Metadata object to convert into a DTScannedCode
 */
+ (instancetype)scannedCodeFromMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject;

/**
 Getting Information about Codes
 */

/**
 The type of the code
 */
@property(nonatomic, readonly) NSString *type;

/**
 The content of the code
 */
@property(nonatomic, readonly) NSString *content;

@end
