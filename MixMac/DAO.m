//
//  DAO.m
//  MixMac
//
//  Created by Dmitry Likhtarov on 10/01/2019.
//  Copyright © 2018 Geomatix Laboratoriess S.R.O. All rights reserved.
//

#import "DAO.h"
#import "Preferences.h"
#import "DebugPrint.h"

@interface DAO () {
    Preferences 	*prefs;
}

@end

@implementation DAO

+ (DAO *) sharedInstance
{
    static DAO *_sharedDao = nil;
    if (!_sharedDao) {
        _sharedDao = [[DAO alloc] init];
    }
    return _sharedDao;
}

- (instancetype) init
{
    if (self = [super init]) {
        prefs = [Preferences sharedPreferences];
        _persistentContainerQueue = [[NSOperationQueue alloc] init];
        _persistentContainerQueue.maxConcurrentOperationCount = 1;
     }
    return self;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSManagedObjectContext *)moc
{
    return self.persistentContainer.viewContext;
}

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MixMac"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                } else {
                    self->_persistentContainer.viewContext.automaticallyMergesChangesFromParent = true;
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext:(NSManagedObjectContext* _Nullable)context
{
    if (!context) {
        context = self.persistentContainer.viewContext;
        DLog(@" 🌹🌹 Сохраненяется Основной контекст");
    }
#ifdef DEBUG
    else {
        DLog(@" 🌹 Сохраненяется Фоновый контекст");
    }
#endif

    NSError *error;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (void)enqueueCoreDataBlock:(void (^)(NSManagedObjectContext* context))block completion:(void (^)(void))completion {
    void (^blockCopy)(NSManagedObjectContext*) = [block copy];
    void (^completionCopy)(void) = [completion copy];
    [self.persistentContainerQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext* context =  self.persistentContainer.newBackgroundContext;
        [context performBlockAndWait:^{
            blockCopy(context); // внутри блока выполняем нужные операции в контексте
            NSError *error;
            if ([context hasChanges] && ![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            } else {
                DLog(@" 🌹 Фоновый контекст сохранен");
                if (completionCopy) {
                    // Блок завершения для операций, которые надо выполнять после сохранения контекста
                    completionCopy();
                }
            }
            
        }];
    }]];
}

#pragma mark -


@end
