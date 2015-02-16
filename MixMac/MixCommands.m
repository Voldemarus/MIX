//
//  MixCommnds.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
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
				
			 ];
}

@end
