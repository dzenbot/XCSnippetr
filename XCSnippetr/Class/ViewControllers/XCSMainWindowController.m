//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSMainWindowController.h"
#import "XCSLoginViewController.h"
#import "XCSStrings.h"
#import "XCSBezelAlert.h"

#import "NSTextView+Placeholder.h"
#import "ACEModeNames+Extension.h"

static CGFloat const kFontPointSize =           12.0;

static NSString * const kSystemSoundFailure =   @"Basso";
static NSString * const kSystemSoundSuccess =   @"Glass";

@interface XCSMainWindowController ()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, strong) XCSSnippet *snippet;
@property (nonatomic, strong) XCSLoginViewController *loginViewController;

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=isUploading) BOOL uploading;

@property (nonatomic) BOOL didAppear;

@end

@implementation XCSMainWindowController
@synthesize fileName = _fileName;
@synthesize fileContent = _fileContent;
@synthesize font = _font;

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    self = [super initWithWindowNibName:NSStringFromClass([XCSMainWindowController class])];
    if (self) {
        [self.window setStyleMask:[self.window styleMask] & ~NSResizableWindowMask];
        
        self.bundle = bundle;
        self.snippet = [[XCSSnippet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidAppear) name:NSWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Only for debug, when the data model has changed or for log out all accounts.
//    [XCSAccount clearAll];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)windowDidAppear
{
    if (self.didAppear) {
        return;
    }
    
    [self configureContent];
    
    if ([XCSAccount needsForcedLoginForService:self.service]) {
        [self performSelector:@selector(presentLoginForm) withObject:nil afterDelay:0.3];
    }
    
    self.didAppear = YES;
}


#pragma mark - Getters

- (XCSLoginViewController *)loginViewController
{
    if (!_loginViewController) {
        _loginViewController = [[XCSLoginViewController alloc] initWithBundle:self.bundle];
        _loginViewController.service = self.service;
    }
    return _loginViewController;
}

- (NSString *)fileName
{
    if (!_fileName) _fileName = @"";
    return _fileName;
}

- (NSString *)fileContent
{
    if (!_fileContent)  _fileContent = @"";
    return _fileContent;
}

- (NSFont *)font
{
    if (!_font) _font = [NSFont systemFontOfSize:kFontPointSize];
    return _font;
}

- (NSString *)addNewTitle
{
    return self.service == XCSServiceSlack ? kAddTeamButtonTitle : kAddUserButtonTitle;
}

- (NSInteger)indexOfCurrentAccount
{
    NSArray *accounts = [XCSAccount allAccountsForService:self.service];
    XCSAccount *currentAccount = [XCSAccount currentAccountForService:self.service];
    
    NSInteger idx = [accounts indexOfObject:currentAccount];
    idx++; // Increments to consider the empty space at first position
    
    return idx;
}

- (BOOL)canAccept
{
    if (self.service == XCSServiceSlack) {
        if (!self.snippet.teamId || (!self.snippet.uploadAsSnippet && !self.snippet.channelId)) {
            return NO;
        }
    }
    else if (self.service == XCSServiceGithub) {
        if ([self.titleTextField stringValue].length == 0) {
            return NO;
        }
    }
    
    if (self.isUploading || self.sourceTextView.string.length == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Setters

- (void)setFileName:(NSString *)fileName
{
    if (!fileName) {
        return;
    }
    
    _fileName = fileName;
    
    self.snippet.filename = fileName;
}

- (void)setFileContent:(NSString *)fileContent
{
    if (!fileContent) {
        return;
    }
    
    _fileContent = fileContent;
    
    [self.snippet setContent:fileContent];
    [self.sourceTextView setString:fileContent];
}

- (void)setLoading:(BOOL)loading
{
    if (self.isLoading == loading) {
        return;
    }
    
    _loading = loading;
    
    if (loading) {
        [self.progressIndicator startAnimation:self];
    }
    else {
        [self.progressIndicator stopAnimation:self];
    }
    
    [self updateAcceptButton];
}

- (void)setFont:(NSFont *)font
{
    if (isNonEmptyString(font.familyName)) {
        _font = [NSFont fontWithName:font.familyName size:kFontPointSize];
    }
    else {
        _font = nil;
    }
    
    if (_font) {
        [self.sourceTextView setFontFamily:self.font.familyName];
        [self.sourceTextView setFontSize:self.font.pointSize];
    }
}


#pragma mark - Configuration

- (void)configureContent
{
    BOOL isSlack = (self.service == XCSServiceSlack);
    
    NSString *titlePlaceholder = isSlack ? kMainTitlePlaceholderSlack : kMainTitlePlaceholderGist;
    NSString *commentPlaceholder = isSlack ? kMainCommentPlaceholderSlack : kMainCommentPlaceholderGist;

    self.window.title = isSlack ? kTitleShareSlack : kTitleShareGist;
    
    XCSAccount *currentAccount = [XCSAccount currentAccountForService:self.service];
    
    // Data Source
    self.snippet.teamId = currentAccount.teamId;
    self.snippet.uploadAsPrivate = self.privacyCheckBox.state;
    self.snippet.uploadAsSnippet = self.uploadTypeCheckBox.state;
    
    // Title View
    self.titleTextField.stringValue = StringOrEmpty(self.snippet.title);
    self.titleTextField.placeholderString = titlePlaceholder;

    // Comment View
    self.commentTextView.string = @"";
    self.commentTextView.placeholderString = commentPlaceholder;
    
    // Source Text View
    [self.sourceTextView setDelegate:self];
    [self.sourceTextView setWrappingBehavioursEnabled:YES];
    [self.sourceTextView setReadOnly:NO];
    [self.sourceTextView setMode:self.snippet.type];
    [self.sourceTextView setTheme:ACEThemeXcode];
    [self.sourceTextView setKeyboardHandler:ACEKeyboardHandlerAce];
    [self.sourceTextView setShowPrintMargin:NO];
    [self.sourceTextView setShowInvisibles:NO];
    [self.sourceTextView setSnippets:YES];
    [self.sourceTextView setEmmet:NO];
    [self.sourceTextView setShowLineNumbers:YES];
    [self.sourceTextView setShowGutter:YES];
    
    // Buttons
    [self.syntaxButton addItemsWithTitles:[ACEModeNames humanModeNames]];
    [self.syntaxButton selectItemAtIndex:self.snippet.type];

    [self configureAccountButton];
    [self configureDirectoryButton];
    
    self.cancelButton.title = kCancelButtonTitle;
    self.cancelButton.hidden = !isXCSPlugin(self.bundle);
    self.acceptButton.title = kUploadButtonTitle;
    
    self.privacyCheckBox.title = kMainUploadAsPrivateTitle;
    self.uploadTypeCheckBox.title = kMainUploadAsSnippetTitle;
    
    if (self.service != XCSServiceSlack) {
        
        self.uploadTypeCheckBox.hidden = YES;
        self.directoryButton.hidden = YES;
        self.directoryButtononstraint.constant = 0.0;
    }
}

- (void)configureAccountButton
{
    [self.accountButton removeAllItems];
    
    if ([XCSAccount allAccountsForService:self.service].count > 0) {
        [self.accountButton addItemsWithTitles:[XCSAccount accountNamesForService:self.service]];
    }
    
    [self.accountButton insertItemWithTitle:@"" atIndex:0]; // First element is empty, to enable to clean states.
    [self.accountButton insertItemWithTitle:[self addNewTitle] atIndex:self.accountButton.numberOfItems];
    
    XCSAccount *currentAccount = [XCSAccount currentAccountForService:self.service];
    
    if (!currentAccount) {
        [self.accountButton selectItemAtIndex:0];
    }
    else {
        [self.accountButton selectItemAtIndex:[self indexOfCurrentAccount]];
    }
}

- (void)configureDirectoryButton
{
    [self.directoryButton removeAllItems];
    
    // Doesn't configure the button and disables it, when the team id isn't available
    if (!isNonEmptyString(self.snippet.teamId)) {
        self.directoryButton.enabled = NO;
        return;
    }
    else {
        self.directoryButton.enabled = YES;
    }
    
    if ([SLKRoomManager hasRooms])
    {
        NSArray *channels = [SLKRoomManager roomNamesForType:SLKRoomTypeChannel];
        NSArray *groups = [SLKRoomManager roomNamesForType:SLKRoomTypeGroup];
        NSArray *ims = [SLKRoomManager roomNamesForType:SLKRoomTypeIM];
        
        if (channels.count > 0) {
            NSMenuItem *separator = [NSMenuItem separatorItem];
            separator.tag = SLKRoomTypeChannel;
            [[self.directoryButton menu] addItem:separator];
            
            [self.directoryButton addItemsWithTitles:channels];
        }
        
        if (groups.count > 0) {
            if (channels.count > 0) {
                NSMenuItem *separator = [NSMenuItem separatorItem];
                separator.tag = SLKRoomTypeGroup;
                [[self.directoryButton menu] addItem:separator];
            }
            
            [self.directoryButton addItemsWithTitles:groups];
        }
        
        if (ims.count > 0) {
            if (groups.count > 0 || channels.count > 0) {
                NSMenuItem *separator = [NSMenuItem separatorItem];
                separator.tag = SLKRoomTypeIM;
                [[self.directoryButton menu] addItem:separator];
            }
            
            [self.directoryButton addItemsWithTitles:ims];
        }
        
        [self selectAppropriateDirectory];
    }
    else {
        [self reloadRoomsIfNeeded];
    }
}

- (void)selectAppropriateDirectory
{
    if (self.directoryButton.itemTitles.count < 3) {
        return;
    }
    
    NSString *channelId = [XCSAccount currentAccountForService:self.service].channelId;
    
    if (isNonEmptyString(channelId)) {
        SLKRoom *room = [SLKRoomManager roomForId:channelId];
        [self.directoryButton selectItemWithTitle:room.name];
    }
    else {
        [self.directoryButton selectItemAtIndex:2];
    }
    
    [self directoryChanged:self.directoryButton];
}

- (void)updateAcceptButton
{
    self.acceptButton.enabled = [self canAccept];
}


#pragma mark - Events

- (void)presentLoginForm
{
    
    
    NSWindow *window = [[NSWindow alloc] init];
    window.contentViewController = self.loginViewController;
    
    [self.window beginSheet:window completionHandler:NULL];
    
    __block __typeof(self)weakSelf = self;
    
    [self.loginViewController setCompletionHandler:^(BOOL didLogin){
        
        [weakSelf.window endSheet:window];
        
        // Close the plugin if no account has been registered.
        if ([XCSAccount needsForcedLoginForService:weakSelf.service]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismiss:nil returnCode:NSModalResponseCancel];
            });
        }
        else {
            [weakSelf configureAccountButton];
            [weakSelf accountChanged:weakSelf.accountButton];
        }
    }];
}

- (void)reloadRoomsIfNeeded
{
    self.loading = YES;
    
    [SLKRoomManager getAvailableRooms:^(NSError *error) {
        if (!error) {
            [self configureDirectoryButton];
        }
        else {
            [self handleError:error];
        }
        
        self.loading = NO;
    }];
}

- (void)didSubmitSnippetWithError:(NSError *)error
{
    if (!error) {
        [[NSSound soundNamed:kSystemSoundSuccess] play];
        
        if (self.snippet.URL) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];

            // If successfully copied the url to the pasteboard, present the system toast alert
            if ([pasteboard writeObjects:@[self.snippet.URL]]) {
                
                if (isXCSPlugin(self.bundle)) {
                    NSImage *icon = [self.bundle imageForResource:@"icon_pasteboard"];
                    [XCSBezelAlert showWithIcon:icon message:kSnippetLinkCopiedTitle];
                }
            }
        }
        
        [self dismiss:nil returnCode:NSModalResponseOK];
    }
    else {
        [[NSSound soundNamed:kSystemSoundFailure] play];
        
        [self handleError:error];
    }
}

- (void)handleError:(NSError *)error
{
    if (!error) {
        return;
    }
    
    self.loading = NO;
    [self updateAcceptButton];
}


#pragma mark - Actions

- (IBAction)syntaxModeChanged:(NSPopUpButton *)sender
{
    ACEMode mode = [sender indexOfSelectedItem];
    
    self.snippet.type = mode;
    
    [self.sourceTextView setMode:mode];
}

- (IBAction)accountChanged:(NSPopUpButton *)sender
{
    NSString *title = sender.titleOfSelectedItem;
    
    if (title.length == 0) {
        self.snippet.teamId = nil;
        self.snippet.channelId = nil;
        
        [self configureDirectoryButton];
    }
    else if ([title isEqualToString:[self addNewTitle]]) {
        [self performSelector:@selector(presentLoginForm) withObject:nil afterDelay:0.3];
    }
    else {
        NSInteger idx = [self.accountButton indexOfItemWithTitle:title];
        idx--; // Decrements to consider the space at first position
        
        XCSAccount *account = [XCSAccount allAccountsForService:self.service][idx];
        
        // Set as the current account
        [account setAsCurrentForService:self.service];
        
        // Updates the target team of the snippet
        self.snippet.teamId = account.teamId;
        
        [self configureDirectoryButton];
    }
    
    [self updateAcceptButton];
}

- (IBAction)directoryChanged:(NSPopUpButton *)sender
{
    NSMenuItem *selectedItem = self.directoryButton.selectedItem;
    NSString *title = selectedItem.title;
    
    NSString *channelId = nil;
    
    if (!selectedItem.isSeparatorItem && title.length > 0) {
        SLKRoom *room = [SLKRoomManager roomForName:title];
        channelId = room.tsid;
    }
    
    self.snippet.channelId = channelId;
    [[XCSAccount currentAccountForService:self.service] setChannelId:channelId];
    
    [self updateAcceptButton];
}

- (IBAction)uploadPrivacyChanged:(NSButton *)sender
{
    self.snippet.uploadAsPrivate = sender.state;
    
    if (self.service == XCSServiceSlack) {
        self.directoryButton.enabled = !sender.state;
    }
}

- (IBAction)uploadTypeChanged:(NSButton *)sender
{
    self.snippet.uploadAsSnippet = sender.state;
    
    if (self.service == XCSServiceSlack) {
        self.titleTextField.enabled = sender.state;
    }
    
    [self updateAcceptButton];
}

- (IBAction)cancelForm:(NSButton *)sender
{
    [XCSClientFactory reset];
    
    [self dismiss:sender returnCode:NSModalResponseCancel];
}

- (IBAction)submitForm:(NSButton *)sender
{
    if (self.isLoading) {
        return;
    }
    
    self.uploading = YES;
    
    self.snippet.title = self.titleTextField.stringValue;
    self.snippet.content = self.sourceTextView.string;
    self.snippet.comment = self.commentTextView.string;
    
    self.loading = YES;
    [self updateAcceptButton];
    
    [[XCSClientFactory clientForService:self.service] uploadSnippet:self.snippet completion:^(NSDictionary *JSON, NSError *error) {
        
        self.uploading = NO;
        [self didSubmitSnippetWithError:error];
    }];
}

- (void)dismiss:(id)sender returnCode:(NSModalResponse)returnCode
{
    [XCSClientFactory reset];
    
    [[self window] close];
    
    if (self.completionHandler) {
        self.completionHandler(returnCode);
    }
}


#pragma mark - ACEViewDelegate methods

- (void)textDidChange:(NSNotification *)notification
{
    [self updateAcceptButton];
}


#pragma mark - NSTextFieldDelegate methods

- (void)controlTextDidChange:(NSNotification *)notification
{
    [self updateAcceptButton];
}


#pragma mark - Lifeterm methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

@end
