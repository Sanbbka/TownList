//
//  DBMail.h
//  pfrf
//
//  Created by Alexander Drovnyashin on 04.12.15.
//  Copyright © 2015 АО "БАРС Груп". All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Town.h"


#define RULE_UID 777

@interface DBWorker : NSObject

//Применять остальные правила
typedef NS_ENUM(NSInteger, OtherRulesApplyFlag) {
    OtherRulesUnuse = 0,
    OtherRulesUse
};

//Удалить
typedef NS_ENUM(NSInteger, DeleteMailFlag) {
    SaveMail = 0,
    DeleteMail
};

typedef NS_ENUM(NSInteger, TypeConditionFlag) {
    FromWhom = 0,
    Whom,
    Subject,
    MessageBody
};

//Совпадает и содержит
typedef NS_ENUM(NSInteger, TypeActionFlag) {
    TypeActionConcides = 0,
    TypeActionContains
};

//Флaги для проверки на правила
typedef NS_ENUM(NSInteger, CheckRuleFlag) {
    CheckRuleNotNecessary = 0,
    CheckRuleNotTested,
    CheckRuleTested
};

//Для кэширования просмотренных сообщений
typedef NS_ENUM(NSInteger, OfflineFlag) {
    OfflineFlagNone = 0,
    OfflineFlagSeen,
    OfflineFlagUnseen
};

//Оффлайн операции
typedef NS_ENUM(NSInteger, flagOfflineOp) {
    flagOfflineOpNone = 0,
    flagOfflineOpAnswer,
    flagOfflineOpMove
};


@property (nonatomic, strong) dispatch_queue_t bgProcessBDWorkingQueue;
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;
@property (nonatomic, strong) NSManagedObjectContext *_daddyManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext *_defaultManagedObjectContext;
@property (atomic, assign)    BOOL isReady;

+ (DBWorker*)sharedInstance;
- (void)initWithCompletionBlock:(void(^)(BOOL success))block;

+ (NSManagedObjectContext*)mocMain;
+ (NSManagedObjectContext*)mocPerThread;

+ (void)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit complectionBlock:(void(^)(NSArray*))block;
+ (NSArray*)objectWithEntity:(NSString*)entity param:(NSDictionary*)param sort:(NSDictionary*)sort offset:(NSInteger)offset limit:(NSInteger)limit MOC:(NSManagedObjectContext*)context;
+ (NSInteger)countWithEntity:(NSString*)entity param:(NSDictionary*)param MOC:(NSManagedObjectContext*)context;

+ (BOOL)saveContext:(NSManagedObjectContext*)bgTaskContext;
+ (void)sayContextError:(NSError*)error;

+ (void)saveAllContext;

@end
