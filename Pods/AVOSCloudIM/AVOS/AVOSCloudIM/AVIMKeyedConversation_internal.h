//
//  LCIMKeyedConversation_internal.h
//  AVOS
//
//  Created by Tang Tianyong on 6/12/15.
//  Copyright (c) 2015 LeanCloud Inc. All rights reserved.
//

#import "AVIMKeyedConversation.h"
@class AVIMMessage;

@interface AVIMKeyedConversation ()

@property (nonatomic, copy)   NSString     *conversationId;
@property (nonatomic, copy)   NSString     *clientId;
@property (nonatomic, copy)   NSString     *creator;
@property (nonatomic, strong) NSDate       *createAt;
@property (nonatomic, strong) NSDate       *updateAt;
@property (nonatomic, strong) NSDate       *lastMessageAt;
@property (nonatomic, strong) NSDate       *lastDeliveredAt;
@property (nonatomic, strong) NSDate       *lastReadAt;
@property (nonatomic, strong) AVIMMessage  *lastMessage;
@property (nonatomic, copy)   NSString     *name;
@property (nonatomic, strong) NSArray      *members;
@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) NSString *uniqueId;

@property (nonatomic, assign) BOOL    unique;
@property (nonatomic, assign) BOOL    transient;
@property (nonatomic, assign) BOOL    system;
@property (nonatomic, assign) BOOL    temporary;
@property (nonatomic, assign) int32_t temporaryTTL;
@property (nonatomic, assign) BOOL    muted;

@property (nonatomic, strong) NSMutableDictionary *properties;
@property (nonatomic, strong) NSDictionary *rawDataDic;

@end
