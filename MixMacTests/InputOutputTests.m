//
//  InputOutpitTests.m
//  MixMacTests
//
//  Created by Водолазкий В.В. on 26/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import "MIXTest.h"
#import "MIXCPU.h"

#define TEST_BLOCK_SIZE	128


#define TEST_WRITE		2500							// Memory block location for OUT command
#define TEST_READ		(TEST_WRITE+TEST_BLOCK_SIZE)	// Address for IN command buffer



@interface InputOutputTests : MIXTest
{
	MIXWORD	testBlock[TEST_BLOCK_SIZE];
}
@end

@implementation InputOutputTests

- (void)setUp
{
	[super setUp];
	// fill test block for reading/wriing and comparison
	for (int i = 0; i < TEST_BLOCK_SIZE; i++) {
		testBlock[i] = [self mixWordFromInteger:i*23];
	}
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

// Test read, write, positioning in MT device

- (void)testMT {
	// init memory zone
	[self copyTestBlockToMemory:TEST_WRITE];
	BOOL copyOK = [self compareTestBlockWithMemory:TEST_WRITE];
	XCTAssert(copyOK, @"Memory block should be initialised properly");
	if (!copyOK) {
		return;
	}
	
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - Utilities

- (BOOL) compareTestBlockWithMemory:(int)startIndex
{
	BOOL blockOK = YES;
	for (int i = 0; i < TEST_BLOCK_SIZE; i++) {
		long a = [self integerFromMIXWORD:testBlock[i]];
		long b = [self integerFromMIXWORD:[cpu memoryWordForCellIndex:startIndex+i]];
		if (a != b) {
			blockOK = NO;
		}
		XCTAssert(a == b, @"data at offset of %d are not the same!",i);
	}
	return blockOK;
}

/**
 	Copy data from testBlock array todesignated area in cpu' memory
 */
- (void) copyTestBlockToMemory:(int)startIndex
{
	for (int i = 0; i < TEST_BLOCK_SIZE; i++) {
		[cpu setMemoryWord:testBlock[i] forCellIndex:startIndex+i];
	}
}

/**
 	Fill area designated to be used as memory block for input/output operations
 	with zeros.
 */
- (void) clearTestBlockArea:(int)startIndex
{
	MIXWORD empty = [self mixWordFromInteger:0];
	for (int i = 0; i < TEST_BLOCK_SIZE; i++) {
		[cpu setMemoryWord:empty forCellIndex:startIndex+i];
	}

}

@end
