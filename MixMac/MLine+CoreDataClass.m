//
//  MLine+CoreDataClass.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import "MLine+CoreDataClass.h"
#import "Theme.h"
#import "DebugPrint.h"
#import "Preferences.h"
#import "DAO.h"


@implementation MLine

- (void) awakeFromInsert
{
    // Устанвим строковый параметры, чтобы потом на нил не проверять
    self.source     =  @"";
    self.label      =  @"";
    self.mnemonic   =  @"";
    self.operand    =  @"";
    self.operandNew =  @"";
    self.comment    =  @"";
    self.errorsList =  @"";
    self.mSIGN      =  @"";
    self.mADDRESS   =  @"";
    self.mINDEX     =  @"";
    self.mMOD       =  @"";
    self.mOPCODE    =  @"";
}

#pragma mark - Методы класса

// Возвращает отформатированную строку с исходным кодом, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributed
{

    NSMutableAttributedString *string = [NSMutableAttributedString new];
    if (self.commentOnly) {
        [string mixAppendComment:self.source];
    } else if (self.error) {
        [string mixAppendError:self.source errorList:self.errorsList]; // errorList - текст с ошибками для всплывающей тултипсы
    } else {
        [string mixAppendLabel:self.label];
        [string mixAppendMnemonic:[NSString stringWithFormat:@"\t%@", self.mnemonic]];
        [string mixAppendOperand:[NSString stringWithFormat:@"\t%@", self.operand]];
        [string mixAppendComment:[NSString stringWithFormat:@"\t%@", self.comment]];
    }

    return string;
}

// Возвращает отформатированную строку с  исходным кодом и замененными метками и адресами, с учетом настройки темы
- (NSMutableAttributedString *) stringAttributedReplaced
{

    NSMutableAttributedString *string = [NSMutableAttributedString new];
    
//    [string mixAppendComment:self.memoryPos > 0 ? [NSString stringWithFormat:@"%lld\t", self.memoryPos] : @"\t"];

    if (self.commentOnly) {
        [string mixAppendComment:self.source];
    } else if (self.error) {
        [string mixAppendError:self.source errorList:self.errorsList]; // errorList - текст с ошибками для всплывающей тултипсы
    } else {
        [string mixAppendLabel:self.label];
        [string mixAppendMnemonic:[NSString stringWithFormat:@"\t%@", self.mnemonic]];
        [string mixAppendOperand:[NSString stringWithFormat:@"\t%@", self.operandNew]];
        [string mixAppendLabel:self.memoryPos > 0 ? [NSString stringWithFormat:@"\t%lld", self.memoryPos] : @"\t"];
        [string mixAppendComment:[NSString stringWithFormat:@"\t%@", self.comment]];
    }
    
    return string;
}

#pragma mark - Анализ строк

+ (NSAttributedString*) parceAllString:(NSString*)string decode:(BOOL)decode error:(BOOL*)hasError
{
    //
    // Работаем в отдельном контексте, которые не сохраняем
    // Если decode == YES - вернем строку с адресами вместо исходной

    NSManagedObjectContext *context = [DAO sharedInstance].persistentContainer.newBackgroundContext;
    // удалить все строки
    [self deleteAllContext:context];
    
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    NSMutableArray * arrayAllRows = [NSMutableArray new];

    NSInteger memoryPos = MEMORY_POSITION_DEFAULT;
    
    if (string.length > 0) {
        NSArray <NSString*>*rows = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        // 1 проход - форматирование строк, и создание массивов меток
        for (NSInteger i = 0; i < rows.count; i++) {
            //ALog(@"-->%@<--",rows[i]);

            MLine * mLine = [NSEntityDescription insertNewObjectForEntityForName:@"MLine" inManagedObjectContext:context];

            [mLine parceString:rows[i]];

            BOOL isEQU = [mLine.mnemonic isEqualToString:@"EQU"];
            BOOL isORIG = [mLine.mnemonic isEqualToString:@"ORIG"];
            
            // !! Надо как то обработать ситуацию когда типа  5H EQU  12345, в этом случае метка 5H не адрес, а значение 12345!
            NSString *label = mLine.label;
            if (label.length > 0) {
                if (isEQU == YES && mLine.operand.length > 0) {
                    mLine.labelValue = mLine.operand;
                } else if (isORIG == YES && mLine.operand.length > 0) {
                    mLine.labelValue = [NSString stringWithFormat:@"%ld", MAX(memoryPos - 1, MEMORY_POSITION_DEFAULT)];
                } else {
                    mLine.labelValue = [NSString stringWithFormat:@"%ld", memoryPos];
                }
            }
            
            // ORIG устанавливает счетчик со следующей строки!
            if (isORIG && mLine.operand.length > 0) {
                memoryPos = mLine.operand.integerValue;
            } else if (isEQU == NO && mLine.mnemonic.length > 0 && ![OPER_NO_MEMORY containsObject:mLine.mnemonic]) {
                mLine.memoryPos = memoryPos;
                memoryPos++;
            }
            
            [arrayAllRows addObject:mLine];
        }

        // 2 проход - определение операндов и подстановка меток
        //ALog(@"------------ 2 проход и Тест ссылок вперед-назад -------------");
        
        for (NSInteger i = 0; i < arrayAllRows.count; i++) {
            MLine *mLine = arrayAllRows[i];
            NSString *operand = mLine.operand;
            if (operand.length > 0 && ![mLine.mnemonic isEqualToString:@"ALF"]) {
                    [mLine replaceLabels]; // Замена ссылок (если ALF и аргумент в кавычках то не ищем!)
            }
            
            if (i>0) {
                [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
            
            if (!*hasError && mLine.error) {
              *hasError = mLine.error;
            }
            
            if (decode) {
                [result appendAttributedString:mLine.stringAttributedReplaced];
            } else {
                [result appendAttributedString:mLine.stringAttributed];
            }

        }
    }
    
    return result;
}

+ (void) deleteAllContext:(NSManagedObjectContext *)context
{
    // Удалим все записи
    NSArray *res = [context executeFetchRequest:[self fetchRequest] error:nil];
    for (int i = 0; i < res.count; i++) {
        [context deleteObject:res[i]];
    }
}

#pragma mark -

- (void) parceString:(NSString*)aString
{
    //
    // 1 проход - разбор строки, и создание массивов меток из исходной строки
    //
    
    NSMutableArray * errors = [NSMutableArray new];
    self.source =  aString ? aString : @"";
    if (aString.length < 1 || [aString hasPrefix:@"*"]) {
        // Строка пустая или полностью комментарий
        self.comment = aString;
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
                                [errors addObject:RStr(@"Valid labels with digit: only digit and symbol \"H\"")];
                            }
                        }
                    } else {
                        self.errorLabel = YES;
                        [errors addObject:RStr(@"The label contains invalid characters")];
                    }
                } else {
                    self.comment = [aString substringWithRange:NSMakeRange(range.location, rangeAll.length - range.location)];
                    commentStored = YES;
                    //ALog(@"‼️ error comment = %@", self.comment);
                    self.errorLabel = YES;
                    [errors addObject:RStr(@"After the label, there must be a valid mnemonic")];
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
                    [errors addObject:RStr(@"The operand contains invalid characters")];
                }
                if ([self.mnemonic isEqualToString:@"ALF"] && [text hasPrefix:@"\""] && [text hasSuffix:@"\""] && text.length > 7) {
                    // contents as a set of five (optionally quoted) characters
                    self.errorMnemonic = YES;
                    [errors addObject:RStr(@"Memonic for ALF operand in \"\" containts more then 5 symbols")];
                }
            } else if (!commentStored){
                self.comment = [aString substringWithRange:NSMakeRange(range.location, rangeAll.length - range.location)];
                commentStored = YES;
                //ALog(@"comment = %@", self.comment);
                break;
            }
        }
    }
    
    if ((labelStored && !mnemonicStored)) {
        self.errorLabel = YES;
        [errors addObject:RStr(@"Invalid string format: after label must be valid mnemonic")];
    }
    if (operandNeeds && !operandStored) {
        self.errorMnemonic = YES;
        [errors addObject:RStr(@"After the mnemonic, there must be a valid operand")];
    }
    
    if (errors.count > 0) {
        self.error = YES;
        self.errorsList = [errors componentsJoinedByString:@"\n"];
    }
    
    return;
    
}

- (void) replaceLabels
{
    
    //
    // 2 проход - Замена ссылок и символов на адреса или значения
    // Подразумевается, что все строки уже распарсены в первом проходе!
    //
    
    // Найдем ссылки в строке операнда
    NSString *operand = self.operand;
    NSInteger memoryPos = self.memoryPos;
    NSRegularExpression  *regExp = [NSRegularExpression regularExpressionWithPattern:@"\\d*[A-Z]+\\d*" options:0 error:nil];
    NSArray <NSTextCheckingResult *> * matches = [regExp matchesInString:operand options:0 range:NSMakeRange(0, operand.length)];

    for (NSInteger i = matches.count - 1; i >=0; i--) {
        NSRange range = matches[i].range;
        if (range.location != NSNotFound && range.length > 0) {
            NSString *label = [operand substringWithRange:range]; // найденная метка в операнде
            BOOL isHBFLink = NO;

            NSFetchRequest *req = [MLine fetchRequest];
            req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"memoryPos" ascending:YES]];
            if ([label isEqualToString:@"2B"]) {
                //
            }
            
            if ([[NSRegularExpression regularExpressionWithPattern:@"^[1-9][F]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1) {
                
                // Это локальная ссылка вперед
                
                req.predicate = [NSPredicate predicateWithFormat:@"label == %@ AND memoryPos > %lld", [[label substringToIndex:1] stringByAppendingString:@"H"], memoryPos];
                req.fetchLimit = 1;
                isHBFLink = YES;
                
            } else if ([[NSRegularExpression regularExpressionWithPattern:@"^[1-9][B]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1) {
                
                // Это локальная ссылка назад
                
                req.predicate = [NSPredicate predicateWithFormat:@"label == %@ AND memoryPos < %lld", [[label substringToIndex:1] stringByAppendingString:@"H"], memoryPos];
                req.fetchLimit = 1;
                isHBFLink = YES;
                
            } else {
                
                // Это друга ссылка, потом надо тоже проверять вперед или назад она может действовать?
                
                req.predicate = [NSPredicate predicateWithFormat:@"label == %@", label];
                
            }
            
            NSArray <MLine*> * res = [self.managedObjectContext executeFetchRequest:req error:nil]; // строки со ссылками
            
            NSString *errorString = nil;
            
            if (res.count < 1) {
                errorString = RStr(@"Label or symbol not found");
            } else if (res.count > 1) {
                for (MLine *erLine in res) {
                    erLine.error = YES;
                    erLine.errorLabel = YES;
                    erLine.errorsList = [NSString stringWithFormat:@"%@%@%@", self.errorsList, self.errorsList.length > 0 ? @"\n" : @"", RStr(@"Duplicate label")];
                }
                errorString = RStr(@"Operand has refers to a label that is defined more than once");
            } else {
                // Все хорошо, найдена единственная строка начинающаяся на нужный лейбл
                operand = [operand stringByReplacingCharactersInRange:range withString:res[0].labelValue];
            }

            if (errorString) {
                self.error = YES;
                self.errorLabel = YES;
                self.errorsList = [NSString stringWithFormat:@"%@%@%@", self.errorsList, self.errorsList.length > 0 ? @"\n" : @"", errorString];
            }
            

        } // найденная метка в операнде
        
    }

    self.operandNew = operand;

//    ALog(@" ------------------");
//    ALog(@" было:  ==>%@<==", self.operand);
//    ALog(@" стало: ==>%@<==", self.operandNew);

}

@end
