//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import <ACEView/ACEModes.h>

#import "XCSService.h"

@interface XCSSnippet : NSObject

#pragma mark - Generic Values

/** The snippet title. (optional) */
@property (nonatomic, copy) NSString *title;
/** The snippet content. (required) */
@property (nonatomic, copy) NSString *content;
/** The snippet initial comment. (optional) */
@property (nonatomic, copy) NSString *comment;
/** The original file name where the text was initially selected. (automatic) */
@property (nonatomic, copy) NSString *filename;
/** The code type such as objective-c, javascript, etc. (automatic) */
@property (nonatomic) ACEMode filetype;
/** Upload as a non-public snippet. */
@property (nonatomic) BOOL uploadAsPrivate;
/** Snippet URL assigned after successful upload. */
@property (nonatomic, copy) NSURL *URL;


#pragma mark - Slack Specific Values

/** Slack Only: The team's id where to upload. (required) */
@property (nonatomic, copy) NSString *teamId;
/** Slack Only: The channel's id where to upload. (optional) */
@property (nonatomic, copy) NSString *channelId;
/** Slack Only: YES if the snippet should be uploaded as a file. NO if the snippet should be uploaded as an enced code block message (optional). */
@property (nonatomic) BOOL uploadAsSnippet;


#pragma mark - Data Payload Converter

/** 
 Returns a set of parameters to when uploading a snippet to a specific service.
 
 @param service The API service type (Slack or Github)
 @return A JSON structure containing required data for interacting with the service's API.
 */
- (NSDictionary *)paramsForService:(XCSService)service;

@end