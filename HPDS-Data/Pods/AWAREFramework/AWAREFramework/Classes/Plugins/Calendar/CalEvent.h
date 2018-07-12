//
//  CalEvent.h
//  AWARE
//
//  Created by Yuuki Nishiyama on 1/16/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalEvent : NSObject

typedef NS_ENUM(NSInteger, CalEventType) {
    CalEventTypeUnknown = 0,
    CalEventTypeOriginal,
    CalEventTypeUpdate,
    CalEventTypeAdd,
    CalEventTypeDelete
};

- (instancetype) initWithEKEvent:(EKEvent *)event eventType:(CalEventType)eventType;
- (instancetype) initWithEKEvent:(EKEvent *)event;

- (NSMutableDictionary *) getCalEventAsDictionaryWithDeviceId:(NSString *)deviceId timestamp:(NSNumber *) unixtime;
- (void) setCalendarEventType: (CalEventType) eventType;
- (NSString *) getCreateTableQuery;

@property (nonatomic, strong)  NSObject* objectManageId;

@property (nonatomic, strong)  NSString *eventType;

@property (nonatomic, strong)  EKEvent * ekEvent;

//[query appendFormat:@"%@ text default '',", CAL_ID];
@property (nonatomic, strong)  NSString* calendarId;
//[query appendFormat:@"%@ text default '',", ACCOUNT_NAME];
@property (nonatomic, strong)  NSString* accountName;
//[query appendFormat:@"%@ text default '',", CAL_NAME];
@property (nonatomic, strong)  NSString* calendarName;

//[query appendFormat:@"%@ text default '',", OWNER_ACCOUNT];
@property (nonatomic, strong)  NSString* ownerAccount;
//[query appendFormat:@"%@ text default '',", CAL_COLOR];
@property (nonatomic, strong)  NSString* calendarColor;


//[query appendFormat:@"%@ text default '',", EVENT_ID];
@property (nonatomic, strong)  NSString * eventId;
//[query appendFormat:@"%@ text default '',", TITLE];
@property (nonatomic, strong)  NSString * title;
//[query appendFormat:@"%@ text default '',", LOCATION];
@property (nonatomic, strong)  NSString*  location;
//[query appendFormat:@"%@ text default '',", DESCRIPTION];
@property (nonatomic, strong)  NSString* notes;
//[query appendFormat:@"%@ text default '',", BEGIN];
@property (nonatomic, strong)  NSString* begin;
//[query appendFormat:@"%@ text default '',", END];
@property (nonatomic, strong)  NSString* end;
//[query appendFormat:@"%@ text default '',", ALL_DAY];
@property (nonatomic, strong)  NSNumber* allDay;
//[query appendFormat:@"%@ text default '',", COLOR];
@property (nonatomic, strong)  NSString* color;
//[query appendFormat:@"%@ text default '',", HAS_ALARM];
@property (nonatomic, strong)  NSString* hasAlarm;
//[query appendFormat:@"%@ text default '',", AVAILABILITY];
@property (nonatomic, strong)  NSString* availability;
//[query appendFormat:@"%@ text default '',", IS_ORGANIZER];
@property (nonatomic, strong)  NSString* isOganizer;
//[query appendFormat:@"%@ text default '',", EVENT_TIMEZONE];
@property (nonatomic, strong)  NSString* eventTimezone;
//[query appendFormat:@"%@ text default '',", RRULE];
@property (nonatomic, strong)  NSString* rrule;
//
//[query appendFormat:@"%@ text default '',", STATUS];
@property (nonatomic, strong)  NSString* status;
//[query appendFormat:@"%@ text default '',", SEEN];
@property (nonatomic, strong)  NSString* seen;

@end
