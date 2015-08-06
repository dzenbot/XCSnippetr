//
//  XCSBezelAlert.m
//  XCSnippetr-Builder
//
//  Created by pronebird on 8/6/15.
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//

#import "XCSBezelAlert.h"

static CGFloat const kDefaultDuration = 3.0;

@protocol XCSBezelAlertPanelInformalProtocol <NSObject>

- (instancetype)initWithIcon:(NSImage *)icon message:(NSString *)message parentWindow:(NSWindow *)parentWindow duration:(NSTimeInterval)duration;

@end

@implementation XCSBezelAlert

+ (void)showWithIcon:(NSImage *)icon message:(NSString *)message
{
    [self showWithIcon:icon message:message parentWindow:nil duration:kDefaultDuration];
}

+ (void)showWithIcon:(NSImage *)icon message:(NSString *)message parentWindow:(NSWindow *)parentWindow duration:(NSTimeInterval)duration
{
    Class alertClass = NSClassFromString(@"DVTBezelAlertPanel");
    
    // Use IDE window when parentWindow = nil
    if (!parentWindow) {
        parentWindow = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
    }
    
    NSPanel *alertPanel = [[alertClass alloc] initWithIcon:icon message:message parentWindow:parentWindow duration:duration];
    
    [alertPanel orderFront:nil];
}

@end
