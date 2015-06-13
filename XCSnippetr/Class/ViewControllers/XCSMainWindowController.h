//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Cocoa/Cocoa.h>
#import <ACEView/ACEView.h>

typedef void (^SLKMainWindowControllerCompletionHandler)(NSModalResponse returnCode);

@interface XCSMainWindowController : NSWindowController <ACEViewDelegate>

@property (nonatomic, assign) IBOutlet NSTextField *titleTextField;
@property (nonatomic, assign) IBOutlet ACEView *sourceTextView;
@property (nonatomic, assign) IBOutlet NSTextView *commentTextView;

@property (nonatomic, assign) IBOutlet NSPopUpButton *syntaxButton;
@property (nonatomic, assign) IBOutlet NSPopUpButton *teamButton;
@property (nonatomic, assign) IBOutlet NSPopUpButton *roomButton;
@property (nonatomic, assign) IBOutlet NSButton *shareCheckBox;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, assign) IBOutlet NSButton *cancelButton;
@property (nonatomic, assign) IBOutlet NSButton *acceptButton;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileContent;
@property (nonatomic, copy) NSFont *font;

@property (nonatomic, strong) SLKMainWindowControllerCompletionHandler completionHandler;

/* IB Fucking Actions*/
- (IBAction)syntaxModeChanged:(id)sender;
- (IBAction)teamChanged:(id)sender;
- (IBAction)roomChanged:(id)sender;
- (IBAction)uploadAsFileChanged:(id)sender;

- (IBAction)cancelForm:(id)sender;
- (IBAction)submitForm:(id)sender;

@end
