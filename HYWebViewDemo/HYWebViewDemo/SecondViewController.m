//
//  SecondViewController.m
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

#import "SecondViewController.h"
#import "HYWebView.h"
#import <WebKit/WebKit.h>

static NSUInteger kBackTag = 300;
static NSUInteger kForwardTag = 301;
static NSUInteger kHistoryTag = 302;

@interface SecondViewController ()<HYWebViewDelegate>

@property (nonatomic, strong) HYWebView *webView;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) WKWebViewConfiguration *wkWebViewConfiguration;

@end

@implementation SecondViewController

- (HYWebView *)webView{
    if (!_webView) {
        CGRect bounds = self.view.bounds;
        bounds.size.height -= 0;
//        _webView = [[HYWebView alloc] initWithFrame:bounds configuration:self.wkWebViewConfiguration];
        _webView = [[HYWebView alloc] initWithFrame:bounds scriptMessageHandlerNames:@[@"callJsAlert"]];
        _webView.delegate = self;
        _webView.progressPosition = HYWebViewProgressPositionNavigationBarBottomOut;
//        _webView.progressColor = [UIColor redColor];
//        _webView.trackColor = [UIColor blueColor];
        _webView.isShowProgressView = YES;
        [self.view addSubview:_webView];
    }
    return _webView;
}

#pragma mark - lazy
- (WKWebViewConfiguration *)wkWebViewConfiguration{
    if (!_wkWebViewConfiguration) {
        _wkWebViewConfiguration = [[WKWebViewConfiguration alloc] init];
        
        WKUserContentController *content = [[WKUserContentController alloc] init];
        [content addScriptMessageHandler:self name:@"alert"];
        
        _wkWebViewConfiguration.userContentController = content;
    }
    return _wkWebViewConfiguration;
}

- (instancetype)initWithUrl:(NSString *)urlString{
    self = [super init];
    if (self) {
        self.urlString = [NSString stringWithFormat:@"%@", urlString];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.backgroundColor = [UIColor purpleColor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Test.html" withExtension:nil];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.backgroundColor = [UIColor orangeColor];
    [myButton setTitle:@"back" forState:UIControlStateNormal];
    [myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    myButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [myButton addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myButton];
    myButton.tag = kBackTag;
    myButton.frame = CGRectMake(300, 200, 100, 50);
    
    
    UIButton *myButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton2.backgroundColor = [UIColor orangeColor];
    [myButton2 setTitle:@"forward" forState:UIControlStateNormal];
    [myButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    myButton2.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [myButton2 addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myButton2];
    myButton2.tag = kForwardTag;
    myButton2.frame = CGRectMake(300, 270, 100, 50);
    
    UIButton *myButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton3.backgroundColor = [UIColor orangeColor];
    [myButton3 setTitle:@"history" forState:UIControlStateNormal];
    [myButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    myButton3.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [myButton3 addTarget:self action:@selector(myButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myButton3];
    myButton3.tag = kHistoryTag;
    myButton3.frame = CGRectMake(300, 350, 100, 50);
    
//    CGRect frame = CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 5);
//    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
//    progressView.progressViewStyle = UIProgressViewStyleBar;
//    progressView.progress = 0.5;
//    progressView.progressTintColor = [UIColor redColor];
//    progressView.trackTintColor = [UIColor whiteColor];
//    [self.view addSubview:progressView];
//    self.progressView = progressView;
    
    /*
     @property(nonatomic) float progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.
     @property(nonatomic, strong, nullable) UIColor* progressTintColor  NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
     @property(nonatomic, strong, nullable) UIColor* trackTintColor     NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
     @property(nonatomic, strong, nullable) UIImage* progressImage      NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
     @property(nonatomic, strong, nullable) UIImage* trackImage         NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
     
     - (void)setProgress:(float)progress animated:(BOOL)animated NS_AVAILABLE_IOS(5_0);
     */
    
}

- (void)myButtonClick:(UIButton *)button{
    
    /*
     document.title 返回当前文档的标题
     document.URL 返回当前文档的 URL
     document.referrer 返回载入当前文档的文档的 URL （第一次载入返回空，标识当前页面是由哪个url点击进入的）
     document.lastModified 返回文档被最后修改的日期和时间
     document.domain 返回当前文档的域名
     document.cookie 设置或返回与当前文档有关的所有 cookie
     
     window----
     window.closed 返回窗口是否已被关闭
     window.defaultStatus='sometext' 设置或返回窗口状态栏中的默认文本
     
     
     history----
     history.length 浏览器历史列表中的元素数量
     history.back() 加载历史列表中的前一个 URL（如果存在） - 等价于 history.go(-1)
     history.forward() 加载历史列表中的下一个 URL - 等价于 history.go(1)
     history.go() 加载历史列表中的某个具体的页面 - history.go(number|URL) 相对于当前的位置或具体的url
     
     Location---- URL
     location.href 设置或返回完整的 URL
     location.protocol 设置或返回当前 URL 的协议
     location.hostname 设置或返回当前 URL 的主机名
     location.port 设置或返回当前 URL 的端口号
     location.pathname 设置或返回当前 URL 的路径部分
     location.search 设置或返回从问号 (?) 开始的 URL（查询部分）
     location.hash 设置或返回从井号 (#) 开始的 URL（锚）
     location.host 设置或返回主机名和当前 URL 的端口号
     */
    
    
    if (button.tag == kBackTag) {

//        [self.webView goBack:1];
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }
        
    } else if (button.tag == kForwardTag) {
        
//        [self.webView goForward:1];
        if ([self.webView canGoForward]) {
            [self.webView goForward];
        }
        
    } else if (button.tag == kHistoryTag) {
        
//        NSString *js = @"location.port";
//        [self.webView evaluateJavaScript:js completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
//            
//            NSLog(@"%@", result);
//            
//        }];
        
//        [self.webView goForward:2];
        
        
        [self.webView evaluateJavaScript:@"show(123456)" completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"OC调用JS方法成功:%@", result);
            } else {
                NSLog(@"OC调用JS方法失败-----%@", error);
            }
        }];
     
    }
    
}

#pragma mark - HYWebViewDelegate
- (BOOL)webView:(HYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request{

    NSString *url = request.URL.absoluteString;
    NSLog(@"%@", url);
    
    return YES;
}

- (void)webViewDidStartLoad:(HYWebView *)webView{
    NSLog(@"%s", __FUNCTION__);

}

- (void)webViewDidFinishLoad:(HYWebView *)webView{
    NSLog(@"%s", __FUNCTION__);

//    NSLog(@"%ld", webView.backForwardCount);
}

- (void)webView:(HYWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%s", __FUNCTION__);
    
}

- (void)webView:(HYWebView *)webView didUpdateProgress:(float)progress{
    NSLog(@"加载进度更新:%f", progress);

}

- (void)webView:(HYWebView *)webView didReceiveScriptMessage:(id)message name:(NSString *)name url:(NSURL *)url{
    NSLog(@"name:%@", name);
    NSLog(@"message:%@", message);
    NSLog(@"url:%@", url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
