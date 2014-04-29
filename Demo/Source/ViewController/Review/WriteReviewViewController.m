//
//  WriteReviewViewController.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "WriteReviewViewController.h"
#import "PLYReview.h"
#import "PLYServer.h"
#import "DTBlockFunctions.h"

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
    [self.ratingTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    
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
	
	if (![self.ratingTextField.text length])
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)save:(id)sender
{
    PLYReview *newReview = [[PLYReview alloc] init];
    
	newReview.gtin = self.gtinTextField.text;
    
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
	NSNumber *rating = [f numberFromString:self.ratingTextField.text];
	if (rating != nil)
	{
        newReview.rating = rating;
	}
	
	newReview.language = [_localePicker.selectedLocale localeIdentifier];
    
	[[PLYServer sharedPLYServer] createReviewForGTIN:newReview.gtin dictionary:[newReview getDictionary] completion:^(id result, NSError *error) {
		
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
                [self performSegueWithIdentifier:@"UnwindFromWriteReview" sender:self];
			});
		}
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
