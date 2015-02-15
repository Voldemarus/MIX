//
//  MixMacTests.m
//  MixMacTests
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "MIXCPU.h"

#define TEST_CELL		2000			// memory cell where data is stored
#define TEST_PC			0				// Program counter to store command for testing

#define TEST_CINDEX		2010			// cell in memory addressed with index offset
#define TEST_CINDEX2	1500			// seconde cell whic his addressed by index register

@interface MixMacTests : XCTestCase {
	MIXCPU	*cpu;
}

@end

@implementation MixMacTests

- (void)setUp {
    [super setUp];
	cpu = [MIXCPU sharedInstance];
	XCTAssert(cpu, @"CPU instance should be ceated");
	
	MIXWORD memoryCell;
	memoryCell.sign = YES;
	memoryCell.byte[0] = 80 >> 6;
	memoryCell.byte[1] = 80 & 0x3f;
	memoryCell.byte[2] = 3;
	memoryCell.byte[3] = 5;
	memoryCell.byte[4] = 4;
	
	NSLog(@"Value stored to memory");
	[self printMemoryCell:memoryCell];
	
	[cpu setMemoryWord:memoryCell forCellIndex:TEST_CELL];
	
	NSLog(@"memory contents");
	MIXWORD cellInMem = [cpu memoryWordForCellIndex:TEST_CELL];
	[self printMemoryCell:cellInMem];
	BOOL equal = [self compareWordA:memoryCell withWordB:cellInMem];
	XCTAssertTrue(equal,@"Word should be properly written to memory and read back");
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -

//
// LDA command test
//
- (void)testLDA {
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"LDA"];
	XCTAssert(ldaCommand, @"LDA Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = 8;				// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	MIXWORD oldA = cpu.A;
	NSLog(@"LDA 2000 - accumulator before");
	[self printMemoryCell:oldA];
	
	[cpu executeCurrentOperation];
	
	NSLog(@"LDA 2000 - accumulator after");
	[self printMemoryCell:cpu.A];
	BOOL isEqual = [self compareWordA:cpu.A withWordB:[cpu memoryWordForCellIndex:TEST_CELL]];
	XCTAssertTrue(isEqual, @"LDA 2000 should copy content of cell to accumulator w/o changes");
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"Program counter should be inremented");
	
	// LDA 2000 (1:5)
	command.byte[3] = 8 + 5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator
	NSLog(@"LDA 2000 (1:5) - accumulator before");
	[self printMemoryCell:oldA];
	BOOL accIsClear = [self compareWordA:oldA withWordB:cpu.A];
	XCTAssertTrue(accIsClear, @"accumulator property should be writable");
	
	[cpu executeCurrentOperation];
	
	NSLog(@"LDA 2000  (1:5) - accumulator after");
	[self printMemoryCell:cpu.A];
	// Result should differ from the data in Memory only in sign byte.
	MIXWORD toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.sign = !toTest.sign;
	isEqual = [self compareWordA:toTest withWordB:cpu.A];
	XCTAssertTrue(isEqual, @"LDA 2000 (1:5) should copy all fields except the sign byte");
	
	// LDA 2000 (3:5)
	command.byte[3] = 3*8 + 5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator

	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000  (3:5) - accumulator after");
	[self printMemoryCell:cpu.A];
	toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.sign = NO;
	toTest.byte[0] = 0;
	toTest.byte[1] = 0;
	isEqual = [self compareWordA:toTest withWordB:cpu.A];
	XCTAssertTrue(isEqual, @"LDA 2000 (3:5) should copy only last three fields and no sign byte");
	
	// LDA 2000 (0:3)
	command.byte[3] = 0*8 + 3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000  (0:3) - accumulator after");
	[self printMemoryCell:cpu.A];
	toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.byte[4] = toTest.byte[2];
	toTest.byte[3] = toTest.byte[1];
	toTest.byte[2] = toTest.byte[0];
	toTest.byte[1] = 0;
	toTest.byte[0] = 0;
	isEqual = [self compareWordA:toTest withWordB:cpu.A];
	XCTAssertTrue(isEqual, @"LDA 2000 (0:3) should copy only left three fields and sign byte");
	
	// LDA 2000 (4:4)
	command.byte[3] = 4*8 + 4;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000  (4:4) - accumulator after");
	[self printMemoryCell:cpu.A];
	XCTAssertEqual(cpu.A.byte[4], 5, @"LDA 2000 (4:4) should copy only 4th field from the memoryCell");
	XCTAssertEqual(cpu.A.sign, NO, @"LDA 2000 (4:4) should copy only 4th field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE-1; i++) {
		XCTAssertEqual(cpu.A.byte[i], 0, @"LDA 2000 (4:4) should copy only 4th field from the memoryCell");
	}
	
	// LDA 2000 (0:0)
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000  (0:0) - accumulator after");
	[self printMemoryCell:cpu.A];
	XCTAssertEqual(cpu.A.sign, YES, @"LDA 2000 (0:0) should copy only sign field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		XCTAssertEqual(cpu.A.byte[i], 0, @"LDA 2000 (0:0) should copy only sign field from the memoryCell");
	}

	// LDA 2000 (1:1)
	command.byte[3] = 1*8+1;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000  (1:1) - accumulator after");
	[self printMemoryCell:cpu.A];
	XCTAssertEqual(cpu.A.byte[4], 1, @"LDA 2000 (1:1) should copy only 0th field from the memoryCell");
	XCTAssertEqual(cpu.A.sign, NO, @"LDA 2000 (1:1) should copy only 0th field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE-1; i++) {
		XCTAssertEqual(cpu.A.byte[i], 0, @"LDA 2000 (1:1) should copy only 0th field from the memoryCell");
	}
	
	// Prepare index registers
	[cpu storeOffset:(TEST_CINDEX - TEST_CELL) inIndexRegister:2];			// I2
	[cpu storeOffset:(TEST_CINDEX2 - TEST_CELL) inIndexRegister:3];			// I3
	
	NSLog(@"I2 = %d", [cpu offsetInIndexRegister:2]);
	[self printIndex:cpu.index2];
	XCTAssertEqual([cpu offsetInIndexRegister:2], (TEST_CINDEX - TEST_CELL),
				   @"Index register should proper set positive offset");
	
	NSLog(@"I3 = %d", [cpu offsetInIndexRegister:3]);
	[self printIndex:cpu.index3];
	XCTAssertEqual([cpu offsetInIndexRegister:3], (TEST_CINDEX2 - TEST_CELL),
				   @"Index register should proper set negative offset");
	
	int testvalue1 = 377;
	[cpu storeNumber:testvalue1 forCellIndex:TEST_CINDEX];
	NSLog(@"test value for I2 access test");
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CINDEX]];
	XCTAssertEqual(testvalue1, [cpu memoryContentForCellIndex:TEST_CINDEX], @"Value should be properly written to memory");
	
	int testValue3 = -2012;
	NSLog(@"test value for I3 access test");
	[cpu storeNumber:testValue3 forCellIndex:TEST_CINDEX2];
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CINDEX2]];
	XCTAssertEqual(testValue3, [cpu memoryContentForCellIndex:TEST_CINDEX2], @"Value should be properly written to memory");
	
	// Data prepared. synthesize command for indexed access
	// LDA 2000, 2
	command.byte[3] = 5;	// no modifier all fields are loaded
	command.byte[2] = 2;	// I2		(effective address should be TEST_CINDEX)
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator

	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000,2  - accumulator after");
	[self printMemoryCell:cpu.A];
	isEqual = [self compareWordA:[cpu memoryWordForCellIndex:TEST_CINDEX] withWordB:cpu.A];
	XCTAssertTrue(isEqual,@"value should be loaded with help of index register I2 from TEST_CINDEX cell");
	
	// LDA 2000, 3 -- negative offset is stored in index register

	command.byte[2] = 3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldA;			// clear Accumulator

	[cpu executeCurrentOperation];
	NSLog(@"LDA 2000,3  - accumulator after");
	[self printMemoryCell:cpu.A];
	isEqual = [self compareWordA:[cpu memoryWordForCellIndex:TEST_CINDEX2] withWordB:cpu.A];
	XCTAssertTrue(isEqual,@"value should be loaded with help of index register I2 from TEST_CINDEX2 cell");

	
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


#pragma mark - Service methoda

- (void) printMemoryCell:(MIXWORD)cell
{
	NSLog(@  "------------------------------");
	NSLog(@"| %@ | %2d | %2d | %2d | %2d | %2d |", (cell.sign ? @"-" : @"+"),
		  cell.byte[0], cell.byte[1], cell.byte[2], cell.byte[3], cell.byte[4]);
	NSLog(@  "------------------------------");

}


- (void) printIndex:(MIXINDEX) cell
{
	NSLog(@  "---------------");
	NSLog(@"| %@ | %2d | %2d |",
		  (cell.sign ? @"-" : @"+"),
		  cell.indexByte[0], cell.indexByte[1]);
	NSLog(@  "---------------");

}

//
// Compare two words
//
- (BOOL) compareWordA:(MIXWORD) wordA withWordB:(MIXWORD) wordB
{
	if (wordA.sign != wordB.sign) {
		return NO;
	}
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		if (wordA.byte[i] != wordB.byte[i]) {
			return NO;
		}
	}
	return YES;
}


@end