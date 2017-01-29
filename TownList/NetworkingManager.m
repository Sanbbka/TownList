//
//  NetworkingManager.m
//  By the way
//
//  Created by Азат Шамсуллин on 27.03.16.
//  Copyright © 2016 ZeydenApp. All rights reserved.
//

#import "NetworkingManager.h"
#import "Singleton.h"
#import "Networking.h"

@implementation NetworkingManager

static NSOperationQueue *currentConnectionQueue;

+  (NSString *)getDomain {
    return @"http://courier.retor.pro/api/v1/";
}

+ (NSString*)makeUrlFromString:(NSString*)urlLink param:(NSDictionary*)param {
    if (param == nil || param.count <= 0)
        return urlLink;
    NSLog(@"%@", [urlLink stringByAppendingFormat:[urlLink rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", stringFromParameters(param)]);
    
    return [urlLink stringByAppendingFormat:[urlLink rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", stringFromParameters(param)];
}

static NSString *stringFromParameters(NSDictionary *params) {
    if (! params)
        return @"";
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *key in params) {
        NSString *field = urlEncode( key, NSUTF8StringEncoding );
        NSString *value = urlEncode( [NSString stringWithFormat:@"%@", params[key]], NSUTF8StringEncoding);
        [arr addObject:[NSString stringWithFormat:@"%@=%@", field ?: @"", value ?: @""]];
    }
    
    return [arr componentsJoinedByString:@"&"];
}

static NSString* urlEncode(NSString *str, NSStringEncoding encoding) {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

#pragma mark - Connections

+ (void)connectionWithUrl:(NSString *)urlLink postData:(NSDictionary*)postData handler:(UrlConnectionCompletionBlock)handler
{
    
    NSURL *url = [NSURL URLWithString:urlLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (postData) {
        [request setHTTPMethod:@"POST"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    [request setHTTPShouldHandleCookies:YES];
    
    if (postData) {
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:postData options:1 error:nil] encoding:NSUTF8StringEncoding];
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestData];
    }
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:[Singleton authorization].userInfo.localize forHTTPHeaderField:@"LANGUAGE"];

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:handler];
    [jsonData resume];
}

+ (void)connectionWithUrl:(NSString *)urlLink postData:(NSDictionary*)postData withToken:(NSString *)tokenValue handler:(UrlConnectionCompletionBlock)handler
{
    
    NSURL *url = [NSURL URLWithString:urlLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (postData) {
        [request setHTTPMethod:@"POST"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    [request setHTTPShouldHandleCookies:YES];
    
    if (postData) {
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:postData options:1 error:nil] encoding:NSUTF8StringEncoding];
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestData];
    }
    
    if (tokenValue) {
        [request addValue:tokenValue forHTTPHeaderField: @"Authorization"];
    }
    
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:[Singleton authorization].userInfo.localize forHTTPHeaderField:@"LANGUAGE"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:handler];
    [jsonData resume];
}


+ (void)connectionWithUrl:(NSString *)urlLink putData:(NSDictionary*)putData withToken:(NSString *)tokenValue handler:(UrlConnectionCompletionBlock)handler
{
    
    NSURL *url = [NSURL URLWithString:urlLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (putData) {
        [request setHTTPMethod:@"PUT"];
    } else {
        return;
    }
    
    [request setHTTPShouldHandleCookies:YES];

    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:putData options:1 error:nil] encoding:NSUTF8StringEncoding];
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:requestData];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:tokenValue forHTTPHeaderField: @"Authorization"];
    [request addValue:[Singleton authorization].userInfo.localize forHTTPHeaderField:@"LANGUAGE"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:handler];
    
    [jsonData resume];
}

+ (void)connectionWithUrl:(NSString *)urlLink deleteDataWithToken:(NSString *)tokenValue handler:(UrlConnectionCompletionBlock)handler
{
    
    NSURL *url = [NSURL URLWithString:urlLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPShouldHandleCookies:YES];
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:tokenValue forHTTPHeaderField: @"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:handler];
    
    [jsonData resume];
}

#pragma mark - =================Authorization====================

+ (void)requestTokenWithParams:(NSDictionary *)params complete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/token/post/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:/*(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments)*/ NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
            } else {
                complete(jsonDict, YES, nil);
            }
        } else {
            if (error.code == 403) {
                NSLog(@"Пользователь с такими данными уже существует");
                complete(nil, NO, [NSString stringWithFormat:@"%@", error.description]);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
            NSLog(@"Ошибка при регистрации");
        }
    }];
    
}

+ (void)authWithUrl:(NSString *)urlLink postData:(NSDictionary*)postData withToken:(NSString *)tokenValue handler:(UrlConnectionCompletionBlock)handler
{
    
    NSURL *url = [NSURL URLWithString:urlLink];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (postData) {
        [request setHTTPMethod:@"POST"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    
    [request setHTTPShouldHandleCookies:YES];
    
    if (postData) {
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:postData options:1 error:nil] encoding:NSUTF8StringEncoding];
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPBody:requestData];
    }
    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    
    if (tokenValue) 
        [request addValue:tokenValue forHTTPHeaderField: @"Authorization"];

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:handler];
    
    [jsonData resume];
}

+ (void)registrationWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/registration/post/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (data && !error) {
             
             NSDictionary *jsonDict = nil;
             NSError *jsonError = nil;
             jsonDict = [NSJSONSerialization JSONObjectWithData:data options:/*(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments)*/ NSJSONReadingAllowFragments error:&jsonError];
             
             if (jsonError) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     complete(nil, NO, jsonError.description);
                 });
             } else {
                 if ([jsonDict[@"status"] boolValue]) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         complete(jsonDict, YES, @"");
                     });
                 } else {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSLog(@"%@", jsonDict[@"Error"]);
                         complete(jsonDict, NO, jsonDict[@"message"]);
                     });
                 }
             }
         } else {
             if (error.code == 403) {
                 NSLog(@"Пользователь с такими данными уже существует");
                 complete(nil, NO, [NSString stringWithFormat:@"%@", error.description]);
             } else
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     complete(nil, NO, @"");
                 });
             NSLog(@"Ошибка при регистрации");
         }
     }];
}

+ (void)authorizationWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/login/post/"];
    
    [NetworkingManager requestTokenWithParams:params complete:^(NSDictionary *dataDict, BOOL success, NSString *errMsg) {
        if (!errMsg || [errMsg isEqualToString:@""]) {
            if (success && dataDict) {
                NSString *token = dataDict[@"token"];
                if (token.length > 0) {
                    [[[Singleton authorization] email] setEmail:params[@"username"]];
                    [[[Singleton authorization] email] setPassword:params[@"password"]];
                    [[[Singleton authorization] email] setToken:dataDict[@"token"]];
                    
                    token = [NSString stringWithFormat:@"Token %@", token];
                    [NetworkingManager authWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if (data && !error) {
                            
                            NSDictionary *jsonDict = nil;
                            NSError *jsonError = nil;
                            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                            
                            if (jsonError) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    complete(nil, NO, jsonError.description);
                                });
                                return ;
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    complete(jsonDict, YES, @"");
                                    [NetworkingManager subscribeRemoteNotificationWithToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] WithComplete:^(NSDictionary *dataDict, BOOL success, NSString *errMsg) {
                                        NSLog(@"");
                                    }];
                                });
                                return ;
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(nil, NO, @"");
                            });
                        }
                    }];
                } else dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, @"");
                });
            } else dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        } else dispatch_async(dispatch_get_main_queue(), ^{
            complete(nil, NO, @"");
        });
    }];
}

+ (void)authorizationWithVKParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/social/vk/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                if ([jsonDict[@"status"] boolValue]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(jsonDict, YES, @"");
                    });
                    return ;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@", jsonDict[@"Error"]);
                        complete(jsonDict, NO, jsonDict[@"Error"]);
                    });
                    return ;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

+ (void)authorizationWithFacebookParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/social/fb/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                if ([jsonDict[@"status"] boolValue]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(jsonDict, YES, @"");
                    });
                    return ;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@", jsonDict[@"Error"]);
                        complete(jsonDict, NO, jsonDict[@"Error"]);
                    });
                    return ;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

+ (void)acceptPhoneNumberWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"core/sendsms/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                if ([jsonDict[@"status"] boolValue]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(jsonDict, YES, @"");
                    });
                    return ;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@", jsonDict[@"Error"]);
                        complete(jsonDict, NO, jsonDict[@"Error"]);
                    });
                    return ;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

+ (void)activatePhoneNumberWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"core/activate/"];
    
    [NetworkingManager connectionWithUrl:pathStr postData:params handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                if ([jsonDict[@"status"] boolValue]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(jsonDict, YES, @"");
                    });
                    return ;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@", jsonDict[@"Error"]);
                        complete(jsonDict, NO, jsonDict[@"Error"]);
                    });
                    return ;
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

#pragma mark - =================User Info====================

+ (void)getInfoAboutMeWithComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }

    }];
}

+ (void)getCardsInfoWithComplete:(AnswerArrBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/cards/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    complete(jsonDict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, @"");
                });
            });
        }
        
    }];
}

+ (void)changeInfoAboutMe:(NSDictionary *)info withComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/change-profile/update/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr putData:info withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)changeCardsInfo:(NSDictionary *)info withComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/cards/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr putData:info withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)deleteCardInfoById:(NSNumber *)cardId withComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [NSString stringWithFormat:@"users/%@me/cards/?id=%@", pathStr, cardId];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr deleteDataWithToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)uploadUserImage:(UIImage *)image withComplete:(AnswerDictBlock)complete {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://courier.retor.pro/api/v1/users/me/photo/"]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"PUT"];
    
    NSString *boundary = [[NSUUID UUID] UUIDString];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
     NSString *token = [Networking instance].token;
    [request setValue:token forHTTPHeaderField: @"Authorization"];
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"Some Caption"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=comingSoon.jpg\r\n", @"avatar"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }

    }];
    [jsonData resume];
}

+ (void)deleteUserImageWithComplete:(AnswerDictBlock)complete {
    NSURL *url = [NSURL URLWithString:@"http://courier.retor.pro/api/v1/users/me/photo/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *token = [Networking instance].token;
    
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPShouldHandleCookies:YES];
//    [request addValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
    [request addValue:token forHTTPHeaderField: @"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
    [jsonData resume];
}

#pragma mark - =================Parcels====================

#pragma mark - Get MyParcels

+ (void)getWorkedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/parcels/inhand/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)getPlannedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/parcels/planned/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)getArchivedParcelsInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/parcels/archived/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

#pragma mark - Create Parcels

+ (void)createNewParcelWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/sending/new/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

#pragma mark - ===========================================


#pragma mark - =================Delivery====================

#pragma mark - Get MyDelivery

+ (void)getWorkedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/routes/inhand/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            ;
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)getPlannedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/routes/planned/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

+ (void)getArchivedDeliveriesInfoWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/routes/archived/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

#pragma mark - Create Delivery

+ (void)createNewDeliveryWithParams:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/delivery/new/"];
    
    NSString *token = [Networking instance].token;
    [NetworkingManager connectionWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

#pragma mark - ===========================================


#pragma mark - =================Couriers====================

//count
//from

+ (void)getCouriersInfoWithParamsCount:(double)count offset:(double)offset withID:(NSString *)ID boolAUTH:(BOOL)auth andComplete:(AnswerDictBlock)complete {
    
    NSDictionary *params = @{@"count" : @(offset), @"from" : @(count)};//потому что
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/sending/found/couriers/"];
    pathStr = [pathStr stringByAppendingString:ID];
    pathStr = [pathStr stringByAppendingString:@"/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    NSString *token = nil;
    if (auth)
        token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

//Детальная информация об курьере

+ (void)getCourierDetailInfoWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/profile/"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:ID];
        pathStr = [pathStr stringByAppendingString:@"/"];
    }
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

//Маршруты курьера
+ (void)getCourierRoutesWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/sending/planned/routes/"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:ID];
        pathStr = [pathStr stringByAppendingString:@"/"];
    }
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - ReviewAdd

/*
 Artem Afonin, [15.08.16 12:55]
 /api/v1/users/me/metions/ <- POST
 {'user_id': 542, 'level': 2, 'text': 'Hi everyone!'}
 
 Artem Afonin, [15.08.16 12:55]
 Response:
 {'status': true, 'id': 43}
 */

+ (void)createReviewWith:(NSDictionary *)params andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    
    
    
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"users/me/mentions/"]];
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
//            NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - =================Senders====================

+ (void)getSendersInfoWithParamsCount:(double)count offset:(double)offset withID:(NSString *)ID boolAUTH:(BOOL)auth andComplete:(AnswerDictBlock)complete {
    
    NSDictionary *params = @{@"count" : @(offset), @"from" : @(count)};
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/delivery/found/parcels/"];
    pathStr = [pathStr stringByAppendingString:ID];
    pathStr = [pathStr stringByAppendingString:@"/"];
    pathStr = [NetworkingManager makeUrlFromString:pathStr param:params];
    NSString *token = nil;
    if (auth)
        token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

//Детальная информация об курьере

+ (void)getSenderDetailInfoWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/profile/"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:ID];
        pathStr = [pathStr stringByAppendingString:@"/"];
    }
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

//Посылки отправителя
+ (void)getPlannedParcelsWithRouteID:(NSString *)ID andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/delivery/planned/parcels/"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:ID];
        pathStr = [pathStr stringByAppendingString:@"/"];
    }
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - Detail Parcel

+ (void)getDetailParcelWithID:(NSString *)ID andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"trips/delivery/edit/"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:ID];
        pathStr = [pathStr stringByAppendingString:@"/"];
    }
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


//Отзывы
#pragma mark - =================Mentions====================
//Если послать nil, вернутся отзывы об текущем пользователе
+ (void)getMentionsAboutCourierWithID:(NSString *)ID isCourier:(BOOL)isCourier andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/mentions"];
    if (ID) {
        pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"/%@", ID]];
    }
    
    pathStr = [NSString stringWithFormat:@"%@/?courier=%@", pathStr, isCourier ? @"true" : @"false"];
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager connectionWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - =================Chat====================

/*
 Создание накладной и чата к нему:
 /api/v1/invoices/invoice/init/ <- POST
 Request://Поля my и компаньон - id посылки или маршрута
 //type - помощник различать эти id
 //
 {"type": true/false, "my": 2, "companion": 12}
 Response:
 {"id": 10}
 Error - Response: {"statusCode": 404, "message": "Error smth"}
 */

//в оттвете ожидается id чата
+ (void)createInvoicesWithType:(BOOL)type myID:(double)myID companionID:(double)companion andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"invoices/invoice/init/"];
    
    NSDictionary *params = @{
                             @"type" : @(type),
                             @"my"   : @(myID),
                             @"companion" : @(companion)
                             
                             };
    NSString *token = [Networking instance].token;

    [NetworkingManager authWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

/*
 Список чатов:
 /api/v1/invoices/chat/list/ <-  GET
 Response: http://jsoneditoronline.org/?id=f66d22fda8187136aebb016ca2c1aba4

 */
//Пример ответа

/*
 {
 "chats": [
 {
    "to": "Frankfurt am Main",
    "unread_messages": 0,
    "chat_status": 2,
    "from": "Montreal",
    "last_message": {
        "text": "",
        "date_created": 0,
        "id": null,
        "own_my": null
    },
    "date_created": 1468488990,
    "chat_user": {
        "status": 2,
        "first_name": "Afonin",
        "last_name": "Artem",
        "id": 2,
        "avatar": "http://cs628830.vk.me/v628830377/5863b/azOqfD3rFUY.jpg"
    },
    "id": 2
 }
 ],
    "count": 1
 }
 */

+ (void)getListChatsAndComplete:(AnswerDictBlock)complete {
 
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"invoices/chat/list/"];
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


/*
 Сообщения в чате:
 /api/v1/invoices/CHAT_ID/messages/ <- GET
 Response: {"msg": [{"status": 0, "date_created": 1468855911, "id": 4, "last_message": {"text": "FUCK THEM ALL!", "date_created": 1468855911, "id": 4, "own_my": false}, "chat_id": 2}, etc...], "count": 8}

 */
+ (void)getMessagesInChatUID:(double)uid andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"invoices/chat/%@/messages/", @(uid)]];
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

/*
 Накатать сообщение:
 /api/v1/invoices/CHAT_ID/messages/ <- POST
 invoices/chat/CHAT_ID/messages/
 Request:
 {"text": "New message to chat", "companion": 1} <- id пользователя компаньона
 Response: {"id": 42}

 */
+ (void)sendMessageInChatUID:(double)uid companionID:(double)companionUID message:(NSString *)message andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"invoices/chat/%@/messages/", @(uid)]];
    
    NSDictionary *params = @{
                             @"text" : message,
                             @"companion" : @(companionUID)
                             };
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

/*
 Метод для установки о прочтении сообщения:
 /api/v1/invoices/chat/read/ <- POST
 Request:
 {"ids": "1,4,3,5,3,6778,33,6,"}
 Response: {"status": true}
 */
+ (void)seenMessageWithArrUIDs:(NSArray *)arr andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    
    NSString *UIDs = [arr componentsJoinedByString:@","];
    
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"invoices/chat/read/"]];
    
    NSDictionary *params = @{
                             @"ids" : UIDs
                             };
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:params withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

/*
 что бы упасть в чат при нажатии кнопки Связаться, делай запрос на
 /api/v1/invoices/chat/detail/ID/ <- GET
 где ID это полученый результат от запроса
 */

+ (void)detailMessageInChatUID:(double)uid andComplete:(AnswerDictBlock)complete {
    
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"invoices/chat/detail/%@/", @(uid)]];
    
    NSString *token = [Networking instance].token;
    
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - Password

+ (void)forgetPasswordWithEmail:(NSString *)email andComplete:(AnswerDictBlock)complete
{
    NSString *pathStr = [NetworkingManager getDomain];
    
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"users/forgot-password/post/"]];
    
    NSDictionary *params = @{
                             @"email" : email
                             };
    
    [NetworkingManager authWithUrl:pathStr postData:params withToken:nil handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}


#pragma mark - setting

/*
 /api/v1/users/me/settings/ <- GET
 Response:
 {"lang": "ru", "currency": "usd"}
 
 Post:
 Тот же JSON только подсовывать надо ru/en, rub/usd/eur
 */

+ (void)getLocalizeUserAndComplete:(AnswerDictBlock)complete
{
    NSString *pathStr = [NetworkingManager getDomain];
    
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"users/me/settings/"]];
    
    [NetworkingManager authWithUrl:pathStr postData:nil withToken:nil handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}
/*
 /api/v1/users/me/settings/ <- GET
 Response:
 {"lang": "ru", "currency": "usd"}
 
 Post:
 Тот же JSON только подсовывать надо ru/en, rub/usd/eur
 */
+ (void)setlocalize:(NSString *)langString andCurrency:(NSString *)currencyString andComplete:(AnswerDictBlock)complete
{
    NSString *pathStr = [NetworkingManager getDomain];
    
    pathStr = [pathStr stringByAppendingString:[NSString stringWithFormat:@"users/forgot-password/post/"]];
    
    NSDictionary *params = @{
                             @"lang"        : langString,
                             @"currency"    : currencyString
                             };
    
    [NetworkingManager authWithUrl:pathStr postData:params withToken:nil handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(jsonDict, YES, @"");
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
    }];
}

/*
 Artem Afonin, [02.10.16 18:10]
 /api/v1/users/me/devices/create/ <- POST
 {'device_id': 'a227d88afa7d97cfdea26790c76102e2efc7b1f774e71fb244b7cd1d1e22ba44', 'device_hash': 'another_hash_of_device_id'}
 
 Artem Afonin, [02.10.16 18:11]
 Response:
 {'status': true, 'id': 23}
 
 */

+ (void)subscribeRemoteNotificationWithToken:(NSString *)device_id WithComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/devices/create/"];
    
    NSString *token = [Networking instance].token;
    
    NSDictionary *info = @{@"device_id" : device_id?:@"", @"device_hash" : [NSString stringWithFormat:@"%@", @([device_id hash])]};
    
    [NetworkingManager connectionWithUrl:pathStr postData:info withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}

/*
 /api/v1/users/me/devices/delete/ <- POST
 {'device_id': 'a227d88afa7d97cfdea26790c76102e2efc7b1f774e71fb244b7cd1d1e22ba44'}
 */

+ (void)unSubscribeRemoteNotificationWithToken:(NSString *)device_id WithComplete:(AnswerDictBlock)complete {
    NSString *pathStr = [self getDomain];
    pathStr = [pathStr stringByAppendingString:@"users/me/devices/delete/"];
    
    NSString *token = [Networking instance].token;
    
    NSDictionary *info = @{@"device_id" : device_id};
    
    [NetworkingManager connectionWithUrl:pathStr postData:info withToken:token handler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            
            NSDictionary *jsonDict = nil;
            NSError *jsonError = nil;
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(nil, NO, jsonError.description);
                });
                return ;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *dict = [self changeNullResult:jsonDict];
                    complete(dict, YES, nil);
                });
                return ;
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(nil, NO, @"");
            });
        }
        
    }];
}



//Fix <Null> string

#pragma mark - NSNull

+ (id)clearNULLResult:(id)listObjects {
    
    if ([self isArray:listObjects]) {
        NSMutableArray *arr = [NSMutableArray new];
        for (id obj in listObjects) {
          [arr addObject:[self clearNULLResult:obj]];
        }
        return arr;
    }
    
    if ([self isDict:listObjects]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (id obj in listObjects) {
            if ([self isCollection:listObjects[obj]]) {
                [dict setObject:[self clearNULLResult:listObjects[obj]] forKey:obj];
                
            } else {
                if ([self isNULLObject:listObjects[obj]]) {
//                     NSString *sss = listObjects[obj];
                    [dict setObject:@"" forKey:obj];
                    
                    NSLog(@"");
                } else {
                    [dict setObject:listObjects[obj] forKey:obj];
                }
            }
        }
        return dict;
    }
    
    return listObjects;
}

+ (BOOL)isArray:(id)obj
{
    return [obj isKindOfClass:[NSArray class]];
}

+ (BOOL)isDict:(id)obj
{
    return [obj isKindOfClass:[NSDictionary class]];
}

+ (BOOL)isNULLObject:(id)object
{
    return [[NSNull null] isEqual:object];
}

+ (BOOL)isCollection:(id)object {
    
    if ([self isDict:object] || [self isArray:object])
        return YES;
    
    return NO;
}

+ (id)changeNullResult:(id)collection
{
    return [self clearNULLResult:collection];
}

@end
