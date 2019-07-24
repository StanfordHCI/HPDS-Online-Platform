//
//  ESMSchedule.h
//  AWAREFramework
//
//  Created by Yuuki Nishiyama on 2018/03/27.
//

#import <Foundation/Foundation.h>
#import "ESMItem.h"

typedef enum: NSInteger {
    AwareESMWeekdaySunday    = 1,
    AwareESMWeekdayMonday    = 2,
    AwareESMWeekdayThuesday  = 3,
    AwareESMWeekdayWednesday = 4,
    AwareESMWeekdayThursday  = 5,
    AwareESMWeekdayFirday    = 6,
    AwareESMWeekdaySaturday  = 7
} AwareESMWeekday;

typedef enum: NSInteger {
    AwareESMInterfaceTypeOneByOne = 0,
    AwareESMInterfaceTypeAllInOne = 1
} AwareESMInterfaceType;

@interface ESMSchedule : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic) NSString *scheduleId;
@property (nonatomic) NSNumber *expirationThreshold;
@property (nonatomic) NSDate   *startDate;
@property (nonatomic) NSDate   *endDate;
@property (nonatomic) NSString *notificationBody;
@property (nonatomic) NSString *notificationTitle;
@property (nonatomic) NSArray <NSNumber *> *fireHours;
@property (nonatomic) NSArray <NSDateComponents *> * timers;
@property (nonatomic) BOOL      repeat;
@property (nonatomic) NSArray <NSString *> * contexts;
@property (nonatomic) NSArray <NSNumber *> * weekdays;
// @property (readonly)  NSArray <NSNumber *> * months;
@property (nonatomic) NSNumber *interface;
@property (nonatomic) NSNumber *randomizeEsm;
@property (nonatomic) NSNumber *randomizeSchedule;
@property (nonatomic) NSNumber *temporary;
@property (nonatomic) NSArray <ESMItem *>  *esms;

- (void) addHours:(NSArray <NSNumber *> *) hours;
- (void) addHour:(NSNumber *)hour;

- (void) addESMs:(NSArray <ESMItem *> *)esmItems;
- (void) addESM:(ESMItem *)esmItem;

- (void) addContext:(NSString *)context;
- (void) addTimer:(NSDateComponents *)timer;
- (void) addWeekday:(AwareESMWeekday)weekday;

- (void) setInterfaceType:(AwareESMInterfaceType)interfaceType;

NS_ASSUME_NONNULL_END

@end
///////////////////
