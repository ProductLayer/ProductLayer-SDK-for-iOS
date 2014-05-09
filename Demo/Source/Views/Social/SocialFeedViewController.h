//
//  SocialFeedViewController.h
//  PL
//
//  Created by René Swoboda on 08/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RFQuiltLayout.h"

@interface SocialFeedViewController : UICollectionViewController <RFQuiltLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *socialFeeds;

- (void) loadSocialFeed;

@end
