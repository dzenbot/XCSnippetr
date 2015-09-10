//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "AppDelegate.h"
#import "XCSMainWindowController.h"

@interface AppDelegate ()
@property (nonatomic, strong) XCSMainWindowController *mainWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *nibName = NSStringFromClass([XCSMainWindowController class]);
    self.mainWindowController = [[XCSMainWindowController alloc] initWithWindowNibName:nibName];
    self.mainWindowController.service = XCSServiceGithub;
    
    [[self.mainWindowController window] makeKeyAndOrderFront:self];
}

@end
