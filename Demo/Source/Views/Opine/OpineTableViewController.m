//
//  OpineTableViewController.m
//  PL
//
//  Created by René Swoboda on 30/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "OpineTableViewController.h"
#import "UIViewTags.h"
#import "DTBlockFunctions.h"
#import "DTSidePanelController.h"
#import "UIViewController+DTSidePanelController.h"
#import "AppSettings.h"
#import "WriteOpineViewController.h"

#import "DTProgressHUD.h"
#import "OpineTableViewCell.h"

#import "ProductLayer.h"

@interface OpineTableViewController ()
@property (nonatomic) bool isLoading;
@end

@implementation OpineTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _isLoading = NO;
    }
    return self;
}

- (void) reloadOpines{
    if(_isLoading) return;
    
    if(!_parent){
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(writeOpine)];
    }
    
    if(_parent || _userNickname){
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"loading" progressType:HUDProgressTypeInfinite];
    
    // Very ugly but API currently has not getOpinesWithParent implemented.
    NSString *GTIN;
    if([_parent isKindOfClass:[PLYProduct class]]){
        GTIN = [(PLYProduct *)_parent GTIN];
    }
    
    _isLoading = YES;
    _locale = [AppSettings currentAppLocale];
    [[PLYServer sharedServer] performSearchForOpineWithGTIN:GTIN
                                                withLanguage:_locale.localeIdentifier
                                        fromUserWithNickname:_userNickname
                                                  showFiendsOnly:false
                                                     orderBy:@"pl-id_asc"
                                                        page:0
                                              recordsPerPage:20
                                                  completion:^(id result, NSError *error) {
                                                      if(error) {
                                                          DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                                              
                                                              if(error.code == 404){
                                                                  // Opines from user.
                                                                  if(_userNickname){
                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No opines found" message:[NSString stringWithFormat:@"There are no opines from %@ available!",_userNickname] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                      [alert show];
                                                                  }
                                                                  // Reviews for product
                                                                  else {
                                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No opines found" message:@"There are no opines for the product available! Be the first to write a opine!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                      [alert show];
                                                                  }
                                                              } else {
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load Opines Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                                                                  [alert show];
                                                              }
                                                          });
                                                      } else {
                                                          DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                                              
                                                              _opines = result;
                                                              
                                                              [self.tableView reloadData];
                                                              
                                                              _isLoading = NO;
                                                          });
                                                      }
                                                      
                                                      DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                                                          [_hud hide];
                                                      });
                                                  }];
}

- (void) writeOpine{
    [self performSegueWithIdentifier:@"writeOpine" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
        [[self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage] removeFromSuperview];
    }
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.sidePanelController;
    _sidebarButton.action = @selector(toggleLeftPanel:);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //Changing Tint Color!
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
                                                                        green:190.0/255.0
                                                                         blue:68.0/255.0
                                                                        alpha:1.0];
    
    [self reloadOpines];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_opines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OpineTableViewCell" forIndexPath:indexPath];
    
    [cell setOpine:[_opines objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"writeOpine"] && ![self checkIfLoggedInAndShowLoginView:YES])
	{
        return NO;
    }
    
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"writeOpine"])
	{
		WriteOpineViewController *writeOpine = (WriteOpineViewController *)segue.destinationViewController;
		writeOpine.parent = _parent;
        writeOpine.gtinTextField.enabled = NO;
	}
}

@end
