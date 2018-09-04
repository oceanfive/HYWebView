//
//  HYWebView.h
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

/*
 @discussion
 
 js向oc调用方法/传递数据的方式：
 一、通过文档的位置发送新页面的请求document.location
    1、js处理：document.location = url （document.location.href = url）
    2、oc处理：拦截url请求，进行判断，并做相关的处理
        2.1、对于UIWebView
        - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
        2.2、对于WKWebView
        - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
 
 二、通过发送消息处理 window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
    1、js处理：window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
        name：方法的名称
        messageBody：传递的数据
    2、oc处理：
        2.1、对于UIWebView - ✘ 不能够使用
        2.2、对于WKWebView - 可以使用
            2.2.1、给WKWebView配置WKWebViewConfiguration属性的WKUserContentController中调用方法
            - (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
            2.2.2、实现代理WKScriptMessageHandler的代理方法
            - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
 
 
 oc调用js方法
 一、使用应封装好的方法：
    1、对于UIWebView
        - (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
    2、对于WKWebView
        - (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;
 二、使用JavaScriptCore框架
 
 
 oc和js的交互方法还可以使用第三方框架 WebViewJavascriptBridge
 
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HYWebView;
@class WKWebViewConfiguration;

@protocol HYWebViewDelegate <NSObject>

@optional

/**
 是否应当加载请求request
 */
- (BOOL)webView:(HYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request;

/**
 开始加载
 */
- (void)webViewDidStartLoad:(HYWebView *)webView;

/**
 加载完成
 */
- (void)webViewDidFinishLoad:(HYWebView *)webView;

/**
 加载失败
 */
- (void)webView:(HYWebView *)webView didFailLoadWithError:(NSError *)error;

/**
 加载进度
 */
- (void)webView:(HYWebView *)webView didUpdateProgress:(float)progress;

/**
 js调用oc方法

 @param webView HYWebView
 @param message js传递过来的消息内容
 @param name js调用的方法名称
 @param url 当前页面的url
 
 @discussion
 此代理方法针对初始化方法 - (instancetype)initWithFrame:(CGRect)frame scriptMessageHandlerNames:(NSArray *)names; 使用
 
 */
- (void)webView:(HYWebView *)webView didReceiveScriptMessage:(id)message name:(NSString *)name url:(NSURL *)url;

/**
 页面标题发生了变化
 */
- (void)webView:(HYWebView *)webView titleDidChanged:(NSString *)title;

@end

/**
 进度条位置
 */
typedef NS_ENUM(NSUInteger, HYWebViewProgressPosition) {
    HYWebViewProgressPositionNavigationBarBottomIn, //导航栏底部（进度条在导航栏内）- 默认
    HYWebViewProgressPositionNavigationBarBottomOut,    //导航栏外部（进度条在导航栏外）
    HYWebViewProgressPositionStatusBarTop,  //状态栏顶部
    HYWebViewProgressPositionStatusBarBottom,   //状态栏底部
};

@interface HYWebView : UIView

#pragma mark - init
/**
 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 初始化方法，通过js调用oc的方法名称

 @param frame frame
 @param names js调用oc的方法名称数组
 @return HYWebView
 
 @discussion
 此方法用于8.0之后使用
 
 */
- (instancetype)initWithFrame:(CGRect)frame scriptMessageHandlerNames:(NSArray<NSString *> *)names NS_AVAILABLE_IOS(8_0);

/**
 当使用WKWebView即8.0之后可以使用的方法

 @param frame frame
 @param configuration 配置信息
 @return HYWebView
 */
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);

/**
 代理
 */
@property (nonatomic, weak) id<HYWebViewDelegate> delegate;

/**
 对应的scrollView
 */
@property (nonatomic, readonly, strong) UIScrollView *scrollView;

#pragma mark - load
/**
 加载网页请求
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 加载HTML
 */
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

#pragma mark - 属性
/**
 页面title
 */
@property (nullable, nonatomic, readonly, copy) NSString *title;

/**
 页面url
 */
@property (nullable, nonatomic, readonly, copy) NSURL *URL;

/**
 是否正在加载中
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

/**
 预估进度
 */
@property (nonatomic, readonly) double estimatedProgress;

#pragma mark - 操作
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

- (void)goBack;
- (void)goForward;
- (void)reload;
//- (void)reloadFromOrigin;
- (void)stopLoading;

/**
 历史记录
 */
@property (nonatomic, readonly, assign) NSUInteger backForwardCount;

/**
 以当前位置为准，后退index个位置，超过范围backForwardCount无效
 */
- (void)goBack:(NSUInteger)index;

/**
 以当前位置为准，前进index个位置，超过范围backForwardCount无效
 */
- (void)goForward:(NSUInteger)index;

#pragma mark - oc调用js方法
/**
 和js交互方法

 @param javaScriptString js语句
 @param completionHandler 回调block
 result: 返回结果
 error: 错误信息
 
 */
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))completionHandler;

#pragma mark - progress

/**
 是否显示进度条，默认为YES
 */
@property (nonatomic, assign) BOOL isShowProgressView;

/**
 进度条位置，默认为HYWebViewProgressPositionNavigationBarBottomIn
 */
@property (nonatomic, assign) HYWebViewProgressPosition progressPosition;

/**
 进度，0.0-1.0，默认为0.0
 */
@property (nonatomic, assign) float progress;

/**
 进度颜色（已完成），默认为
 [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0]
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 轨道颜色 (未完成)，默认为[UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *trackColor;

@end

NS_ASSUME_NONNULL_END
