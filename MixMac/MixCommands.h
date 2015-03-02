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
	MIX_F_NOTDEFINED = -1,
	MIX_F_SIGNONLY = 0,			// only sign is extracted
	MIX_F_SHORT1 = 1,
	MIX_F_SHORT2 = 2,
	MIX_F_SHORT3 = 3,
	MIX_F_SHORT4 = 4,
	MIX_F_FIELD = 5,			// the whole memory cell content
	MIX_F_SHORT6 = 6,
	MIX_F_SHORT7 = 7,
	MIX_F_SHORT8 = 8,
	MIX_F_SHORT9 = 9,
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

#define CMD_ADD		1
#define CMD_SUB		2
#define CMD_MUL		3
#define CMD_DIV		4
#define CMD_SLA		6
#define CMD_MOVE	7
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
#define CMD_JMP		39
#define CMD_JAN		40
#define CMD_J1		41
#define CMD_J2		42
#define CMD_J3		43
#define CMD_J4		44
#define CMD_J5		45
#define CMD_J6		46
#define CMD_JXN		47
#define CMD_ENTA	48
#define CMD_ENT1	49
#define CMD_ENT2	50
#define CMD_ENT3	51
#define CMD_ENT4	52
#define CMD_ENT5	53
#define CMD_ENT6	54
#define CMD_ENTX	55
#define CMD_CMPA	56
#define	CMD_CMP1	57
#define CMD_CMP2	58
#define CMD_CMP3	59
#define CMD_CMP4	60
#define CMD_CMP5	61
#define CMD_CMP6	62
#define CMD_CMPX	63




