#include "HelloWorldScene.h"
#include "SimpleAudioEngine.h"

#include "network/HttpClient.h"
#include "json/document.h"
#include "json/prettywriter.h"
#include "json/rapidjson.h"
#include "json/stringbuffer.h"

#include "NativeInterface.h"

#include "SimpleAudioEngine.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif

USING_NS_CC;

Scene* HelloWorld::createScene()
{
    return HelloWorld::create();
}

// Print useful error message instead of segfaulting when files are not there.
static void problemLoading(const char* filename)
{
    printf("Error while loading: %s\n", filename);
    printf("Depending on how you compiled you might have to add 'Resources/' in front of filenames in HelloWorldScene.cpp\n");
}

// on "init" you need to initialize your instance
bool HelloWorld::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Scene::init() )
    {
        return false;
    }
    
    auto visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    
    // RapidJSON example
    // JSON パースするやつ
    auto json = "{ \"hoge\" : \"foobar\" }";
    rapidjson::Document document;
    document.Parse<rapidjson::ParseFlag::kParseDefaultFlags>(json);
    rapidjson::Value& value = document["hoge"];
    CCLOG("@@ %s %s", value.GetString(), __FUNCTION__);
    
    // Convert std::string -> NSString
    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    value.Accept(writer);
    std::string str = buffer.GetString();
    NSString *nsStr = [NSString stringWithUTF8String:str.c_str()];
    auto jsonLabel = cocos2d::Label::createWithSystemFont([nsStr UTF8String], "Helvetica", 36);
    jsonLabel->setPosition(visibleSize / 2);
//    this->addChild(jsonLabel);
    
    // 毎秒実行
    this->schedule(schedule_selector(HelloWorld::post), 1.0f);


    /////////////////////////////
    // 2. add a menu item with "X" image, which is clicked to quit the program
    //    you may modify it.

    // add a "close" icon to exit the progress. it's an autorelease object
    auto closeItem = MenuItemImage::create(
                                           "CloseNormal.png",
                                           "CloseSelected.png",
                                           CC_CALLBACK_1(HelloWorld::menuCloseCallback, this));

    if (closeItem == nullptr ||
        closeItem->getContentSize().width <= 0 ||
        closeItem->getContentSize().height <= 0)
    {
        problemLoading("'CloseNormal.png' and 'CloseSelected.png'");
    }
    else
    {
        float x = origin.x + visibleSize.width - closeItem->getContentSize().width/2;
        float y = origin.y + closeItem->getContentSize().height/2;
        closeItem->setPosition(Vec2(x,y));
    }

    // create menu, it's an autorelease object
    auto menu = Menu::create(closeItem, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);

    /////////////////////////////
    // 3. add your codes below...

    // add a label shows "Hello World"
    // create and initialize a label

    auto label = Label::createWithTTF("Hello World", "fonts/Marker Felt.ttf", 24);
    if (label == nullptr)
    {
        problemLoading("'fonts/Marker Felt.ttf'");
    }
    else
    {
        // position the label on the center of the screen
        label->setPosition(Vec2(origin.x + visibleSize.width/2,
                                origin.y + visibleSize.height - label->getContentSize().height));

        // add the label as a child to this layer
        this->addChild(label, 1);
    }

    // add "HelloWorld" splash screen"
    /*
    auto sprite = Sprite::create("HelloWorld.png");
    if (sprite == nullptr)
    {
        problemLoading("'HelloWorld.png'");
    }
    else
    {
        // position the sprite on the center of the screen
        sprite->setPosition(Vec2(visibleSize.width/2 + origin.x, visibleSize.height/2 + origin.y));

        // add the sprite as a child to this layer
        this->addChild(sprite, 0);
    }
     */


    //メニュー
    auto labelBtnLabel = LabelTTF::create("しゃべるボタン", "Arial", 15);
    auto labelItem1 = MenuItemLabel::create(labelBtnLabel, CC_CALLBACK_0(HelloWorld::menuAction, this));
    auto menu2 = Menu::create(labelItem1,NULL);
    this->addChild(menu2);
    
    return true;
}

void HelloWorld::update(float dt)
{
    
}

void HelloWorld::setHeartBeats(float heartBeat)
{
    this->heart_beats = heartBeat;
}

void HelloWorld::post(float dt)
{
    CCLOG("@@ %s 実行", __FUNCTION__);
    
    const static std::string backend_url = "http://backend.cactacea.io/";
    
    // 友情パラメータ取得
    const static std::string friend_url = backend_url + "friend";
    
    // Azure結果保存
    const static std::string expressions_url = backend_url + "expressions";
    
    // 心拍数結果保存
    const static std::string hearts_url = backend_url + "hearts";
    
    // Azure感情解析
    const static std::string azure_url = "https://azure.microsoft.com/ja-jp/services/cognitive-services/emotion/";
    
    // POST
    auto request = new cocos2d::network::HttpRequest();
    
    auto setUrl = [request](std::string url)
    {
        request->setUrl(url.c_str());
        request->setRequestType(cocos2d::network::HttpRequest::Type::POST);
    };
    
    // 心拍数をPOSTする
    setUrl(hearts_url);
    
    auto postHeart = [request](float val)
    {
        // ヘッダの設定
        std::vector<std::string> headers;
        headers.push_back("Content-Type: application/json");
        request->setHeaders(headers);
        
        std::string requestJson = "{\"beat\":1.0}";//{\"beat\":" + std::to_string(val) + "}";
        CCLOG("@@ 心拍数: %s", requestJson.c_str());
        const char * jsonBuffer = requestJson.c_str();
        request->setRequestData(jsonBuffer, std::strlen(jsonBuffer));
    };
    
    postHeart(this->heart_beats);

    request->setResponseCallback([this](cocos2d::network::HttpClient* client, cocos2d::network::HttpResponse* response) {
        CCLOG("@@ ResponseCode:%ld %s", response->getResponseCode(), response->getHttpRequest()->getUrl());
        
        if (response->isSucceed())
        {
            // レスポンスの取得に成功したらここの処理
            std::vector<char> * buffer = response->getResponseData();
            std::string s;
            std::copy(buffer->begin(), buffer->end(), std::back_inserter(s));
            // レスポンスをログ表示
            CCLOG("@@ s: %s", s.c_str());
        }
    });
    // 送信してインスタンスは破棄
    auto client = cocos2d::network::HttpClient::getInstance();
    client->enableCookies(nullptr);
    client->send(request);
    // client->destroyInstance();
    
    
}

void HelloWorld::speech(){
    //なんかしゃべる
    cocos2dExt::NativeInterface::speech("あいうえお");
}

void HelloWorld::menuAction(){
    CCLOG("Hello!!");
    this->speech();
}

void HelloWorld::menuCloseCallback(Ref* pSender)
{
    //Close the cocos2d-x game scene and quit the application
    Director::getInstance()->end();

    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif

    /*To navigate back to native iOS screen(if present) without quitting the application  ,do not use Director::getInstance()->end() and exit(0) as given above,instead trigger a custom event created in RootViewController.mm as below*/

    //EventCustom customEndEvent("game_scene_close_event");
    //_eventDispatcher->dispatchEvent(&customEndEvent);


}
