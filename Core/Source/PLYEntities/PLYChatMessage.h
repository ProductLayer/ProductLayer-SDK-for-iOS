//
//  PLYChatMessage.h
//  ProductLayerSDK
//
//  Created by René Swoboda on 15/06/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYChatMessage : PLYEntity

/**
 The text of the message.
 */
@property (nonatomic, copy) NSString *message;

@end
