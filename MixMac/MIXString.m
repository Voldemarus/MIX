//
//  MIXString.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 28/12/2018.
//  Copyright © 2018 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "MIXString.h"

NSString * const LD_source          =    @"1";
NSString * const LD_label           =    @"2";
NSString * const LD_mnemonic        =    @"3";
NSString * const LD_operand         =    @"4";
NSString * const LD_comment         =    @"5";
NSString * const LD_address         =    @"6";
NSString * const LD_commentOnly     =    @"7";
NSString * const LD_errorLabel      =    @"8";
NSString * const LD_errorMnemonic   =    @"9";
NSString * const LD_errorOperand    =    @"10";
NSString * const LD_error           =    @"11";
NSString * const LD_errors          =    @"12";

@implementation MIXString

@synthesize source, label, mnemonic, operand, comment, address, commentOnly, errorLabel, errorMnemonic, errorOperand, error, errors;

- (instancetype) init
{
    if ([super init]) {
        self.source         = @"";
        self.label          = @"";
        self.mnemonic       = @"";
        self.operand        = @"";
        self.comment        = @"";
        
        self.address        = 0; // Адрес начала программы, если 0 то не назначен
        
        self.commentOnly    = NO;
        self.errorLabel     = NO;
        self.errorMnemonic  = NO;
        self.errorOperand   = NO;
        self.error          = NO;
        self.errors         = [NSMutableArray new];
    }
    return self;
}

- (instancetype) initWithText:(NSString* _Nullable)text
{
    if ([self init]) {
        self.source = text ? text : @"";
        [self parceString:text];
    }
    return self;
}

- (instancetype) copyWithZone:(NSZone *)zone
{
    MIXString *newRec = [[MIXString alloc] init];
    if (newRec) {
        newRec.source      = self.source;
        newRec.label       = self.label;
        newRec.mnemonic    = self.mnemonic;
        newRec.operand     = self.operand;
        newRec.comment     = self.comment;
        
        newRec.address     = self.address;
        
        newRec.commentOnly    = self.commentOnly;
        newRec.errorLabel     = self.error;
        newRec.errorMnemonic  = self.error;
        newRec.errorOperand   = self.error;
        newRec.error          = self.error;
        newRec.errors         = self.errors;
    }
    return newRec;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.source      forKey:LD_source];
    [aCoder encodeObject:self.label       forKey:LD_label];
    [aCoder encodeObject:self.mnemonic    forKey:LD_mnemonic];
    [aCoder encodeObject:self.operand     forKey:LD_operand];
    [aCoder encodeObject:self.comment     forKey:LD_comment];
    
    [aCoder encodeInteger:self.address    forKey:LD_address];
    
    [aCoder encodeBool:self.commentOnly   forKey:LD_commentOnly];
    [aCoder encodeBool:self.errorLabel    forKey:LD_errorLabel];
    [aCoder encodeBool:self.errorMnemonic forKey:LD_errorMnemonic];
    [aCoder encodeBool:self.errorOperand  forKey:LD_errorOperand];
    [aCoder encodeBool:self.error         forKey:LD_error];
    [aCoder encodeObject:self.errors      forKey:LD_errors];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    MIXString *newRec = [[MIXString alloc] init];
    if (newRec) {
        newRec.source        = [aDecoder decodeObjectForKey:LD_source];
        newRec.label         = [aDecoder decodeObjectForKey:LD_label];
        newRec.mnemonic      = [aDecoder decodeObjectForKey:LD_mnemonic];
        newRec.operand       = [aDecoder decodeObjectForKey:LD_operand];
        newRec.comment       = [aDecoder decodeObjectForKey:LD_comment];
        
        newRec.address       = [aDecoder decodeIntegerForKey:LD_address];
        
        newRec.commentOnly   = [aDecoder decodeBoolForKey:LD_commentOnly];
        newRec.errorLabel    = [aDecoder decodeBoolForKey:LD_errorLabel];
        newRec.errorMnemonic = [aDecoder decodeBoolForKey:LD_errorMnemonic];
        newRec.errorOperand  = [aDecoder decodeBoolForKey:LD_errorOperand];
        newRec.error         = [aDecoder decodeBoolForKey:LD_error];
        newRec.errors        = [aDecoder decodeObjectForKey:LD_errors];
    }
    return newRec;
}

#pragma mark - Методы класса

// Возвращает простую строку, с разделелителями- табуляторами
- (NSString *) stringPlain
{
    if (self.commentOnly) {
        return self.source;
    }
    return [NSString stringWithFormat:@"%@\t%@\t%@\t\t%@",self.label, self.mnemonic, self.operand, self.comment];
}

// Возвращает отформатированную строку, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributed
{

    NSMutableAttributedString *string = [NSMutableAttributedString new];
    if (self.commentOnly) {
        [string mixAppendComment:self.source];        
    } else if (self.error) {
        [string mixAppendError:self.source errorList:self.errorList]; // errorList - текст с ошибками для всплывающей тултипсы
    } else {
        [string mixAppendLabel:self.label];
        [string mixAppendMnemonic:[NSString stringWithFormat:@"\t%@", self.mnemonic]];
        [string mixAppendOperand:[NSString stringWithFormat:@"\t%@", self.operand]];
        [string mixAppendComment:[NSString stringWithFormat:@"\t%@", self.comment]];
    }
    
    return string;
}

- (NSString *)errorList
{
    return [self.errors componentsJoinedByString:@"\n"];
}

- (void) parceString:(NSString*)aString
{
    // Парить строку MIX - ассемблера
    // * Комментарий это
    // D2            LD1        0, 2(TYPE)     Дифференцирование
    //
    //    ALog(@"------------------------------------------\n%@\n------------------------------------------", aString);
    
    //MIXString *mixString = [[MIXString alloc] initWithText:aString];

    if (aString.length < 1 || [aString hasPrefix:@"*"]) {
        // Строка пустая или полностью комментарий
        self.commentOnly = YES;
        return;
    }
    
    NSRange rangeAll = NSMakeRange(0, aString.length);
    
    // Ищем 4 стандартных столбца и разбираем их
    static NSString * patternSintax = @"^([^\\s]*)\\s*([^\\s]*)\\s*(\"[^\"]*\"|[^\\s]*)\\s*(.*)";
    NSRegularExpression * regSyntax = [NSRegularExpression regularExpressionWithPattern:patternSintax options:NSRegularExpressionAnchorsMatchLines error:nil];

    NSTextCheckingResult * matches = [regSyntax firstMatchInString:aString options:0 range:rangeAll];
    NSRange range;
    
    BOOL labelStored = NO;
    BOOL mnemonicStored = NO;
    BOOL operandStored = NO;
    BOOL operandNeeds = NO;
    BOOL commentStored = NO;
    
    // индекс 0 - это весь текст, начинаем с 1
    for (NSInteger i = 1; i < matches.numberOfRanges; i++) {
        range = [matches rangeAtIndex:i];
        if (range.length > 0) {
            NSString *text = [aString substringWithRange:range];
            //ALog(@"%ld  ==>%@<==", i, text);
            
            if (!mnemonicStored) {
                if ([VALID_COMMAND containsObject:text]) {
                    self.mnemonic = text;
                    //ALog(@"mnemonic = %@", self.mnemonic);
                    labelStored = YES;
                    mnemonicStored = YES;
                    
                    operandNeeds = ![OPER_WITHOUT_PARAM containsObject:text];
                    operandStored = !operandNeeds;
                } else if (!labelStored) {
                    self.label = text;
                    //ALog(@"label = %@", self.label);
                    labelStored = YES;
                    NSRange rangeText = NSMakeRange(0, text.length);
                    if ([[NSRegularExpression regularExpressionWithPattern:@"^[0-9A-Z]+$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:text options:0 range:rangeText] > 0) {
                        if ([[NSRegularExpression regularExpressionWithPattern:@"\\d" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:text options:0 range:NSMakeRange(0, 1)] > 0) {
                            // Если первая цифра, то допустимы только 1H 1B(ссылка на 1H до вызова) 1F(ссылка на 1H впереди)
                            if ([[NSRegularExpression regularExpressionWithPattern:@"^[1-9][H]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:text options:0 range:rangeText] == 0) {
                                self.errorLabel = YES;
                                [self.errors addObject:RStr(@"Valid labels with digit: only digit and symbol \"H\"")];
                            }
                        }
                    } else {
                        self.errorLabel = YES;
                        [self.errors addObject:RStr(@"The label contains invalid characters")];
                    }
                } else {
                    self.comment = [aString substringWithRange:NSMakeRange(range.location, rangeAll.length - range.location)];
                    commentStored = YES;
                    //ALog(@"‼️ error comment = %@", self.comment);
                    self.errorLabel = YES;
                    [self.errors addObject:RStr(@"After the label, there must be a valid mnemonic")];
                    break;
                }
            } else if (!operandStored) {
                self.operand = text;
                //ALog(@"operand = %@", self.operand);
                operandStored = YES;
//                if ([VALID_COMMAND containsObject:text]) {
//                    self.errorMnemonic = YES;
//                    [self.errors addObject:RStr(@"After the mnemonic, there must be a valid operand, or incorrect label")];
//                }
                if ([[NSRegularExpression regularExpressionWithPattern:@"^[\\s\\*\\=\\+\\-\\,\\(\\)\\\"\\:\\/0-9A-Z]+$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)] == 0) {
                    self.errorOperand = YES;
                    [self.errors addObject:RStr(@"The operand contains invalid characters")];
                }
                if ([self.mnemonic isEqualToString:@"ALF"] && [text hasPrefix:@"\""] && [text hasSuffix:@"\""] && text.length > 7) {
                    self.errorMnemonic = YES;
                    [self.errors addObject:RStr(@"Memonic for ALF operand containts more then 5 symbols")];
                }
            } else if (!commentStored){
                //scanner.scanLocation
                self.comment = [aString substringWithRange:NSMakeRange(range.location, rangeAll.length - range.location)];
                commentStored = YES;
                //ALog(@"comment = %@", self.comment);
                break;
            }
        }
    }
    
    if ((labelStored && !mnemonicStored)) {
        self.errorLabel = YES;
        [self.errors addObject:RStr(@"Invalid string format: after label must be valid mnemonic")];
    }
    if (operandNeeds && !operandStored) {
        self.errorMnemonic = YES;
        [self.errors addObject:RStr(@"After the mnemonic, there must be a valid operand")];
    }

    self.error = (self.errors.count > 0); // Если список ошибок не пуст
//    if (self.error) {
//        ALog(@"‼️ %@", self.errorlist);
//    }
    return;
    
}


@end
