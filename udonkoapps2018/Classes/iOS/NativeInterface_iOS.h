//
//  NativeInterface_iOS.h
//  JankenPon
//
//  Created by OhsakaTakashi on 2015/01/11.
//
//

#import <Foundation/Foundation.h>
#include "cocos2d.h"

#import <CoreLocation/CoreLocation.h>
@interface CompassViewController : UIViewController
<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@end


@interface NativeInterface_iOS

//Watchから文字を受け取る
+ (void) getTextFromWatch:(NSString *) text;

//Watchへ文字を送る
+ (void) putTextToWatch:(std::string) text;

//コンパス
+ (cocos2d::Point) getCompass;

//読み上げてるメソッド
+ (void)speech:(NSString *)message;

@end
