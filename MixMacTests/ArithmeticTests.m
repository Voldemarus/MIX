//
//  ArithmeticYests.m
//  MixMac
//
//  Created by Водолазкий В.В. on 19.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import "MIXTest.h"

@interface ArithmeticTests : MIXTest

@end

@implementation ArithmeticTests


- (void) testAdd
{
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"ADD"];
	XCTAssert(ldaCommand, @"ADD Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_ADD;				// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	long add1[10] = { 120, 256, -2345, 455, 22004, 111, -23, 0, 10121, 777 };
	long add2[10] = { 3456, 332, -343, -34567, 334, 731, 33533, 222, 11133, 23245};
	
	for (int i = 0; i < 10; i++) {
		cpu.PC = TEST_PC;
		
		NSLog(@"ADD TEST_CELL - %ld + %ld", add1[i], add2[i]);
		
		[cpu storeNumber:add1[i] forCellIndex:TEST_CELL];
		
		cpu.A = [self mixWordFromInteger:add2[i]];
		
		//	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL]];
		//	[self printMemoryCell:cpu.A];
		
		[cpu executeCurrentOperation];
		
		//	[self printMemoryCell:cpu.A];
		
		long result = [self integerFromMIXWORD:cpu.A];
		XCTAssertEqual(result,add1[i]+add2[i], @"ADD should porperly calculate sum for two numbers");

	}
	
}

- (void) testSub
{
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"SUB"];
	XCTAssert(ldaCommand, @"SUB Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_SUB;				// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	long add1[10] = { 120, 256, -2345, 455, 22004, 111, -23, 0, 10121, 777 };
	long add2[10] = { 3456, 332, -343, -34567, 334, 731, 33533, 222, 11133, 23245};
	
	for (int i = 0; i < 10; i++) {
		cpu.PC = TEST_PC;
		
		NSLog(@"ADD TEST_CELL - %ld + %ld", add1[i], add2[i]);
		
		[cpu storeNumber:add1[i] forCellIndex:TEST_CELL];
		
		cpu.A = [self mixWordFromInteger:add2[i]];
		
		//	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL]];
		//	[self printMemoryCell:cpu.A];
		
		[cpu executeCurrentOperation];
		
		//	[self printMemoryCell:cpu.A];
		
		long result = [self integerFromMIXWORD:cpu.A];
		XCTAssertEqual(result,add2[i]-add1[i], @"SUB should porperly substract content of memory cell from accumulator");
	}
}


//
// test overflow flag settings during ADD
//
- (void) testAddWithCarry
{
	[cpu clearFlags];
	XCTAssertFalse(cpu.overflow, @"Overflow flag should be cleared");
	
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"ADD"];
	XCTAssert(ldaCommand, @"ADD Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_ADD;				// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];

	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:[cpu maxInteger]];
	[cpu storeNumber:1 forCellIndex:TEST_CELL];
	
	[cpu executeCurrentOperation];
	
	// Now we should check both accumulator and carry/overflow register
	
	XCTAssertTrue(cpu.overflow, @"Overflow flag should be set");
	XCTAssertEqual([self integerFromMIXWORD:cpu.A], 0, @"sum should be equal to zero");
	
	[cpu clearFlags]; // clean after youself!
	
}

- (void) testSubWithCarry
{
	[cpu clearFlags];
	XCTAssertFalse(cpu.overflow, @"Overflow flag should be cleared");
	
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"SUB"];
	XCTAssert(ldaCommand, @"Sub Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_SUB;				// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:(-[cpu maxInteger])];
	[cpu storeNumber:1 forCellIndex:TEST_CELL];
	
	[cpu executeCurrentOperation];
	
	// Now we should check both accumulator and carry/overflow register
	
	XCTAssertTrue(cpu.overflow, @"Overflow flag should be set");
	XCTAssertEqual([self integerFromMIXWORD:cpu.A], 0, @"sub should be equal to - maxInt");
	XCTAssertEqual(cpu.A.sign, NO, @"sign bit should be off");
	
	[cpu clearFlags]; // clean after youself!
}


- (void) testMul
{
	[cpu clearFlags];
	XCTAssertFalse(cpu.overflow, @"Overflow flag should be cleared");
	
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"MUL"];
	XCTAssert(ldaCommand, @"MUL Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_MUL;			// command code
	
	long add1[10] = { 120, 256, -2345, 455, 22004, 111, -23, 0, 10121, 777 };
	long add2[10] = { 3456, 332, -343, -34567, 334, 731, 33533, 222, 11133, 23245};
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	for (int i = 0; i < 10; i++) {
		cpu.PC = TEST_PC;
		
		NSLog(@"MUL TEST_CELL - %ld * %ld", add1[i], add2[i]);
		
		[cpu storeNumber:add1[i] forCellIndex:TEST_CELL];
		
		cpu.A = [self mixWordFromInteger:add2[i]];
		
		//	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL]];
		//	[self printMemoryCell:cpu.A];
		
		[cpu executeCurrentOperation];
		
		//	[self printMemoryCell:cpu.A];
		
		long result = [self longIntegerFromCpu];
		XCTAssertEqual(result,add2[i]*add1[i], @"MUL should porperly substract content of memory cell from accumulator");
	}
	
	// Special cases - examples from Knuth, Vol.1
	
	cpu.PC = TEST_PC;
	
	MIXWORD testValue =  [self wordWithNegativeSign:NO andByte0:1 byte1:1 byte2:1 byte3:1 byte4:1];
	[cpu setMemoryWord:testValue forCellIndex:TEST_CELL];
	cpu.A = testValue;
	
	[cpu executeCurrentOperation];
	
	MIXWORD expectedRA = [self wordWithNegativeSign:NO andByte0:0 byte1:1 byte2:2 byte3:3 byte4:4];
	MIXWORD expectedRX = [self wordWithNegativeSign:NO andByte0:5 byte1:4 byte2:3 byte3:2 byte4:1];
	
	BOOL isEqual = [self compareWordA:cpu.A withWordB:expectedRA];
	XCTAssertTrue(isEqual, @"accumulator value should be as declared in expected variable");
	isEqual = [self compareWordA:cpu.X withWordB:expectedRX];
	
	XCTAssertTrue(isEqual, @"X register value should be as declared in expected variable");
	
	// MUL 2000 (1:1)
	
	cpu.A = [self mixWordFromInteger:112];
	[cpu setMemoryWord:[self wordWithNegativeSign:NO andByte0:2 byte1:0 byte2:0 byte3:0 byte4:0] forCellIndex:TEST_CELL];
	
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL]];
//	NSLog(@"* * *");
	
	command.byte[3] = 1*8+1;			// (1:1) modifier
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];

	cpu.PC = TEST_PC;

	[cpu executeCurrentOperation];

	long result = [self longIntegerFromCpu];
	
	XCTAssertEqual(result, 112*2,@"MUL should work with field modifiers as well");
	
}

- (void) testDiv
{
	[cpu clearFlags];
	XCTAssertFalse(cpu.overflow, @"Overflow flag should be cleared");
	
	MixCommand *ldaCommand = [[MixCommands sharedInstance] getCommandByMnemonic:@"DIV"];
	XCTAssert(ldaCommand, @"DIV Command should be present in command list");
	
	// LDA 2000
	MIXWORD command;
	command.sign = NO;
	command.byte[0] = 2000 >> 6;
	command.byte[1] = 2000 & 0x3f;
	command.byte[2] = 0;				// index Register
	command.byte[3] = 5;				// field modifier
	command.byte[4] = CMD_DIV;			// command code
	
	[self.cpu setMemoryWord:command forCellIndex:TEST_PC];


	// Special cases - examples from Knuth, Vol.1
	
	cpu.PC = TEST_PC;
	
	MIXWORD testValue =  [self mixWordFromInteger:3];
	[cpu setMemoryWord:testValue forCellIndex:TEST_CELL];
	cpu.A = [self mixWordFromInteger:0];
	cpu.X = [self mixWordFromInteger:17];
	
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:cpu.X];
	
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL] withTitle:@"Cell TEST_CELL"];

	[cpu executeCurrentOperation];
	
//	NSLog(@"$$$$$$");
//	[self printMemoryCell:cpu.A];
//	[self printMemoryCell:cpu.X];
	
	MIXWORD expectedRA = [self mixWordFromInteger:5];
	MIXWORD expectedRX = [self mixWordFromInteger:2];
	
	BOOL isEqual = [self compareWordA:cpu.A withWordB:expectedRA];
	XCTAssertTrue(isEqual, @"accumulator value should be as declared in expected variable");
	isEqual = [self compareWordA:cpu.X withWordB:expectedRX];
	
	XCTAssertTrue(isEqual, @"X register value should be as declared in expected variable");
	
	cpu.PC = TEST_PC;
	[cpu setMemoryWord:[self mixWordFromInteger:0] forCellIndex:TEST_CELL];
	
	XCTAssertFalse(cpu.overflow, @"overflow flag should be not set initially");
	
	[cpu executeCurrentOperation];
	
	MIXWORD desiredResult = [self mixWordFromInteger:0];
	XCTAssertTrue(cpu.overflow, @"overflow shoild be set after division to zero");
	isEqual = [self compareWordA:cpu.A withWordB:desiredResult];
	XCTAssertTrue(isEqual,@"A should be set to zero");
	isEqual = [self compareWordA:cpu.X withWordB:desiredResult];
	XCTAssertTrue(isEqual, @"X should be eaual to zero");
	
	
}



@end
