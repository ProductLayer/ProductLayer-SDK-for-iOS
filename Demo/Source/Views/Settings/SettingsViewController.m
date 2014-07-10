//
//  SettingsViewController.m
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "SettingsViewController.h"

#import "UIViewController+DTSidePanelController.h"
#import "DTSidePanelController.h"

#import "UIViewTags.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.getSidePanelController;
    _sidebarButton.action = @selector(showLeftPanel:);
    
    // Set delegate for locale updates
    _localePicker._delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 1 && self.localePickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 1 && self.localePickerIsShowing == YES){
        return 177.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        if (self.localePickerIsShowing){
            [self hideLocalePickerCell];
        }else {
            [self showLocalePickerCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Locale Picker Delegate

- (void) localeSelected:(NSLocale *)_locale{
    [_localeTextField setText:[_locale displayNameForKey:NSLocaleIdentifier value:_locale.localeIdentifier]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_locale.localeIdentifier forKey:@"PLYLocale"];
}

@end
