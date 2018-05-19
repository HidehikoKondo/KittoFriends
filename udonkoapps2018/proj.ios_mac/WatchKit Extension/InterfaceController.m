//
//  InterfaceController.m
//  WatchKit Extension
//
//  Created by UDONKONET on 2018/03/10.
//

#import "InterfaceController.h"


@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    NSLog(@"objective-c");
    // Configure interface objects here.
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}



//ボタンをタップで通知
-(IBAction)heartbeatHigh:(id)sender{
    NSLog(@"心拍数HIGH");
    [self submit:@"HIGH"];
}

-(IBAction)heartbeatLow:(id)sender{
    NSLog(@"心拍数LOW");
    [self submit:@"LOW"];
}


-(void)submit:(NSString *)message{
    NSDictionary *applicationDict = @{@"message" : message};
    [[WCSession defaultSession] updateApplicationContext:applicationDict error:nil];
    
    
    if ([[WCSession defaultSession] isReachable]) {
        NSLog(@"繋がった");
        [[WCSession defaultSession] sendMessage:applicationDict
                                   replyHandler:^(NSDictionary *replyHandler) {
                                       // do something
                                       NSLog(@"送った/ %@",message);
                                   }
                                   errorHandler:^(NSError *error) {
                                       // do something
                                       NSLog(@"送れなかった・・・orz");
                                   }
         ];
    }else{
        NSLog(@"つながってないよ");
    }
}



@end



