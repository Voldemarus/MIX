//
//  MLine+CoreDataProperties.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import "MLine+CoreDataProperties.h"

@implementation MLine (CoreDataProperties)

+ (NSFetchRequest<MLine *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"MLine"];
}

@dynamic lineNumber;
@dynamic source;
@dynamic label;
@dynamic labelValue;
@dynamic mnemonic;
@dynamic operand;
@dynamic comment;
@dynamic memoryPos;
@dynamic commentOnly;
@dynamic errorLabel;
@dynamic errorMnemonic;
@dynamic errorOperand;
@dynamic error;
@dynamic errorsList;
@dynamic operandNew;
@dynamic mSIGN;
@dynamic mADDRESS;
@dynamic mINDEX;
@dynamic mMOD;
@dynamic mOPCODE;
@dynamic file;

@end
