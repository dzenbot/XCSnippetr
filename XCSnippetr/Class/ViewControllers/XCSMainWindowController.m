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

#import "SLKAPIClient.h"
#import "SLKRoomManager.h"
#import "SLKAccount.h"
#import "SLKSnippet.h"
#import "SLKRoom.h"
#import "SLKAPIConstants.h"
#import "XCSMacros.h"

#import "NSTextView+Placeholder.h"
#import "ACEModeNames+Extension.h"

#import <ACEView/ACEModeNames.h>

static CGFloat const kFontPointSize =           12.0;

static NSString * const kSystemSoundFailure =   @"Basso";
static NSString * const kSystemSoundSuccess =   @"Glass";

@interface XCSMainWindowController ()

@property (nonatomic, strong) SLKSnippet *snippet;
@property (nonatomic, strong) XCSLoginViewController *loginViewController;

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, getter=isUploading) BOOL uploading;

@property (nonatomic) BOOL didAppear;

@end

@implementation XCSMainWindowController
@synthesize fileName = _fileName;
@synthesize fileContent = _fileContent;
@synthesize font = _font;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.window.title = kTitleShareSlack;
        [self.window setStyleMask:[self.window styleMask] & ~NSResizableWindowMask];
        
        self.snippet = [[SLKSnippet alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidAppear) name:NSWindowDidBecomeKeyNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Only for debug, when the data model has changed or for log out all accounts.
    // [SLKAccount clearAll];
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
    
    if ([SLKAccount forceLogin]) {
        [self performSelector:@selector(presentLoginForm) withObject:nil afterDelay:0.3];
    }
    
    self.didAppear = YES;
}


#pragma mark - Getters

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

- (NSInteger)indexOfCurrentAccount
{
    NSInteger idx = [[SLKAccount allAccounts] indexOfObject:[SLKAccount currentAccount]];
    idx++; // Increments to consider the empty space at first position
    
    return idx;
}


#pragma mark - Setters

- (void)setFileName:(NSString *)fileName
{
    if (!fileName) {
        return;
    }
    
    _fileName = fileName;
    
    [self.snippet setFilename:fileName];
    [self.snippet setTitle:[fileName stringByDeletingPathExtension]];
    [self.snippet setFiletype:ACEModeForFileName(fileName)];
    
    [self.titleTextField setStringValue:self.snippet.title];
    [self.syntaxButton selectItemAtIndex:self.snippet.filetype];
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
    // Data Source
    self.snippet.teamId = [SLKAccount currentAccount].teamId;
    self.snippet.uploadAsFile = self.shareCheckBox.state;
    
    // Title View
    [self.titleTextField setPlaceholderString:kMainTitlePlaceholder];
    
    // Comment View
    [self.commentTextView setString:@""];
    [self.commentTextView setPlaceholderString:kMainCommentPlaceholder];
    
    // Source Text View
    [self.sourceTextView setDelegate:self];
    [self.sourceTextView setWrappingBehavioursEnabled:YES];
    [self.sourceTextView setReadOnly:NO];
    [self.sourceTextView setMode:self.snippet.filetype];
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
    
    [self configureTeamButton];
    [self configureRoomButton];
    
    self.cancelButton.title = kCancelButtonTitle;
    self.cancelButton.hidden = !isSLKPlugin();
    self.acceptButton.title = kUploadButtonTitle;
    self.shareCheckBox.title = kMainCheckBoxTitle;
}

- (void)configureTeamButton
{
    [self.teamButton removeAllItems];
    
    if ([SLKAccount allAccounts].count > 0) {
        [self.teamButton addItemsWithTitles:[SLKAccount teamNames]];
    }
    
    [self.teamButton insertItemWithTitle:@"" atIndex:0]; // First element is empty, to enable to clean states.
    [self.teamButton insertItemWithTitle:kAddTeamButtonTitle atIndex:self.teamButton.numberOfItems];
    
    if (![SLKAccount currentAccount]) {
        [self.teamButton selectItemAtIndex:0];
    }
    else {
        [self.teamButton selectItemAtIndex:[self indexOfCurrentAccount]];
    }
}

- (void)configureRoomButton
{
    [self.roomButton removeAllItems];
    
    // Doesn't configure the button and disables it, when the team id isn't available
    if (!isNonEmptyString(self.snippet.teamId)) {
        self.roomButton.enabled = NO;
        return;
    }
    
    // Always has the option to share privately
    [self.roomButton addItemWithTitle:kSharePrivateButtonTitle];
    self.roomButton.enabled = YES;
    
    if ([SLKRoomManager hasRooms])
    {
        NSArray *channels = [SLKRoomManager roomNamesForType:SLKRoomTypeChannel];
        NSArray *groups = [SLKRoomManager roomNamesForType:SLKRoomTypeGroup];
        NSArray *ims = [SLKRoomManager roomNamesForType:SLKRoomTypeIM];
        
        if (channels.count > 0) {
            NSMenuItem *separator = [NSMenuItem separatorItem];
            separator.tag = SLKRoomTypeChannel;
            [[self.roomButton menu] addItem:separator];
            
            [self.roomButton addItemsWithTitles:channels];
        }
        
        if (groups.count > 0) {
            if (channels.count > 0) {
                NSMenuItem *separator = [NSMenuItem separatorItem];
                separator.tag = SLKRoomTypeGroup;
                [[self.roomButton menu] addItem:separator];
            }
            
            [self.roomButton addItemsWithTitles:groups];
        }
        
        if (ims.count > 0) {
            if (groups.count > 0 || channels.count > 0) {
                NSMenuItem *separator = [NSMenuItem separatorItem];
                separator.tag = SLKRoomTypeIM;
                [[self.roomButton menu] addItem:separator];
            }
            
            [self.roomButton addItemsWithTitles:ims];
        }
        
        [self selectAppropriateRoom];
    }
    else {
        [self reloadRoomsIfNeeded];
    }
}

- (void)selectAppropriateRoom
{
    if (self.roomButton.itemTitles.count < 3) {
        return;
    }
    
    NSString *channelId = [SLKAccount currentAccount].channelId;
    
    if (isNonEmptyString(channelId)) {
        SLKRoom *room = [SLKRoomManager roomForId:channelId];
        [self.roomButton selectItemWithTitle:room.name];
    }
    else {
        [self.roomButton selectItemAtIndex:2];
    }
    
    [self roomChanged:self.roomButton];
}

- (void)updateAcceptButton
{
    if (self.isUploading ||
        self.sourceTextView.string.length == 0 ||
        !self.snippet.teamId ||
        (!self.snippet.uploadAsFile && !self.snippet.channelId)) {
        self.acceptButton.enabled = NO;
    }
    else {
        self.acceptButton.enabled = YES;
    }
}


#pragma mark - Events

- (void)presentLoginForm
{
    NSString *nibName = NSStringFromClass([XCSLoginViewController class]);
    NSBundle *bundle = SLKBundle();
    
    self.loginViewController = [[XCSLoginViewController alloc] initWithNibName:nibName bundle:bundle];
    NSWindow *window = [[NSWindow alloc] init];
    window.contentViewController = self.loginViewController;
    
    [self.window beginSheet:window completionHandler:NULL];
    
    __weak __typeof(self)weakSelf = self;
    
    [self.loginViewController setCompletionHandler:^(BOOL didLogin){
        
        // Close the plugin if no account has been registered.
        if ([SLKAccount forceLogin]) {
            [weakSelf dismiss:nil returnCode:NSModalResponseCancel];
        }
        else {
            [weakSelf.window endSheet:window];
            [weakSelf configureTeamButton];
            [weakSelf teamChanged:weakSelf.teamButton];
        }
    }];
}

- (void)reloadRoomsIfNeeded
{
    self.loading = YES;
    
    [SLKRoomManager getAvailableRooms:^(NSError *error) {
        if (!error) {
            [self configureRoomButton];
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
    
    [self.snippet setFiletype:mode];
    [self.sourceTextView setMode:mode];
}

- (IBAction)teamChanged:(NSPopUpButton *)sender
{
    NSString *title = sender.titleOfSelectedItem;
    
    if (title.length == 0) {
        self.snippet.teamId = nil;
        self.snippet.channelId = nil;
        
        [self configureRoomButton];
    }
    else if ([title isEqualToString:kAddTeamButtonTitle]) {
        [self performSelector:@selector(presentLoginForm) withObject:nil afterDelay:0.3];
    }
    else {
        NSInteger idx = [self.teamButton indexOfItemWithTitle:title];
        idx--; // Decrements to consider the space at first position
        
        SLKAccount *account = [SLKAccount allAccounts][idx];
        
        // Set as the current account
        [account setAsCurrent];
        
        // Updates the target team of the snippet
        self.snippet.teamId = account.teamId;
        
        [self configureRoomButton];
    }
    
    [self updateAcceptButton];
}

- (IBAction)roomChanged:(NSPopUpButton *)sender
{
    NSMenuItem *selectedItem = self.roomButton.selectedItem;
    NSString *title = selectedItem.title;
    
    NSString *channelId = nil;
    
    if (!selectedItem.isSeparatorItem && title.length > 0 && ![title isEqualToString:kSharePrivateButtonTitle]) {
        SLKRoom *room = [SLKRoomManager roomForName:title];
        channelId = room.tsid;
    }
    
    self.snippet.channelId = channelId;
    [[SLKAccount currentAccount] setChannelId:channelId];
    
    [self updateAcceptButton];
}

- (IBAction)uploadAsFileChanged:(NSButton *)sender
{
    self.snippet.uploadAsFile = sender.state;
    self.titleTextField.enabled = sender.state;
    
    [self updateAcceptButton];
}

- (IBAction)cancelForm:(NSButton *)sender
{
    [[SLKAPIClient sharedClient] cancelRequestsIfNeeded];
    
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
    
    [[SLKAPIClient sharedClient] uploadSnippet:self.snippet completion:^(NSDictionary *JSON, NSError *error) {
        self.uploading = NO;
        [self didSubmitSnippetWithError:error];
    }];
}

- (void)dismiss:(id)sender returnCode:(NSModalResponse)returnCode
{
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


#pragma mark - Lifeterm methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

@end
