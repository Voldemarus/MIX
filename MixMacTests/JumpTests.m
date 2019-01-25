//
//  JumpTests.m
//  MixMac
//
//  Created by Водолазкий В.В. on 25.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIXTest.h"

@interface JumpTests : MIXTest

@end

@implementation JumpTests

- (void) testJMP
{
	MIXWORD command = [self mixCommandForMnemonic:@"JMP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.J = [self mixIndexFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"PC register sould contain TEST_CELL address");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"J register should contian next address");
}

/*
 	Triccky part.  subroutine call and processing in MIX contains of several parts
 
 		. . .
 		JMP	SUB		Store address of the NEXT in the J and jumps to required address
 NEXT	. . .
 		. . .
 
 SUB	STJ	EXIT	Store current content of J register into the Address field of EXIT cell
  		. . .		I.e. words * is substituted for NEXT at the runtime (!!! no reenterable !!!
 		. . .
 EXIT	JMP *		Here the address of NEXT will be stored "instead of *"
 */

- (void) testSubroutineCall
{
	NSLog(@"TEST_PC:	 	JMP TEST_CELL");
	MIXWORD command = [self mixCommandForMnemonic:@"JMP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	// reset J register to initial state
	cpu.J = [self mixIndexFromInteger:0];
	NSLog(@"				. . .");
	NSLog(@"TEST_CELL: 		STJ EXIT");

	MIXWORD commandS = [self mixCommandForMnemonic:@"STJ" withAddress:TEST_CELL+2 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:commandS forCellIndex:TEST_CELL];
	
	NSLog(@"TEST_CELL+1:	NOP");
	MIXWORD commandNOP = [self mixCommandForMnemonic:@"NOP" withAddress:TEST_CELL+1 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:commandNOP forCellIndex:TEST_CELL+1];
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL+1] withTitle:@"NOP in memory"];

	
	NSLog(@"TEST_CELL+2:	JMP *");
	MIXWORD commandRet = [self mixCommandForMnemonic:@"JMP" withAddress:TEST_CELL+2 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:commandRet forCellIndex:TEST_CELL+2];
	
	// All commands placed into memory, now we'll execute this "nano" program
	
	[cpu executeCurrentOperation];
	// Check result of the JMP
	XCTAssertEqual(cpu.PC, TEST_CELL, @"PC register sould contain TEST_CELL address");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"J register should contian address TEST_PC+1");

	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL+2] withTitle:@"Before STJ"];
	[cpu executeCurrentOperation];
	[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_CELL+2] withTitle:@"After STJ"];

	// STJ should modify point of return. Original MIXWORD is stored in commandRet
	// and should differ by address
	MIXWORD modifiedCell = [cpu memoryWordForCellIndex:TEST_CELL+2];
	NSInteger pointOfReturn = [self effectiveAddress:modifiedCell];
	XCTAssertEqual(pointOfReturn, TEST_PC+1, @"Return point should be set to the next label");
	XCTAssertEqual(cpu.PC, TEST_CELL+1, @"PC register sould point to NOP");
	
	// Perform next operation - NOP
	[cpu executeCurrentOperation];
	XCTAssertEqual(cpu.PC, TEST_CELL+2, @"PC register sould point to return op");

	// and now we'll return back from subroutine
	[cpu executeCurrentOperation];
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"PC register sould point to return point");

}


- (void) testJSJ
{
	MIXWORD command = [self mixCommandForMnemonic:@"JSJ" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.J = [self mixIndexFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"PC register sould contain TEST_CELL address");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0, @"J register should contian next address");
}

- (void) testJOV
{
	// set overflow flag first
	cpu.A = [self mixWordFromInteger:[cpu maxInteger]];
	MIXWORD command = [self mixCommandForMnemonic:@"INCA" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertTrue(cpu.overflow, @"overflow flag should be set");
	
	command = [self mixCommandForMnemonic:@"JOV" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertFalse(cpu.overflow, @"JOV should reset overflow flag");
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"next address should be stored in PC");
	
	// second branch - JOV shouldn't make jump if overflow flag is not set

	[cpu clearFlags];
	
	cpu.PC = TEST_PC;
	cpu.J = [self mixIndexFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertFalse(cpu.overflow, @"overflow flag should remain OFF");
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"instruction pointer should be incremented");
	
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0 ,@"J register will be updated only when jump is performed");

	[cpu clearFlags];
}

- (void) testJNOV
{
	// set overflow flag first
	cpu.A = [self mixWordFromInteger:[cpu maxInteger]];
	MIXWORD command = [self mixCommandForMnemonic:@"INCA" withAddress:1 index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertTrue(cpu.overflow, @"overflow flag should be set");
	
	command = [self mixCommandForMnemonic:@"JNOV" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertTrue(cpu.overflow, @"JNOV should not reset overflow flag");
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	// second branch - JNOV jumps if overflow flag is not set
	[cpu clearFlags];
	
	cpu.PC = TEST_PC;
	cpu.J = [self mixIndexFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertFalse(cpu.overflow, @"overflow flag should remain intact");
	XCTAssertEqual(cpu.PC, TEST_CELL, @"instruction pointer should be equal to TEST_CELL");
	
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1 ,@"J register will be updated only when jump is performed");
	
}

- (void) testJL
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JL" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	cpu.A = [self mixWordFromInteger:50];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_LESS, @"Less flag should be set");
	
	command = [self mixCommandForMnemonic:@"JL" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should remain intact");
	
	
	[cpu clearFlags];
}


- (void) testJE
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");

	cpu.A = [self mixWordFromInteger:100];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"equal flag should be set");

	command = [self mixCommandForMnemonic:@"JE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should remain intact");
	

	[cpu clearFlags];
}

- (void) testJG
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JG" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	cpu.A = [self mixWordFromInteger:300];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_GREATER, @"Greaterflag should be set");
	
	command = [self mixCommandForMnemonic:@"JG" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should remain intact");
	
	
	[cpu clearFlags];
}

- (void) testJGE
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JGE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	cpu.A = [self mixWordFromInteger:100];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"equal flag should be set");
	
	command = [self mixCommandForMnemonic:@"JGE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	
	cpu.A = [self mixWordFromInteger:300];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_GREATER, @"Greater flag should be set");
	
	command = [self mixCommandForMnemonic:@"JGE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");

	cpu.A = [self mixWordFromInteger:50];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_LESS, @"Less flag should be set");
	
	command = [self mixCommandForMnemonic:@"JGE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");

	[cpu clearFlags];
}

- (void) testJNE
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JNE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	cpu.A = [self mixWordFromInteger:300];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_GREATER, @"Greater flag should be set");
	
	command = [self mixCommandForMnemonic:@"JNE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	
	cpu.A = [self mixWordFromInteger:300];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_GREATER, @"Greater flag should be set");
	
	command = [self mixCommandForMnemonic:@"JGE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:100];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"Equal flag should be set");
	
	command = [self mixCommandForMnemonic:@"JNE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	[cpu clearFlags];
}

- (void) testJLE
{
	// no jump when flag is not set
	
	[cpu clearFlags];
	
	MIXWORD command = [self mixCommandForMnemonic:@"JLE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	cpu.A = [self mixWordFromInteger:100];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"equal flag should be set");
	
	command = [self mixCommandForMnemonic:@"JLE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	
	cpu.A = [self mixWordFromInteger:50];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_LESS, @"Less flag should be set");
	
	command = [self mixCommandForMnemonic:@"JLE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:150];
	[cpu setMemoryWord:[self mixWordFromInteger:100] forCellIndex:TEST_CELL];
	
	command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_GREATER, @"Greater flag should be set");
	
	command = [self mixCommandForMnemonic:@"JLE" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should remain intact");
	
	[cpu clearFlags];
}

- (void) testJAN
{
	
	MIXWORD command = [self mixCommandForMnemonic:@"JAN" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:-5];

	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");

	cpu.A = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");

}

- (void) testJAZ
{
	MIXWORD command = [self mixCommandForMnemonic:@"JAZ" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:10];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJAP
{
	MIXWORD command = [self mixCommandForMnemonic:@"JAP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJANN
{
	MIXWORD command = [self mixCommandForMnemonic:@"JANN" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJANZ
{
	MIXWORD command = [self mixCommandForMnemonic:@"JANZ" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0, @"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
}

- (void) testJANP
{
	MIXWORD command = [self mixCommandForMnemonic:@"JANP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.A = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0, @"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1, @"Jump register should be updated");
	
	cpu.A = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
}

- (void) testJXN
{
	
	MIXWORD command = [self mixCommandForMnemonic:@"JXN" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:-5];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
}

- (void) testJXZ
{
	MIXWORD command = [self mixCommandForMnemonic:@"JXZ" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:0];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:10];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJXP
{
	MIXWORD command = [self mixCommandForMnemonic:@"JXP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJXNN
{
	MIXWORD command = [self mixCommandForMnemonic:@"JXNN" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0,@"Jump register should be updated");
}

- (void) testJXNZ
{
	MIXWORD command = [self mixCommandForMnemonic:@"JXNZ" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0, @"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
}

- (void) testJXNP
{
	MIXWORD command = [self mixCommandForMnemonic:@"JXNP" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:10];
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
	long jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, 0, @"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:0];
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1, @"Jump register should be updated");
	
	cpu.X = [self mixWordFromInteger:-10];
	
	cpu.J = [self mixIndexFromInteger:0];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
	jreg = [self integerFromMIXINDEX:cpu.J];
	XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
}

- (void) testJIN
{
	
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		NSString *mnemonic = [NSString stringWithFormat:@"J%dN",i];

		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-5] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];

		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];

		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");

	}
}

- (void) testJIZ
{
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		
		NSString *mnemonic = [NSString stringWithFormat:@"J%dZ",i];
		
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-10] withNumber:i];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");

	}
}

- (void) testJIP
{
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		
		NSString *mnemonic = [NSString stringWithFormat:@"J%dP",i];
		
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-10] withNumber:i];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	}
}

- (void) testJINN
{
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		
		NSString *mnemonic = [NSString stringWithFormat:@"J%dNN",i];
		
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-10] withNumber:i];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0,@"Jump register should be updated");
	}
}

- (void) testJINZ
{
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		
		NSString *mnemonic = [NSString stringWithFormat:@"J%dNZ",i];
		
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0, @"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-10] withNumber:i];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	}
}

- (void) testJINP
{
	for (int i = 1; i < MIX_INDEX_REGISTERS; i++) {
		
		NSString *mnemonic = [NSString stringWithFormat:@"J%dNP",i];
		
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu setIndexRegister:[self mixIndexFromInteger:10] withNumber:i];
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_PC+1, @"jump should  be performed");
		long jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, 0, @"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:i];
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should  be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1, @"Jump register should be updated");
		
		[cpu setIndexRegister:[self mixIndexFromInteger:-10] withNumber:i];
		
		cpu.J = [self mixIndexFromInteger:0];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.PC, TEST_CELL, @"jump should not be performed");
		jreg = [self integerFromMIXINDEX:cpu.J];
		XCTAssertEqual(jreg, TEST_PC+1,@"Jump register should be updated");
	}
}

#pragma mark - Service methods

// Copy of internal MIXCPU method
- (NSInteger) effectiveAddress:(MIXWORD) command
{
	Byte addrLeft = command.byte[0];
	Byte addrRight = command.byte[1];
	NSInteger address = addrLeft << ( cpu.sixBitByte ? 6 : 8);
	address += addrRight;
	if (command.sign) {
		address = - address;
	}
	// apply index register if any
	Byte index = command.byte[2];
	if (index > 0) {
		MIXINDEX indexValue = [cpu indexRegisterValue:index];
		NSInteger ind = indexValue.indexByte[0] << (cpu.sixBitByte ? 6 : 8);
		ind += indexValue.indexByte[1];
		if (indexValue.sign) {
			ind = -ind;
		}
		address += ind;
	}
	return address;
}



@end
