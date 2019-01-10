//
//  Document.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "Document.h"
#import "DebugPrint.h"
#import "MIXString.h"
#import "MarkerLineNumberView.h"

@interface Document () <NSTextViewDelegate, NSTextStorageDelegate>
{
    MarkerLineNumberView *lineNumberView;
    NSMutableArray <MIXString*>* arrayAllRows;
    
    NSMutableDictionary * labelDict; // Словарь метка:адрес/Значение
    NSMutableArray <NSDictionary*> * labels_H_Array; // Массив словарей специальных меток типа @"7H":@(3015)
    NSInteger memoryPos;
    
    BOOL errorSyntax;
}

@property (nonatomic, retain) NSString *contentString; // исходный текст после открытия
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

@implementation Document

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    errorSyntax = NO;
    
    // ****
    // Добавить линейку с номерами строк и маркерами
    NSScrollView *scrollView = [self.textView enclosingScrollView];
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    lineNumberView.font = [NSFont fontWithName:@"Monaco" size:11];
    scrollView.verticalRulerView = lineNumberView;
    scrollView.hasVerticalRuler = YES;
    scrollView.hasHorizontalRuler = NO;
    scrollView.rulersVisible = YES;
    // ****

    self.textView.textStorage.delegate = self;
    if (!self.fileURL) {
        // Видимо новый файл, згрузим пример для отладки программы
        self.contentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"exampledefault" ofType:@"mixal"] encoding:NSUTF8StringEncoding error:nil];
    }
    
    [self reloarTextView];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    return [self.textView.string dataUsingEncoding:NSUTF8StringEncoding];
    
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    
    self.contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.contentString = [self.contentString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [self reloarTextView];
    
    return YES;
}

//- (void) close
//{
//    DLog(@"%@ %@", self.documentEdited?@"был изменен:":@"не изменялся:", self.fileURL.lastPathComponent);
//}

#pragma mark - Методы делегата редактирования текста

- (void) textDidChange:(NSNotification *)notification
{
    if (errorSyntax) {
        NSRange rangeEdit = self.textView.selectedRanges[0].rangeValue;
        // При начале редактирования убрать форматирование строки
//        if ([self.textView.textStorage attribute:NSBackgroundColorAttributeName atIndex:rangeEdit.location effectiveRange:nil]) {
            //// Если есть ошибка (есть фон), то при начале редактирования строки удалить атрибуты
            NSUInteger lineStart = 0;
            NSUInteger lineEnd = 0;
            [self.textView.string getLineStart:&lineStart end:&lineEnd contentsEnd:nil forRange:rangeEdit];
            NSRange range = NSMakeRange(lineStart, lineEnd - lineStart);
            //ALog(@"%ld - %ld =>%@<=",lineStart, lineEnd, [self.textView.textStorage.string substringWithRange:range]);
            [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:range];
            [self.textView.textStorage removeAttribute:NSForegroundColorAttributeName range:range];
//        }
     }
    
}
//- (BOOL) textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(nullable NSString *)replacementString
//{
//    NSString *string = textView.textStorage.string;
//
//    NSUInteger lineStart = 0;
//    NSUInteger lineEnd = 0;
//    [string getLineStart:&lineStart end:&lineEnd contentsEnd:nil forRange:affectedCharRange];
//    ALog(@"%ld - %ld",lineStart, lineEnd);
//    NSRange range = NSMakeRange(lineStart, lineEnd - lineStart);
//    string = [string substringWithRange:range];
//    ALog(@"=>%@<=", string);
//    [self.textView.textStorage replaceCharactersInRange:range withAttributedString:[[MIXString alloc] initWithText:string].attributeString];
//    //[self reloarTextView];
//    return YES;
//}


#pragma mark - Формат и отображение кода

- (IBAction)refresh:(id)sender {
    [self reloarTextView];
}

- (IBAction)openTeacherBook:(id)sender {
    //[[NSWorkspace sharedWorkspace] openURL:[[NSBundle mainBundle] URLForResource:@"MIXAL tacherbook" withExtension:@"html"]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://linux.yaroslavl.ru/docs/altlinux/doc-gnu/mdk/mdk_4.html"]];
}

- (void) reloarTextView
{
    ALog(@"reloarTextView %@", self.fileURL.lastPathComponent);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView.textStorage setAttributedString:[self parceAllString:self.contentString]];
        self.contentString = self.textView.textStorage.string;
//        NSInteger rows = self->arrayAllRows.count;
//        NSArray <NSNumber*>*keys = self->lineNumberView.linesToMarkers.allKeys;
//        for (NSInteger i = 0; i < keys.count; i++) {
//            NSNumber *key = keys[i];
//            if (key.integerValue > rows) {
//                [self->lineNumberView.linesToMarkers removeObjectForKey:key];
//                ALog(@"%ld removing marker=%@", i, key);
//            }
//        }
////        for (NSInteger i = 0; i < self->arrayAllRows.count; i++) {
////            NoodleLineNumberMarker * marker = markers[@(i)];
////            DLog(@"%ld marker=%@", i, marker);
////        }
    });
}

#pragma mark - Анализ строк

- (NSAttributedString*) parceAllString:(NSString*)string
{
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    arrayAllRows = [NSMutableArray new];
    
    labelDict = [NSMutableDictionary new]; // Словарь метка:адрес/значение
    labels_H_Array = [NSMutableArray new]; // Массив словарей специальных меток типа @"7H":@(3015)
    
    memoryPos = 1000;

    if (string.length > 0) {
        NSArray <NSString*>*rows = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        // 1 проход - форматирование строк, и создание массивов меток
        for (NSInteger i = 0; i < rows.count; i++) {
            MIXString *mixString = [[MIXString alloc] initWithText:rows[i]];
            mixString = [self calculateLabel:mixString];
            if (!errorSyntax) errorSyntax = mixString.error;
            [arrayAllRows addObject:mixString];
        }
        
        ALog(@" --- Словарь метка:адрес/значение: ---\n%@", labelDict);
        ALog(@" --- Массив словарей специальных меток: ---\n%@", labels_H_Array);

        // 2 проход - определение операндов и подстановка меток
        ALog(@"------------ 2 проход и Тест ссылок вперед-назад -------------");

        for (NSInteger i = 0; i < arrayAllRows.count; i++) {
            MIXString *mixString = arrayAllRows[i];
            mixString = [self calculateOperand:mixString];
            if (!errorSyntax) errorSyntax = mixString.error;


            if (i>0) {
                [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }

            
            [result appendAttributedString:mixString.stringAttributed];
            
            
            [result mixAppendComment:[NSString stringWithFormat:@"\t* %ld", mixString.memoryPos]];

        }
    }
    

    
    return result;
}

- (MIXString*) calculateOperand:(MIXString*) mixString
{
    __block NSString *operand = mixString.operand;
    if (mixString.memoryPos > 0 && ![mixString.mnemonic isEqualToString:@"ALF"]) {
        
        //
        // Замена ссылок
        //
        // Найдем ссылки в строке операнда
        NSRegularExpression  *regExp = [NSRegularExpression regularExpressionWithPattern:@"\\d*[A-Z]+\\d*" options:0 error:nil];
        NSArray <NSTextCheckingResult *> * matches = [regExp matchesInString:operand options:0 range:NSMakeRange(0, operand.length)];
        for (NSInteger i = matches.count - 1; i >=0; i--) {
            NSRange range = matches[i].range;
            if (range.location != NSNotFound && range.length > 0) {
                NSString *label = [operand substringWithRange:range]; // найденная ссылка на метку
                NSString *replace = @"";
                if ([self isBLabel:label]) {
                    // локальная ссылка назад
                    replace = [self valueBackwardNumber:label.integerValue currentMemoryPos:mixString.memoryPos];
                } else if ([self isFLabel:label]) {
                    // локальная ссылка вперед
                    replace = [self valueForvardNumber:label.integerValue currentMemoryPos:mixString.memoryPos];
                } else {
                    replace = labelDict[label];
                    if (!replace.length) {
                        replace = label;
                        mixString.error = YES;
                        mixString.errorOperand = YES;
                        [mixString.errors addObject:RStr(@"Label or symbol not found")];
                    }
                }
                ALog(@"%ld  %ld,   ==>%@<==   ==>%@<==", range.location, range.length, [operand substringWithRange:range], replace);
                operand = [operand stringByReplacingCharactersInRange:range withString:replace];
            }

        };
        
        mixString.operandNew = operand;
//        mixString.operand = operand;
        
        
        //ALog(@"текущий %ld  оператор %@   dB:%@   dF:%@", mixString.memoryPos, mixString.operand, [self valueForvardNumber:5 currentMemoryPos:mixString.memoryPos], [self valueBackwardNumber:5 currentMemoryPos:mixString.memoryPos]);
    }
    return mixString;
}

- (NSString*) valueForvardNumber:(NSInteger)linkInOperand currentMemoryPos:(NSInteger)currentMemoryPos
{
    // Возвращает значение для ссылок вперед типа [1-9]F
    for (NSInteger i = 0; i < labels_H_Array.count; i++) {
        NSDictionary *dict = labels_H_Array[i];
        NSNumber *memoryPos = dict[@"memoryPos"];
        if (memoryPos && memoryPos.integerValue > currentMemoryPos && [dict[@"label"] integerValue] == linkInOperand) {
            return dict[@"value"];
            break;
        }
    }
    return @"";
}

- (NSString*) valueBackwardNumber:(NSInteger)linkInOperand currentMemoryPos:(NSInteger)currentMemoryPos
{
    // Возвращает значение для ссылок назад типа [1-9]B
    for (NSInteger i = labels_H_Array.count - 1; i >= 0; i--) {
        NSDictionary *dict = labels_H_Array[i];
        NSNumber *memoryPos = dict[@"memoryPos"];
        if (memoryPos && memoryPos.integerValue < currentMemoryPos && [dict[@"label"] integerValue] == linkInOperand) {
            return dict[@"value"];
            break;
        }
    }
    return @"";
}

- (MIXString*) calculateLabel:(MIXString*) mixString
{
    
    BOOL isEQU = [mixString.mnemonic isEqualToString:@"EQU"];
    
    // !! Надо как то обработать ситуацию когда типа  5H EQU  12345, в этом случае метка 5H не адрес, а значение 12345!
    NSString *label = mixString.label;
    if (label.length > 0) {
        
        if (isEQU == YES && mixString.operand.length > 0) {
            if ([self is_H_Label:label]) { // Это спецметка, поэтому не адрес а значение
                [labels_H_Array addObject:@{@"label":label, @"memoryPos":[NSString stringWithFormat:@"%ld", memoryPos], @"value":mixString.operand}]; // типа @"7H":@"3015"
            } else {
                labelDict[label] = mixString.operand;
            }
        } else {
            
            if ([self is_H_Label:label]) {
                NSString *value = [NSString stringWithFormat:@"%ld", memoryPos];
                [labels_H_Array addObject:@{@"label":label, @"memoryPos" : value, @"value" : value}]; // типа @"7H":@"3015"
                // потом искать нужную метку выборкой по имени и смотреть номер адреса, в зависимости от iF iB
                
            } else {
                if (labelDict[label] != nil) {
                    [mixString.errors addObject:RStr(@"Duplicate label")];
                    mixString.errorLabel = YES;
                    mixString.error = YES;
                }
                labelDict[label] = [NSString stringWithFormat:@"%ld", memoryPos];
            }
        }
        
    }

    // ORIG устанавливает счетчик со следующей строки!
    if ([mixString.mnemonic isEqualToString:@"ORIG"]) {
        memoryPos = mixString.operand.integerValue;
    } else if (isEQU == NO && mixString.mnemonic.length > 0 && ![OPER_NO_MEMORY containsObject:mixString.mnemonic]) {
        mixString.memoryPos = memoryPos;
        memoryPos++;
    }

    return mixString;
}

- (BOOL) is_H_Label:(NSString*)label
{
    // Если это метка типа типа iH
    return [[NSRegularExpression regularExpressionWithPattern:@"^[1-9][H]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1;
}

- (BOOL) isFLabel:(NSString*)label
{
    // Если это метка типа типа [1-9]F
    return [[NSRegularExpression regularExpressionWithPattern:@"^[1-9][F]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1;
}

- (BOOL) isBLabel:(NSString*)label
{
    // Если это метка типа типа [1-9]F
    return [[NSRegularExpression regularExpressionWithPattern:@"^[1-9][B]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1;
}

@end
