//
//  NativeInterface.mm
//  JankenPon
//
//  Created by OhsakaTakashi on 2015/01/11.
//
//

#include "NativeInterface.h"

#import "NativeInterface_iOS.h"

#include "cocos2d.h"

#include "PrivateConfig.h"


namespace cocos2dExt
{
    //Watchから文字を受け取る
    void NativeInterface::getTextFromWatch(const std::string &text)
    {
        //イベントでわたしてみる (必要なとこで受け取る)
        auto event = cocos2d::EventCustom(EVENT_NAME__TEXTFROMWATCH);

        auto data = cocos2d::Value(text);
        event.setUserData(&data);

        cocos2d::Director::getInstance()->getEventDispatcher()->dispatchEvent(&event);
    }

    void NativeInterface::putTextToWatch(const std::string &text)
    {
        [NativeInterface_iOS putTextToWatch:text];
    }

    //コンパス
    cocos2d::Point NativeInterface::getCompass()
    {
        auto pos = [NativeInterface_iOS getCompass];
        return pos;
    }

    //読み上げてるメソッド
    void NativeInterface::speech(const std::string &message)
    {
        [NativeInterface_iOS speech:[NSString stringWithUTF8String:message.c_str()]];
    }
};
