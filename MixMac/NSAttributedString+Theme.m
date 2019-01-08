//
//  NSAttributedString+Theme.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import "NSAttributedString+Theme.h"
#import "NSColor+Theme.h"
#import "NSFont+Theme.h"

@implementation NSMutableAttributedString (Theme)

- (void) mixAppendLabel:(NSString *)text
{
    [self appendAttributedString:[NSAttributedString mixLabel:text]];
}

- (void) mixAppendMnemonic:(NSString *)text
{
    [self appendAttributedString:[NSAttributedString mixMnemonic:text]];
}

- (void) mixAppendOperand:(NSString *)text
{
    [self appendAttributedString:[NSAttributedString mixOperand:text]];
}

- (void) mixAppendComment:(NSString*)text
{
    [self appendAttributedString:[NSAttributedString mixComment:text]];
}

- (void) mixAppendError:(NSString *)text errorList:(NSString*)errorList
{
    [self appendAttributedString:[NSAttributedString mixError:text]];
    
    NSRange range = NSMakeRange(0, text.length);
    [self addAttribute:NSToolTipAttributeName value:errorList range:range];
    NSCursor *cursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"cursor_hand"] hotSpot:NSMakePoint(0, 8)];
    [self addAttribute:NSCursorAttributeName value:cursor range:range];
    //[self addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[NSString stringWithFormat:@"errorList://%@",[errorList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]] range:range];

}

@end

@implementation NSAttributedString (Theme)

+ (NSParagraphStyle*) mixParagraphStyle
{
    // Общий стиль параграфа, табуляторов и выравнивания
    static NSMutableParagraphStyle * parStyle = nil;
    if (!parStyle) {
        parStyle = [NSMutableParagraphStyle new];
        
        parStyle.defaultTabInterval = 226;
        parStyle.headIndent = 226; // commentOnly ? 15 : 226 ; // Отступ переноса строки
        parStyle.firstLineHeadIndent = 0.0f;
        parStyle.tabStops = @[
                              // TODO: что есть options? с ходу не нашел, пусть пустые будут пока
                              [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:80 options:@{}],
                              [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:130 options:@{}],
                              [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:226 options:@{}],
                              ];
    }
    return parStyle;
}

+ (NSAttributedString*) mixLabel:(NSString *)text
{
    static NSDictionary *attributes = nil;
    if (!attributes) {
        attributes = @{
                       NSForegroundColorAttributeName:[NSColor mixLabel],
                       NSFontAttributeName:[NSFont mixLabel],
                       NSParagraphStyleAttributeName:[self mixParagraphStyle],
                       };
    }
   return [[NSAttributedString alloc] initWithString:text?text:@"" attributes:attributes];

}

+ (NSAttributedString*) mixMnemonic:(NSString *)text
{
    static NSDictionary *attributes = nil;
    if (!attributes) {
        attributes = @{
                       NSForegroundColorAttributeName:[NSColor mixMnemonic],
                       NSFontAttributeName:[NSFont mixMnemonic],
                       NSParagraphStyleAttributeName:[self mixParagraphStyle],
                       };
    }
    return [[NSAttributedString alloc] initWithString:text?text:@"" attributes:attributes];
}

+ (NSAttributedString*) mixOperand:(NSString *)text
{
    static NSDictionary *attributes = nil;
    if (!attributes) {
        attributes = @{
                       NSForegroundColorAttributeName:[NSColor mixOperand],
                       NSFontAttributeName:[NSFont mixOperand],
                       NSParagraphStyleAttributeName:[self mixParagraphStyle],
                       };
    }
    return [[NSAttributedString alloc] initWithString:text?text:@"" attributes:attributes];
}

+ (NSAttributedString*) mixComment:(NSString *)text
{
    static NSDictionary *attributes = nil;
    if (!attributes) {
        attributes = @{
                       NSForegroundColorAttributeName:[NSColor mixComment],
                       NSFontAttributeName:[NSFont mixComment],
                       NSParagraphStyleAttributeName:[self mixParagraphStyle],
                       };
    }
    return [[NSAttributedString alloc] initWithString:text?text:@"" attributes:attributes];
}

+ (NSAttributedString*) mixError:(NSString *)text
{
    static NSDictionary *attributes = nil;
    if (!attributes) {
        attributes = @{
                       NSBackgroundColorAttributeName:[NSColor mixErrorBackground],
                       NSForegroundColorAttributeName:[NSColor mixErrorForegraund],
                       NSFontAttributeName:[NSFont mixError],
                       NSParagraphStyleAttributeName:[self mixParagraphStyle],
                       };
    }
    return [[NSAttributedString alloc] initWithString:text?text:@"" attributes:attributes];
}

@end
