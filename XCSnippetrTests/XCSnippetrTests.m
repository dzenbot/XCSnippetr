//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "XCSAccount.h"
#import "SLKRoom.h"
#import "SLKAPIConstants.h"
#import "XCSMacros.h"

#import "NSJSONSerialization+FileContent.h"

@interface XCSnippetrTests : XCTestCase
@end

@implementation XCSnippetrTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBundleMacros
{
    XCTAssertNotNil(SLKBundle());
    
    XCTAssertEqualObjects(SLKBundleName(), @"XCSnippetr");
    XCTAssertEqualObjects(SLKBundleIdentifier(), @"com.dzn.XCSnippetrdApp");

    XCTAssertFalse(isSLKPlugin());
}

- (void)testAccountSerialization
{
    id response = [NSJSONSerialization JSONObjectFromBundleResource:kSlackAPIMethodAuthTest];
        
    XCSAccount *account = [[XCSAccount alloc] initWithResponse:response];
    
    XCTAssertNotNil(account);
    
    XCTAssertEqualObjects(account.teamName, @"Test Team");
    XCTAssertEqualObjects(account.teamId, @"T02C7QGM9");
    XCTAssertEqualObjects(account.userName, @"john");
    XCTAssertEqualObjects(account.userId, @"U02M9KR1X");
}

- (void)testRoomsSerialization
{
    id response = [NSJSONSerialization JSONObjectFromBundleResource:kSlackAPIMethodRTMStart];
    
    NSDictionary *rooms = [SLKRoom roomsFromResponse:response];
    
    NSArray *channels = rooms[SLKKeyFromRoomType(SLKRoomTypeChannel)];
    
    XCTAssertNotNil(channels);
    XCTAssertEqual(channels.count, 20);
    
    NSArray *ims = rooms[SLKKeyFromRoomType(SLKRoomTypeIM)];
    
    XCTAssertNotNil(ims);
    XCTAssertEqual(ims.count, 20);
}

- (void)testSnippetDeserialization
{
    // TODO: Test deserialization
    XCTAssert(YES, @"Pass");
}

@end
