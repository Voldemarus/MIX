//
//  Document.m
//  MixMac
//
//  Created by Водолазкий В.В. on 14.02.15.
//  Copyright (c) 2015 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "Document.h"
#import "DebugPrint.h"
#import "MarkerLineNumberView.h"
#import "DAO.h"

@interface Document () <NSTextViewDelegate, NSTextStorageDelegate>
{
    MarkerLineNumberView *lineNumberView;
    DAO *dao;
    
    BOOL errorSyntax;
}

@property (nonatomic, retain) NSString *contentString; // исходный текст
@property (unsafe_unretained) IBOutlet NSTextView *textView;

// временная кнопка
@property (weak) IBOutlet NSButton *buttonViewDecode;

@end

@implementation Document

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        dao = [DAO sharedInstance];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    errorSyntax = NO;
    
    // *********************************************
    // Добавить линейку с номерами строк и маркерами
    NSScrollView *scrollView = [self.textView enclosingScrollView];
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:scrollView];
    lineNumberView.font = [NSFont fontWithName:@"Monaco" size:11];
    scrollView.verticalRulerView = lineNumberView;
    scrollView.hasVerticalRuler = YES;
    scrollView.hasHorizontalRuler = NO;
    scrollView.rulersVisible = YES;
    // *********************************************

    self.textView.textStorage.delegate = self;
    
#ifdef DEBUG
    if (!self.fileURL) {   //   Это новый файл, згрузим пример для отладки программы
        self.contentString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"exampledefault" ofType:@"mixal"] encoding:NSUTF8StringEncoding error:nil];
        [self reloarTextView];
    }
#endif
    
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

#pragma mark - Методы делегата редактирования текста

- (void) textDidChange:(NSNotification *)notification
{
//    if (errorSyntax) {
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
//     }
    
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
    if (!self.buttonViewDecode.hidden) {
        self.contentString = [self.textView.textStorage.string copy];
    }
    [self reloarTextView];
}

- (IBAction)viewDecode:(id)sender {
    ALog(@"Временная кнопка - Просмотрт декодирования адресов");
    self.contentString = [self.textView.textStorage.string copy];

    self.buttonViewDecode.hidden = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *attS = [MLine parceAllString:self.contentString decode:YES error:&(self->errorSyntax)];
        [self.textView.textStorage setAttributedString:attS];
    });
}

- (void) reloarTextView
{
    ALog(@"reloarTextView %@", self.fileURL.lastPathComponent);
    // Парсит исходный код для отображения в редакторе
    dispatch_async(dispatch_get_main_queue(), ^{
        self.buttonViewDecode.hidden = NO;
        self->errorSyntax = NO; // Признак наличия ошибок в коде, устанавливается в классе
        NSAttributedString *attS = [MLine parceAllString:self.contentString decode:NO error:&(self->errorSyntax)];
        [self.textView.textStorage setAttributedString:attS];
        self.contentString = [self.textView.textStorage.string copy]; // !! именно копия!
        self.textView.editable = YES;
    });
}

@end
