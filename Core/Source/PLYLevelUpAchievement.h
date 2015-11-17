//
//  PLYLevelUpAchievement.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 17/11/15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

#import "PLYAchievement.h"

@interface PLYLevelUpAchievement : PLYAchievement

@property(nonatomic, assign) NSUInteger pointsBeforeLevelUp;
@property(nonatomic, assign) NSUInteger pointsAfterLevelUp;

@end
