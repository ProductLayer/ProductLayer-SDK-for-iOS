//
//  UserTableViewCell.m
//  PL
//
//  Created by René Swoboda on 02/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "UserTableViewCell.h"

#import "PLYServer.h"
#import "PLYUser.h"

#import "DTLog.h"
#import "DTImageCache.h"
#import "DTDownloadCache.h"
#import "DTBlockFunctions.h"

@implementation UserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ChangeRelationButtonClicked:(id)sender {
    if(![[PLYServer sharedServer] loggedInUser]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login required" message:@"You need to login to follow a user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if(!_user.followed){
    [[PLYServer sharedServer] followUserWithNickname:_user.nickname completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            if(error){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't follow user!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            } else {
					// workaround for read-only property
					[_user setValue:@(_user.followerCount+1) forKey:@"followerCount"];
					[_user setValue:@(YES) forKey:@"followed"];
					
					[self updateCell];
            }
		});
	}];
    } else {
        [[PLYServer sharedServer] unfollowUserWithNickname:_user.nickname completion:^(id result, NSError *error) {
            
            DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                if(error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't un-follow user!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                } else {
						 // workaround for read-only property
						 [_user setValue:@(_user.followerCount-1) forKey:@"followerCount"];
						 [_user setValue:@(NO) forKey:@"followed"];
						 
                    [self updateCell];
                }
            });
        }];
    }
}

- (void) setUser:(PLYUser *)user{
    if([_user isEqual:user]){
        return;
    }
    
    _user = user;
    
    [self updateCell];
}

- (void) updateCell{
    [_userNicknameLabel setText:_user.nickname];
    
    // Set follower count
    if(_user.followerCount) {
        [_followerCountLabel setText:[NSString stringWithFormat:@"%ld", (unsigned long)_user.followerCount]];
    } else {
        [_followerCountLabel setText:@"0"];
    }
    
    // Set following count
    if(_user.followingCount) {
		 [_followingCountLabel setText:[NSString stringWithFormat:@"%ld", (unsigned long)_user.followingCount]];
    } else {
        [_followingCountLabel setText:@"0"];
    }
    
    // Check if the user is the current logged in user
    if([_user.nickname isEqualToString:[[PLYServer sharedServer] loggedInUser].nickname]){
        _followUnFollowButton.hidden = YES;
    } else {
        _followUnFollowButton.hidden = NO;
        
        // Check if the user is followed by the currentl logged in user
        if(_user.followed){
            [_followUnFollowButton setTitle:@"un-follow" forState:UIControlStateNormal];
        } else {
            [_followUnFollowButton setTitle:@"follow" forState:UIControlStateNormal];
        }
    }
    
    [self loadUserImage];
}

- (void) loadUserImage
{
    _userImageView.hidden = YES;
	
	DTImageCache *imageCache = [DTImageCache sharedCache];
	
	NSString *imageIdentifier = [_user.Id copy];
	
	// need to load it
	UIImage *image = [[DTDownloadCache sharedInstance] cachedImageForURL:_user.avatarURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			if (error)
			{
				DTLogError(@"Error loading image %@", [error localizedDescription]);
			}
			else
			{
				[imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:nil];
				
				// Check if user has changed since request
				if(![_user.Id isEqualToString:imageIdentifier])
					return;
				
				[_userImageView setImage:image];
			}
		});
	}];
	
	if (image)
	{
		[_userImageView setImage:image];
	}
	
	
	_userImageView.hidden = NO;
}

@end
