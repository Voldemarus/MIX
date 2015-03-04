//
//  MixMacTests.m
//  MixMacTests
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "MIXTest.h"

@interface LoadStoreTests : MIXTest

@end

@implementation LoadStoreTests

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
	command.byte[4] = CMD_LDA;				// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];
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


//
// LDX command test
//
- (void)testLDX {
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"LDX"];
	XCTAssert(ldaCommand, @"LDX Command should be present in command list");
	
	// LDX 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_LDX;				// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	MIXWORD oldX = cpu.X;
	NSLog(@"LDX 2000 - accumulator before");
	[self printMemoryCell:oldX];
	
	[cpu executeCurrentOperation];
	
	NSLog(@"LDX 2000 - accumulator after");
	[self printMemoryCell:cpu.X];
	BOOL isEqual = [self compareWordA:cpu.X withWordB:[cpu memoryWordForCellIndex:TEST_CELL]];
	XCTAssertTrue(isEqual, @"LDX 2000 should copy content of cell to accumulator w/o changes");
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"Program counter should be inremented");
	
	// LDX 2000 (1:5)
	command.byte[3] = 8 + 5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.X = oldX;			// clear Accumulator
	NSLog(@"LDX 2000 (1:5) - accumulator before");
	[self printMemoryCell:oldX];
	BOOL accIsClear = [self compareWordA:oldX withWordB:cpu.X];
	XCTAssertTrue(accIsClear, @"extension register property should be writable");
	
	[cpu executeCurrentOperation];
	
	NSLog(@"LDX 2000  (1:5) - accumulator after");
	[self printMemoryCell:cpu.X];
	// Result should differ from the data in Memory only in sign byte.
	MIXWORD toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.sign = !toTest.sign;
	isEqual = [self compareWordA:toTest withWordB:cpu.X];
	XCTAssertTrue(isEqual, @"LDA X000 (1:5) should copy all fields except the sign byte");
	
	// LDX 2000 (3:5)
	command.byte[3] = 3*8 + 5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000  (3:5) - accumulator after");
	[self printMemoryCell:cpu.X];
	toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.sign = NO;
	toTest.byte[0] = 0;
	toTest.byte[1] = 0;
	isEqual = [self compareWordA:toTest withWordB:cpu.X];
	XCTAssertTrue(isEqual, @"LDX 2000 (3:5) should copy only last three fields and no sign byte");
	
	// LDA 2000 (0:3)
	command.byte[3] = 0*8 + 3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000  (0:3) - accumulator after");
	[self printMemoryCell:cpu.X];
	toTest = [cpu memoryWordForCellIndex:TEST_CELL];
	toTest.byte[4] = toTest.byte[2];
	toTest.byte[3] = toTest.byte[1];
	toTest.byte[2] = toTest.byte[0];
	toTest.byte[1] = 0;
	toTest.byte[0] = 0;
	isEqual = [self compareWordA:toTest withWordB:cpu.X];
	XCTAssertTrue(isEqual, @"LDX 2000 (0:3) should copy only left three fields and sign byte");
	
	// LDX 2000 (4:4)
	command.byte[3] = 4*8 + 4;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000  (4:4) - accumulator after");
	[self printMemoryCell:cpu.X];
	XCTAssertEqual(cpu.X.byte[4], 5, @"LDX 2000 (4:4) should copy only 4th field from the memoryCell");
	XCTAssertEqual(cpu.X.sign, NO, @"LDX 2000 (4:4) should copy only 4th field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE-1; i++) {
		XCTAssertEqual(cpu.X.byte[i], 0, @"LDX 2000 (4:4) should copy only 4th field from the memoryCell");
	}
	
	// LDX 2000 (0:0)
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000  (0:0) - accumulator after");
	[self printMemoryCell:cpu.X];
	XCTAssertEqual(cpu.X.sign, YES, @"LDX 2000 (0:0) should copy only sign field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		XCTAssertEqual(cpu.X.byte[i], 0, @"LDX 2000 (0:0) should copy only sign field from the memoryCell");
	}
	
	// LDX 2000 (1:1)
	command.byte[3] = 1*8+1;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000  (1:1) - accumulator after");
	[self printMemoryCell:cpu.X];
	XCTAssertEqual(cpu.X.byte[4], 1, @"LDX 2000 (1:1) should copy only 0th field from the memoryCell");
	XCTAssertEqual(cpu.X.sign, NO, @"LDX 2000 (1:1) should copy only 0th field from the memoryCell");
	for (int i = 0; i < MIX_WORD_SIZE-1; i++) {
		XCTAssertEqual(cpu.X.byte[i], 0, @"LDX 2000 (1:1) should copy only 0th field from the memoryCell");
	}
	
	// Prepare index registers
	[cpu storeOffset:(TEST_CINDEX - TEST_CELL) inIndexRegister:4];			// I4
	[cpu storeOffset:(TEST_CINDEX2 - TEST_CELL) inIndexRegister:5];			// I5
	
	NSLog(@"I2 = %d", [cpu offsetInIndexRegister:4]);
	[self printIndex:cpu.index4];
	XCTAssertEqual([cpu offsetInIndexRegister:4], (TEST_CINDEX - TEST_CELL),
				   @"Index register should proper set positive offset");
	
	NSLog(@"I3 = %d", [cpu offsetInIndexRegister:5]);
	[self printIndex:cpu.index5];
	XCTAssertEqual([cpu offsetInIndexRegister:5], (TEST_CINDEX2 - TEST_CELL),
				   @"Index register should proper set negative offset");
	
	int testvalue1 = 455;
	[cpu storeNumber:testvalue1 forCellIndex:TEST_CINDEX];
	NSLog(@"test value for I4 access test");
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CINDEX]];
	XCTAssertEqual(testvalue1, [cpu memoryContentForCellIndex:TEST_CINDEX], @"Value should be properly written to memory");
	
	int testValue3 = -117;
	NSLog(@"test value for I3 access test");
	[cpu storeNumber:testValue3 forCellIndex:TEST_CINDEX2];
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CINDEX2]];
	XCTAssertEqual(testValue3, [cpu memoryContentForCellIndex:TEST_CINDEX2], @"Value should be properly written to memory");
	
	// Data prepared. synthesize command for indexed access
	// LDX 2000, 2
	command.byte[3] = 5;	// no modifier all fields are loaded
	command.byte[2] = 4;	// I2		(effective address should be TEST_CINDEX)
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000,2  - accumulator after");
	[self printMemoryCell:cpu.X];
	isEqual = [self compareWordA:[cpu memoryWordForCellIndex:TEST_CINDEX] withWordB:cpu.X];
	XCTAssertTrue(isEqual,@"value should be loaded with help of index register I2 from TEST_CINDEX cell");
	
	// LDX 2000, 3 -- negative offset is stored in index register
	
	command.byte[2] = 5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	cpu.A = oldX;			// clear Accumulator
	
	[cpu executeCurrentOperation];
	NSLog(@"LDX 2000,3  - accumulator after");
	[self printMemoryCell:cpu.A];
	isEqual = [self compareWordA:[cpu memoryWordForCellIndex:TEST_CINDEX2] withWordB:cpu.X];
	XCTAssertTrue(isEqual,@"value should be loaded with help of index register I2 from TEST_CINDEX2 cell");
}

//
// test each index register
//
- (void) testLDI
{
	for (int i = 1; i <= 6; i++) {
		NSString *lds = [NSString stringWithFormat:@"LD%d",i];
		MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:lds];
		XCTAssert(ldaCommand, @"%@ Command should be present in command list", lds);

		NSLog(@" Test run for %@ command",lds);
		// LDI 2000
		MIXWORD command;
		command.sign = NO;
		command.byte[0] = 2000 >> 6;
		command.byte[1] = 2000 & 0x3f;
		command.byte[2] = 0;				// index Register
		command.byte[3] = 5;				// field modifier
		command.byte[4] = CMD_LDA+i;		// command code, identifies index register used in this run of test
	
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
	
		MIXINDEX oldIndex = [cpu indexRegisterValue:i];
		NSLog(@"LD%d 2000 - index register before", i);
		[self printIndex:oldIndex];
		[self printMemoryCell:command];
	
		[cpu executeCurrentOperation];
		
		MIXINDEX result = [cpu indexRegisterValue:i];
		[self printIndex:result];
		
		// test index to index load
		int secondIndex = i + 1;
		if (secondIndex > MIX_INDEX_REGISTERS) secondIndex = 1;
		
		[cpu storeOffset:(TEST_CINDEX - TEST_CELL) inIndexRegister:secondIndex];
		command.byte[2] = secondIndex;
		
		[self printMemoryCell:command];
		int testValue = i*24+secondIndex;
		[cpu storeNumber:testValue forCellIndex:TEST_CINDEX];
		[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CINDEX]];
		XCTAssertEqual(testValue, [cpu memoryContentForCellIndex:TEST_CINDEX], @"Value should be properly written to memory");

		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		result = [cpu indexRegisterValue:i];
		NSLog(@"loaded with indexRegister offset");
		[self printIndex:result];
		XCTAssertEqual(testValue, [cpu offsetInIndexRegister:i],
					   @"Index register should contian the same value we put into memory cell");
	}
}

- (void) testLDIN
{
	for (int i = 1; i <= 6; i++) {
		NSString *lds = [NSString stringWithFormat:@"LD%dN",i];
		MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:lds];
		XCTAssert(ldaCommand, @"%@ Command should be present in command list", lds);
		
		NSLog(@" Test run for %@ command",lds);
		// LDI 2000
		MIXWORD command;
		command.sign = NO;
		command.byte[0] = TEST_CELL >> 6;
		command.byte[1] = TEST_CELL & 0x3f;
		command.byte[2] = 0;				// index Register
		command.byte[3] = 5;				// field modifier
		command.byte[4] = CMD_LDAN+i;		// command code, identifies index register used in this run of test
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		MIXINDEX oldIndex = [cpu indexRegisterValue:i];
		NSLog(@"LD%dN 2000 - index register before", i);
		[self printIndex:oldIndex];
		
		[cpu executeCurrentOperation];
		
		MIXINDEX result = [cpu indexRegisterValue:i];
		[self printIndex:result];
		MIXWORD cell = [cpu memoryWordForCellIndex:TEST_CELL];
		
		BOOL isEqual = YES;
		if (cell.sign == result.sign) isEqual = NO;
		if (cell.byte[4] != result.indexByte[1]) isEqual = NO;
		if (cell.byte[3] != result.indexByte[0]) isEqual = NO;
		XCTAssertTrue(isEqual, @"index should contains last two bytes from mwmory word, but with different sign");
	}
}


//
// Due to actual procedures to process LDA and LDAN are the same we'll test here only specific part -
// sign inversion
//
- (void) testLDAN
{
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"LDAN"];
	XCTAssert(ldaCommand, @"LDAN Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = TEST_CELL >> 6;
	command.byte[1] = TEST_CELL & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_LDAN;				// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];

	MIXWORD accum = cpu.A;
	MIXWORD cell = [cpu memoryWordForCellIndex:TEST_CELL];
	
	NSLog(@"Memory Cell:");
	[self printMemoryCell:cell];
	NSLog(@"accumulator");
	[self printMemoryCell:accum];
	
	accum.sign = !accum.sign;
	BOOL isEqual = [self compareWordA:accum withWordB:cell];
	XCTAssertTrue(isEqual, @"accumilator should differ with sign only");
}


- (void) testLDXN
{
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"LDXN"];
	XCTAssert(ldaCommand, @"LDXN Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_LDXN;				// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	MIXWORD accum = cpu.X;
	MIXWORD cell = [cpu memoryWordForCellIndex:TEST_CELL];
	
	NSLog(@"Memory Cell:");
	[self printMemoryCell:cell];
	NSLog(@"accumulator");
	[self printMemoryCell:accum];
	
	accum.sign = !accum.sign;
	BOOL isEqual = [self compareWordA:accum withWordB:cell];
	XCTAssertTrue(isEqual, @"X register should differ with sign only");

}

//
// STZ - xero separate fields in target  memory cell
//
- (void) testSTZ
{
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"STZ"];
	XCTAssert(ldaCommand, @"STZ Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_STZ;			// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:[self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5] forCellIndex:TEST_CELL];
	
	MIXWORD oldValue = [cpu memoryWordForCellIndex:TEST_CELL];
	
	[cpu executeCurrentOperation];
	
	MIXWORD newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	
	MIXWORD desiredValue = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
	BOOL isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ should clear all fields in target cell");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	// modifier (0:0) -- sign only
	
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];

	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear sign field in target cell only");
	
	
	// modifier  (0:0) no sign  but all other fields
	
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear sign field in target cell only");
	
	
	// modifier (1:5) no sign  but all other fields

	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 1*8+5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
//	[self printMemoryCell:newValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear all fields in target cell except the sign field");
	

	// modifier (2:3)
	
	NSLog(@"STZ (2:3)");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:0 byte2:0 byte3:4 byte4:5];
	
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear all fields in target cell except the sign field");
	

	// modifier (1:4)
	
	NSLog(@"STZ (1:4)");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 1*8+4;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:0 byte4:5];
	
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear all fields in target cell except the sign field");
	
	// modifier (5:5)
	
	NSLog(@"STZ (5:5)");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 5*8+5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:0];
	
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STZ  (0:0) should clear all fields in target cell except the sign field");
	
}

- (void) testSTA
{
	NSLog(@"STA test");
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"STA"];
	XCTAssert(ldaCommand, @"STA Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_STA;			// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;

	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:[self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5] forCellIndex:TEST_CELL];
	
	MIXWORD oldValue = [cpu memoryWordForCellIndex:TEST_CELL];
	cpu.A = [self wordWithNegativeSign:NO andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
	NSLog(@"STA TEST_CELL");
	
	[cpu executeCurrentOperation];
	
	MIXWORD newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	MIXWORD desiredValue = [self wordWithNegativeSign:NO andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
	BOOL isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA should store accumulator contents into memory cell");
	
	NSLog(@"STA (0:0) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA  (0:0) should store sign field in target cell only");
	
	NSLog(@"STA (1:5) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 1*8+5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA  (1:5) should store all fields except the sign");
	

	NSLog(@"STA (2:3) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:9 byte2:0 byte3:4 byte4:5];
	
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:oldValue];
//	[self printMemoryCell:newValue];
//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA  (2:3) should store last 2 bytes from accumulator in the specified fields");
	
	NSLog(@"STA (0:1) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0*8+1;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:0 byte1:2 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA  (0:1) should store sign byte and last byte from accumulator into MSB of memoty cell");
	
	NSLog(@"STA (2:2) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+2;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:0 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA  (2:2) should store in selected fields two LSB from accumulator ");
}

- (void) testSTX
{
	NSLog(@"STA test");
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"STX"];
	XCTAssert(ldaCommand, @"STX Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_STX;			// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:[self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5] forCellIndex:TEST_CELL];
	
	MIXWORD oldValue = [cpu memoryWordForCellIndex:TEST_CELL];
	cpu.X = [self wordWithNegativeSign:NO andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
	NSLog(@"STX TEST_CELL");
	
	[cpu executeCurrentOperation];
	
	MIXWORD newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	MIXWORD desiredValue = [self wordWithNegativeSign:NO andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
	BOOL isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STA should store accumulator contents into memory cell");
	
	NSLog(@"STX (0:0) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STX  (0:0) should store sign field in target cell only");
	
	NSLog(@"STX (1:5) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 1*8+5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:6 byte1:7 byte2:8 byte3:9 byte4:0];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STX  (1:5) should store all fields except the sign");
	
	NSLog(@"STX (2:3) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:9 byte2:0 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STX  (2:3) should store last 2 bytes from accumulator in the specified fields");
	
	NSLog(@"STX (0:1) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0*8+1;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:0 byte1:2 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STX  (0:1) should store sign byte and last byte from accumulator into MSB of memoty cell");
	
	NSLog(@"STX (2:2) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+2;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:0 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STX  (2:2) should store in selected fields two LSB from accumulator ");
	
}


- (void) testSTJ
{
	NSLog(@"STJ test");
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"STJ"];
	XCTAssert(ldaCommand, @"STJ Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_STJ;			// command code
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu setMemoryWord:[self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5] forCellIndex:TEST_CELL];
	
	MIXWORD oldValue = [cpu memoryWordForCellIndex:TEST_CELL];
	cpu.J = [self indexWithSign:NO byte0:7 andByte1:8];
	
	NSLog(@"STJ TEST_CELL");
	
	[cpu executeCurrentOperation];
	
	MIXWORD newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	MIXWORD desiredValue = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:7 byte4:8];
	
//		[self printMemoryCell:oldValue];
//		[self printMemoryCell:newValue];
//		[self printMemoryCell:desiredValue];

	
	BOOL isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ should store accumulator contents into memory cell");
	
	NSLog(@"STJ (0:0) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ  (0:0) should store sign field in target cell only");
	
	NSLog(@"STJ (1:5) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 1*8+5;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:7 byte4:8];
	
//		[self printMemoryCell:cpu.A];
//		[self printMemoryCell:oldValue];
//		[self printMemoryCell:newValue];
//		[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ  (1:5) should store all fields except the sign");
	
	NSLog(@"STJ (2:3) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+3;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:7 byte2:8 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ  (2:3) should store last 2 bytes from accumulator in the specified fields");
	
	NSLog(@"STJ (0:1) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 0*8+1;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:NO andByte0:8 byte1:2 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ  (0:1) should store sign byte and last byte from accumulator into MSB of memoty cell");
	
	NSLog(@"STJ (2:2) TEST_CELL");
	
	[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
	
	command.byte[3] = 2*8+2;
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	[cpu executeCurrentOperation];
	
	newValue = [cpu memoryWordForCellIndex:TEST_CELL];
	desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:8 byte2:3 byte3:4 byte4:5];
	
	//	[self printMemoryCell:cpu.A];
	//	[self printMemoryCell:oldValue];
	//	[self printMemoryCell:newValue];
	//	[self printMemoryCell:desiredValue];
	
	isEqual = [self compareWordA:newValue withWordB:desiredValue];
	XCTAssertTrue(isEqual, @"STJ  (2:2) should store in selected fields two LSB from accumulator ");
	
}

- (void) testSTI
{
	for (int i = 0; i < MIX_INDEX_REGISTERS; i++) {
		int indexNum = i+1;
		
		NSString *indexName = [NSString stringWithFormat:@"ST%1d",indexNum];
		NSLog(@"%@", indexName);
		MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:indexName];
		XCTAssert(ldaCommand, @"%@ Command should be present in command list", indexName);
		
		// LDA 2000
		MIXWORD command;
		command.sign = NO;
		command.byte[0] = 2000 >> 6;
		command.byte[1] = 2000 & 0x3f;
		command.byte[2] = 0;					// index Register
		command.byte[3] = 5;					// field modifier
		command.byte[4] = CMD_STA + indexNum;	// command code
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setMemoryWord:[self wordWithNegativeSign:YES andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5] forCellIndex:TEST_CELL];
		
		MIXWORD oldValue = [cpu memoryWordForCellIndex:TEST_CELL];
		[cpu setIndexRegister:[self indexWithSign:NO byte0:7 andByte1:8] withNumber:indexNum];
		
		NSLog(@"%@ TEST_CELL", indexName);
		
		[cpu executeCurrentOperation];
		
		MIXWORD newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		MIXWORD desiredValue = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:7 byte4:8];
		
				[self printMemoryCell:oldValue];
				[self printMemoryCell:newValue];
				[self printMemoryCell:desiredValue];
		
		
		BOOL isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@ should store accumulator contents into memory cell", indexName);

		NSLog(@"%@ (0:0) TEST_CELL", indexName);
		
		[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
		
		command.byte[3] = 0;
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		[cpu executeCurrentOperation];
		
		newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		desiredValue = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
		
		//	[self printMemoryCell:oldValue];
		//	[self printMemoryCell:newValue];
		//	[self printMemoryCell:desiredValue];
		
		isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@  (0:0) should store sign field in target cell only", indexName);

		NSLog(@"%@ (1:5) TEST_CELL", indexName);
		
		[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
		
		command.byte[3] = 1*8+5;
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		[cpu executeCurrentOperation];
		
		newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		desiredValue = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:7 byte4:8];
		
		//		[self printMemoryCell:cpu.A];
		//		[self printMemoryCell:oldValue];
		//		[self printMemoryCell:newValue];
		//		[self printMemoryCell:desiredValue];
		
		isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@ (1:5) should store all fields except the sign", indexName);

		NSLog(@"%@ (2:3) TEST_CELL", indexName);
		
		[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
		
		command.byte[3] = 2*8+3;
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		[cpu executeCurrentOperation];
		
		newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:7 byte2:8 byte3:4 byte4:5];
		
		//	[self printMemoryCell:cpu.A];
		//	[self printMemoryCell:oldValue];
		//	[self printMemoryCell:newValue];
		//	[self printMemoryCell:desiredValue];
		
		isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@ (2:3) should store last 2 bytes from accumulator in the specified fields", indexName);
		
		NSLog(@"%@ (0:1) TEST_CELL", indexName);
		
		[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
		
		command.byte[3] = 0*8+1;
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		[cpu executeCurrentOperation];
		
		newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		desiredValue = [self wordWithNegativeSign:NO andByte0:8 byte1:2 byte2:3 byte3:4 byte4:5];
		
		//	[self printMemoryCell:cpu.A];
		//	[self printMemoryCell:oldValue];
		//	[self printMemoryCell:newValue];
		//	[self printMemoryCell:desiredValue];
		
		isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@ (0:1) should store sign byte and last byte from accumulator into MSB of memoty cell", indexName);
		
		NSLog(@"%@ (2:2) TEST_CELL", indexName);
		
		[cpu setMemoryWord:oldValue forCellIndex:TEST_CELL];
		
		command.byte[3] = 2*8+2;
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		[cpu executeCurrentOperation];
		
		newValue = [cpu memoryWordForCellIndex:TEST_CELL];
		desiredValue = [self wordWithNegativeSign:YES andByte0:1 byte1:8 byte2:3 byte3:4 byte4:5];
		
		//	[self printMemoryCell:cpu.A];
		//	[self printMemoryCell:oldValue];
		//	[self printMemoryCell:newValue];
		//	[self printMemoryCell:desiredValue];
		
		isEqual = [self compareWordA:newValue withWordB:desiredValue];
		XCTAssertTrue(isEqual, @"%@ (2:2) should store in selected fields two LSB from accumulator", indexName);
	}

}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}


@end
