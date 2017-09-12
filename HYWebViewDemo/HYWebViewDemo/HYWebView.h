//
//  HYWebView.h
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HYWebView;

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
- (void)webView:(HYWebView *)webView didUpdateProgress:(CGFloat)progress;

@end

@interface HYWebView : UIView

#pragma mark - init
/**
 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame;

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
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
