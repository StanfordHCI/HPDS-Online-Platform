//
//  GoogleLogin.h
//  AWARE
//
//  Created by Yuuki Nishiyama on 1/6/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//

/**
 0. Add URL scheme to your project. Please chekc more detail information below.
    https://developers.google.com/identity/sign-in/ios/start-integrating
 
 1. Please implement the following method to "AppDelegate.m"
 - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
 }
 
 2. Please make an UI  https://developers.google.com/identity/sign-in/ios/sign-in
    or
    Use AWAREGoogleLoginViewController. For using it, you have to connect a GoogleLogin instance the ViewController before.
 
    GoogleLogin * login = [[GoogleLogin alloc] initWithAwareStudy:[AWAREStudy sharedStudy] dbType:AwareDBTypeJSON clientId:@"Your client ID"];
    [login startSensor];
    if([login isNeedLogin]){
        AWAREGoogleLoginViewController * loginViewController = [[AWAREGoogleLoginViewController alloc] init];
        loginViewController.googleLogin = login;
        [self presentViewController:loginViewController animated:YES completion:^{
            NSLog(@"done");
        }];
    }
 
    // You can hadle an event that account information is saved by Observer (The name is ACTION_AWARE_GOOGLE_LOGIN_SUCCESS).
    [[NSNotificationCenter defaultCenter] addObserverForName:ACTION_AWARE_GOOGLE_LOGIN_SUCCESS object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"hello");
    }];

 */


#import "AWARESensor.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface GoogleLogin : AWARESensor <AWARESensorDelegate>

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithAwareStudy:(AWAREStudy * _Nullable)study
                            dbType:(AwareDBType)dbType
                          clientId:(NSString * _Nullable) clientId;

- (void) setClientId:(NSString *) clientId;

- (BOOL) isNeedLogin;

- (void) setGoogleAccountWithUserName:(NSString *)name
                                email:(NSString *)email
                          phonenumber:(NSString *)phonenumber
                              picture:(NSData * __nullable) picture;

+ (void) deleteGoogleAccountFromLocalStorage;
+ (NSString *) getUserName;
+ (NSString *) getEmail;
+ (NSString *) getPhonenumber;
+ (NSData   *) getPicture;

+ (void) setUserNameEncryption:(BOOL)state;
+ (void) setEmailEncryption:(BOOL)state;
+ (void) setPhonenumberEncryption:(BOOL)state;

NS_ASSUME_NONNULL_END

@end
