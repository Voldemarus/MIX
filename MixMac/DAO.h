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

@property (readonly, strong) NSPersistentContainer *persistentContainer; // Хранилище
@property (nonatomic, retain) NSManagedObjectContext *moc; // Основной контекст
@property (nonatomic, strong) NSOperationQueue* persistentContainerQueue; // Очередь фоновой записи локальной базы

+ (DAO *) sharedInstance;

- (void)saveContext:(NSManagedObjectContext* _Nullable)context;

- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block completion:(void (^)(void))completion;

@end

