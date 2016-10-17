//
//  TestTests.m
//  TestTests
//
//  Created by 宋晓光 on 17/10/2016.
//  Copyright © 2016 qfu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TQLocationConverter.h"

@interface TestTests : XCTestCase

@end

@implementation TestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testIsLocationOutOfChina{
  
  BOOL isOutOfChina = NO;
  
  //  Part 1
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(43.9391930000,105.1132810000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 1 failed.");
  
  //  Part 2
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(23.9423720000,121.0821340000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 2 failed.");
  
  //  Part 3
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(21.2779820000,105.407565000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 3 failed.");
  
  //  Part 4
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(40.6485130000,-109.9160210000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 4 failed.");
  
  //  Part 5
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(-23.4521890000,124.8351820000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 5 failed.");
  
  //  Part 6
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(52.3696860000,-0.8551500000)];
  XCTAssertEqual(isOutOfChina, YES,@"Part 6 failed.");
  
  //  Part 7
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(40.6424438827,114.3790442482)];
  XCTAssertEqual(isOutOfChina, NO,@"Part 7 failed.");
  
  //  Part 8
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(32.7132247538,119.3814515758)];
  XCTAssertEqual(isOutOfChina, NO,@"Part 8 failed.");
  
  //  Part 9
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(19.3281880801,109.9619378181)];
  XCTAssertEqual(isOutOfChina, NO,@"Part 9 failed.");
  
  //  Part 10
  isOutOfChina = [TQLocationConverter isLocationOutOfChina:CLLocationCoordinate2DMake(38.5939174139,76.1092626238)];
  XCTAssertEqual(isOutOfChina, NO,@"Part 10 failed.");
}

@end
