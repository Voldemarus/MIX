//
//  MLine+CoreDataClass.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLine : NSManagedObject

// Возвращает отформатированную строку, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributed;
// Возвращает отформатированную строку с  исходным кодом и замененными метками и адресами, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributedReplaced;

+ (NSAttributedString*) parceAllString:(NSString*)string decode:(BOOL)decode error:(BOOL* _Nullable)hasError;

@end

NS_ASSUME_NONNULL_END

#import "MLine+CoreDataProperties.h"

// Учебник по MIX и MIXAL на прусском:
// http://linux.yaroslavl.ru/docs/altlinux/doc-gnu/mdk/mdk_4.html#SEC31
//

#define MEMORY_POSITION_DEFAULT 2000

// 59 валидных операторов
#define VALID_COMMAND @[@"ADD", @"CHAR", @"CMPA", @"CMP1", @"CMP2", @"CMP3", @"CMP4", @"CMP5", @"CMP6", @"CMPX", @"DECA", @"DEC1", @"DEC2", @"DEC3", @"DEC4", @"DEC5", @"DEC6", @"DECX", @"DIV", @"ENNA", @"ENN1", @"ENN2", @"ENN3", @"ENN4", @"ENN5", @"ENN6", @"ENNX", @"ENTA", @"ENT1", @"ENT2", @"ENT3", @"ENT4", @"ENT5", @"ENT6", @"ENTX", @"HLT", @"IN", @"INCA", @"INC1", @"INC2", @"INC3", @"INC4", @"INC5", @"INC6", @"INCX", @"IOC", @"JAN", @"JANN", @"JANP", @"JANZ", @"JAP", @"JAZ", @"JBUS", @"JE", @"JG", @"JGE", @"J1N", @"J2N", @"J3N", @"J4N", @"J5N", @"J6N", @"J1NN", @"J2NN", @"J3NN", @"J4NN", @"J5NN", @"J6NN", @"J1NP", @"J2NP", @"J3NP", @"J4NP", @"J5NP", @"J6NP", @"J1NZ", @"J2NZ", @"J3NZ", @"J4NZ", @"J5NZ", @"J6NZ", @"J1P", @"J2P", @"J3P", @"J4P", @"J5P", @"J6P", @"J1Z", @"J2Z", @"J3Z", @"J4Z", @"J5Z", @"J6Z", @"JL", @"JLE", @"JMP", @"JNE", @"JNOV", @"JOV", @"JRED", @"JSJ", @"JXN", @"JXNN", @"JXNP", @"JXNZ", @"JXP", @"JXZ", @"LDA", @"LDAN", @"LD1", @"LD2", @"LD3", @"LD4", @"LD5", @"LD6", @"LD1N", @"LD2N", @"LD3N", @"LD4N", @"LD5N", @"LD6N", @"LDX", @"LDXN", @"MOVE", @"MUL", @"NOP", @"NUM", @"OUT", @"SLA", @"SLAX", @"SLC", @"SRA", @"SRAX", @"SRC", @"STA", @"ST1", @"ST2", @"ST3", @"ST4", @"ST5", @"ST6", @"STJ", @"STX", @"STZ", @"SUB", \
@"ORIG", @"EQU", @"CON", @"ALF", @"END"]

// 3 оператора не требующих аргументы
#define OPER_WITHOUT_PARAM @[@"NOP", @"HLT", @"CHAR"]

// операторы не увеличивающие счетчик памяти
#define OPER_NO_MEMORY @[@"ORIG", @"EQU"]
