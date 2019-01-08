//
//  NSAttributedString+Theme.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 08/01/2019.
//  Copyright © 2018 Geomatix Laboratory S.R.O. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Theme.h"

@interface NSMutableAttributedString (Theme)

- (void) mixAppendLabel:(NSString*)text;
- (void) mixAppendMnemonic:(NSString*)text;
- (void) mixAppendOperand:(NSString*)text;
- (void) mixAppendComment:(NSString*)text;
- (void) mixAppendError:(NSString *)text errorList:(NSString*)errorList;

@end

@interface NSAttributedString (Theme)

+ (NSAttributedString*) mixLabel:(NSString*)text;
+ (NSAttributedString*) mixMnemonic:(NSString*)text;
+ (NSAttributedString*) mixOperand:(NSString*)text;
+ (NSAttributedString*) mixComment:(NSString*)text;
+ (NSAttributedString*) mixError:(NSString*)text ;

@end
