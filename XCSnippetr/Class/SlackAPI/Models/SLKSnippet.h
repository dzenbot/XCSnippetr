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

@interface SLKSnippet : NSObject

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
/** The team's id where to upload. (required) */
@property (nonatomic, copy) NSString *teamId;
/** The channel's id where to upload. (optional) */
@property (nonatomic, copy) NSString *channelId;

/** YES if the snippet should be uploaded as a file. No if the snippet is an enced code block message.  (automatic) */
@property (nonatomic) BOOL uploadAsFile;

/** 
 Returns a set of parameters to be used when uploading the snippet to Slack's API.
 */
- (NSDictionary *)params;

@end