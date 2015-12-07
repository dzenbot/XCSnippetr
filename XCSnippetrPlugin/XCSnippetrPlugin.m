//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSnippetrPlugin.h"
#import "XCSMainWindowController.h"
#import "XCSSnippetRepository.h"
#import "XCSStrings.h"

#import "DTXcodeUtils.h"
#import "DTXcodeHeaders.h"

static XCSnippetrPlugin *_sharedPlugin;

static NSString * const kDVTSourceTextView =                @"DVTSourceTextView";
static NSString * const kIDEWorkspaceWindowController =     @"IDEWorkspaceWindowController";
static NSString * const kIDEWorkspaceWindow =               @"IDEWorkspaceWindow";

@interface XCSnippetrPlugin() <NSTextViewDelegate>
@end

@implementation XCSnippetrPlugin

#pragma mark - Initilization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *bundleName = [[NSBundle mainBundle] infoDictionary][kCFBundleName];
    
    if ([bundleName isEqual:kIDEXcodeTitle]) {
        dispatch_once(&onceToken, ^{
            _sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    self = [super init];
    if (self) {
        self.bundle = plugin;

        // Listen to menu tracking to hook up the contextual menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidBeginTracking:) name:NSMenuDidBeginTrackingNotification object:nil];
    }
    return self;
}


#pragma mark - Getters

+ (instancetype)sharedPlugin
{
    return _sharedPlugin;
}

- (XCSMainWindowController *)mainWindowController
{
    if (!_mainWindowController) {
        
        _mainWindowController = [[XCSMainWindowController alloc] initWithBundle:self.bundle];
        _mainWindowController.font = [DTXcodeUtils currentSourceTextView].font;
    }
    return _mainWindowController;
}

- (NSString *)selectedText
{
    NSTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
    
    if (sourceTextView && [sourceTextView isKindOfClass:NSClassFromString(kDVTSourceTextView)]) {
        return [[sourceTextView string] substringWithRange:[sourceTextView selectedRange]];
    }
    return nil;
}

NSString *activeDocumentPath()
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSArray *controllers = (NSArray *)[NSClassFromString(kIDEWorkspaceWindowController) performSelector:@selector(workspaceWindowControllers)];
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    
    if ([keyWindow isKindOfClass:NSClassFromString(kIDEWorkspaceWindow)]) {
        for (IDEWorkspaceWindowController *windowController in controllers)
        {
            if ([windowController.window isEqual:keyWindow]) {
                
                id editorArea = nil;
                id document = nil;
                
                @try { editorArea = [windowController performSelector:@selector(editorArea)]; }
                @catch (NSException *exception) { return nil; }
                
                @try { document = [editorArea performSelector:@selector(primaryEditorDocument)]; }
                @catch (NSException *exception) { return nil; }
                
                return [document fileURL].absoluteString;
            }
        }
    }
    
    return nil;
    
#pragma clang diagnostic pop
}

NSString *activeDocumentName()
{
    NSString *filePath = activeDocumentPath();
    return [filePath lastPathComponent];
}

- (BOOL)canPresentSnippetEditor
{
    if (![self menuTarget]) {
        return NO;
    }
    
    return YES;
}

- (id)menuTarget
{
    return (self.selectedText.length > 1) ? self : nil;
}


#pragma mark - Menu

- (void)configureMenuIfNeeded:(NSMenu *)menu
{
    if (![menu isKindOfClass:[NSMenu class]]) {
        return;
    }
    
    NSMenu *submenu = nil;
    
    if ([menu itemWithTitle:kIDESubMenuReferenceTitle]) {
        submenu = menu;
    }
    
    if (submenu) {
        id target = [self menuTarget];
        NSInteger idx = [self appropriateIndexInMenu:menu];
        
        // Creates the Slack Menu Item
        NSMenuItem *slackItem = [submenu itemWithTitle:kTitleShareSlack];
        
        // Creates the Gist Menu Item
        NSMenuItem *gistItem = [submenu itemWithTitle:kTitleShareGist];
        
        // Creates the Xcode Menu Item
        NSMenuItem *xcodeItem = [submenu itemWithTitle:kTitleAddXcode];
        
        // Configure Slack Item
        if (!slackItem) {
            slackItem = [[NSMenuItem alloc] initWithTitle:kTitleShareSlack action:@selector(presentSnippetEditor:) keyEquivalent:@""];
            slackItem.tag = XCSServiceSlack;
            slackItem.target = target;
            
            [submenu insertItem:slackItem atIndex:idx];
            
            idx++;
        }
        else {
            slackItem.target = target;
        }
        
        // Configure Gist Item
        if (!gistItem) {
            gistItem = [[NSMenuItem alloc] initWithTitle:kTitleShareGist action:@selector(presentSnippetEditor:) keyEquivalent:@""];
            gistItem.tag = XCSServiceGithub;
            gistItem.target = target;
            
            [submenu insertItem:gistItem atIndex:idx];
            
            idx++;
        }
        else {
            gistItem.target = target;
        }
        
        // Configure Slack Item
        if (!xcodeItem) {
            xcodeItem = [[NSMenuItem alloc] initWithTitle:kTitleAddXcode action:@selector(presentSnippetEditor:) keyEquivalent:@""];
            xcodeItem.tag = XCSServiceXcode;
            xcodeItem.target = target;
            
            [submenu insertItem:xcodeItem atIndex:idx];
            
            idx++;
        }
        else {
            xcodeItem.target = target;
        }
        
        NSMenuItem *separator = [NSMenuItem separatorItem];
        [submenu insertItem:separator atIndex:idx];
    }
}

- (NSInteger)appropriateIndexInMenu:(NSMenu *)menu
{
    if ([menu itemWithTitle:kIDEBarMenuReferenceTitle]) {
        NSMenuItem *menuItem = [menu itemWithTitle:kIDEBarMenuReferenceTitle];
        
        NSInteger idx = [[menuItem submenu] indexOfItemWithTitle:kIDESubMenuReferenceTitle];
        
        // So the title is above 'Open in Assistant Editor'
        idx += 3;
        
        return idx;
    }
    else {
        NSInteger idx = [menu indexOfItemWithTitle:kIDESubMenuReferenceTitle];
        NSMenuItem *item = [menu itemAtIndex:idx];
        
        while ([item isSeparatorItem]) {
            idx--;
            item = [menu itemAtIndex:idx];
        }
        
        // So the title is above 'Open in Assistant Editor'
        idx-=2;
        
        return idx;
    }
}


#pragma mark - Notifications

- (void)menuDidBeginTracking:(NSNotification *)notification
{
    id object = [notification object];
    id name = [notification name];
    
    if ([name isEqualToString:NSMenuDidBeginTrackingNotification]) {
        if (object) {
            [self configureMenuIfNeeded:object];
        }
    }
}


#pragma mark - Events

- (void)presentSnippetEditor:(NSMenuItem *)menuItem
{
    if (![self canPresentSnippetEditor]) {
        return;
    }
    
    NSTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
    NSRange selectedRange = sourceTextView.selectedRange;
    
    NSString *documentName = activeDocumentName();
    NSString *selectedText = self.selectedText;
    
    // Setup content
    self.mainWindowController.fileName = documentName;
    self.mainWindowController.fileContent = selectedText;
    self.mainWindowController.font = sourceTextView.font;
    self.mainWindowController.service = menuItem.tag;
    
    __weak __typeof(self) weakSelf = self;
    
    self.mainWindowController.completionHandler = ^(NSModalResponse returnCode) {
        weakSelf.mainWindowController = nil;
    };
        
    // Deselects the text in Xcode
    sourceTextView.selectedRange = NSMakeRange(selectedRange.location, 0);
    
    NSWindow *window = self.mainWindowController.window;
    NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
    
    NSRect mainFrame = mainWindow.frame;
    NSRect windowFrame = window.frame;

    windowFrame.origin.x = mainFrame.origin.x+(mainFrame.size.width/2-windowFrame.size.width/2);
    windowFrame.origin.y = mainFrame.origin.y+(mainFrame.size.height-windowFrame.size.height);
    [window setFrameOrigin:windowFrame.origin];
    
    [self.mainWindowController showWindow:self];
}

//- (void)saveCodeSnippet:(NSMenuItem *)menuItem
//{
//    XCSSnippet *snippet = [[XCSSnippet alloc] init];
//    snippet.title = NSLocalizedString(@"My Code Snippet", nil);
//    snippet.filename = activeDocumentName();
//    snippet.content = self.selectedText;
//    
//    [[XCSSnippetRepository defaultRepository] saveSnippet:snippet completion:^(NSString *filePath, NSError *error) {
//        NSLog(@"%s filePath: %@ error: %@",__FUNCTION__, filePath, error);
//    }];
//}


#pragma mark - Lifeterm

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMenuDidBeginTrackingNotification object:nil];
    
    _mainWindowController = nil;
}

@end
