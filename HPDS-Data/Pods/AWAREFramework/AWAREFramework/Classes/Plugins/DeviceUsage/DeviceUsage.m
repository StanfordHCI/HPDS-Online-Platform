//
//  DeviceUsage.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 12/14/15.
//  Copyright © 2015 Yuuki NISHIYAMA. All rights reserved.
//

#import "DeviceUsage.h"
#import "notify.h"
#import "EntityDeviceUsage.h"

NSString* const AWARE_PREFERENCES_STATUS_DEVICE_USAGE = @"status_plugin_device_usage";

@implementation DeviceUsage {
    double lastTime;
    int _notifyTokenForDidChangeLockStatus;
    // int _notifyTokenForDidChangeDisplayStatus;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType{
    AWAREStorage * storage = nil;
    if (dbType == AwareDBTypeJSON) {
        storage = [[JSONStorage alloc] initWithStudy:study sensorName:SENSOR_PLUGIN_DEVICE_USAGE];
    }else if(dbType == AwareDBTypeCSV){
        NSArray * header = @[@"timestamp",@"device_id",@"elapsed_device_on",@"elapsed_device_off"];
        NSArray * headerTypes  = @[@(CSVTypeReal),@(CSVTypeText),@(CSVTypeReal),@(CSVTypeReal)];
        storage = [[CSVStorage alloc] initWithStudy:study sensorName:SENSOR_PLUGIN_DEVICE_USAGE headerLabels:header headerTypes:headerTypes];
    }else{
        storage = [[SQLiteStorage alloc] initWithStudy:study sensorName:SENSOR_PLUGIN_DEVICE_USAGE entityName:NSStringFromClass([EntityDeviceUsage class])
                                        insertCallBack:^(NSDictionary *data, NSManagedObjectContext *childContext, NSString *entity) {
                                            
                                            EntityDeviceUsage * deviceUsage = (EntityDeviceUsage *)[NSEntityDescription insertNewObjectForEntityForName:entity
                                                                                                                                 inManagedObjectContext:childContext];
                                            deviceUsage.timestamp = [data objectForKey:@"timestamp"];
                                            deviceUsage.device_id = [data objectForKey:@"device_id"];
                                            deviceUsage.elapsed_device_on = [data objectForKey:@"elapsed_device_on"];
                                            deviceUsage.elapsed_device_off = [data objectForKey:@"elapsed_device_off"];
                                            
                                        }];
    }
    
    self = [super initWithAwareStudy:study
                          sensorName:SENSOR_PLUGIN_DEVICE_USAGE
                             storage:storage];
    if (self) {
        
    }
    return self;
}

- (void) createTable{
    if ([self isDebug]) {
        NSLog(@"[%@] Create Table", [self getSensorName]);
    }
    NSString *query = @"_id integer primary key autoincrement,"
    "timestamp real default 0,"
    "device_id text default '',"
    "elapsed_device_on real default 0,"
    "elapsed_device_off real default 0";
    [self.storage createDBTableOnServerWithQuery:query];
}

- (void)setParameters:(NSArray *)parameters{
    
}

- (BOOL)startSensor{
    if ([self isDebug]){
        NSLog(@"[%@] Start Device Usage Sensor", [self getSensorName]);
    }
    lastTime = [[[NSDate alloc] init] timeIntervalSince1970];
    
    [self registerAppforDetectDisplayStatus];
    [self setSensingState:YES];
    return YES;
}

- (BOOL)stopSensor{
    [self unregisterAppforDetectDisplayStatus];
    [self setSensingState:NO];
    return YES;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


- (void) registerAppforDetectDisplayStatus {
    
    NSString * head = @"com.apple.springboard";
    NSString * tail = @".lockstate";
    
    notify_register_dispatch((char *)[head stringByAppendingString:tail].UTF8String, &_notifyTokenForDidChangeLockStatus,dispatch_get_main_queue(), ^(int token) {
        
        NSNumber * unixtime = [AWAREUtils getUnixTimestamp:[NSDate new]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:unixtime forKey:@"timestamp"];
        [dict setObject:[self getDeviceId] forKey:@"device_id"];
        
        
        int awareScreenState = 0;
        double currentTime = [[NSDate date] timeIntervalSince1970];
        // https://github.com/denzilferreira/com.aware.plugin.device_usage
        double elapsedTime = (currentTime - self->lastTime) * 1000.0; // to convert millisecond
        self->lastTime = currentTime;
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        //  elapsed_device_off: (double) amount of time turned off (milliseconds)
        //  elapsed_device_on: (double) amount of time turned on (milliseconds)
        
        // when screen is ON
        if(state == 0) {
            awareScreenState = 0;
            [dict setObject:@(0)           forKey:@"elapsed_device_on"]; // real
            [dict setObject:@(elapsedTime) forKey:@"elapsed_device_off"]; // real
            if ([self isDebug]) {
                NSLog(@"screen off");
            }
        // when screen is OFF
        } else {
            awareScreenState = 1;
            [dict setObject:@(elapsedTime) forKey:@"elapsed_device_on"]; // real
            [dict setObject:@(0)           forKey:@"elapsed_device_off"]; // real
            if([self isDebug]){
                NSLog(@"screen on");
            }
        }
        
        [self setLatestValue:[NSString stringWithFormat:@"[%d] %f", awareScreenState, elapsedTime ]];
        // [self saveData:dict];
        [self.storage saveDataWithDictionary:dict buffer:NO saveInMainThread:NO];
        [self setLatestData:dict];
        
        SensorEventHandler handler = [self getSensorEventHandler];
        if (handler!=nil) {
            handler(self, dict);
        }
        
    });
}


- (void) unregisterAppforDetectDisplayStatus {
    //    notify_suspend(_notifyTokenForDidChangeDisplayStatus);
    /*
    uint32_t result = notify_cancel(_notifyTokenForDidChangeDisplayStatus);
    if (result == NOTIFY_STATUS_OK) {
        NSLog(@"[screen] OK ==> %d", result);
    } else {
        NSLog(@"[screen] NO ==> %d", result);
    }
    */
    
    //    notify_suspend(_notifyTokenForDidChangeLockStatus);
    uint32_t result = notify_cancel(_notifyTokenForDidChangeLockStatus);
    
    if (result == NOTIFY_STATUS_OK) {
        NSLog(@"[screen] OK --> %d", result);
    } else {
        NSLog(@"[screen] NO --> %d", result);
    }
}


/////////////////////////////////////////////////////////////




/////////////////////////////////////////////////////////////

-(NSString*)unixtime2str:(double)elapsedTime{
    NSString * strElapsedTime = @"";
    if( elapsedTime < 60){
        strElapsedTime = [NSString stringWithFormat:@"%d sec.", (int)elapsedTime];
    }else{ // 1min
        strElapsedTime = [NSString stringWithFormat:@"%d min.", (int)(elapsedTime/60)];
    }
    return strElapsedTime;
}

-(NSString*)nsdate2FormattedTime:(NSDate*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    // [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    [formatter setDateFormat:@"HH:mm:ss"];
    return [formatter stringFromDate:date];
}


@end
