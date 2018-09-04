//
//  HYWebView.m
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

#import "HYWebView.h"
#import <WebKit/WebKit.h>
#import <WebKit/WKWebView.h>
#import <JavaScriptCore/JavaScriptCore.h>

#define kKVOPropertyTitle @"title"
#define kKVOPropertyURL @"URL"
#define kKVOPropertyLoading @"loading"
#define kKVOPropertyEstimatedProgress @"estimatedProgress"

#define kStatusBarHeight 20.0
#define kNavigationBarHeight 44.0
#define kTabBarHeight 49.0

#define is_iPhoneX CGSizeEqualToSize(CGSizeMake(375, 812), [[UIScreen mainScreen] bounds].size)
#define iPhoneXTabBarAddHeight 34
#define iPhoneXStatusBarAddHeight 24
#define kSafeStatusBarHeight (is_iPhoneX ? (kStatusBarHeight + iPhoneXStatusBarAddHeight) : kStatusBarHeight)
#define kSafeTabBarHeight (is_iPhoneX ? (kTabBarHeight + iPhoneXTabBarAddHeight) : kTabBarHeight)
#define kSafeNavigationBarHeight kNavigationBarHeight

@interface HYWebView ()<UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) WKWebViewConfiguration *wkWebViewConfiguration;

@property (nonatomic, strong) UIWebView *uiWebView;

@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSArray *messageNames;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) float progressHeight; //设置无效，默认为2

@end

@implementation HYWebView

#pragma mark - helper
- (BOOL)isiOS8Later {
    return NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0;
}

- (UIViewController *)findVC {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - lazy
- (WKWebViewConfiguration *)wkWebViewConfiguration {
    if (!_wkWebViewConfiguration) {
        _wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
    }
    return _wkWebViewConfiguration;
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if ([self isiOS8Later]) {
            [self initWKWebViewWithFrame:frame configuration:self.wkWebViewConfiguration];
        } else {
            [self initUIWebViewWithFrame:frame];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame scriptMessageHandlerNames:(NSArray<NSString *> *)names {
    self = [super initWithFrame:frame];
    if (self) {
        if ([self isiOS8Later]) {
            WKUserContentController *content = [[WKUserContentController alloc] init];
            for (NSString *name in names) {
                [content addScriptMessageHandler:self name:name];
            }
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            configuration.userContentController = content;
            [self initWKWebViewWithFrame:frame configuration:configuration];
        } else {
            self.messageNames = names;
            [self initUIWebViewWithFrame:frame];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame];
    if (self) {
        if ([self isiOS8Later]) {
            [self initWKWebViewWithFrame:frame configuration:configuration];
        } else {
            [self initUIWebViewWithFrame:frame];
        }
    }
    return self;
}

- (void)initWKWebViewWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    [self initWKWebViewKVO];
    [self addSubview:self.wkWebView];
    [self initProgressView];
}

- (void)initUIWebViewWithFrame:(CGRect)frame {
    self.uiWebView = [[UIWebView alloc] initWithFrame:frame];
    self.uiWebView.delegate = self;
    self.uiWebView.scalesPageToFit = YES;
    self.uiWebView.autoresizesSubviews = YES;
    self.uiWebView.opaque = NO;
    [self addSubview:self.uiWebView];
    [self initProgressView];
}

- (void)initProgressView {
    [self initProgressViewSetup];
    self.isShowProgressView = YES;
    self.progressPosition = HYWebViewProgressPositionNavigationBarBottomIn;
    self.progressHeight = 2.0f;
    self.progress = 0.0;
    self.progressColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0];
    self.trackColor = [UIColor clearColor];
}

- (void)initProgressViewSetup {
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.backgroundColor = [UIColor clearColor];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.progressView];
    [keyWindow bringSubviewToFront:self.progressView];
}

- (void)resetProgressView {
    if (self.progressView) {
        [self.progressView removeFromSuperview];
        self.progress = 0.0;
    }
    [self initProgressViewSetup];
    [self resetProgressViewProperty];
    [self setNeedsLayout]; //旧的已被销毁，新的需要重新布局
}

- (void)resetProgressViewProperty {
    self.progressView.progress = self.progress;
    self.progressView.progressTintColor = self.progressColor;
    self.progressView.trackTintColor = self.trackColor;
}

#pragma mark - KVO
- (void)initWKWebViewKVO {
    [self.wkWebView addObserver:self forKeyPath:kKVOPropertyTitle options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:kKVOPropertyLoading options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:kKVOPropertyURL options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:kKVOPropertyEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id newValue = [change objectForKey:NSKeyValueChangeNewKey];
    if ([keyPath isEqualToString:kKVOPropertyTitle]) {
        _title = (NSString *)newValue;
        [self _titleDidChanged];
    } else if ([keyPath isEqualToString:kKVOPropertyLoading]) {
        _loading = [(NSNumber *)newValue boolValue];
    } else if ([keyPath isEqualToString:kKVOPropertyURL]) {
        _URL = (NSURL *)newValue;
    } else if ([keyPath isEqualToString:kKVOPropertyEstimatedProgress]) {
        _estimatedProgress = [(NSNumber *)newValue floatValue];
        [self _didUpdateProgress:_estimatedProgress];
        /*
         加载失败的情况下，_estimatedProgress的值也会为1.0
         */
    }
}

#pragma mark - load
- (void)loadRequest:(NSURLRequest *)request {
    if ([self isiOS8Later]) {
        [self.wkWebView loadRequest:request];
    } else {
        [self.uiWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    if ([self isiOS8Later]) {
        [self.wkWebView loadHTMLString:string baseURL:baseURL];
    } else {
        [self.uiWebView loadHTMLString:string baseURL:baseURL];
    }
}

#pragma mark - getter
- (UIScrollView *)scrollView {
    if ([self isiOS8Later]) {
        return self.wkWebView.scrollView;
    } else {
        return self.uiWebView.scrollView;
    }
}

#pragma mark - setter

#pragma mark - 操作
- (BOOL)canGoBack {
    if ([self isiOS8Later]) {
        return [self.wkWebView canGoBack];
    } else {
        return [self.uiWebView canGoBack];
    }
}

- (BOOL)canGoForward {
    if ([self isiOS8Later]) {
        return [self.wkWebView canGoForward];
    } else {
        return [self.uiWebView canGoForward];
    }
}

- (void)goBack {
    if ([self isiOS8Later]) {
        [self.wkWebView goBack];
    } else {
        [self.uiWebView goBack];
    }
}

- (void)goForward {
    if ([self isiOS8Later]) {
        [self.wkWebView goForward];
    } else {
        [self.uiWebView goForward];
    }
}

- (void)reload {
    if ([self isiOS8Later]) {
        [self.wkWebView reload];
    } else {
        [self.uiWebView reload];
    }
}

- (void)stopLoading {
    if ([self isiOS8Later]) {
        [self.wkWebView stopLoading];
    } else {
        [self.uiWebView stopLoading];
    }
}

- (void)goBack:(NSUInteger)index {
    NSString *js = [NSString stringWithFormat:@"history.go(-%ld)", index];
    [self evaluateJavaScript:js completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        
    }];
}

- (void)goForward:(NSUInteger)index {
    NSString *js = [NSString stringWithFormat:@"history.go(%ld)", index];
    [self evaluateJavaScript:js completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
        
    }];
}

- (void)handlerHistory {
    if ([self isiOS8Later]) {
        _backForwardCount = self.wkWebView.backForwardList.backList.count + self.wkWebView.backForwardList.forwardList.count + 1;
    } else {
        _backForwardCount = [[self.uiWebView stringByEvaluatingJavaScriptFromString:@"history.length"] integerValue];
    }
}

#pragma mark - oc call js
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))completionHandler{
    if ([self isiOS8Later]) {
        [self.wkWebView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable res, NSError * _Nullable err) {
            if (completionHandler) {
                completionHandler(res, err);
            }
        }];
    } else {
        NSString *res = [self.uiWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(res, nil);
        }
        //        if (self.jsContext) {
        //            JSValue *value = [self.jsContext evaluateScript:javaScriptString];
        //
        //        } else {
        //
        //        }
    }
}

#pragma mark - 代理回调

- (void)_titleDidChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:titleDidChanged:)]) {
        [self.delegate webView:self titleDidChanged:_title];
    }
}

- (BOOL)_shouldStartLoadWithRequest:(NSURLRequest *)request {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:)]) {
        return [self.delegate webView:self shouldStartLoadWithRequest:request];
    }
    return YES;
}

- (void)_didStartLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:self];
    }
    //estimatedProgress属性值变化(先)和代理方法didCommitNavigation(后)不同步执行
    if (![self isiOS8Later]) {
        [self _didUpdateProgress:0.0];
    }
}

- (void)_didFinishLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:self];
    }
    [self handlerHistory];
    [self _didUpdateProgress:1.0];
}

- (void)_didFailLoadWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:self didFailLoadWithError:error];
    }
    [self _didUpdateProgress:0.0];
}

- (void)_didUpdateProgress:(float)progress {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didUpdateProgress:)]) {
        [self.delegate webView:self didUpdateProgress:progress];
    }
    self.progress = progress;
    if (self.progress >= 1.0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self resetProgressView];
        });
    }
}

#pragma mark - WKNavigationDelegate
//1、请求发送之前，决定是否发送请求
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self _shouldStartLoadWithRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

//2、开始发送请求 （当targetFrame是isMainFrame的时候才会调用???，页面内点击跳转是不会走这个方法的）
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

//3、请求成功；请求获得响应之后，确定是否加载页面(请求成功)
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

//3、请求失败（WKNavigationResponsePolicyCancel的时候也会调用，相当于请求失败了）
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self _didFailLoadWithError:error];
}

//4、开始加载页面（WKNavigationResponsePolicyAllow的时候调用）
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self _didStartLoad];
}

//5、页面加载完成（成功的时候调用）
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self _didFinishLoad];
}

//5、页面加载失败（失败的时候调用）
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)errorP {
    [self _didFailLoadWithError:errorP];
}

//其他:重定向访问url
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
    
}

//其他:授权验证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
//    NSLog(@"%s",__FUNCTION__);
//
//    completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
//}

//其他:webView处理内容的发生中断的时候调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"webViewWebContentProcessDidTerminate"}];
    [self _didFailLoadWithError:error];
}

#pragma mark - WKUIDelegate


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self _shouldStartLoadWithRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _loading = YES;
    [self _didStartLoad];
    //产生 10-50的随机数
    int random = (int)(10 + (arc4random() % ((50 - 10 + 1))));
    _estimatedProgress = random / 100.0f;
    [self _didUpdateProgress:_estimatedProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _loading = NO;
    _title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _URL = webView.request.URL;
    [self handlerJSCallOCWithWebView:webView];
    [self _didFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _loading = NO;
    [self _didFailLoadWithError:error];
}

- (void)handlerJSCallOCWithWebView:(UIWebView *)webView {
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    __weak typeof(self) wself = self;
    //    for (NSString *name in self.messageNames) {
    //        self.jsContext[name] = ^(id parameters) {
    //            JSContext *currentContext = [JSContext currentContext];
    //            JSValue *callee = [JSContext currentCallee];
    //            JSValue *this = [JSContext currentThis];
    //            NSArray *arguments = [JSContext currentArguments];
    //            JSValue *globalObject = wself.jsContext.globalObject;
    //            JSValue *exception = wself.jsContext.exception;
    //
    //            if (wself.delegate && [wself respondsToSelector:@selector(webView:didReceiveScriptMessage:name:url:)]) {
    //
    //            }
    //        };
    //    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:didReceiveScriptMessage:name:url:)]) {
        [self.delegate webView:self didReceiveScriptMessage:message.body name:message.name url:message.frameInfo.request.URL];
    }
}

#pragma mark - progress
- (void)setIsShowProgressView:(BOOL)isShowProgressView {
    _isShowProgressView = isShowProgressView;
    [self setNeedsLayout];
}

- (void)setProgressPosition:(HYWebViewProgressPosition)progressPosition {
    _progressPosition = progressPosition;
    [self setNeedsLayout];
}

- (void)setProgressHeight:(float)progressHeight {
    _progressHeight = progressHeight;
    [self setNeedsLayout];
}

- (void)setProgress:(float)progress {
    if (progress > 1.0) progress = 1.0;
    if (progress < 0.0) progress = 0.0;
    //"增加"的进度才有动画效果，"减少"的进度会从新加载，比如一个页面还没有加载完成又重新打开了一个网页
    BOOL animated = progress >= _progress;
    if (!animated) progress = 0.0;
    _progress = progress;
    [self.progressView setProgress:progress animated:animated];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.progressView.progressTintColor = progressColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    self.progressView.trackTintColor = trackColor;
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isShowProgressView) {
        CGFloat statusAndNavigationBarHeight = kSafeStatusBarHeight + kSafeNavigationBarHeight;
        UIViewController *vc = [self findVC];
        if (vc) {
            CGRect frame = vc.navigationController.navigationBar.frame;
            statusAndNavigationBarHeight = frame.origin.y + frame.size.height;
        }
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGRect frame = CGRectMake(0, statusAndNavigationBarHeight, width, self.progressHeight);
        switch (self.progressPosition) {
            case HYWebViewProgressPositionNavigationBarBottomIn: {
                frame = CGRectMake(0, statusAndNavigationBarHeight - 2, width, self.progressHeight);
            }   break;
                
            case HYWebViewProgressPositionNavigationBarBottomOut: {
                frame = CGRectMake(0, statusAndNavigationBarHeight, width, self.progressHeight);
            }   break;
                
            case HYWebViewProgressPositionStatusBarTop: {
                frame = CGRectMake(0, is_iPhoneX ? iPhoneXStatusBarAddHeight : 0, width, self.progressHeight);
            }   break;
                
            case HYWebViewProgressPositionStatusBarBottom: {
                frame = CGRectMake(0, kSafeStatusBarHeight, width, self.progressHeight);
            }   break;
                
            default:
                break;
        }
        self.progressView.frame = frame;
    } else {
        if (self.progressView) {
            [self.progressView removeFromSuperview];
        }
    }
}

#pragma mark - dealloc
- (void)dealloc{
    if ([self isiOS8Later]) {
        [self.wkWebView removeObserver:self forKeyPath:kKVOPropertyTitle];
        [self.wkWebView removeObserver:self forKeyPath:kKVOPropertyLoading];
        [self.wkWebView removeObserver:self forKeyPath:kKVOPropertyURL];
        [self.wkWebView removeObserver:self forKeyPath:kKVOPropertyEstimatedProgress];
        self.wkWebView.UIDelegate = nil;
        self.wkWebView.navigationDelegate = nil;
        [self.wkWebView stopLoading];
        [self.wkWebView removeFromSuperview];
        self.wkWebView = nil;
    } else {
        self.uiWebView.delegate = nil;
        [self.uiWebView stopLoading];
        [self.uiWebView removeFromSuperview];
        self.uiWebView = nil;
    }
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

@end
