//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

#import "ACEModeNames.h"

/**
 Returns a ACEMode representation of a file name (name + extension).
 
 @param filetype The file extension.
 @return A ACEMode type.
 */
ACEMode ACEModeForFileName(NSString *fileName);

/**
 Returns a Slack internal string representation of a ACEMode type.
 This is used to match the API constants for file types.
 
 @param mode The ACEMode type.
 @return A Slack string type.
 */
NSString *NSStringFromACEMode(ACEMode mode);