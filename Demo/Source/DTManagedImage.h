//
//  DTManagedImage.h
//  PL
//
//  Created by Oliver Drobnik on 29.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DTManagedImage : NSManagedObject

/**
 A unique identifier identifying this image. For example the remote URL.
 */
@property (nonatomic, retain) NSString *uniqueIdentifier;

/**
 A unique identifier identifying a variation of this image. For example the thumbnail size.
 */
@property (nonatomic, retain) NSString *variantIdentifier;

/**
 The last time when the receiver was accessed
 */
@property (nonatomic, retain) NSDate *lastAccessDate;

/**
 The data in the file represented by the receiver
 */
@property (nonatomic, retain) NSData *fileData;

/**
 The file size in bytes of the receiver
 */
@property (nonatomic, retain) NSNumber *fileSize;


@property (nonatomic, assign) CGSize imageSize;

@end
