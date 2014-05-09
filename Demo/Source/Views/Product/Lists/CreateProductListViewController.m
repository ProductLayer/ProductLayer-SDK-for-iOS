//
//  CreateProductListViewController.m
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "CreateProductListViewController.h"

#import "ProductLayer.h"

#import "DTBlockFunctions.h"

@interface CreateProductListViewController ()

@end

@implementation CreateProductListViewController {
    PLYList *_list;
}

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
    
    [self.titleTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.listTypeTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.sharingTypeTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
    
    [self.listTypePicker set_delegate:self];
    self.listTypePicker.stringList = [PLYList availableListTypes];
    [self.listTypePicker reloadAllComponents];
    [self.listTypePicker selectRow:0 inComponent:0 animated:NO];
    
    [self.sharingTypePicker set_delegate:self];
    self.sharingTypePicker.stringList = [PLYList availableSharingTypes];
    [self.sharingTypePicker reloadAllComponents];
    [self.sharingTypePicker selectRow:0 inComponent:0 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction) createProductList:(id)sender{
    [self updateList];
    
    if([_list isValidForSaving]){
        [[PLYServer sharedPLYServer] createProductList:_list completion:^(id result, NSError *error) {
            if (error)
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product List Creation Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else
            {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    [self.navigationController popViewControllerAnimated:true];
                });
            }
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not valid for saving!" message:@"Please fill out all necessary fields and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (PLYList *) updateList{
    
    if(!_list){
        _list = [[PLYList alloc] init];
    }
    
    NSString *title = self.titleTextfield.text;
    if([title length]){
        _list.title = title;
    }
    
    NSString *description = self.descriptionTextview.text;
    if([description length]){
        _list.description = description;
    }
    
    NSString *listType = self.listTypePicker.selectedString;
    if([listType length]){
        _list.listType = listType;
    }
    
    NSString *shareType = self.sharingTypePicker.selectedString;
    if([shareType length]){
        _list.shareType = shareType;
    }
    
    return _list;
}

- (void)_updateSaveButtonStatus
{
	if ([[self updateList] isValidForSaving])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)textFieldChanged:(id)sender
{
	[self _updateSaveButtonStatus];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 3 && self.listTypePickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 3 && self.listTypePickerIsShowing == YES){
        return 177.0f;
    }
    
    if (indexPath.section == 0 && indexPath.row == 5 && self.sharingTypePickerIsShowing == NO){
        // hide date picker row
        return 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 5 && self.sharingTypePickerIsShowing == YES){
        return 177.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2){
        if (self.listTypePickerIsShowing){
            [self hideListTypePickerCell];
        }else {
            [self showListTypePickerCell];
            
            if(self.sharingTypePickerIsShowing){
                [self hideSharingPickerCell];
            }
        }
    }
    if (indexPath.row == 4){
        if (self.sharingTypePickerIsShowing){
            [self hideSharingPickerCell];
        }else {
            [self showSharingPickerCell];
            
            if(self.listTypePickerIsShowing){
                [self hideListTypePickerCell];
            }
        }
    }
}


#pragma mark - Localized String Picker Delegate

- (void) localizedStringPicker:(LocalizableStringPicker *)_picker selectedString:(NSString *)_string{
    if([_picker isEqual:_listTypePicker]){
        [_listTypeTextfield setText:NSLocalizedString(_string, @"")];
    } else if([_picker isEqual:_sharingTypePicker]){
        [_sharingTypeTextfield setText:NSLocalizedString(_string, @"")];
    }
    
    
}

#pragma mark - Hide & Show List Type Picker

- (void)showListTypePickerCell {
    self.listTypePickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.listTypePicker.hidden = NO;
    self.listTypePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.listTypePicker.alpha = 1.0f;
    }];
}

- (void)hideListTypePickerCell {
    self.listTypePickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.listTypePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.listTypePicker.hidden = YES;
                     }];
}

#pragma mark - Hide & Show Locale Picker

- (void)showSharingPickerCell {
    self.sharingTypePickerIsShowing = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.sharingTypePicker.hidden = NO;
    self.sharingTypePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.sharingTypePicker.alpha = 1.0f;
    }];
}

- (void)hideSharingPickerCell {
    self.sharingTypePickerIsShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sharingTypePicker.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         self.sharingTypePicker.hidden = YES;
                     }];
}


@end
