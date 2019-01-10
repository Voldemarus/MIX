//
//  MIXString.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 28/12/2018.
//  Copyright © 2018 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Theme.h"
#import "DebugPrint.h"
#import "Preferences.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIXString : NSObject < NSCoding, NSCopying >

- (instancetype) initWithText:(NSString* _Nullable)text;

@property (nonatomic, retain) NSString *source;       // Исходная строка
@property (nonatomic, retain) NSString *label;        // Метка
@property (nonatomic, retain) NSString *mnemonic;     // Мнемокод операции
@property (nonatomic, retain) NSString *operand;      // Параметры операции
@property (nonatomic, retain) NSString *comment;      // Комментарий
@property (nonatomic, readwrite) NSInteger memoryPos; // Адрес в памяти
@property (nonatomic, readwrite) BOOL commentOnly;    // Если YES то вся строка это комментарий
@property (nonatomic, readwrite) BOOL errorLabel;     // Если есть ошибка в метка
@property (nonatomic, readwrite) BOOL errorMnemonic;  // Если есть ошибка в мнемокоде
@property (nonatomic, readwrite) BOOL errorOperand;   // Если есть ошибка в операнде
@property (nonatomic, readwrite) BOOL error;          // Если есть ошибка в строке
@property (nonatomic, retain) NSMutableArray *errors; // Список ошибок, пока не настроен!

// Для разобраной строки:
@property (nonatomic, retain) NSString *operandNew;      // Параметры операции
@property (nonatomic, retain) NSString * SIGN;
@property (nonatomic, retain) NSString * ADDRESS;
@property (nonatomic, retain) NSString * INDEX;
@property (nonatomic, retain) NSString * MOD;
@property (nonatomic, retain) NSString * OPCODE;



// Возвращает простую строку, с разделелителями- табуляторами
- (NSString *) stringPlain;

// Возвращает отформатированную строку, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributed;

@end

NS_ASSUME_NONNULL_END

// Учебник по MIX и MIXAL на прусском:
// http://linux.yaroslavl.ru/docs/altlinux/doc-gnu/mdk/mdk_4.html#SEC31
//

// 59 валидных операторов
#define VALID_COMMAND @[@"ADD", @"CHAR", @"CMPA", @"CMP1", @"CMP2", @"CMP3", @"CMP4", @"CMP5", @"CMP6", @"CMPX", @"DECA", @"DEC1", @"DEC2", @"DEC3", @"DEC4", @"DEC5", @"DEC6", @"DECX", @"DIV", @"ENNA", @"ENN1", @"ENN2", @"ENN3", @"ENN4", @"ENN5", @"ENN6", @"ENNX", @"ENTA", @"ENT1", @"ENT2", @"ENT3", @"ENT4", @"ENT5", @"ENT6", @"ENTX", @"HLT", @"IN", @"INCA", @"INC1", @"INC2", @"INC3", @"INC4", @"INC5", @"INC6", @"INCX", @"IOC", @"JAN", @"JANN", @"JANP", @"JANZ", @"JAP", @"JAZ", @"JBUS", @"JE", @"JG", @"JGE", @"J1N", @"J2N", @"J3N", @"J4N", @"J5N", @"J6N", @"J1NN", @"J2NN", @"J3NN", @"J4NN", @"J5NN", @"J6NN", @"J1NP", @"J2NP", @"J3NP", @"J4NP", @"J5NP", @"J6NP", @"J1NZ", @"J2NZ", @"J3NZ", @"J4NZ", @"J5NZ", @"J6NZ", @"J1P", @"J2P", @"J3P", @"J4P", @"J5P", @"J6P", @"J1Z", @"J2Z", @"J3Z", @"J4Z", @"J5Z", @"J6Z", @"JL", @"JLE", @"JMP", @"JNE", @"JNOV", @"JOV", @"JRED", @"JSJ", @"JXN", @"JXNN", @"JXNP", @"JXNZ", @"JXP", @"JXZ", @"LDA", @"LDAN", @"LD1", @"LD2", @"LD3", @"LD4", @"LD5", @"LD6", @"LD1N", @"LD2N", @"LD3N", @"LD4N", @"LD5N", @"LD6N", @"LDX", @"LDXN", @"MOVE", @"MUL", @"NOP", @"NUM", @"OUT", @"SLA", @"SLAX", @"SLC", @"SRA", @"SRAX", @"SRC", @"STA", @"ST1", @"ST2", @"ST3", @"ST4", @"ST5", @"ST6", @"STJ", @"STX", @"STZ", @"SUB", \
@"ORIG", @"EQU", @"CON", @"ALF", @"END"]

// 3 оператора не требующих аргументы
#define OPER_WITHOUT_PARAM @[@"NOP", @"HLT", @"CHAR"]

// операторы не увеличивающие счетчик памяти
#define OPER_NO_MEMORY @[@"ORIG", @"EQU"]
