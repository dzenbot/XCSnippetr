//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

// Urls
static NSString * const kAPIBaseUrl =                   @"https://slack.com/api/";
static NSString * const kWebAPIUrl =                    @"https://api.slack.com/web";

// API Methods
static NSString * const kAPIMethodAuthTest =            @"auth.test";
static NSString * const kAPIMethodFilesUpload =         @"files.upload";
static NSString * const kAPIMethodChatPostMessage =     @"chat.postMessage";
static NSString * const kAPIMethodRTMStart =            @"rtm.start"; // To get all lists w/ 1 request (users, groups and channels)

// HTTP Methods
static NSString * const kHTTPMethodPOST =               @"POST";

// API Param keys
static NSString * const kAPIParamTeam =                 @"team";
static NSString * const kAPIParamTeamId =               @"team_id";
static NSString * const kAPIParamToken =                @"token";
static NSString * const kAPIParamIsArchived =           @"is_archived";
static NSString * const kAPIParamIsMember =             @"is_member";
static NSString * const kAPIParamIsChannel =            @"is_channel";
static NSString * const kAPIParamIsGroup =              @"is_group";
static NSString * const kAPIParamIsIM =                 @"is_im";
static NSString * const kAPIParamIsOpen =               @"is_open";
static NSString * const kAPIParamId =                   @"id";
static NSString * const kAPIParamTsid =                 @"tsid";
static NSString * const kAPIParamName =                 @"name";
static NSString * const kAPIParamRealName =             @"real_name";
static NSString * const kAPIParamUser =                 @"user";
static NSString * const kAPIParamUserId =               @"user_id";
static NSString * const kAPIParamUsers =                @"users";
static NSString * const kAPIParamAsUser =               @"as_user";
static NSString * const kAPIParamChannel =              @"channel";
static NSString * const kAPIParamChannels =             @"channels";
static NSString * const kAPIParamGroups =               @"groups";
static NSString * const kAPIParamIMs =                  @"ims";
static NSString * const kAPIParamContent =              @"content";
static NSString * const kAPIParamFilename =             @"filename";
static NSString * const kAPIParamTitle =                @"title";
static NSString * const kAPIParamInitialComment =       @"initial_comment";
static NSString * const kAPIParamFiletype =             @"filetype";
static NSString * const kAPIParamText =                 @"text";
static NSString * const kAPIParamError =                @"error";

// API values
static NSString * const kAPISlackbotId =                @"USLACKBOT";
static NSString * const kAPISlackbotName =              @"Slackbot";
