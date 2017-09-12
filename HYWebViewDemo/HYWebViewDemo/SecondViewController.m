//
//  SecondViewController.m
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

#import "SecondViewController.h"
#import "HYWebView.h"

@interface SecondViewController ()<HYWebViewDelegate>

@property (nonatomic, strong) HYWebView *webView;

@property (nonatomic, copy) NSString *urlString;

@end

@implementation SecondViewController

- (HYWebView *)webView{
    if (!_webView) {
        CGRect bounds = self.view.bounds;
        bounds.size.height -= 64;
        _webView = [[HYWebView alloc] initWithFrame:bounds];
        _webView.delegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
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
    
    self.webView.backgroundColor = [UIColor whiteColor];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

#pragma mark - HYWebViewDelegate
- (BOOL)webView:(HYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request{

    NSString *url = request.URL.absoluteString;
    
    return YES;
}

- (void)webViewDidStartLoad:(HYWebView *)webView{
    NSLog(@"%s", __FUNCTION__);

}

- (void)webViewDidFinishLoad:(HYWebView *)webView{
    NSLog(@"%s", __FUNCTION__);

}

- (void)webView:(HYWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%s", __FUNCTION__);
}

- (void)webView:(HYWebView *)webView didUpdateProgress:(CGFloat)progress{
    NSLog(@"加载进度更新:%f", progress);

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
