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

#define CMD_LDA	8

