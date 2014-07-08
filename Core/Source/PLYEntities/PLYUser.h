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
{
    // The class identifier.
    NSString *Class;
    // The object id.
    NSString *Id;
    // The version.
    NSNumber *version;
    
    // The user who created the object.
    PLYAuditor *createdBy;
    // The timestamp when object was created.
    NSNumber *createdTime;
    
    // The user who updated the object the last time.
    PLYAuditor *updatedBy;
    // The timestamp when object was updated the last time.
    NSNumber *updatedTime;
    
    // The nickname of the user.
    NSString *nickname;
    
    // The first name of the user.
    NSString *firstName;
    // The last name of the user.
    NSString *lastName;
    
    // The email of the user.
    NSString *email;
    // The birthday of the user.
    NSDate *birthday;
    // The gender of the user.
    NSString *gender;
    
    // The gamification points of the user.
    NSNumber *points;
    // A list of unlocked achievements.
    NSArray *unlockedAchievements;
    
    // The counter for all user which are follower of this user.
    NSNumber *followerCount;
    // The counter for all user this user is following.
    NSNumber *followingCount;
    
    // The url of the users avatar image. If no image is defined productlayer returns a gravatar image url.
    NSString *avatarUrl;
    
    // Is this user following the logged in user.
    bool following;
    // Is this user followed the logged in user.
    bool followed;
}
@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *nickname;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSString *gender;

@property (nonatomic, strong) NSNumber *points;
@property (nonatomic, strong) NSArray *unlockedAchievements;

@property (nonatomic, strong) NSNumber *followerCount;
@property (nonatomic, strong) NSNumber *followingCount;

@property (nonatomic, strong) NSString *avatarUrl;

@property (nonatomic) bool following;
@property (nonatomic) bool followed;

@end
