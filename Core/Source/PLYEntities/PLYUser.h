//
//  PLYUser.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYAuditor;

@interface PLYUser : NSObject{
    
    NSString *Class;
    NSString *Id;
    NSNumber *version;
    
    PLYAuditor *createdBy;
    NSNumber *createdTime;
    PLYAuditor *updatedBy;
    NSNumber *updatedTime;
    
    NSString *nickname;
    
    NSString *firstName;
    NSString *lastName;
    
    NSString *email;
    NSDate *birthday;
    NSString *gender;
    
    NSNumber *points;
    NSArray *unlockedAchievements;
    
    NSNumber *followerCount;
    NSNumber *followingCount;
    
    NSString *avatarUrl;
    
    bool following;
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

+ (NSString *) classIdentifier;
+ (PLYUser *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
