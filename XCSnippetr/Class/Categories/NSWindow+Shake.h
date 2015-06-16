//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <AppKit/AppKit.h>

@interface NSWindow (Shake)

/**
 Makes a window shake horizontally, useful for error feedback,
 usually present in built-in apps on Mac OS X.
 */
- (void)shake;

@end
