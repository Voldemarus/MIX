//
//  DAO.h
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2018 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MFiles+CoreDataClass.h"
#import "MLine+CoreDataClass.h"


@interface DAO : NSObject

@property (nonatomic, readwrite) NSInteger counteriter; // Счетчик вызовов для отладки

@property (readonly, strong) NSPersistentContainer * _Nullable persistentContainer; // Хранилище
@property (nonatomic, retain) NSManagedObjectContext * _Nullable moc; // Основной контекст
@property (nonatomic, strong) NSOperationQueue *  _Nullable persistentContainerQueue; // Очередь фоновой записи локальной базы

+ (DAO * _Nonnull) sharedInstance;

- (void)saveContext:(NSManagedObjectContext* _Nullable)context;

- (void)enqueueCoreDataBlock:(void (^ _Nonnull)(NSManagedObjectContext* _Nonnull context))block completion:(void (^ _Nullable)(void))completion;

@end

