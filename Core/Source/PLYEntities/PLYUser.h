//
//  PLYUser.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;

@interface PLYUser : PLYEntity

/**
 The class identifier.
 */
@property (nonatomic, strong) NSString *Class;

/**
 The object id.
 */
@property (nonatomic, strong) NSString *Id;

/**
 The version.
 */
@property (nonatomic, strong) NSNumber *version;

/**
 The user who created the object.
 */
@property (nonatomic, strong) PLYAuditor *createdBy;

/**
 The timestamp when object was created.
 */
@property (nonatomic, strong) NSNumber *createdTime;

/**
 The user who updated the object the last time.
 */
@property (nonatomic, strong) PLYAuditor *updatedBy;

/**
 The timestamp when object was updated the last time.
 */
@property (nonatomic, strong) NSNumber *updatedTime;

/**
 The nickname of the user.
 */
@property (nonatomic, strong) NSString *nickname;

/**
 The first name of the user.
 */
@property (nonatomic, strong) NSString *firstName;

/**
 The last name of the user.
 */
@property (nonatomic, strong) NSString *lastName;

/**
 The email of the user.
 */
@property (nonatomic, strong) NSString *email;

/**
 The birthday of the user.
 */
@property (nonatomic, strong) NSDate *birthday;

/**
 The gender of the user.
 */
@property (nonatomic, strong) NSString *gender;

/**
 The gamification points of the user.
 */
@property (nonatomic, strong) NSNumber *points;

/**
 A list of unlocked achievements.
 */
@property (nonatomic, strong) NSArray *unlockedAchievements;

/**
 The counter for all user which are follower of this user.
 */
@property (nonatomic, strong) NSNumber *followerCount;

/**
 The counter for all user this user is following.
 */
@property (nonatomic, strong) NSNumber *followingCount;

/**
 The url of the users avatar image. If no image is defined productlayer returns a gravatar image url.
 */
@property (nonatomic, strong) NSString *avatarUrl;

/**
 Is this user following the logged in user.
 */
@property (nonatomic) BOOL following;

/**
 Is this user followed the logged in user.
 */
@property (nonatomic) BOOL followed;

@end
