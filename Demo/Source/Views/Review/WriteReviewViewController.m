//
//  WriteReviewViewController.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "WriteReviewViewController.h"

#import "ProductLayer.h"

#import "DTBlockFunctions.h"
#import "DTProgressHUD.h"

#import "RatingTableCell.h"

@interface WriteReviewViewController ()

@end

@implementation WriteReviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.gtinTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    [self.subjectTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    
    self.gtinTextField.text = _gtin;
    
    _localePicker._delegate = self;
	
	[self _updateSaveButtonStatus];
}

- (void)_updateSaveButtonStatus
{
	if (![self.subjectTextField.text length])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	if (_ratingCell.rating == 0)
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender
{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"saving" progressType:HUDProgressTypeInfinite];
    
    PLYReview *newReview = [[PLYReview alloc] init];
    
	newReview.GTIN = self.gtinTextField.text;
    
	NSString *subject = self.subjectTextField.text;
	if ([subject length])
	{
		newReview.subject = subject;
	}
	
	NSString *body = self.bodyTextView.text;
	if ([body length])
	{
		newReview.body = body;
	}
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *rating = [NSNumber numberWithInt:_ratingCell.rating];
	if (rating != nil)
	{
        newReview.rating = rating;
	}
	
	newReview.language = [_localePicker.selectedLocale localeIdentifier];
    
	[[PLYServer sharedServer] createReviewForGTIN:newReview.GTIN dictionary:[newReview dictionaryRepresentation] completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Review Creation Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                [self.navigationController popViewControllerAnimated:true];
			});
		}
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}

- (void)textFieldChanged:(id)sender
{
	[self _updateSaveButtonStatus];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 5 && self.localePickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 5 && self.localePickerIsShowing == YES){
        return 177.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4){
        if (self.localePickerIsShowing){
            [self hideLocalePickerCell];
        }else {
            [self showLocalePickerCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Locale Picker Delegate

- (void) localeSelected:(NSLocale *)_locale{
    [_localeTextField setText:[_locale displayNameForKey:NSLocaleIdentifier value:_locale.localeIdentifier]];
}

#pragma mark - Hide & Show Locale Picker

- (void)showLocalePickerCell {
    self.localePickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.localePicker.hidden = NO;
    self.localePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.localePicker.alpha = 1.0f;
    }];
}

- (void)hideLocalePickerCell {
    self.localePickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.localePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.localePicker.hidden = YES;
                     }];
}

@end
