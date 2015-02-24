//
//  MIXCPU.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "MIXCPU.h"
#import "Preferences.h"

#import "DebugPrint.h"

@interface MIXCPU() {
	
	MixCommands *commands;
	
	MIXWORD memory[MIX_MEMORY_SIZE];		// internal Memory
	
	MIXINDEX indexRegister[MIX_INDEX_REGISTERS];

	MIXINDEX	jumpRegister;					// register J (Program Counter)
	MIXWORD		accumultor;						// register A
	MIXWORD		extension;						// register X
	
	BOOL overflowFlag;
	MIX_COMPARASION comparasionFlag;
}

@end

NSString * const MIXExceptionInvalidMemoryCellIndex	=	@"MIXExceptionInvalidMemoryCellIndex";
NSString * const MIXExceptionInvalidIndexRegister	=	@"MIXExceptionInvalidIndexRegister";
NSString * const MIXExceptionInvalidOperationCode	=	@"MIXExceptionInvalidOperationCode";
NSString * const MIXExceptionInvalidFieldModifer	=	@"MIXExceptionInvalidFieldModifer";


@implementation MIXCPU

@synthesize PC;

+ (MIXCPU *) sharedInstance
{
	static MIXCPU *_instance;
	if (_instance == nil) {
		_instance = [[MIXCPU alloc] init];
	}
	return _instance;
}

- (id) init
{
	if (self = [super init]) {
		self.sixBitByte = [Preferences sharedPreferences].byteHas6Bit;
		
		commands = [MixCommands sharedInstance];	// set up commands data
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(byteSizeChanged:) name:VVVbyteSizeChanged object:nil];
	}
	return self;
}

#pragma mark - Public methods

- (void) resetCPU
{
	// Clear flags
	comparasionFlag = MIX_NOT_SET;
	overflowFlag = NO;
	
	MIXWORD emptyCell;
	self.A = emptyCell;
	self.X = emptyCell;
	self.PC = 0;
	MIXINDEX emptyIndex;
	emptyIndex.sign = 0;
	emptyIndex.indexByte[0] = 0;
	emptyIndex.indexByte[1] = 0;
	for (int i = 1; i <= MIX_INDEX_REGISTERS;i++) {
		[self setIndexRegister:emptyIndex withNumber:i];
	}
	self.J = emptyIndex;
	
	// clear memory
	for (int i = 0; i < MIX_MEMORY_SIZE; i++) {
		MIXWORD cell = memory[i];
		cell.sign = 0;
		for (int j = 0; j < MIX_WORD_SIZE; j++) {
			cell.byte[j] = 0;
		}
	}
}

- (void) clearFlags
{
	overflowFlag = NO;
	comparasionFlag = MIX_NOT_SET;
}


- (long) maxInteger
{
	long result = 0;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result = result << (self.sixBitByte ? 6 : 8);
		result += (self.sixBitByte ? 0x3f : 0xff);
	}
	return result;
}

- (long) maxIndex
{
	long result = 0;
	for (int i = 0; i < 2; i++) {
		result = result << (self.sixBitByte ? 6 : 8);
		result += (self.sixBitByte ? 0x3f : 0xff);
	}
	return result;
	
}

- (long) maxDoubleWord
{
	long result = 0;
	for (int i = 0; i < MIX_WORD_SIZE*2; i++) {
		result = result << (self.sixBitByte ? 6 : 8);
		result += (self.sixBitByte ? 0x3f : 0xff);
	}
	return result;

}

- (void) setMemoryWord:(MIXWORD)aWord forCellIndex:(int) index
{
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	MIXWORD cell;
	cell.sign = aWord.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		cell.byte[i] = aWord.byte[i];
	}
	memory[index] = cell;
}

- (MIXWORD) memoryWordForCellIndex:(int) index
{
	MIXWORD result;
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return result;
	}
	MIXWORD cell = memory[index];
	result.sign = cell.sign ;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = cell.byte[i];
	}
	return result;
}

- (void) storeNumber:(long)aValue forCellIndex:(int) index
{
	MIXWORD storeValue;
	storeValue.sign = NO;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		storeValue.byte[i] = 0;
	}
	if (aValue < 0) {
		storeValue.sign = YES;
		aValue = -aValue;
	}
	for (int i = MIX_WORD_SIZE-1; i >= 0; i--) {
		Byte tmp = aValue & (self.sixBitByte ? 0x3F : 0xFF);
		storeValue.byte[i] = tmp;
		aValue >>= (self.sixBitByte ? 6 : 8);
	}
	[self setMemoryWord:storeValue forCellIndex:index];
}


- (long) memoryContentForCellIndex:(int)index
{
	if (index < 0 || index >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return 0;
	}
	MIXWORD memCell = memory[index];
	return [self integerForMixWord:memCell];
}

- (long) integerForMixWord:(MIXWORD) memCell
{
	int result = 0;
	for (int i=0; i < MIX_WORD_SIZE; i++) {
		result <<= (self.sixBitByte ? 6 : 8);
		result += memCell.byte[i];
	}
	if (memCell.sign) {
		result = -result;
	}
	return result;
}


#pragma mark - properties getter/seeter methods

- (MIXWORD) A
{
	MIXWORD result;
	result.sign = accumultor.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = accumultor.byte[i];
	}
	return result;
}

- (void) setA:(MIXWORD) newA
{
	accumultor.sign = newA.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		accumultor.byte[i] = newA.byte[i];
	}
}

- (MIXWORD) X
{
	MIXWORD result;
	result.sign = extension.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = extension.byte[i];
	}
	return result;
}

- (void) setX:(MIXWORD)X
{
	extension.sign = X.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		extension.byte[i] = X.byte[i];
	}
}


- (MIXINDEX) J
{
	MIXINDEX result;
	result.sign = jumpRegister.sign;
	result.indexByte[0] = jumpRegister.indexByte[0];
	result.indexByte[1] = jumpRegister.indexByte[1];
	return result;
}

- (void) setJ:(MIXINDEX)J
{
	jumpRegister.sign = J.sign;
	jumpRegister.indexByte[0] = J.indexByte[0];
	jumpRegister.indexByte[1] = J.indexByte[1];
}

#pragma mark Index Registers access

- (void) setIndexRegister:(MIXINDEX) aValue withNumber:(int)aIndex
{
	if (aIndex < 1 || aIndex > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister
					format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	MIXINDEX result;
	result.sign = aValue.sign;
	result.indexByte[0] = aValue.indexByte[0];
	result.indexByte[1] = aValue.indexByte[1];
	indexRegister[aIndex-1] = result;
}

- (MIXINDEX) indexRegisterValue:(int)aIndex
{
	MIXINDEX result;
	// OPTION BASE 1  !!!
	if (aIndex < 1 || aIndex > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister
					format:RStr(MIXExceptionInvalidIndexRegister)];
		return result;
	}
	MIXINDEX indexReg = indexRegister[aIndex-1];
	result.sign = indexReg.sign;
	result.indexByte[0] = indexReg.indexByte[0];
	result.indexByte[1] = indexReg.indexByte[1];
	return result;
}

- (void) storeOffset:(int)offset inIndexRegister:(int)aIndex
{
	MIXINDEX indexData;
	if (offset < 0) {
		indexData.sign = YES;
		offset = -offset;
	} else {
		indexData.sign = NO;
	}
	if (offset > MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	indexData.indexByte[0] = offset >> (self.sixBitByte ? 6 : 8);
	indexData.indexByte[1] = offset & (self.sixBitByte ? 0x3F : 0xFF);
	
	[self setIndexRegister:indexData withNumber:aIndex];
}

- (int) offsetInIndexRegister:(int)aIndex
{
	MIXINDEX ind = [self indexRegisterValue:aIndex];
	int result = ind.indexByte[0] << (self.sixBitByte ? 6 : 8);
	result += ind.indexByte[1];
	if (ind.sign) {
		result = -result;
	}
	return result;
}


#pragma mark Auxillary Registers Access

- (BOOL) overflow
{
	return overflowFlag;
}

- (MIX_COMPARASION) flag
{
	return comparasionFlag;
}

- (MIXINDEX) index1
{
	return [self indexRegisterValue:1];
}

- (void) setIndex1:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:1];
}

- (MIXINDEX) index2
{
	return [self indexRegisterValue:2];
}

- (void) setIndex2:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:2];
}

- (MIXINDEX) index3
{
	return [self indexRegisterValue:3];
}

- (void) setIndex3:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:3];
}

- (MIXINDEX) index4
{
	return [self indexRegisterValue:4];
}

- (void) setIndex4:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:4];
}

- (MIXINDEX) index5
{
	return [self indexRegisterValue:5];
}

- (void) setIndex5:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:5];
}

- (MIXINDEX) index6
{
	return [self indexRegisterValue:6];
}

- (void) setIndex6:(MIXINDEX)index1
{
	[self setIndexRegister:index1 withNumber:6];
}

#pragma mark - Opercode processing methods

//
// Interprets content of the memory cell as command and eecute proper CPU command
//
- (void) executeCurrentOperation
{
	MIXWORD command = memory[self.PC];
	Byte operCode = command.byte[4];			// C Field
	
	MixCommand *cmd = [commands getCommandByCode:operCode];
	if (!cmd) {
		[NSException raise:MIXExceptionInvalidOperationCode format:RStr(MIXExceptionInvalidOperationCode)];
	} else {
		//
		// Increment program counter
		//
		self.PC = self.PC+1;
		if (self.PC >= MIX_MEMORY_SIZE) self.PC = 0;
		//
		// Decode CPU commands
		//
		switch (operCode) {
			case CMD_LDA:		[self processLDACommand:command negate:NO]; break;
			case CMD_LDX:		[self processLDXCommand:command negate:NO]; break;
			case CMD_LD1:
			case CMD_LD2:
			case CMD_LD3:
			case CMD_LD4:
			case CMD_LD5:
			case CMD_LD6:		[self processLDICommand:command forRegister:(operCode-CMD_LDA) negate:NO]; break;
			case CMD_LDAN:		[self processLDACommand:command negate:YES]; break;
			case CMD_LDXN:		[self processLDXCommand:command negate:YES]; break;
			case CMD_LD1N:
			case CMD_LD2N:
			case CMD_LD3N:
			case CMD_LD4N:
			case CMD_LD5N:
			case CMD_LD6N:		[self processLDICommand:command forRegister:(operCode-CMD_LDAN) negate:YES]; break;
			case CMD_STA:		[self processSTACommand:command]; break;
			case CMD_STX:		[self processSTXCommand:command]; break;
			case CMD_ST1:
			case CMD_ST2:
			case CMD_ST3:
			case CMD_ST4:
			case CMD_ST5:
			case CMD_ST6:		[self processSTICommand:command forRegister:(operCode-CMD_STA)]; break;
			case CMD_STJ:		[self processSTJCommand:command]; break;
			case CMD_STZ:		[self processSTZCommand:command]; break;
			case CMD_ADD:		[self processADDCommand:command negate:NO]; break;
			case CMD_SUB:		[self processADDCommand:command negate:YES]; break;
			case CMD_MUL:		[self processMULCommand:command]; break;
			case CMD_DIV:		[self processDIVCommand:command]; break;
			case CMD_ENTA:		[self processENTACommand:command accumulator:YES]; break;		// ENTA, ENNA, INCA, and DECA
			case CMD_ENTX:		[self processENTACommand:command accumulator:NO]; break;		// ENTX, ENNX, INCX, and DECX
			case CMD_ENT1:
			case CMD_ENT2:
			case CMD_ENT3:
			case CMD_ENT4:
			case CMD_ENT5:
			case CMD_ENT6:		[self processENTICommand:command
										 forRegister:(operCode-CMD_ENTA)]; break; //ENTI, ENNI, INCI, and DECI
				
				
			default: {
				[NSException raise:MIXExceptionInvalidOperationCode
							format:RStr(MIXExceptionInvalidOperationCode)];
				return;
			}
		}
	}
}


// LDA - load accumulator with memory cell' value
- (void) processLDACommand:(MIXWORD) command negate:(BOOL)negateFlag
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD finalValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	if (negateFlag) {
		finalValue.sign = !finalValue.sign;
	}
	// put result to accumulator
	self.A = finalValue;
}

// LDX - load accumulator with memory cell' value
- (void) processLDXCommand:(MIXWORD) command negate:(BOOL)negateFlag
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD finalValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	if (negateFlag) {
		finalValue.sign = !finalValue.sign;
	}
	// put result to X register
	self.X = finalValue;
}

//
// LD(RegNum) -- load index register, regNum - from 1 to 6
//
- (void) processLDICommand:(MIXWORD) command forRegister:(int)indReg negate:(BOOL)negateFlag
{
	if (indReg < 1 || indReg > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD finalValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	MIXINDEX finalIndex;	// now convert final value to the index format
	finalIndex.sign = (negateFlag ? !finalValue.sign :finalValue.sign);
	finalIndex.indexByte[0] = finalValue.byte[3];
	finalIndex.indexByte[1] = finalValue.byte[4];
	[self setIndexRegister:finalIndex withNumber:indReg];
}

//
//	STA - store data from accumulator to memory cell
//
- (void) processSTACommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from accumulator
	MIXWORD valueToProcess = self.A;
	MIXWORD finalValue = [self maskFieldsWithModifier:command.byte[3]
												  forWord:memory[effectiveAddress]
										 withModifier:valueToProcess];
	// put result to memory cell
	[self setMemoryWord:finalValue forCellIndex:(int)effectiveAddress];
}

//
// STX - store data from extension registor to memory cell
//
- (void) processSTXCommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from extension register
	MIXWORD valueToProcess = self.X;
	MIXWORD finalValue = [self maskFieldsWithModifier:command.byte[3]
												   forWord:memory[effectiveAddress]
										  withModifier:valueToProcess];
	// put result to memory cell
	[self setMemoryWord:finalValue forCellIndex:(int)effectiveAddress];
}

//
// STZ - store +0 into memory cell
//
- (void) processSTZCommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// create empty word
	MIXWORD emptyWord = [self createEmptyWord];
	MIXWORD result = [self maskFieldsWithModifier:command.byte[3]
											  forWord:memory[effectiveAddress]
									 withModifier:emptyWord];
	[self setMemoryWord:result forCellIndex:(int)effectiveAddress];
}

//
// STJ - store jump register into memory cell
//
- (void) processSTJCommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// create empty word
	MIXWORD emptyWord = [self createEmptyWord];
	emptyWord.byte[MIX_WORD_SIZE-2] = self.J.indexByte[0];
	emptyWord.byte[MIX_WORD_SIZE-1] = self.J.indexByte[1];
	MIXWORD result = [self maskFieldsWithModifier:command.byte[3]
											  forWord:memory[effectiveAddress]
									 withModifier:emptyWord];
	[self setMemoryWord:result forCellIndex:(int)effectiveAddress];

}

//
// ST* - store index register into memory cell
//
- (void) processSTICommand:(MIXWORD) command forRegister:(int)indReg
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// create empty word
	MIXWORD emptyWord = [self createEmptyWord];
	MIXINDEX indexReg = [self indexRegisterValue:indReg];
	emptyWord.sign = indexReg.sign;
	emptyWord.byte[MIX_WORD_SIZE-2] = indexReg.indexByte[0];
	emptyWord.byte[MIX_WORD_SIZE-1] = indexReg.indexByte[1];
	MIXWORD result = [self maskFieldsWithModifier:command.byte[3]
										  forWord:memory[effectiveAddress]
									 withModifier:emptyWord];
	[self setMemoryWord:result forCellIndex:(int)effectiveAddress];
}

//
//	Add - add content of memory cell to accumulator
//
- (void) processADDCommand:(MIXWORD) command  negate:(BOOL)negateFlag
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD addValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	MIXWORD summator = self.A;
	// Now we should add value from this word to the accumulator on per byte basis -
	// starting from the LSB with carry bits between bytes
	
	// to save time and efforts - first find conventional sum :-)
	long add1 = [self integerForMixWord:addValue];
	if (negateFlag) add1 = -add1;
	long sum = [self integerForMixWord:summator];
	sum += add1;
	
	// and now decode result into MIXWORD format
	if (sum < 0) {
		sum = -sum;
		summator.sign = YES;
	} else {
		summator.sign = NO;
	}
	BOOL specialCase = YES;
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = sum & (self.sixBitByte ? 0x3F : 0xFF);
		sum = sum >> (self.sixBitByte ? 6 : 8);
		summator.byte[i] = part;
		if (part > 0) specialCase = NO;
	}
	if (sum > 0) {
		// set overflow bit
		overflowFlag = YES;
	}
	// Very special case !!!   0 cannot be negative! 
	if (overflowFlag && specialCase && summator.sign == YES) {
		summator.sign = NO;
	}
	self.A = summator;
}

- (void) processMULCommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD addValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	// Now we should add value from this word to the accumulator on per byte basis -
	// starting from the LSB with carry bits between bytes
	
	long result = [self integerForMixWord:self.A];
	long multiplier = [self integerForMixWord:addValue];
	
	result = result * multiplier;
	
	MIXWORD	ra, rx;
	if (result < 0) {
		result = -result;
		ra.sign = YES;
		rx.sign = YES;
	} else {
		ra.sign = NO;
		rx.sign = NO;
	}

	BOOL specialCase = YES;
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = result & (self.sixBitByte ? 0x3F : 0xFF);
		result = result >> (self.sixBitByte ? 6 : 8);
		rx.byte[i] = part;
		if (part > 0) specialCase = NO;
	}
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = result & (self.sixBitByte ? 0x3F : 0xFF);
		result = result >> (self.sixBitByte ? 6 : 8);
		ra.byte[i] = part;
		if (part > 0) specialCase = NO;
	}
	if (result > 0) {
		overflowFlag = YES;
	}
	if (overflowFlag && specialCase && ra.sign == YES) {
		ra.sign = NO;
		rx.sign = NO;
	}
	self.A = ra;		// MSW
	self.X = rx;		// LSW
}


- (void) processDIVCommand:(MIXWORD) command
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// This address should pount to cell in memoty space
	if (effectiveAddress < 0 || effectiveAddress >= MIX_MEMORY_SIZE) {
		[NSException raise:MIXExceptionInvalidMemoryCellIndex
					format:RStr(MIXExceptionInvalidMemoryCellIndex)];
		return;
	}
	// Read value from the memory
	MIXWORD valueToProcess = memory[effectiveAddress];
	MIXWORD addValue = [self extractFieldswithModifier:command.byte[3] from:valueToProcess];
	// Now we should add value from this word to the accumulator on per byte basis -
	// starting from the LSB with carry bits between bytes
	
	long divider = [self integerForMixWord:addValue];
	long src = [self integerForMixWord:self.A];

	long abssrc = (src < 0 ? - src : src);
	long absdiv = (divider < 0 ? -divider : divider);
	BOOL oldASign = (src < 0);		// to be set into X after operation;
	
	if (divider == 0 || abssrc > absdiv ) {
		self.A = [self createEmptyWord];
		self.X = [self createEmptyWord];
		overflowFlag = YES;
		return;
	}

	src <<= (self.sixBitByte ? 6 : 8) * MIX_WORD_SIZE;
	src += [self integerForMixWord:self.X];
	
	long integerPart = src / divider;
	long fractionPart = src % divider;
	BOOL newASign = (integerPart < 0);
	
	MIXWORD	ra, rx;
	ra.sign = newASign;
	rx.sign = oldASign;
	
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = integerPart & (self.sixBitByte ? 0x3F : 0xFF);
		integerPart >>= (self.sixBitByte ? 6 : 8);
		ra.byte[i] = part;
	}

	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = fractionPart & (self.sixBitByte ? 0x3F : 0xFF);
		fractionPart >>= (self.sixBitByte ? 6 : 8);
		rx.byte[i] = part;
	}
	self.A = ra;		// MSW  - integer part
	self.X = rx;		// LSW  - fractional part
}

- (void) processENTACommand:(MIXWORD) command accumulator:(BOOL) accum
{
	MIX_F modifier = command.byte[3];
	switch (modifier) {
		case MIX_F_SIGNONLY:		[self processINCACommand:command negative:NO accumulator: accum]; break;
		case MIX_F_SHORT1:			[self processINCACommand:command negative:YES accumulator:accum]; break;
		case MIX_F_SHORT2:			[self processRealEnta:command negative:NO accumulator:accum]; break;
		case MIX_F_SHORT3:			[self processRealEnta:command negative:YES accumulator:accum]; break;
		default : {
			//
			// For this set of command arbitrary modifier is not supporrted.
			//
			[NSException raise:MIXExceptionInvalidFieldModifer format:RStr(MIXExceptionInvalidFieldModifer)];
		}
	}
}

// Add content of the effective address field to accumulator
- (void) processINCACommand:(MIXWORD) command negative:(BOOL)negative accumulator:(BOOL) accum
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	long sum = [self integerForMixWord:(accum ? self.A : self.X)];
	
	if (negative) {
		sum -= effectiveAddress;
	} else {
		sum += effectiveAddress;
	}
	MIXWORD summator;
	// and now decode result into MIXWORD format
	if (sum < 0) {
		sum = -sum;
		summator.sign = YES;
	} else {
		summator.sign = NO;
	}
	BOOL specialCase = YES;
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = sum & (self.sixBitByte ? 0x3F : 0xFF);
		sum = sum >> (self.sixBitByte ? 6 : 8);
		summator.byte[i] = part;
		if (part > 0) specialCase = NO;
	}
	if (sum > 0) {
		// set overflow bit
		overflowFlag = YES;
	}
	// Very special case !!!   0 cannot be negative!
	if (overflowFlag && specialCase && summator.sign == YES) {
		summator.sign = NO;
	}
	if (accum) {
		self.A = summator;
	} else {
		self.X = summator;
	}
}
	
	
- (void) processRealEnta:(MIXWORD) command negative:(BOOL) negative accumulator:(BOOL) accum
{
	NSInteger effectiveAddress = [self effectiveAddress:command];
	MIXWORD newValue = [self mixWordFromInteger:effectiveAddress];
	if (negative) {
		newValue.sign = !newValue.sign;
	}
	if (accum) {
		self.A = newValue;
	} else {
		self.X = newValue;
	}
}


- (void) processENTICommand:(MIXWORD)command forRegister:(int) indRegister
{
	MIX_F modifier = command.byte[3];
	switch (modifier) {
		case MIX_F_SIGNONLY:		[self processINCICommand:command register:indRegister negative:NO]; break;
		case MIX_F_SHORT1:			[self processINCICommand:command register:indRegister negative:YES]; break;
		case MIX_F_SHORT2:			[self processRealENTI:command register:indRegister negative:NO]; break;
		case MIX_F_SHORT3:			[self processRealENTI:command register:indRegister negative:YES]; break;
		default : {
			//
			// For this set of command arbitrary modifier is not supporrted.
			//
			[NSException raise:MIXExceptionInvalidFieldModifer format:RStr(MIXExceptionInvalidFieldModifer)];
		}
	}
}

- (void) processINCICommand:(MIXWORD)command register:(int)indReg negative:(BOOL)negative
{
	if (indReg < 1 || indReg > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// Read value from the memory
	MIXINDEX finalIndex = [self indexRegisterValue:indReg];
	long sum = [self integerFromMIXINDEX:finalIndex];
	if (negative) {
		effectiveAddress = -effectiveAddress;
	}
	sum += effectiveAddress;
	
	// fill output valie
	
	if (sum < 0) {
		finalIndex.sign = YES;
		sum = -sum;
	} else {
		finalIndex.sign = NO;
	}
	finalIndex.indexByte[1] = sum & (self.sixBitByte ? 0x3f : 0xFF);
	sum >>= (self.sixBitByte ? 6 : 8);
	finalIndex.indexByte[0] = sum & (self.sixBitByte ? 0x3f : 0xFF);
	[self setIndexRegister:finalIndex withNumber:indReg];
	if (sum > 0) {
		overflowFlag = YES;
	}
}

- (void) processRealENTI:(MIXWORD)command register:(int)indReg negative:(BOOL)negative
{
	if (indReg < 1 || indReg > MIX_INDEX_REGISTERS) {
		[NSException raise:MIXExceptionInvalidIndexRegister format:RStr(MIXExceptionInvalidIndexRegister)];
		return;
	}
	NSInteger effectiveAddress = [self effectiveAddress:command];
	// Read value from the memory
	MIXINDEX finalIndex;	// now convert final value to the index format
	BOOL sign = (effectiveAddress < 0);
	if (sign) {
		effectiveAddress = -effectiveAddress;
	}
	finalIndex.sign = (negative ? !sign : sign);
	finalIndex.indexByte[1] = effectiveAddress & (self.sixBitByte ? 0x3f : 0xFF);
	effectiveAddress >>= (self.sixBitByte ? 6 : 8);
	finalIndex.indexByte[0] = effectiveAddress & (self.sixBitByte ? 0x3f : 0xFF);
	[self setIndexRegister:finalIndex withNumber:indReg];
}
	

#pragma mark - Internal service methods

//
// Method extracts right fields from the src word and replaces fields, defined by fieldModifier in msk
// Returns resulted word
//

- (MIXWORD) maskFieldsWithModifier:(MIX_F) fieldModifier forWord:(MIXWORD) src withModifier:(MIXWORD) msk
{
	MIXWORD result;
	// default case - just store the whole accumaulator into memory cell
	if (fieldModifier == MIX_F_FIELD) return msk;
	
	result.sign = src.sign;
	for (int i = 0; i < MIX_WORD_SIZE; i++) {
		result.byte[i] = src.byte[i];
	}
	
	if (fieldModifier == MIX_F_SIGNONLY) {
		result.sign = msk.sign;
		return result;
	}
	// now process step by step
	int leftPos = (fieldModifier >> 3) & 0x7;
	int rightPos = fieldModifier & 0x7;
	if (rightPos < leftPos) {
		[NSException raise:MIXExceptionInvalidFieldModifer
					format:RStr(MIXExceptionInvalidFieldModifer)];
	}
	if (leftPos == 0) {
		// sign should be copied
		result.sign = msk.sign;
		leftPos = 1;
	}
	int mskIndex = MIX_WORD_SIZE - rightPos + leftPos - 1;	// where start for mask
	leftPos--;
	for (int i = mskIndex; i < MIX_WORD_SIZE; i++) {
		result.byte[leftPos++] = msk.byte[i];
	}
	return result;
}

//
// Method extract fields, defined by mask and creates word to be placed into full registers - A or X
//

- (MIXWORD) extractFieldswithModifier:(MIX_F)fieldModifier from:(MIXWORD)src
{
	// special cases will be processed first
	if (fieldModifier == MIX_F_FIELD) {
		return src;
	}
	MIXWORD result;
	result.sign = NO;			// it is set yo YES when initialized
	for (int i = 0; i < MIX_WORD_SIZE; i++) result.byte[i] = 0;
	if (fieldModifier == MIX_F_SIGNONLY) {
		result.sign = src.sign;
	} else {
		// complex case - should analyze fields
		int leftPos = (fieldModifier >> 3) & 0x7;
		int rightPos = fieldModifier & 0x7;
		if (rightPos < leftPos) {
			[NSException raise:MIXExceptionInvalidFieldModifer
						format:RStr(MIXExceptionInvalidFieldModifer)];
		}
		if (leftPos == 0) {
			// sign should be copied
			result.sign = src.sign;
			leftPos = 1;
		}
		// now we'll select fields and place them to the right side
		rightPos--;				// option base 0 in internal representation
		leftPos--;
		int outputPos = 4;		// last element
		for (int i = rightPos; i >= leftPos; i--) {
			result.byte[outputPos--] = src.byte[i];
		}
	}
	return result;
}

//
// Calculates effective address (memory cell index) from the J register
// sign bit is not used, this is a pointer to absolute address
//
- (NSInteger) executionAddr
{
	Byte left = jumpRegister.indexByte[0];
	Byte right = jumpRegister.indexByte[1];
	NSInteger address;
	address = left << (self.sixBitByte ? 6 : 8);
	address += right;
	
	//
	// Sanity check - wrap around memory_size
	//
	address = address % MIX_MEMORY_SIZE;

	return address;
}

//
// Calculates effective address of the data to be used in command
// supplied in argument
//
- (NSInteger) effectiveAddress:(MIXWORD) command
{
	Byte addrLeft = command.byte[0];
	Byte addrRight = command.byte[1];
	NSInteger address = addrLeft << (self.sixBitByte ? 6 : 8);
	address += addrRight;
	if (command.sign) {
		address = - address;
	}
	// apply index register if any
	Byte index = command.byte[2];
	if (index > 0) {
		if (index > MIX_INDEX_REGISTERS) {
			[NSException raise:MIXExceptionInvalidIndexRegister
						format:RStr(MIXExceptionInvalidIndexRegister)];
			return - [self maxInteger];
		}
		MIXINDEX indexValue = [self indexRegisterValue:index];
		NSInteger ind = indexValue.indexByte[0] << (self.sixBitByte ? 6 : 8);
		ind += indexValue.indexByte[1];
		if (indexValue.sign) {
			ind = -ind;
		}
		address += ind;
	}
	return address;
}



- (void) updateCPUCells
{
	
}



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


- (MIXWORD) createEmptyWord
{
	MIXWORD emptyWord;
	emptyWord.sign = NO;		// J is always non-negative!
	for (int i  = 0; i < MIX_WORD_SIZE; i++) {
		emptyWord.byte[i] = 0;
	}
	return emptyWord;
}

#pragma mark - Selectors

//
// Called when size of the byte is changed
//
- (void) byteSizeChanged:(NSNotification *) note
{
	self.sixBitByte = [[note object] boolValue];
	[self updateCPUCells];
}


#pragma mark - Internal data type converters

- (MIXWORD) mixWordFromInteger:(long) sum
{
	MIXWORD summator;
	if (sum < 0) {
		sum = -sum;
		summator.sign = YES;
	} else {
		summator.sign = NO;
	}
	for (int i = MIX_WORD_SIZE-1; i >=0; i--) {
		Byte part = sum & (self.sixBitByte ? 0x3F : 0xFF);
		sum = sum >> (self.sixBitByte ? 6 : 8);
		summator.byte[i] = part;
	}
	return summator;
}

- (long) integerFromMIXINDEX:(MIXINDEX) aIndex
{
		long result = 0;
		for (int i = 0; i < 2; i++) {
			result += aIndex.indexByte[i];
			result = result << (self.sixBitByte ? 6 : 8);
		}
		if (aIndex.sign) {
			result = -result;
		}
		return result;
}
				
- (MIXINDEX) mixIndexFromInteger:(long)aInt
{
		MIXINDEX result;
		result.sign = (aInt < 0);
		result.sign = (aInt < 0);
		if (aInt < 0) {
			aInt = -aInt;
		}
		for (int i = 1;i >= 0; i--) {
			result.indexByte[i] = aInt & (self.sixBitByte ? 0x3f : 0xFF);
			aInt = aInt >> (self.sixBitByte ? 6 : 8);
		}
		return result;
}
				


@end
