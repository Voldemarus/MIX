#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import "MIXString.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
 Generate a preview for file
 
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    //
    // Гененрирация RTF файл для форматированного превью нашего кода.
    // ! html не годится, так как криво отрабатывает табуляторы, поэтому RTF
    //
    // Небольшой фак тут: https://habr.com/post/208552/
    // но не надо добавлять скрипт для автоматической установки!
    // достаточно для обновления превьювера в скрипт добавить   qlmanage -r
    //
    
    if (QLPreviewRequestIsCancelled(preview)) {
        return noErr;
    }
 
    // Получим текст из просматриваемого файла
    NSString * string = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:(__bridge NSURL *)url] encoding:NSUTF8StringEncoding];
    if (string.length < 1) {
        string = [NSString stringWithFormat:@"       ------   %@   ------       ", RStr(@"File empty or corrupt")];
    }
    
    // Отформатировать текст программы используя парсер из основной программы
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    if (string.length > 0) {
        NSArray <NSString*>*rows = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        for (NSInteger i = 0; i < rows.count; i++) {
            MIXString *mixString = [[MIXString alloc] initWithText:rows[i]];
            if (i > 0)  [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [attributedString appendAttributedString:mixString.stringAttributed];
        }
    }

    // Отобразить контетн RTF, полученного из атрибутированной строки
    NSData *dataRTF = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:NULL];
    NSDictionary *propsRTF = @{ (__bridge NSString*)kQLPreviewPropertyTextEncodingNameKey : @"UTF-8",
                             (__bridge NSString*)kQLPreviewPropertyMIMETypeKey : @"application/rtf" };
    QLPreviewRequestSetDataRepresentation(preview, (__bridge CFDataRef)dataRTF, kUTTypeRTF, (__bridge CFDictionaryRef)propsRTF);

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
