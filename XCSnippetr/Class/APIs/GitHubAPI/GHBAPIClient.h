//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSBaseAPI.h"

#import "GHBAPIConstants.h"

@class SLKSnippet;

@interface GHBAPIClient : XCSBaseAPI

/**
 Uploads a code snippet in GitHub Gist.
 If a previous request was pending, it is first cancelled before performing a new request.
 
 @param snippet The snippet object containing all the necessairy metadata.
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a JSON response (either a File object or a Message object, depending of how the snippet was uploaded). If unsuccessfully, it returns an Error.
 */
- (void)createGist:(SLKSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion;

@end