//
//  PLYChoosePasswordViewController.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 20/11/15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

#import "PLYChoosePasswordViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayerUI.h"

#import "DTBlockFunctions.h"
#import "DTAlertView.h"

@interface PLYChoosePasswordViewController() <PLYFormValidationDelegate, UITextFieldDelegate>

@end


@implementation PLYChoosePasswordViewController
{
    NSArray *_validators;
    
    UIBarButtonItem *_leftButton;
    UIBarButtonItem *_rightButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *explainLabel = [[UILabel alloc] init];
    explainLabel.text = PLYLocalizedStringFromTable(@"PLY_SETPASSWD_EXPLAIN", @"UI", @"Explanation to show on set password dialog");
    explainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    explainLabel.numberOfLines = 0;
    explainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [explainLabel sizeToFit];
    [self.view addSubview:explainLabel];
    
    NSMutableArray *validators = [NSMutableArray array];
    
    PLYUserNameValidator *nameValidator = [PLYUserNameValidator validatorWithDelegate:self];
    [validators addObject:nameValidator];
    
    _passwordField = [[PLYTextField alloc] initWithFrame:CGRectZero];
    _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.spellCheckingType = UITextSpellCheckingTypeNo;
    _passwordField.secureTextEntry = YES;
    _passwordField.placeholder = PLYLocalizedStringFromTable(@"PLY_PASSWORD_PLACEHOLDER", @"UI", @"Password Field Placeholder");
    _passwordField.validator = nameValidator;
    _passwordField.returnKeyType = UIReturnKeySend;
    _passwordField.delegate = self;
    _passwordField.enablesReturnKeyAutomatically = YES;
    [self.view addSubview:_passwordField];
    
    PLYFormEmailValidator *emailValidator = [PLYFormEmailValidator validatorWithDelegate:self];
    [validators addObject:emailValidator];
    
      _validators = [validators copy];
    
    
    id topGuide = [self topLayoutGuide];
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_passwordField, topGuide, explainLabel);
    NSArray *constraints1 =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[explainLabel]-[_passwordField]"
                                            options:0 metrics:nil views:viewsDictionary];
    NSArray *constraints2 =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_passwordField(300)]"
                                            options:0 metrics:nil views:viewsDictionary];
    
    NSArray *constraints4 =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[explainLabel(280)]"
                                            options:0 metrics:nil views:viewsDictionary];
    
    [self.view addConstraints:constraints1];
    [self.view addConstraints:constraints2];
    [self.view addConstraints:constraints4];
    
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:_passwordField
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:explainLabel
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1
                                   constant:0]];
    
    [self.navigationController.view setTintColor:PLYBrandColor()];
    
    NSString *title = PLYLocalizedStringFromTable(@"PLY_PASSWORD_RIGHT_BUTTON_TITLE", @"UI", @"Text for done button in set password dialog");
    _rightButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    _rightButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _rightButton;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (PLY_SUPPORTED_INTERFACE_ORIENTATIONS_RETURN_TYPE)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.viewControllers[0] == self)
    {
        _leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = _leftButton;
    }
    
    [_passwordField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)done:(id)sender
{
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
    
    __weak PLYChoosePasswordViewController *weakSelf = self;
    
    [self.productLayerServer setUserPassword:_passwordField.text resetToken:_resetToken completion:^(PLYUser *user, NSError *error) {
        
        PLYChoosePasswordViewController *strongSelf = weakSelf;
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
            if (error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PLYLocalizedStringFromTable(@"PLY_SIGNUP_ERROR_ALERT", @"UI", @"Title of alert in signup dialog")
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
                                                      otherButtonTitles:nil];
                alert.tintColor = [UIColor redColor];
                [alert show];
                
                // restore button
                strongSelf.navigationItem.rightBarButtonItem = strongSelf->_rightButton;
                
                return;
            }
            
            // set thumbs up
            UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
            check.tintColor = strongSelf.navigationController.view.tintColor;
            strongSelf.navigationItem.rightBarButtonItem = check;
            
            NSString *title = PLYLocalizedStringFromTable(@"PLY_SETPW_SUCCESS_ALERT_TITLE", @"UI", @"Title for successful password change");
            NSString *format = PLYLocalizedStringFromTable(@"PLY_SETPW_SUCCESS_ALERT_MSG", @"UI", @"Message for successful password change");
            NSString *msg = [NSString stringWithFormat:format, user.nickname];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([strongSelf.delegate respondsToSelector:@selector(choosePasswordViewControllerDidFinish:forUser:)])
                {
                    [strongSelf.delegate choosePasswordViewControllerDidFinish:strongSelf forUser:user];
                }
            }];
            
            [alert addAction:okButton];
            
            [strongSelf presentViewController:alert animated:YES completion:NULL];
        });
    }];
}

#pragma mark - Form Validation

- (BOOL)_allFieldsValid
{
    for (PLYFormValidator *oneValidator in _validators)
    {
        // revalidate
        [oneValidator validate];
        
        if (!oneValidator.isValid)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)validityDidChange:(PLYFormValidator *)validator
{
    for (PLYFormValidator *oneValidator in _validators)
    {
        if (!oneValidator.isValid)
        {
            _rightButton.enabled = NO;
            return;
        }
    }
    
    _rightButton.enabled = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self _allFieldsValid])
    {
        [self done:nil];
        return YES;
    }
    
    return NO;
}

@end
