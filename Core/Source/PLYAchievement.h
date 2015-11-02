//
//  PLYAchievement.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 02/11/15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

/**
 An achievement that has been awarded to a user
 */
@interface PLYAchievement : PLYEntity

/**
 Short name of the awarded achievement
 */
@property (nonatomic, copy) NSString *awardName;

/**
 Description of the awarded achievement
 */
@property (nonatomic, copy) NSString *awardDescription;

/**
 Type of the awarded achievement
 */
@property (nonatomic, copy) NSString *awardType;

/**
 URL for the image representing the award badge
 */
@property (nonatomic, copy) NSURL *imageURL;

/**
 Internal key identifying the achievement
 */
@property (nonatomic, copy) NSString *key;

@end
