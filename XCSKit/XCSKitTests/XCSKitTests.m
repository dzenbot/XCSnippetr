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
#import <XCSKit/XCSKit.h>

#import "XCSSlackConstants.h"

#import "NSJSONSerialization+FileContent.h"

@interface XCSKitTests : XCTestCase
@end

@implementation XCSKitTests

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
    XCTAssertNotNil(XCSBundle());
    
    XCTAssertEqualObjects(XCSBundleName(), @"XCSnippetr");
    XCTAssertEqualObjects(XCSBundleIdentifier(), @"com.dzn.XCSnippetrApp");
    
    XCTAssertFalse(isXCSPlugin([NSBundle mainBundle]));
}

- (void)testAccountSerialization
{
    id response = [NSJSONSerialization JSONObjectFromBundleResource:kSlackAPIMethodAuthTest];
    
    XCSAccount *account = [[XCSAccount alloc] initWithResponse:response service:XCSServiceSlack];
    
    XCTAssertNotNil(account);
    
    XCTAssertEqualObjects(account.teamName, @"Test Team");
    XCTAssertEqualObjects(account.teamId, @"T02C7QGM9");
    XCTAssertEqualObjects(account.userName, @"john");
    XCTAssertEqualObjects(account.userId, @"U02M9KR1X");
}

- (void)testRoomsSerialization
{
    id response = [NSJSONSerialization JSONObjectFromBundleResource:kSlackAPIMethodRTMStart];
    
    NSDictionary *rooms = [XCSRoom roomsFromResponse:response];
    
    NSArray *channels = rooms[XCSKeyFromRoomType(XCSRoomTypeChannel)];
    
    XCTAssertNotNil(channels);
    XCTAssertEqual(channels.count, 20);
    
    NSArray *ims = rooms[XCSKeyFromRoomType(XCSRoomTypeIM)];
    
    XCTAssertNotNil(ims);
    XCTAssertEqual(ims.count, 20);
}

- (void)testSnippetDeserialization
{
    // TODO: Test deserialization
    XCTAssert(YES, @"Pass");
}

@end
