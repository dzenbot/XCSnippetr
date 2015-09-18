//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <AppKit/AppKit.h>

@class XCSMainWindowController;

@interface XCSnippetrPlugin : NSObject

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) XCSMainWindowController *mainWindowController;

+ (instancetype)sharedPlugin;

@end