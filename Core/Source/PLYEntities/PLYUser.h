//
//  PLYUser.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor, PLYUserAvatar;

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
 The gamification level of the user
 */
@property (nonatomic, readonly) NSInteger level;

/**
 The gamification level progress of the user
 */
@property (nonatomic, readonly) NSInteger progress;

/**
 A list of unlocked achievements.
 */
@property (nonatomic, copy, readonly) NSArray *unlockedAchievements;

/**
 The counter for all user which are follower of this user.
 */
@property (nonatomic, readonly) NSUInteger followerCount;

/**
 The counter for all user this user is following.
 */
@property (nonatomic, readonly) NSUInteger followingCount;

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
@property (nonatomic, copy, readonly) NSDictionary *socialConnections;


/**
 The roles of the user
 */
@property (nonatomic, copy, readonly) NSArray *roles;

/**
 An PLYUserAvatar object for the receiver
 */
@property (nonatomic, copy, readonly) PLYUserAvatar *avatar;

/**
 A dictionary of user-specific preferences
 */
@property (nonatomic, copy, readonly) NSDictionary *settings;

@end
