//
//  testShidtOperations.m
//  MixMac
//
//  Created by Водолазкий В.В. on 02.03.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIXTest.h"

@interface testShiftOperations : MIXTest

@end

@implementation testShiftOperations


- (void) testSLA
{
	// Test #1.   SEt up TOO BIG value as argument - so accumulator content should be shifted away
	
	MIXWORD command = [self mixCommandForMnemonic:@"SLA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	[cpu setMemoryWord:[self mixWordFromInteger:1] forCellIndex:TEST_CELL];
	
	[cpu executeCurrentOperation];

	MIXWORD template = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];

	BOOL equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SLA result should be equal to expected one");
	
	// Test #2. Shift for one position
	
	command = [self mixCommandForMnemonic:@"SLA" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];

	[cpu executeCurrentOperation];
	
	template = [self wordWithNegativeSign:NO andByte0:2 byte1:3 byte2:4 byte3:5 byte4:0];
	
	equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SLA result should be equal to expected one");

	// Test #2. Shift for 4 position
	
	command = [self mixCommandForMnemonic:@"SLA" withAddress:4 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	[cpu executeCurrentOperation];
	
	template = [self wordWithNegativeSign:NO andByte0:5 byte1:0 byte2:0 byte3:0 byte4:0];
	
	equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SLA result should be equal to expected one");
	
}

- (void) testSRA
{
	// Test #1.   SEt up TOO BIG value as argument - so accumulator content should be shifted away
	
	MIXWORD command = [self mixCommandForMnemonic:@"SRA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	[cpu setMemoryWord:[self mixWordFromInteger:1] forCellIndex:TEST_CELL];
	
	[cpu executeCurrentOperation];
	
	MIXWORD template = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
	BOOL equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SRA result should be equal to expected one");
	
	// Test #2. Shift for one position
	
	command = [self mixCommandForMnemonic:@"SRA" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	[cpu executeCurrentOperation];
	
	template = [self wordWithNegativeSign:NO andByte0:0 byte1:1 byte2:2 byte3:3 byte4:4];
	
	equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SRA result should be equal to expected one");
	
	// Test #2. Shift for 4 position
	
	command = [self mixCommandForMnemonic:@"SRA" withAddress:4 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	
	[cpu executeCurrentOperation];
	
	template = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:1];
	
	equal = [self compareWordA:cpu.A withWordB:template];
	
	XCTAssertTrue(equal, @"SRA result should be equal to expected one");
	
}

- (void) testSLAX
{
	MIXWORD command = [self mixCommandForMnemonic:@"SLAX" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	MIXWORD template1 = [self wordWithNegativeSign:NO andByte0:2 byte1:3 byte2:4 byte3:5 byte4:6];
	MIXWORD template2 = [self wordWithNegativeSign:YES andByte0:7 byte1:8 byte2:9 byte3:10 byte4:0];

	BOOL isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");

	
	 command = [self mixCommandForMnemonic:@"SLAX" withAddress:8 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:9 byte1:10 byte2:0 byte3:0 byte4:0];
	template2 = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	command = [self mixCommandForMnemonic:@"SLAX" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	template2 = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
	
	[self printMemoryCell:cpu.A];
	[self printMemoryCell:cpu.X];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
}

- (void) testSRAX
{
	MIXWORD command = [self mixCommandForMnemonic:@"SRAX" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	MIXWORD template1 = [self wordWithNegativeSign:NO andByte0:0 byte1:1 byte2:2 byte3:3 byte4:4];
	MIXWORD template2 = [self wordWithNegativeSign:YES andByte0:5 byte1:6 byte2:7 byte3:8 byte4:9];
	
	BOOL isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	
	command = [self mixCommandForMnemonic:@"SRAX" withAddress:8 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	template2 = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:1 byte4:2];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	command = [self mixCommandForMnemonic:@"SRAX" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	template2 = [self wordWithNegativeSign:YES andByte0:0 byte1:0 byte2:0 byte3:0 byte4:0];
	
	
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:cpu.X];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
}


- (void) testSRC
{
	MIXWORD command = [self mixCommandForMnemonic:@"SRC" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	MIXWORD template1 = [self wordWithNegativeSign:NO andByte0:10 byte1:1 byte2:2 byte3:3 byte4:4];
	MIXWORD template2 = [self wordWithNegativeSign:YES andByte0:5 byte1:6 byte2:7 byte3:8 byte4:9];
	
	BOOL isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");

	command = [self mixCommandForMnemonic:@"SRC" withAddress:8 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:3 byte1:4 byte2:5 byte3:6 byte4:7];
	template2 = [self wordWithNegativeSign:YES andByte0:8 byte1:9 byte2:10 byte3:1 byte4:2];

	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	command = [self mixCommandForMnemonic:@"SRC" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	template2 = [self wordWithNegativeSign:YES andByte0:6 byte1:7 byte2:8 byte3:9 byte4:10];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
}

- (void) testSLC
{
	MIXWORD command = [self mixCommandForMnemonic:@"SLC" withAddress:9 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	MIXWORD template1 = [self wordWithNegativeSign:NO andByte0:10 byte1:1 byte2:2 byte3:3 byte4:4];
	MIXWORD template2 = [self wordWithNegativeSign:YES andByte0:5 byte1:6 byte2:7 byte3:8 byte4:9];
	
	BOOL isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	command = [self mixCommandForMnemonic:@"SLC" withAddress:2 index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:3 byte1:4 byte2:5 byte3:6 byte4:7];
	template2 = [self wordWithNegativeSign:YES andByte0:8 byte1:9 byte2:10 byte3:1 byte4:2];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
	
	command = [self mixCommandForMnemonic:@"SLC" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[self initRegisters];
	
	[cpu executeCurrentOperation];
	
	template1 = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	template2 = [self wordWithNegativeSign:YES andByte0:6 byte1:7 byte2:8 byte3:9 byte4:10];
	
	isEqual = [self compareWordA:cpu.A withWordB:template1];
	XCTAssertTrue(isEqual, @"A register should be shifted properly");
	isEqual = [self compareWordA:cpu.X withWordB:template2];
	XCTAssertTrue(isEqual, @"X register should be shifted properly");
}


#pragma mark -

- (void) initRegisters
{
	cpu.A = [self wordWithNegativeSign:NO andByte0:1 byte1:2 byte2:3 byte3:4 byte4:5];
	cpu.X = [self wordWithNegativeSign:YES andByte0:6 byte1:7 byte2:8 byte3:9 byte4:10];
}

@end
