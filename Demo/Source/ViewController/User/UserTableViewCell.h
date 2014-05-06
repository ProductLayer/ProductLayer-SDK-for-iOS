//
//  UserTableViewCell.h
//  PL
//
//  Created by René Swoboda on 02/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLYUser;

@interface UserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followUnFollowButton;

- (IBAction)ChangeRelationButtonClicked:(id)sender;

@property (nonatomic, strong) PLYUser *user;


@end
