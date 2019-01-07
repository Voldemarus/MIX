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
    
    NSMutableDictionary * equDict; // Словарь метка:значение
    NSMutableDictionary * labelDict; // Словарь метка:адрес
    NSMutableArray <NSDictionary*> * labelBackForwardArray; // Массив словарей специальных меток типа @"7H":@(3015)
    NSInteger address;
    
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
        [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textView.textStorage.string.length)];
    }
    
}

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

#warning ! Temporaly ! After, Needs move another singlton class !
//
// Позже перенести все это в отдельный класс-синглтон
//

- (NSAttributedString*) parceAllString:(NSString*)string
{
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    arrayAllRows = [NSMutableArray new];
    
    equDict = [NSMutableDictionary new]; // Словарь метка:значение
    labelDict = [NSMutableDictionary new]; // Словарь метка:адрес
    labelBackForwardArray = [NSMutableArray new]; // Массив словарей специальных меток типа @"7H":@(3015)
    
    address = 3000;

    if (string.length > 0) {
        NSArray <NSString*>*rows = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSInteger i = 0; i < rows.count; i++) {
            MIXString *mixString = [[MIXString alloc] initWithText:rows[i]];
            [arrayAllRows addObject:mixString];
            if (!errorSyntax) {
                errorSyntax = mixString.error;
            }
            if (i>0) {
                [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }

            //  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            mixString = [self calculateLabel:mixString];
            //  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            [result appendAttributedString:mixString.stringAttributed];
        }
    }
    
    ALog(@" --- Словарь метка:значение: ---\n%@", equDict);
    ALog(@" --- Словарь метка:адрес: ---\n%@", labelDict);
    ALog(@" --- Массив словарей специальных меток: ---\n%@", [[[labelBackForwardArray componentsJoinedByString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"}{   " withString:@"}\n{"]);

    
    return result;
}

- (MIXString*) calculateLabel:(MIXString*) mixString
{
    
    BOOL isEQU = [mixString.mnemonic isEqualToString:@"EQU"];
    
    if ([mixString.mnemonic isEqualToString:@"ORIG"]) {
        address = mixString.operand.integerValue;
    } else if (isEQU == NO) {
        mixString.address = address;
        address++;
    }
    NSString *label = mixString.label;
    if (label.length > 0) {
        if (isEQU == YES && mixString.operand.length > 0) {
            equDict[label] = mixString.operand;
        } else {
            
            if ([[NSRegularExpression regularExpressionWithPattern:@"^[1-9][H]$" options:NSRegularExpressionAnchorsMatchLines error:nil] numberOfMatchesInString:label options:0 range:NSMakeRange(0, label.length)] == 1) {
                
                [labelBackForwardArray addObject:@{label : @(address)}]; // типа @"7H":@"3015"
                // потом искать нужную метку выборкой по имени и смотреть номер адреса, в зависимости от iF iB
                
            } else {
                if (labelDict[label] != nil) {
                    [mixString.errors addObject:RStr(@"Duplicate label")];
                    mixString.error = YES;
                    errorSyntax = YES;
                }
                labelDict[label] = @(address);
            }
        }
        
    }
    return mixString;
}


@end
