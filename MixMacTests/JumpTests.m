//
//  JumpTests.m
//  MixMac
//
//  Created by Водолазкий В.В. on 25.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
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




@end
