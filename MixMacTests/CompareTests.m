//
//  CompareTests.m
//  MixMac
//
//  Created by Водолазкий В.В. on 25.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MIXTest.h"

@interface CompareTests : MIXTest

@end

@implementation CompareTests

- (void) testCMPA
{
	// Initial test - simple case: load to accumulator constants
	long mem[10] = { 120, 2345, -343, 4067, 1111, 1152, 3433, 2330, 221, -667 };			// memory cell address
	long acc[10] = { 46,  3445, - 343, 235,  -34,  -1152, 2322, -0,   432,  1123 };
	for (int i = 0; i < 10; i++) {
		// use default modifier for these tests
		MIXWORD command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
		[cpu setMemoryWord:[self mixWordFromInteger:mem[i]] forCellIndex:TEST_CELL];
		
		cpu.A = [self mixWordFromInteger:acc[i]];			// initial value to accumulator
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		if (cpu.flag ==	MIX_EQUAL) {
			XCTAssertTrue(mem[i] == acc[i], @"Equal flag should be set up");
		} else if (cpu.flag == MIX_GREATER) {
			XCTAssertTrue(acc[i] > mem[i], @"GREATER flag should be set up");
		}  else if (cpu.flag == MIX_LESS) {
			XCTAssertTrue(acc[i] < mem[i], @"LESS flag should be set up");
		} else {
			XCTFail(@"one of the meaningful states should be set up - iteration #%d",i);
		}
	}
	// special case - 0 field
	MIXWORD command = [self mixCommandForMnemonic:@"CMPA" withAddress:TEST_CELL index:0 andModifier:MIX_F_SIGNONLY];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];

	[cpu setMemoryWord:[self mixWordFromInteger:-78] forCellIndex:TEST_CELL];
	cpu.A = [self mixWordFromInteger:12];

	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];

	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"when only signs are compared, equal flag should be set");
}

- (void) testCMPX
{
	// Initial test - simple case: load to accumulator constants
	long mem[10] = { 120, 2345, -343, 4067, 1111, 1152, 3433, 2330, 221, -667 };			// memory cell address
	long acc[10] = { 46,  3445, - 343, 235,  -34,  -1152, 2322, -0,   432,  1123 };
	for (int i = 0; i < 10; i++) {
		// use default modifier for these tests
		MIXWORD command = [self mixCommandForMnemonic:@"CMPX" withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
		[cpu setMemoryWord:[self mixWordFromInteger:mem[i]] forCellIndex:TEST_CELL];
		
		cpu.X = [self mixWordFromInteger:acc[i]];			// initial value to accumulator
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		if (cpu.flag ==	MIX_EQUAL) {
			XCTAssertTrue(mem[i] == acc[i], @"Equal flag should be set up");
		} else if (cpu.flag == MIX_GREATER) {
			XCTAssertTrue(acc[i] > mem[i], @"GREATER flag should be set up");
		}  else if (cpu.flag == MIX_LESS) {
			XCTAssertTrue(acc[i] < mem[i], @"LESS flag should be set up");
		} else {
			XCTFail(@"one of the meaningful states should be set up - iteration #%d",i);
		}
	}
	// special case - 0 field
	MIXWORD command = [self mixCommandForMnemonic:@"CMPX" withAddress:TEST_CELL index:0 andModifier:MIX_F_SIGNONLY];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	[cpu setMemoryWord:[self mixWordFromInteger:-78] forCellIndex:TEST_CELL];
	cpu.X = [self mixWordFromInteger:12];
	
	cpu.PC = TEST_PC;
	
	[cpu executeCurrentOperation];
	
	XCTAssertEqual(cpu.flag, MIX_EQUAL, @"when only signs are compared, equal flag should be set");
}

- (void) testCMPI
{
	
	for (int indexNum = 1; indexNum <= MIX_INDEX_REGISTERS; indexNum++) {
		
		[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:indexNum];	// initial value to index register

		NSString *mnemonic = [NSString stringWithFormat:@"CMP%d",indexNum];
		
		// Initial test - simple case: load to accumulator constants
		long mem[10] = { 120, 2345, -343, 4067, 1111, 1152, 3433, 2330, 221, -667 };			// memory cell address
		long acc[10] = { 46,  3445, - 343, 235,  -34,  -1152, 2322, -0,   432,  1123 };
		for (int i = 0; i < 10; i++) {
			// use default modifier for these tests
			MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_NOTDEFINED];
			
			[cpu setMemoryWord:command forCellIndex:TEST_PC];
			
			[cpu setMemoryWord:[self mixWordFromInteger:mem[i]] forCellIndex:TEST_CELL];
			
			[cpu setIndexRegister:[self mixIndexFromInteger:acc[i]] withNumber:indexNum];
			cpu.PC = TEST_PC;
			
			[cpu executeCurrentOperation];
			
			if (cpu.flag ==	MIX_EQUAL) {
				XCTAssertTrue(mem[i] == acc[i], @"Equal flag should be set up");
			} else if (cpu.flag == MIX_GREATER) {
				XCTAssertTrue(acc[i] > mem[i], @"GREATER flag should be set up");
			}  else if (cpu.flag == MIX_LESS) {
				XCTAssertTrue(acc[i] < mem[i], @"LESS flag should be set up");
			} else {
				XCTFail(@"one of the meaningful states should be set up - iteration #%d",i);
			}
		}
		// special case - 0 field
		MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:TEST_CELL index:0 andModifier:MIX_F_SIGNONLY];
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
		[cpu setMemoryWord:[self mixWordFromInteger:-78] forCellIndex:TEST_CELL];
		[cpu setIndexRegister:[self mixIndexFromInteger:33] withNumber:indexNum];
		
		cpu.PC = TEST_PC;
		
		[cpu executeCurrentOperation];
		
		XCTAssertEqual(cpu.flag, MIX_EQUAL, @"when only signs are compared, equal flag should be set");
	}
}



@end
