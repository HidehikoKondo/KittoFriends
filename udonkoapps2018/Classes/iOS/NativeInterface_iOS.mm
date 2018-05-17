//
//  NativeInterface_iOS.mm
//  JankenPon
//
//  Created by OhsakaTakashi on 2015/01/11.
//
//

#include "NativeInterface_iOS.h"
#include "NativeInterface.h"

#import "AppController.h"
#import "RootViewController.h"


@interface NativeInterface_iOS()
@end


@implementation NativeInterface_iOS

//Watchから文字を受け取る
+ (void) getTextFromWatch:(NSString *) text
{
    cocos2dExt::NativeInterface::getTextFromWatch([text UTF8String]);
}


//Watchへ文字を送る
+ (void) putTextToWatch:(std::string) text
{
    AppController *appController = (AppController *)[UIApplication sharedApplication].delegate;
    if (appController)
    {
        NSLog(@"--- cocos -> appcontroller ---");
        NSLog([NSString stringWithUTF8String:text.c_str()]);

        //TODO:
        [appController sendMessageForWatch:[NSString stringWithUTF8String:text.c_str()]];
    }
}


//コンパス
+ (cocos2d::Point) getCompass
{
    cocos2d::Point pos = cocos2d::Point::ZERO;

    RootViewController * rootviewController = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootviewController)
    {
//        pos.x = rootviewController.compasslocation.x;
//        pos.y = rootviewController.compasslocation.y;
    }

    return pos;
}

//読み上げてるメソッド
+ (void)speech:(NSString *)message
{
    AppController *appController = (AppController *)[UIApplication sharedApplication].delegate;
    if (appController)
    {
        [appController speech:message];
    }
}

@end
