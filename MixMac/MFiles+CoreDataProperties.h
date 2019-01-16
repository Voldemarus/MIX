//
//  MFiles+CoreDataProperties.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2019 Geomatix Laboratoriy S.R.O. All rights reserved.
//
//

#import "MFiles+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MFiles (CoreDataProperties)

+ (NSFetchRequest<MFiles *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *fileName;
@property (nullable, nonatomic, retain) NSOrderedSet<MLine *> *lines;

@end

@interface MFiles (CoreDataGeneratedAccessors)

- (void)insertObject:(MLine *)value inLinesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLinesAtIndex:(NSUInteger)idx;
- (void)insertLines:(NSArray<MLine *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLinesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLinesAtIndex:(NSUInteger)idx withObject:(MLine *)value;
- (void)replaceLinesAtIndexes:(NSIndexSet *)indexes withLines:(NSArray<MLine *> *)values;
- (void)addLinesObject:(MLine *)value;
- (void)removeLinesObject:(MLine *)value;
- (void)addLines:(NSOrderedSet<MLine *> *)values;
- (void)removeLines:(NSOrderedSet<MLine *> *)values;

@end

NS_ASSUME_NONNULL_END
