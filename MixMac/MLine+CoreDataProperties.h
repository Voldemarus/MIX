//
//  MLine+CoreDataProperties.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import "MLine+CoreDataClass.h"

@class MFiles;

NS_ASSUME_NONNULL_BEGIN

@interface MLine (CoreDataProperties)

+ (NSFetchRequest<MLine *> *)fetchRequest;

@property (nonatomic) int64_t lineNumber;
@property (nullable, nonatomic, copy) NSString *source;
@property (nullable, nonatomic, copy) NSString *label;
@property (nullable, nonatomic, copy) NSString *labelValue;
@property (nullable, nonatomic, copy) NSString *mnemonic;
@property (nullable, nonatomic, copy) NSString *operand;
@property (nullable, nonatomic, copy) NSString *comment;
@property (nonatomic) int64_t memoryPos;
@property (nonatomic) BOOL commentOnly;
@property (nonatomic) BOOL errorLabel;
@property (nonatomic) BOOL errorMnemonic;
@property (nonatomic) BOOL errorOperand;
@property (nonatomic) BOOL error;
@property (nullable, nonatomic, copy) NSString *errorsList;
@property (nullable, nonatomic, copy) NSString *operandNew;
@property (nullable, nonatomic, copy) NSString *mSIGN;
@property (nullable, nonatomic, copy) NSString *mADDRESS;
@property (nullable, nonatomic, copy) NSString *mINDEX;
@property (nullable, nonatomic, copy) NSString *mMOD;
@property (nullable, nonatomic, copy) NSString *mOPCODE;
@property (nullable, nonatomic, retain) MFiles *file;

@end

NS_ASSUME_NONNULL_END
