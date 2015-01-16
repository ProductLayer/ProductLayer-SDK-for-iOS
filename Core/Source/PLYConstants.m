//
//  PLYConstants.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYConstants.h"

NSString * const PLYErrorDomain = @"Product Layer API";
NSString * const PLYServerLoginErrorNotification = @"PLYServerLoginErrorNotification";
NSString * const PLYUserDefaultOpineComposerIncludeLocation = @"PLYUserDefaultOpineComposerIncludeLocation";
NSString * const PLYServerDidDeleteEntityNotification = @"PLYServerDidDeleteEntityNotification";
NSString * const PLYServerDidModifyListNotification = @"PLYServerDidModifyListNotification";
NSString * const PLYServerDidDeleteEntityKey = @"PLYServerDidDeleteEntityKey";
NSString * const PLYServerDidModifyListKey = @"PLYServerDidModifyListKey";

/**
 Timeline Options
 */
NSString * const PLYTimelineOptionIncludeOpines = @"opines";
NSString * const PLYTimelineOptionIncludeReviews = @"reviews";
NSString * const PLYTimelineOptionIncludeImages = @"images";
NSString * const PLYTimelineOptionIncludeProducts = @"products";
NSString * const PLYTimelineOptionIncludeFriends = @"include_friends";
NSString * const PLYTimelineOptionSinceID = @"since_id";
NSString * const PLYTimelineOptionUntilID = @"until_id";
NSString * const PLYTimelineOptionCount = @"count";