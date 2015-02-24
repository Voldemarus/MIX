//
//  EntFamilyTest.m
//  MixMac
//
//  Created by Водолазкий В.В. on 22.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIXTest.h"

@interface EntFamilyTest : MIXTest

@end

@implementation EntFamilyTest

- (void) testENTA
{
	// Initial test - simple case: load to accumulator constants
	long data[10] = { 120, 2345, -343, -4067, 1111, 1152, 3433, -2330, -221, -667 };
	for (int i = 0; i < 10; i++) {
		// use default modifier for these tests
		MIXWORD command = [self mixCommandForMnemonic:@"ENTA" withAddress:data[i] index:0 andModifier:MIX_F_NOTDEFINED];
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
		cpu.A = [self mixWordFromInteger:0];			// initial value to accumulator
		
		[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_PC]];
		cpu.PC = TEST_PC;
		
		long accumulator = [self integerFromMIXWORD:cpu.A];
		XCTAssertEqual(accumulator, 0, @"accumulator should be properly cleared");
		
		[cpu executeCurrentOperation];
		
		accumulator = [self integerFromMIXWORD:cpu.A];
		XCTAssertEqual(accumulator, data[i], @"Data shpuld be loaded into accumulator properly");
	}
	// special case: if effective address is equal to 0, sign is derived from the command sign byte
	//  ENTA -100, 4
	
	MIXWORD command = [self mixCommandForMnemonic:@"ENTA" withAddress:-100 index:4 andModifier:MIX_F_NOTDEFINED];
	[cpu storeOffset:100 inIndexRegister:4];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];

	cpu.PC = TEST_PC;

	cpu.A = [self mixWordFromInteger:0];			// initial value to accumulator
	XCTAssertFalse(cpu.A.sign, @"sign bit in accumulator should be off");
	
	[cpu executeCurrentOperation];
	
	XCTAssertFalse(cpu.A.sign, @"sign bit in accumulator should be ON");
	long result = [self integerFromMIXWORD:cpu.A];
	XCTAssertEqual(result,0, @"Accumulator should contain zero");
	
}

- (void) testENTX
{
	// Initial test - simple case: load to accumulator constants
	long data[10] = { 120, 2345, -343, -4067, 1111, 1152, 3433, -2330, -221, -667 };
	for (int i = 0; i < 10; i++) {
		// use default modifier for these tests
		MIXWORD command = [self mixCommandForMnemonic:@"ENTX" withAddress:data[i] index:0 andModifier:MIX_F_NOTDEFINED];
		
		[self printMemoryCell:command];
		
		[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
		cpu.X = [self mixWordFromInteger:0];			// initial value to accumulator
		
		[self printMemoryCell:[cpu memoryWordForCellIndex:TEST_PC]];
		cpu.PC = TEST_PC;
		
		
		long accumulator = [self integerFromMIXWORD:cpu.X];
		XCTAssertEqual(accumulator, 0, @"X register should be properly cleared");
		
		[cpu executeCurrentOperation];
		
		[self printMemoryCell:cpu.X];
		
		accumulator = [self integerFromMIXWORD:cpu.X];
		XCTAssertEqual(accumulator, data[i], @"Data shpuld be loaded into X register properly");
	}
	// special case: if effective address is equal to 0, sign is derived from the command sign byte
	//  ENTX -100, 4
	
	MIXWORD command = [self mixCommandForMnemonic:@"ENTX" withAddress:-100 index:4 andModifier:MIX_F_NOTDEFINED];
	[cpu storeOffset:100 inIndexRegister:4];
	[cpu setMemoryWord:command forCellIndex:TEST_PC];
	
	cpu.PC = TEST_PC;
	
	cpu.X = [self mixWordFromInteger:0];			// initial value to accumulator
	XCTAssertFalse(cpu.X.sign, @"sign bit in X should be off");
	
	[cpu executeCurrentOperation];
	
	XCTAssertFalse(cpu.X.sign, @"sign bit in X should be ON");
	long result = [self integerFromMIXWORD:cpu.X];
	XCTAssertEqual(result,0, @"X should contain zero");
	
}

- (void) testENTI
{
	long data[10] = { 120, 2345, -343, -4067, 1111, 1152, 3433, -2330, -221, -667 };
	for (int indexNum = 1; indexNum <= MIX_INDEX_REGISTERS; indexNum++) {
		NSString *mnemonic = [NSString stringWithFormat:@"ENT%d",indexNum];
		
		for (int i = 0; i < 10; i++) {
			
			// use default modifier for these tests
			MIXWORD command = [self mixCommandForMnemonic:mnemonic withAddress:data[i] index:0 andModifier:MIX_F_NOTDEFINED];

			[cpu setMemoryWord:command forCellIndex:TEST_PC];
		
			[cpu setIndexRegister:[self mixIndexFromInteger:0] withNumber:indexNum];	// initial value to index register
			cpu.PC = TEST_PC;
			
			long accumulator = [self integerFromMIXINDEX:[cpu indexRegisterValue:indexNum]];
			XCTAssertEqual(accumulator, 0, @"index register should be properly cleared");
			
			[cpu executeCurrentOperation];
			
			accumulator = [self integerFromMIXINDEX:[cpu indexRegisterValue:indexNum]];
			NSLog(@"%@  %ld",mnemonic, data[i]);

			XCTAssertEqual(accumulator, data[i], @"Data shpuld be loaded into index register properly");
		}

		
	}

}


@end
