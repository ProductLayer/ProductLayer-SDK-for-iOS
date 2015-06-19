//
//  PLYChatGroup.h
//  ProductLayerSDK
//
//  Created by René Swoboda on 15/06/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYChatGroup : PLYEntity

/**
 The title of the chat group.
 */
@property (nonatomic, copy) NSString *title;

/**
 The members of the chat group.
 */
@property (nonatomic, copy) NSArray *members;

@end
