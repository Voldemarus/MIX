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

@property (readonly, strong) NSPersistentContainer * _Nonnull persistentContainer; // Хранилище
@property (nonatomic, retain) NSManagedObjectContext * _Nonnull moc; // Основной контекст
@property (nonatomic, strong) NSOperationQueue* _Nonnull persistentContainerQueue; // Очередь фоновой записи локальной базы

+ (DAO *_Nonnull) sharedInstance;

- (void)saveContext:(NSManagedObjectContext* _Nullable)context;

- (void)enqueueCoreDataBlock:(void (^_Nullable)(NSManagedObjectContext* _Nullable context))block completion:(void (^_Nullable)(void))completion;

@end

