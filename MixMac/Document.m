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
    
    [self reloarTextView];
    
    return YES;
}

//- (void) close
//{
//    DLog(@"%@ %@", self.documentEdited?@"был изменен:":@"не изменялся:", self.fileURL.lastPathComponent);
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
            [result appendAttributedString:mixString.stringAttributed];
        }
    }
    return result;
}

#pragma mark - Методы делегата редактирования текста
- (void) textDidChange:(NSNotification *)notification
{
    if (errorSyntax) {
        [self.textView.textStorage removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textView.textStorage.string.length)];
    }

}

@end
