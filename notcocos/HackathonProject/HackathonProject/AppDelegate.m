//
//  AppDelegate.m
//  HackathonProject
//
//  Created by UDONKONET on 2017/05/14.
//  Copyright © 2017年 UDONKONET. All rights reserved.
//

#import "AppDelegate.h"
#import <MEMELib/MEMELib.h>
#import "AFNetworking.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

float heartBeats = 0;

NSTimer *_timer = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSString *url = @"http://backend.cactacea.io/friend";
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:url parameters:nil progress:nil   // GETがPOSTに paramatersがnilからjsonに変わった
             success:^(NSURLSessionTask *task, id responseObject) {
                 // GETに成功した場合の処理
                 NSLog(@"友達レベル %@", [responseObject valueForKey:@"value"]);
             } failure:^(NSURLSessionTask *operation, NSError *error) {
                 // エラーの場合の処理
                 NSLog(@"失敗");
             }
         ];
        
    }];
    
    //Watchとのセッション確立
    if ([WCSession isSupported]) {
        NSLog(@"通った？");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    

    //MEME セットアップ
    [MEMELib setAppClientId:APPCLIENDID clientSecret:CLIENTSECRET];
    
    //TODO:自動再接続の設定を有効にするかどうか要検討。アプリの性質上向こうで良い気がする。
    // 自動再接続設定
    [[MEMELib sharedInstance] setAutoConnect:NO];
    
    /*
     瞬きの状態
     status : normal caution dangerの状態が入る
     blinkcount : １分間ごとの瞬きの回数
     cautiondatetime : cautionの状態になってからの経過時間
     */
    _blinkStatus = [NSMutableDictionary dictionary];
    
    //delegate変数の初期化
    //テストデータ（MEMEに接続しなくても使えるように）
    MEMERealTimeData *testData = [[MEMERealTimeData alloc]init];
    testData.accX = -14;
    testData.accY = -5;
    testData.accZ = -6;
    testData.blinkSpeed = 0;
    testData.blinkStrength = 0;
    testData.eyeMoveDown = 0;
    testData.eyeMoveLeft = 0;
    testData.eyeMoveRight = 0;
    testData.eyeMoveUp = 0;
    testData.fitError = 0;
    testData.isWalking = 0;
    testData.pitch = 22.66;
    testData.powerLeft = 5;
    testData.roll = 64.45;
    testData.yaw = 247.4;
    
    _memeValue = testData;
    

    return YES;
}

// Interactive Message
//メッセージ受信
- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * __nonnull))replyHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog( [NSString stringWithFormat:@"%s: %@", __func__, message]);
        //[NativeInterface_iOS getTextFromWatch: [message objectForKey:@"message"]];
        
    });
    
    replyHandler(@{@"reply" : @"OK"});
    
    NSLog(@"%@",message);
    
    int i = rand()%10 + 1;
    
    
    if( [[message objectForKey:@"message"] isEqualToString:@"HIGH"]){
        NSLog(@"%f", 100.0f + i);
        heartBeats = 100.0f + i;
    }else if( [[message objectForKey:@"message"] isEqualToString:@"HIGH"]){
        NSLog(@"%f", 70.0f + i);
        heartBeats = 70.0f + i;
    }
    
    if( [[message objectForKey:@"message"] isEqualToString:@"GOOD"]){
         [(ViewController *)self.window.rootViewController good];
    } else if( [[message objectForKey:@"message"] isEqualToString:@"BAD"]){
        [(ViewController *)self.window.rootViewController bad];
    } else if( [[message objectForKey:@"message"] isEqualToString:@"STOP"]){
        [(ViewController *)self.window.rootViewController stop];
    }

    
    NSDictionary *json = @{@"beat": [NSNumber numberWithFloat:heartBeats]};
    NSString *url = @"http://backend.cactacea.io/hearts";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager POST:url parameters:json progress:nil   // GETがPOSTに paramatersがnilからjsonに変わった
          success:^(NSURLSessionTask *task, id responseObject) {
              // POSTに成功した場合の処理
              NSLog(@"成功");
          } failure:^(NSURLSessionTask *operation, NSError *error) {
              // エラーの場合の処理
              NSLog(@"失敗");
          }
     ];

    
    //[self speech:@"寝たら死ぬぞ"];
   // [self sendMessageForWatch: @"123"];
}


//メッセージ送信 watchへ
- (void)sendMessageForWatch:(NSString *)message {
    NSLog(@"----sendMessageForWatch----");
    NSLog(message);
    
    
    if ([[WCSession defaultSession] isReachable])
    {
        [[WCSession defaultSession] sendMessage:@{@"message":[NSString stringWithFormat:message]}
                                   replyHandler:^(NSDictionary *replyHandler) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           //[self.resultLabel setText:[NSString stringWithFormat:@"replyHandler = %@", replyHandler]];
                                           NSLog(@"-- app -> watch OK!! ---");
                                           NSLog([NSString stringWithFormat:@"replyHandler = %@", replyHandler]);
                                       });
                                   }
                                   errorHandler:^(NSError *error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSLog(@"-- app -> watch NG!! ---");
                                       });
                                   }
         ];
    }
}







-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
    
    //送られてきたdictionaryのデータを取り出す
    NSString *message = [userInfo objectForKey:@"message"];
    
    //WatchAppに返すデータを作成
    NSDictionary *applicationData = @{@"reply":@"ダイアログを表示しました"};
    reply(applicationData);
    
    
    //アラート表示
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Message"
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         
                                                         
                                                     }
                               ];
    [ac addAction:okAction];
    [self.window.rootViewController presentViewController:ac animated:YES completion:nil];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
