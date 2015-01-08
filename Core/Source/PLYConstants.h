//
//  PLYConstants.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

/**
 Domain of all errors that have ProductLayer as source
 */
extern NSString * const PLYErrorDomain;

/**
 Notification that gets sent if there is a problem logging in or refreshing the session
 */
extern NSString * const PLYServerLoginErrorNotification;


/**
 Notification for when an entity has been deleted
 */
extern NSString * const PLYServerDidDeleteEntityNotification;

/**
 Key in the info dictionary for PLYServerDidDeleteEntityNotification
 */
extern NSString * const PLYServerDidDeleteEntityKey;

/**
 User Defaults Keys
*/
extern NSString * const PLYUserDefaultOpineComposerIncludeLocation;

/**
 Timeline Options
 */
extern NSString * const PLYTimelineOptionIncludeOpines;
extern NSString * const PLYTimelineOptionIncludeReviews;
extern NSString * const PLYTimelineOptionIncludeImages;
extern NSString * const PLYTimelineOptionIncludeProducts;
extern NSString * const PLYTimelineOptionIncludeFriends;
extern NSString * const PLYTimelineOptionSinceID;
extern NSString * const PLYTimelineOptionUntilID;
extern NSString * const PLYTimelineOptionCount;

