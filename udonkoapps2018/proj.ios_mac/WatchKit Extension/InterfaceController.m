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
    //[self submit:@"SWING"];
}

-(IBAction)heartbeatLow:(id)sender{
    NSLog(@"心拍数LOW");
    //[self submit:@"SWING"];
}

@end



