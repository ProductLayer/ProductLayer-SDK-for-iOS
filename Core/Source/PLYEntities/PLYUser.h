//
//  PLYUser.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;

/**
 Model class representing a ProductLayer user
 */
@interface PLYUser : PLYEntity

/**
 The nickname of the user.
 */
@property (nonatomic, copy) NSString *nickname;

/**
 The first name of the user.
 */
@property (nonatomic, copy) NSString *firstName;

/**
 The last name of the user.
 */
@property (nonatomic, copy) NSString *lastName;

/**
 The email of the user.
 */
@property (nonatomic, copy) NSString *email;

/**
 The birthday of the user.
 */
@property (nonatomic, strong) NSDate *birthday;

/**
 The gender of the user.
 */
@property (nonatomic, copy) NSString *gender;

/**
 The gamification points of the user.
 */
@property (nonatomic, readonly) NSInteger points;

/**
 A list of unlocked achievements.
 */
@property (nonatomic, readonly) NSArray *unlockedAchievements;

/**
 The counter for all user which are follower of this user.
 */
@property (nonatomic, readonly) NSUInteger followerCount;

/**
 The counter for all user this user is following.
 */
@property (nonatomic, readonly) NSUInteger followingCount;

/**
 The url of the users avatar image. If no image is defined productlayer returns a gravatar image url.
 */
@property (nonatomic, readonly) NSURL *avatarURL;

/**
 Is this user following the logged in user.
 */
@property (nonatomic, readonly) BOOL following;

/**
 Is this user followed the logged in user.
 */
@property (nonatomic, readonly) BOOL followed;


/**
 The social connections of the user
 */
@property (nonatomic, readonly) NSDictionary *socialConnections;

@end
