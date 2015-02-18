//
//  MixCommnds.h
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>

// default value for F field in command
typedef enum {
	MIX_F_SIGNONLY = 0,			// only sign is extracted
	MIX_F_FIELD = 5,			// the whole memory cell content
	
} MIX_F;

@interface MixCommand : NSObject

@property (nonatomic, readonly) Byte commandCode;
@property (nonatomic, readonly) MIX_F defaultFField;
@property (nonatomic, readonly, retain) NSString *mnemonic;
@property (nonatomic, readonly, retain) NSString *note;
@property (nonatomic, readonly) Byte	tacts;		// machine tacts required to preform command

@end


@interface MixCommands : NSObject

+ (MixCommands *) sharedInstance;			// singleton

- (MixCommand *) getCommandByCode:(Byte) commandCode;			// returns command for the code
- (MixCommand *) getCommandByMnemonic:(NSString *)mnemoCode;	// returns command for the mnemo
@end


#pragma mark - Command codes to avoid typeouts in assembler/processor

#define CMD_LDA		8
#define CMD_LD1		9
#define CMD_LD2		10
#define CMD_LD3		11
#define CMD_LD4		12
#define CMD_LD5		13
#define CMD_LD6		14
#define CMD_LDX		15
#define CMD_LDAN	16
#define CMD_LD1N	17
#define CMD_LD2N	18
#define CMD_LD3N	19
#define CMD_LD4N	20
#define CMD_LD5N	21
#define CMD_LD6N	22
#define CMD_LDXN	23
#define CMD_STA		24
#define CMD_ST1		25
#define CMD_ST2		26
#define CMD_ST3		27
#define CMD_ST4		28
#define CMD_ST5		29
#define CMD_ST6		30
#define CMD_STX		31
#define CMD_STJ		32
#define CMD_STZ		33


