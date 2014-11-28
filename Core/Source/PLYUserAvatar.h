//
//  PLYUserAvatar.h
//  PL
//
//  Created by Oliver Drobnik on 28/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <ProductLayer/ProductLayer.h>

@interface PLYUserAvatar : PLYImage


/**
 The user ID of the user that the receiver belongs to
 */
@property (nonatomic, copy) NSString *userID;

/**
 Nickname of the user that the receiver belongs to
 */
@property (nonatomic, copy) NSString *userNickname;

@end
