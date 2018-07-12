//
//  Telephony.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 1/19/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//
//  http://www.awareframework.com/communication/
//  https://developer.apple.com/library/ios/documentation/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Chapters/QuickStart.html#//apple_ref/doc/uid/TP40007744-CH2-SW1
//

#import "Calls.h"
#import "AWAREUtils.h"
#import "EntityCall.h"

NSString* const AWARE_PREFERENCES_STATUS_CALLS = @"status_calls";

NSString* const KEY_CALLS_TIMESTAMP = @"timestamp";
NSString* const KEY_CALLS_DEVICEID = @"device_id";
NSString* const KEY_CALLS_CALL_TYPE = @"call_type";
NSString* const KEY_CALLS_CALL_DURATION = @"call_duration";
NSString* const KEY_CALLS_TRACE = @"trace";

@implementation Calls {
    NSDate * start;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType{
    AWAREStorage * storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study sensorName:@"calls"];
    }else if(dbType == AwareDBTypeCSV){
        NSArray * header = @[KEY_CALLS_TIMESTAMP, KEY_CALLS_DEVICEID, KEY_CALLS_CALL_TYPE, KEY_CALLS_CALL_DURATION, KEY_CALLS_TRACE];
        NSArray * headerTypes  = @[@(CSVTypeReal),@(CSVTypeText),@(CSVTypeInteger),@(CSVTypeInteger),@(CSVTypeText)];
        storage = [[CSVStorage alloc] initWithStudy:study sensorName:@"calls" headerLabels:header headerTypes:headerTypes];
    }else{
        storage = [[SQLiteStorage alloc] initWithStudy:study sensorName:@"calls" entityName:NSStringFromClass([EntityCall class])
                                        insertCallBack:^(NSDictionary *data, NSManagedObjectContext *childContext, NSString *entity) {
                                            
                                            EntityCall* callData = (EntityCall *)[NSEntityDescription
                                                                                  insertNewObjectForEntityForName:entity
                                                                                  inManagedObjectContext:childContext];
                                            callData.device_id = [data objectForKey:KEY_CALLS_DEVICEID];
                                            callData.timestamp = [data objectForKey:KEY_CALLS_TIMESTAMP];
                                            callData.call_type = [data objectForKey:KEY_CALLS_CALL_TYPE];
                                            callData.call_duration = [data objectForKey:KEY_CALLS_CALL_DURATION];
                                            callData.trace = [data objectForKey:KEY_CALLS_TRACE];
                                        }];
    }
    
    self = [super initWithAwareStudy:study
                          sensorName:@"calls" storage:storage];
    if (self!=nil) {
        // [self setCSVHeader:
    }
    return self;
}


- (void) createTable{
    if([self isDebug]){
        NSLog(@"[%@] Create Telephony Sensor Table", [self getSensorName]);
    }
    TCQMaker * maker = [[TCQMaker alloc] init];
    [maker addColumn:KEY_CALLS_CALL_TYPE type:TCQTypeInteger default:@"0"];
    [maker addColumn:KEY_CALLS_CALL_DURATION type:TCQTypeInteger default:@"0"];
    [maker addColumn:KEY_CALLS_TRACE type:TCQTypeText default:@"''"];
    [self.storage createDBTableOnServerWithTCQMaker:maker];
}

- (void)setParameters:(NSArray *)parameters{
    
}

-(BOOL)startSensor{
    
    /// [super startSensor];
    
    // Set and start a call sensor
    _callCenter = [[CTCallCenter alloc] init];
    _callCenter.callEventHandler = ^(CTCall* call){
        NSString * callId = call.callID;
        if (callId == nil) callId = @"";
        NSNumber * callType = @0;
        NSString * callTypeStr = @"Unknown";
        int duration = 0;
        if (self->start == nil) self->start = [NSDate new];
        
        // one of the Android’s call types (1 – incoming, 2 – outgoing, 3 – missed)
        if (call.callState == CTCallStateIncoming) {
            // start
            callType = @1;
            self->start = [NSDate new];
            callTypeStr = @"Incoming";
        } else if (call.callState == CTCallStateConnected){
            callType = @2;
            duration = [[NSDate new] timeIntervalSinceDate:self->start];
            self->start = [NSDate new];
            callTypeStr = @"Connected";
        } else if (call.callState == CTCallStateDialing){
            // start
            callType = @3;
            self->start = [NSDate new];
            callTypeStr = @"Dialing";
        } else if (call.callState == CTCallStateDisconnected){
            // fin
            callType = @4;
            callTypeStr = @"Disconnected";
            duration = [[NSDate new] timeIntervalSinceDate:self->start];
            self->start = [NSDate new];
        }
        
        if ([self isDebug]) {
            NSLog(@"[%@] Call Duration is %d seconds @ [%@]", [super getSensorName], duration, callTypeStr);
        }
        
        // dispatch_async(dispatch_get_main_queue(), ^{
            
        NSNumber *durationValue = [NSNumber numberWithInt:duration];
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[AWAREUtils getUnixTimestamp:[NSDate new]] forKey:KEY_CALLS_TIMESTAMP];
        [dict setObject:[super getDeviceId] forKey:KEY_CALLS_DEVICEID];
        [dict setObject:callType forKey:KEY_CALLS_CALL_TYPE];
        [dict setObject:durationValue forKey:KEY_CALLS_CALL_DURATION];
        [dict setObject:callId forKey:KEY_CALLS_TRACE];
            
            // [super saveData:dict];
        [self.storage saveDataWithDictionary:dict buffer:NO saveInMainThread:YES];
        [super setLatestData:dict];
        
        // Set latest sensor data
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
        NSString * dateStr = [timeFormat stringFromDate:[NSDate new]];
        NSString * latestData = [NSString stringWithFormat:@"%@ [%@] %d seconds",dateStr, callTypeStr, duration];
        [super setLatestValue: latestData];
        
        SensorEventHandler handler = [self getSensorEventHandler];
        if (handler!=nil) {
            handler(self, dict);
        }
        
        // Broadcast a notification
        // http://www.awareframework.com/communication/
        // [NOTE] On the Andoind AWARE client, when the ACTION_AWARE_USER_NOT_IN_CALL and ACTION_AWARE_USER_IN_CALL are called?
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:dict forKey:EXTRA_DATA];
        if (call.callState == CTCallStateIncoming) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_CALL_RINGING
                                                                object:nil
                                                              userInfo:userInfo];
        } else if (call.callState == CTCallStateConnected){
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_CALL_ACCEPTED
                                                                object:nil
                                                              userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_USER_IN_CALL
                                                                object:nil
                                                              userInfo:userInfo];
        } else if (call.callState == CTCallStateDialing){
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_CALL_MADE
                                                                object:nil
                                                              userInfo:userInfo];
        } else if (call.callState == CTCallStateDisconnected){
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_CALL_MISSED
                                                                object:nil
                                                              userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_USER_NOT_IN_CALL
                                                                object:nil
                                                              userInfo:userInfo];
        }
        //});
    };
    [self setSensingState:YES];
    return YES;
}



-(BOOL) stopSensor{
    _callCenter.callEventHandler = nil;
    
    [self setSensingState:NO];
    
    return YES;
}


////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////



- (void) sendLocalNotificationWithCallId : (NSString *) callId
                                 soundFlag : (BOOL) soundFlag {
    UILocalNotification *localNotification = [UILocalNotification new];
    CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    // NSLog(@"OS:%f", currentVersion);
    if (currentVersion >= 9.0){
        localNotification.alertBody = @"Call from/to who?";
    } else {
        localNotification.alertBody = @"Call from/to who?";
    }
    localNotification.fireDate = [NSDate new];
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.category = callId;
    if(soundFlag) {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.hasAction = YES;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
