//
//  NetworkingManager.h
//  By the way
//
//  Created by Азат Шамсуллин on 27.03.16.
//  Copyright © 2016 ZeydenApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BGTools.h"

typedef void(^UrlConnectionCompletionBlock)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^UrlConnectionWithDataBlock)(NSURLResponse* response, NSData* data, NSError* error);
typedef void(^AnswerArrBlock)(NSArray *dataArr, BOOL success, NSString *errMsg);
typedef void(^AnswerDictBlock)(NSDictionary *dataDict, BOOL success, NSString *errMsg);

@interface NetworkingManager : NSObject

// Additory
+ (NSString*)makeUrlFromString:(NSString*)urlLink param:(NSDictionary*)param;

// Connection
+ (void)connectionWithUrl:(NSString *)urlLink postData:(NSDictionary*)postData handler:(UrlConnectionCompletionBlock)handler;
+ (void)connectionWithUrl:(NSString *)urlLink postData:(NSDictionary*)postData withToken:(NSString *)tokenValue handler:(UrlConnectionCompletionBlock)handler;

// Authorization
+ (void)registrationWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)authorizationWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)authorizationWithVKParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)authorizationWithFacebookParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)acceptPhoneNumberWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)activatePhoneNumberWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

// Info
+ (void)getInfoAboutMeWithComplete:(AnswerDictBlock)complete;
+ (void)getCardsInfoWithComplete:(AnswerArrBlock)complete;
+ (void)changeInfoAboutMe:(NSDictionary *)info withComplete:(AnswerDictBlock)complete;
+ (void)changeCardsInfo:(NSDictionary *)info withComplete:(AnswerDictBlock)complete;
+ (void)deleteCardInfoById:(NSNumber *)cardId withComplete:(AnswerDictBlock)complete;
+ (void)uploadUserImage:(UIImage *)image withComplete:(AnswerDictBlock)complete;
+ (void)deleteUserImageWithComplete:(AnswerDictBlock)complete;

// Parcels
// Get Parcels
+ (void)getWorkedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)getPlannedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)getArchivedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

//DetailParce;
+ (void)getDetailParcelWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete;


// Create Parcels
+ (void)createNewParcelWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

//Delivery
//Get Deliveries
+ (void)getWorkedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)getPlannedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;
+ (void)getArchivedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

//Create Delivery
+ (void)createNewDeliveryWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

//Couriers
+ (void)getCouriersInfoWithParamsCount:(double)count offset:(double)offset withID:(NSString *)ID boolAUTH:(BOOL)auth andComplete:(AnswerDictBlock)complete;
+ (void)getCourierDetailInfoWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete;

//Senders
+ (void)getSendersInfoWithParamsCount:(double)count offset:(double)offset withID:(NSString *)ID boolAUTH:(BOOL)auth andComplete:(AnswerDictBlock)complete;

//Review
+ (void)createReviewWith:(NSDictionary *)params andComplete:(AnswerDictBlock)complete;

//Mentions
+ (void)getMentionsAboutCourierWithID:(NSString *)ID isCourier:(BOOL)isCourier andComplete:(AnswerDictBlock)complete;

//Chats
+ (void)createInvoicesWithType:(BOOL)type myID:(double)myID companionID:(double)companion andComplete:(AnswerDictBlock)complete;
+ (void)getListChatsAndComplete:(AnswerDictBlock)complete;
+ (void)getMessagesInChatUID:(double)uid andComplete:(AnswerDictBlock)complete;
+ (void)sendMessageInChatUID:(double)uid companionID:(double)companionUID message:(NSString *)message andComplete:(AnswerDictBlock)complete;
+ (void)seenMessageWithArrUIDs:(NSArray *)arr andComplete:(AnswerDictBlock)complete;
+ (void)detailMessageInChatUID:(double)uid andComplete:(AnswerDictBlock)complete;
//маршрут курьера
+ (void)getCourierRoutesWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete;


+ (void)forgetPasswordWithEmail:(NSString *)email andComplete:(AnswerDictBlock)complete;

//localized
+ (void)getLocalizeUserAndComplete:(AnswerDictBlock)complete;
+ (void)setlocalize:(NSString *)langString andCurrency:(NSString *)currencyString andComplete:(AnswerDictBlock)complete;

//notificationns
+ (void)subscribeRemoteNotificationWithToken:(NSString *)device_id WithComplete:(AnswerDictBlock)complete;
+ (void)unSubscribeRemoteNotificationWithToken:(NSString *)device_id WithComplete:(AnswerDictBlock)complete;

@end
