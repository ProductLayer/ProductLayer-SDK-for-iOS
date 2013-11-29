//
//  DTImageCache.h
//  PL
//
//  Created by Oliver Drobnik on 29.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTImageCache : NSObject

+ (DTImageCache *)sharedCache;

- (void)addImage:(UIImage *)image forUniqueIdentifier:(NSString *)uniqueIdentifier variantIdentifier:(NSString *)variantIdentifier;

- (UIImage *)imageForUniqueIdentifier:(NSString *)uniqueIdentifier variantIdentifier:(NSString *)variantIdentifier;

@end
