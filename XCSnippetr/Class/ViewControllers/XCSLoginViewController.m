//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSLoginViewController.h"
#import "XCSStrings.h"

#import "NSWindow+Shake.h"

@interface XCSLoginViewController ()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, strong) XCSAccount *account;
@property (nonatomic, getter=isLoading) BOOL loading;

@end

@implementation XCSLoginViewController

- (instancetype)initWithBundle:(NSBundle *)bundle;
{
    self = [super initWithNibName:NSStringFromClass([XCSLoginViewController class]) bundle:bundle];
    if (self) {
        self.bundle = bundle;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureContent];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
}


#pragma mark - Setters

- (void)setLoading:(BOOL)loading
{
    if (self.isLoading == loading) {
        return;
    }
    
    _loading = loading;
    
    if (loading) {
        [self.progressIndicator startAnimation:self];
        self.acceptButton.enabled = NO;
        self.errorLabel.hidden = YES;
    }
    else {
        [self.progressIndicator stopAnimation:self];
        self.acceptButton.enabled = YES;
    }
}


#pragma mark - Configuration

- (void)configureContent
{
    NSString *webApiUrl = [XCSClientFactory tokenSourceUrlForService:self.service];
    NSString *descriptionText = (self.service == XCSServiceSlack) ? kLoginDescriptionTextSlack : kLoginDescriptionTextGithub;
    NSString *serviceImageName = (self.service == XCSServiceSlack) ? @"logo_slack" : @"logo_github";
    NSImage *serviceImage = [self.bundle imageForResource:serviceImageName];
    
    self.tokenTextField.placeholderString = kLoginPlaceholder;
    self.detailTextView.string = [NSString stringWithFormat:@"%@ %@", descriptionText, webApiUrl];
    self.serviceImageView.image = serviceImage;
   
    NSRange range = [self.detailTextView.string rangeOfString:webApiUrl];
    [[self.detailTextView textStorage] addAttribute:NSLinkAttributeName value:[NSURL URLWithString:webApiUrl] range:range];
    
    self.cancelButton.title = kCancelButtonTitle;
    self.acceptButton.title = kLoginButtonTitle;
    self.acceptButton.keyEquivalent = kReturnKeyEquivalent;
    
    if ([XCSAccount allAccountsForService:self.service].count == 0) {
        [self.cancelButton setEnabled:isXCSPlugin(self.bundle)];
    }
}


#pragma mark - Events

- (IBAction)cancelForm:(id)sender
{
    // Cancels any pending requests
    [[XCSClientFactory clientForService:self.service] cancelRequestsIfNeeded];
    
    // Removes the incomplete account
    [self.account clear];
    
    if (self.completionHandler) {
        self.completionHandler(NO);
    }
}

- (IBAction)submitForm:(id)sender
{
    self.loading = YES;
    
    self.tokenTextField.enabled = NO;
    
    NSString *token = self.tokenTextField.stringValue;
    
    [[XCSClientFactory clientForService:self.service] authWithToken:token completion:^(XCSAccount *account, NSError *error) {
        
        if (account) {
            self.account = account;
            [self.account setAsCurrentForService:self.service];
            
            if (self.completionHandler) {
                self.completionHandler(YES);
            }
        }
        else {
            [self handleError:error];
        }
        
        self.loading = NO;
    }];
}

- (void)handleError:(NSError *)error
{
    if (!error) {
        return;
    }
    
    self.tokenTextField.enabled = YES;
    
    NSString *errorMessage = error.userInfo[NSLocalizedDescriptionKey];
    self.errorLabel.stringValue = [errorMessage stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    self.errorLabel.hidden = NO;
    
    [self.view.window shake];
}


#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    if ([[notification object] isEqual:self.tokenTextField]) {
        self.acceptButton.enabled = (self.tokenTextField.stringValue.length > 0);
    }
}

@end
