//
//  MixCommnds.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriy S.R.O. All rights reserved.
//

#import "MixCommands.h"
#import "DebugPrint.h"

@interface MixCommand() {
	NSString *mnemoCode;
	Byte opercode;
	MIX_F operField;
	NSString *commnadNote;
	Byte machineTacts;
}

- (id) initCommandWithMnemonic:(NSString *)aMnemo commandCode:(Byte)aCode fieldType:(MIX_F)aField
						mTacts:(Byte)aTacts andDescription:(NSString *)aDescr;

@end


@implementation MixCommand

@synthesize commandCode = opercode, defaultFField = operField,
			mnemonic = mnemoCode, note = commnadNote;

- (id) initCommandWithMnemonic:(NSString *)aMnemo commandCode:(Byte)aCode fieldType:(MIX_F)aField
						mTacts:(Byte)aTacts andDescription:(NSString *)aDescr
{
	if (self = [super init]) {
		mnemoCode = aMnemo;
		opercode = aCode;
		operField = aField;
		commnadNote = aDescr;
		machineTacts = aTacts;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ : %@", self.mnemonic, self.note];
}

@end


@interface MixCommands() {
	NSDictionary *commandsByCode;
	NSDictionary *commandsByMnemonic;
}

@end

#pragma mark - MixCommands -

@implementation MixCommands


+ (MixCommands *) sharedInstance
{
	static MixCommands *_instance;
	if (_instance == nil) {
		_instance = [[MixCommands alloc] init];
	}
	return _instance;
}

- (id) init
{
	NSMutableDictionary *tmpCodeBase = [[NSMutableDictionary alloc] initWithCapacity:256];
	NSMutableDictionary *tmpMnemoBase = [[NSMutableDictionary alloc] initWithCapacity:256];
	
	if (self = [super init]) {
		for (NSArray *arr in [MixCommands commandList]) {
			NSString *mnemo = arr[0];
			MIX_F field = [arr[1] intValue];
			Byte operCode = [arr[2] intValue];
			NSString *note = arr[4];
			Byte aTact = [arr[3] intValue];
			
			MixCommand *command = [[MixCommand alloc] initCommandWithMnemonic:mnemo commandCode:operCode
																	fieldType:field mTacts:aTact andDescription:note];
			NSString *codeString = [NSString stringWithFormat:@"%03d",operCode];
			
			[tmpCodeBase setObject:command forKey:codeString];
			[tmpMnemoBase setObject:command forKey:mnemo];
			
		}
		// Working dataset is NOT mutable
		commandsByCode = [[NSDictionary alloc] initWithDictionary:tmpCodeBase];
		commandsByMnemonic = [[NSDictionary alloc] initWithDictionary:tmpMnemoBase];
	}
	return self;
}

- (MixCommand *) getCommandByCode:(Byte) commandCode
{
	NSString *codeString = [NSString stringWithFormat:@"%03d",commandCode];
	MixCommand *found = [commandsByCode objectForKey:codeString];
	return found;
}

- (MixCommand *) getCommandByMnemonic:(NSString *)mnemoCode
{
	if (!mnemoCode) return nil;
	return [commandsByMnemonic objectForKey:mnemoCode];
}

#pragma mark -  OperCode initialization -

+ (NSArray *) commandList
{
	// Mnemonic, F, C, machine tacts  and description
	return @[
				@[ @"LDA", @(MIX_F_FIELD), @(CMD_LDA), @(2), RStr(@"Load accumulator")],
				@[ @"LDX", @(MIX_F_FIELD), @(CMD_LDX), @(2), RStr(@"Load extension register")],
				@[ @"LD1", @(MIX_F_FIELD), @(CMD_LD1), @(2), RStr(@"Load index register 1")],
				@[ @"LD2", @(MIX_F_FIELD), @(CMD_LD2), @(2), RStr(@"Load index register 2")],
				@[ @"LD3", @(MIX_F_FIELD), @(CMD_LD3), @(2), RStr(@"Load index register 3")],
				@[ @"LD4", @(MIX_F_FIELD), @(CMD_LD4), @(2), RStr(@"Load index register 4")],
				@[ @"LD5", @(MIX_F_FIELD), @(CMD_LD5), @(2), RStr(@"Load index register 5")],
				@[ @"LD6", @(MIX_F_FIELD), @(CMD_LD6), @(2), RStr(@"Load index register 6")],
				@[ @"LDAN", @(MIX_F_FIELD), @(CMD_LDAN), @(2), RStr(@"Load accumulator negative")],
				@[ @"LDXN", @(MIX_F_FIELD), @(CMD_LDXN), @(2), RStr(@"Load extension register negative")],
				@[ @"LD1N", @(MIX_F_FIELD), @(CMD_LD1N), @(2), RStr(@"Load index register 1 negative")],
				@[ @"LD2N", @(MIX_F_FIELD), @(CMD_LD2N), @(2), RStr(@"Load index register 2 negative")],
				@[ @"LD3N", @(MIX_F_FIELD), @(CMD_LD3N), @(2), RStr(@"Load index register 3 negative")],
				@[ @"LD4N", @(MIX_F_FIELD), @(CMD_LD4N), @(2), RStr(@"Load index register 4 negative")],
				@[ @"LD5N", @(MIX_F_FIELD), @(CMD_LD5N), @(2), RStr(@"Load index register 5 negative")],
				@[ @"LD6N", @(MIX_F_FIELD), @(CMD_LD6N), @(2), RStr(@"Load index register 6 negative")],
				@[ @"STA", @(MIX_F_FIELD), @(CMD_STA), @(2), RStr(@"Store accumulator")],
				@[ @"STX", @(MIX_F_FIELD), @(CMD_STX), @(2), RStr(@"Store extension register")],
				@[ @"ST1", @(MIX_F_FIELD), @(CMD_ST1), @(2), RStr(@"Store index register 1")],
				@[ @"ST2", @(MIX_F_FIELD), @(CMD_ST2), @(2), RStr(@"Store index register 2")],
				@[ @"ST3", @(MIX_F_FIELD), @(CMD_ST3), @(2), RStr(@"Store index register 3")],
				@[ @"ST4", @(MIX_F_FIELD), @(CMD_ST4), @(2), RStr(@"Store index register 4")],
				@[ @"ST5", @(MIX_F_FIELD), @(CMD_ST5), @(2), RStr(@"Store index register 5")],
				@[ @"ST6", @(MIX_F_FIELD), @(CMD_ST6), @(2), RStr(@"Store index register 6")],
				@[ @"STJ", @(MIX_F_FIELD), @(CMD_STJ), @(2), RStr(@"Store jump register")],
				@[ @"STZ", @(MIX_F_FIELD), @(CMD_STZ), @(2), RStr(@"Clear memory cell")],
				@[ @"ADD", @(MIX_F_FIELD), @(CMD_ADD), @(2), RStr(@"Add to Accumulator")],
				@[ @"SUB", @(MIX_F_FIELD), @(CMD_SUB), @(2), RStr(@"Substract from Accumulator")],
				@[ @"MUL", @(MIX_F_FIELD), @(CMD_MUL), @(10), RStr(@"Multiply accumultor and memory cell")],
				@[ @"DIV", @(MIX_F_FIELD), @(CMD_DIV), @(12), RStr(@"Divide accumulator to memory cell content")],
				@[ @"ENTA", @(MIX_F_SHORT2), @(CMD_ENTA), @(1), RStr(@"enter A")],
				@[ @"ENTX", @(MIX_F_SHORT2), @(CMD_ENTX), @(1), RStr(@"Enter X")],
				@[ @"ENT1", @(MIX_F_SHORT2), @(CMD_ENT1), @(1), RStr(@"Enter index register 1")],
				@[ @"ENT2", @(MIX_F_SHORT2), @(CMD_ENT2), @(1), RStr(@"Enter index register 2")],
				@[ @"ENT3", @(MIX_F_SHORT2), @(CMD_ENT3), @(1), RStr(@"Enter index register 3")],
				@[ @"ENT4", @(MIX_F_SHORT2), @(CMD_ENT4), @(1), RStr(@"Enter index register 4")],
				@[ @"ENT5", @(MIX_F_SHORT2), @(CMD_ENT5), @(1), RStr(@"Enter index register 5")],
				@[ @"ENT6", @(MIX_F_SHORT2), @(CMD_ENT6), @(1), RStr(@"Enter index register 6")],
				@[ @"ENNA", @(MIX_F_SHORT3), @(CMD_ENTA), @(1), RStr(@"enter A negative")],
				@[ @"ENNX", @(MIX_F_SHORT3), @(CMD_ENTX), @(1), RStr(@"Enter X negative")],
				@[ @"ENN1", @(MIX_F_SHORT3), @(CMD_ENT1), @(1), RStr(@"Enter index register 1 negative")],
				@[ @"ENN2", @(MIX_F_SHORT3), @(CMD_ENT2), @(1), RStr(@"Enter index register 2 negative")],
				@[ @"ENN3", @(MIX_F_SHORT3), @(CMD_ENT3), @(1), RStr(@"Enter index register 3 negative")],
				@[ @"ENN4", @(MIX_F_SHORT3), @(CMD_ENT4), @(1), RStr(@"Enter index register 4 negative")],
				@[ @"ENN5", @(MIX_F_SHORT3), @(CMD_ENT5), @(1), RStr(@"Enter index register 5 negative")],
				@[ @"ENN6", @(MIX_F_SHORT3), @(CMD_ENT6), @(1), RStr(@"Enter index register 6 negative")],
				@[ @"INCA", @(MIX_F_SIGNONLY), @(CMD_ENTA), @(1), RStr(@"Increment A")],
				@[ @"DECA", @(MIX_F_SHORT1), @(CMD_ENTA), @(1), RStr(@"Decrement A")],
				@[ @"INCX", @(MIX_F_SIGNONLY), @(CMD_ENTX), @(1), RStr(@"Increment X")],
				@[ @"DECX", @(MIX_F_SHORT1), @(CMD_ENTX), @(1), RStr(@"Decrement X")],
				@[ @"INC1", @(MIX_F_SIGNONLY), @(CMD_ENT1), @(1), RStr(@"Increment Index Register 1")],
				@[ @"DEC1", @(MIX_F_SHORT1), @(CMD_ENT1), @(1), RStr(@"Decrement Index Register 1")],
				@[ @"INC2", @(MIX_F_SIGNONLY), @(CMD_ENT2), @(1), RStr(@"Increment Index Register 2")],
				@[ @"DEC2", @(MIX_F_SHORT1), @(CMD_ENT2), @(1), RStr(@"Decrement Index Register 2")],
				@[ @"INC3", @(MIX_F_SIGNONLY), @(CMD_ENT3), @(1), RStr(@"Increment Index Register 3")],
				@[ @"DEC3", @(MIX_F_SHORT1), @(CMD_ENT3), @(1), RStr(@"Decrement Index Register 3")],
				@[ @"INC4", @(MIX_F_SIGNONLY), @(CMD_ENT4), @(1), RStr(@"Increment Index Register 4")],
				@[ @"DEC4", @(MIX_F_SHORT1), @(CMD_ENT4), @(1), RStr(@"Decrement Index Register 4")],
				@[ @"INC5", @(MIX_F_SIGNONLY), @(CMD_ENT5), @(1), RStr(@"Increment Index Register 5")],
				@[ @"DEC5", @(MIX_F_SHORT1), @(CMD_ENT5), @(1), RStr(@"Decrement Index Register 5")],
				@[ @"INC6", @(MIX_F_SIGNONLY), @(CMD_ENT6), @(1), RStr(@"Increment Index Register 6")],
				@[ @"DEC6", @(MIX_F_SHORT1), @(CMD_ENT6), @(1), RStr(@"Decrement Index Register 6")],
				@[ @"CMPA", @(MIX_F_FIELD), @(CMD_CMPA), @(2), RStr(@"Compare A")],
				@[ @"CMPX", @(MIX_F_FIELD), @(CMD_CMPX), @(2), RStr(@"Compare X")],
				@[ @"CMP1", @(MIX_F_FIELD), @(CMD_CMP1), @(2), RStr(@"Compare index register 1")],
				@[ @"CMP2", @(MIX_F_FIELD), @(CMD_CMP2), @(2), RStr(@"Compare index register 2")],
				@[ @"CMP3", @(MIX_F_FIELD), @(CMD_CMP3), @(2), RStr(@"Compare index register 3")],
				@[ @"CMP4", @(MIX_F_FIELD), @(CMD_CMP4), @(2), RStr(@"Compare index register 4")],
				@[ @"CMP5", @(MIX_F_FIELD), @(CMD_CMP5), @(2), RStr(@"Compare index register 5")],
				@[ @"CMP6", @(MIX_F_FIELD), @(CMD_CMP6), @(2), RStr(@"Compare index register 6")],
				@[ @"JMP",	@(MIX_F_SIGNONLY), @(CMD_JMP), @(1), RStr(@"Jump")],
				@[ @"JSJ",	@(MIX_F_SHORT1), @(CMD_JMP), @(1), RStr(@"Jump, save J")],
				@[ @"JOV",	@(MIX_F_SHORT2), @(CMD_JMP), @(1), RStr(@"Jump, on overflow")],
				@[ @"JNOV",	@(MIX_F_SHORT3), @(CMD_JMP), @(1), RStr(@"Jump, on no overflow")],
				@[ @"JL",	@(MIX_F_SHORT4), @(CMD_JMP), @(1), RStr(@"Jump, on less")],
				@[ @"JE",	@(MIX_F_FIELD), @(CMD_JMP), @(1), RStr(@"Jump, on equal")],
				@[ @"JG",	@(MIX_F_SHORT6), @(CMD_JMP), @(1), RStr(@"Jump, on greater")],
				@[ @"JGE",	@(MIX_F_SHORT7), @(CMD_JMP), @(1), RStr(@"Jump, on greater or equal")],
				@[ @"JNE",	@(MIX_F_SHORT8), @(CMD_JMP), @(1), RStr(@"Jump, on non equal")],
				@[ @"JLE",	@(MIX_F_SHORT9), @(CMD_JMP), @(1), RStr(@"Jump, on less or equal")],
				@[ @"JAN",	@(MIX_F_SIGNONLY), @(CMD_JAN), @(1), RStr(@"Jump A negative")],
				@[ @"JAZ",	@(MIX_F_SHORT1), @(CMD_JAN), @(1), RStr(@"Jump A zero")],
				@[ @"JAP",	@(MIX_F_SHORT2), @(CMD_JAN), @(1), RStr(@"Jump A positive")],
				@[ @"JANN",	@(MIX_F_SHORT3), @(CMD_JAN), @(1), RStr(@"Jump A nonnegative")],
				@[ @"JANZ",	@(MIX_F_SHORT4), @(CMD_JAN), @(1), RStr(@"Jump A nonzero")],
				@[ @"JANP",	@(MIX_F_FIELD), @(CMD_JAN), @(1), RStr(@"Jump A nonpositive")],
				@[ @"JXN",	@(MIX_F_SIGNONLY), @(CMD_JXN), @(1), RStr(@"Jump X negative")],
				@[ @"JXZ",	@(MIX_F_SHORT1), @(CMD_JXN), @(1), RStr(@"Jump X zero")],
				@[ @"JXP",	@(MIX_F_SHORT2), @(CMD_JXN), @(1), RStr(@"Jump X positive")],
				@[ @"JXNN",	@(MIX_F_SHORT3), @(CMD_JXN), @(1), RStr(@"Jump X nonnegative")],
				@[ @"JXNZ",	@(MIX_F_SHORT4), @(CMD_JXN), @(1), RStr(@"Jump X nonzero")],
				@[ @"JXNP",	@(MIX_F_FIELD), @(CMD_JXN), @(1), RStr(@"Jump X nonpositive")],
				@[ @"J1N",	@(MIX_F_SIGNONLY), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 negative")],
				@[ @"J1Z",	@(MIX_F_SHORT1), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 zero")],
				@[ @"J1P",	@(MIX_F_SHORT2), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 positive")],
				@[ @"J1NN",	@(MIX_F_SHORT3), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 nonnegative")],
				@[ @"J1NZ",	@(MIX_F_SHORT4), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 nonzero")],
				@[ @"J1NP",	@(MIX_F_FIELD), @(CMD_J1), @(1), RStr(@"Jump Index Register 1 nonpositive")],
				@[ @"J2N",	@(MIX_F_SIGNONLY), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 negative")],
				@[ @"J2Z",	@(MIX_F_SHORT1), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 zero")],
				@[ @"J2P",	@(MIX_F_SHORT2), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 positive")],
				@[ @"J2NN",	@(MIX_F_SHORT3), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 nonnegative")],
				@[ @"J2NZ",	@(MIX_F_SHORT4), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 nonzero")],
				@[ @"J2NP",	@(MIX_F_FIELD), @(CMD_J2), @(1), RStr(@"Jump Index Register 2 nonpositive")],
				@[ @"J3N",	@(MIX_F_SIGNONLY), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 negative")],
				@[ @"J3Z",	@(MIX_F_SHORT1), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 zero")],
				@[ @"J3P",	@(MIX_F_SHORT2), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 positive")],
				@[ @"J3NN",	@(MIX_F_SHORT3), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 nonnegative")],
				@[ @"J3NZ",	@(MIX_F_SHORT4), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 nonzero")],
				@[ @"J3NP",	@(MIX_F_FIELD), @(CMD_J3), @(1), RStr(@"Jump Index Register 3 nonpositive")],
				@[ @"J4N",	@(MIX_F_SIGNONLY), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 negative")],
				@[ @"J4Z",	@(MIX_F_SHORT1), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 zero")],
				@[ @"J4P",	@(MIX_F_SHORT2), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 positive")],
				@[ @"J4NN",	@(MIX_F_SHORT3), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 nonnegative")],
				@[ @"J4NZ",	@(MIX_F_SHORT4), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 nonzero")],
				@[ @"J4NP",	@(MIX_F_FIELD), @(CMD_J4), @(1), RStr(@"Jump Index Register 4 nonpositive")],
				@[ @"J5N",	@(MIX_F_SIGNONLY), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 negative")],
				@[ @"J5Z",	@(MIX_F_SHORT1), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 zero")],
				@[ @"J5P",	@(MIX_F_SHORT2), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 positive")],
				@[ @"J5NN",	@(MIX_F_SHORT3), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 nonnegative")],
				@[ @"J5NZ",	@(MIX_F_SHORT4), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 nonzero")],
				@[ @"J5NP",	@(MIX_F_FIELD), @(CMD_J5), @(1), RStr(@"Jump Index Register 5 nonpositive")],
				@[ @"J6N",	@(MIX_F_SIGNONLY), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 negative")],
				@[ @"J6Z",	@(MIX_F_SHORT1), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 zero")],
				@[ @"J6P",	@(MIX_F_SHORT2), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 positive")],
				@[ @"J6NN",	@(MIX_F_SHORT3), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 nonnegative")],
				@[ @"J6NZ",	@(MIX_F_SHORT4), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 nonzero")],
				@[ @"J6NP",	@(MIX_F_FIELD), @(CMD_J6), @(1), RStr(@"Jump Index Register 6 nonpositive")],
				@[ @"SLA",	@(MIX_F_SIGNONLY), @(CMD_SLA), @(2), RStr(@"Shift left A")],
				@[ @"SRA",	@(MIX_F_SHORT1), @(CMD_SLA), @(2), RStr(@"Shift right A")],
				@[ @"SLAX",	@(MIX_F_SHORT2), @(CMD_SLA), @(2), RStr(@"Shift left AX")],
				@[ @"SRAX",	@(MIX_F_SHORT3), @(CMD_SLA), @(2), RStr(@"Shift right AX")],
				@[ @"SLC",	@(MIX_F_SHORT4), @(CMD_SLA), @(2), RStr(@"Shift left AX circularly")],
				@[ @"SRC",	@(MIX_F_FIELD), @(CMD_SLA), @(2), RStr(@"Shift right AX circularly")],
				@[ @"MOVE",	@(MIX_F_NOTDEFINED), @(CMD_MOVE), @(1), RStr(@"Move memory block")],
				@[ @"NOP",	@(MIX_F_NOTDEFINED), @(CMD_MOVE), @(1), RStr(@"No operation")],
				@[ @"HLT",	@(MIX_F_SHORT2), @(CMD_HLT), @(10), RStr(@"Halt CPU")],
				@[ @"IN",	@(MIX_F_NOTDEFINED), @(CMD_IN), @(1), RStr(@"Input data")],
				@[ @"OUT",	@(MIX_F_NOTDEFINED), @(CMD_OUT), @(1), RStr(@"Output data")],
				];
}

@end
