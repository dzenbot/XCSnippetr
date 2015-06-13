//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Cocoa/Cocoa.h>

@class SLKAccount;

typedef void (^SLKLoginViewControllerCompletionHandler)(BOOL didLogin);

@interface XCSLoginViewController : NSViewController <NSTextFieldDelegate>

@property (nonatomic, assign) IBOutlet NSTextField *tokenTextField;
@property (nonatomic, assign) IBOutlet NSTextView *detailTextView;

@property (nonatomic, assign) IBOutlet NSButton *cancelButton;
@property (nonatomic, assign) IBOutlet NSButton *acceptButton;

@property (nonatomic, assign) IBOutlet NSTextField *errorLabel;
@property (nonatomic, assign) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) SLKLoginViewControllerCompletionHandler completionHandler;

- (IBAction)cancelForm:(id)sender;
- (IBAction)submitForm:(id)sender;

@end
