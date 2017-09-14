//
//  OneViewController.m
//  HYWebViewDemo
//
//  Created by ocean on 2017/9/12.
//  Copyright © 2017年 ocean. All rights reserved.
//

#import "OneViewController.h"
#import "SecondViewController.h"


@interface OneViewController ()


@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSString *url = @"http://test.haiziguo.cn/h5_reports/everyDayReport/dailyHealthyReport.html?childId=174350&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJoYWl6aWd1byIsImpzb25TdHIiOiJ7XCJleHB0aW1lXCI6bnVsbCxcIm9yZ0lEXCI6XCIxMDI2M1wiLFwic2Vzc2lvbklEXCI6XCJcIixcInVzZXJJRFwiOlwiMTk4MzEyXCJ9IiwiaXNzIjoiYXBwIiwiZXhwIjoxNTA1MjAxNTM5LCJpYXQiOjE1MDUxOTQzMzl9.5_XzrNNT0JTsE-mYkVCbzfbbRq1_3Fhsy-J47iAhCVQ&time=1505194355970";
//    NSString *url = @"http://test.haiziguo.cn/physique/phone/tzcs_bg.html?childId=174350&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJoYWl6aWd1byIsImpzb25TdHIiOiJ7XCJleHB0aW1lXCI6bnVsbCxcIm9yZ0lEXCI6XCIxMDI2M1wiLFwic2Vzc2lvbklEXCI6XCJcIixcInVzZXJJRFwiOlwiMTk4MzEyXCJ9IiwiaXNzIjoiYXBwIiwiZXhwIjoxNTA1MzczMDU2LCJpYXQiOjE1MDUzNjU4NTZ9.uPf9kMEdwPR_FaVjLPjO4MZ3Cf9ZM64Qs3CWPblPp-8&time=1505365885580";
       NSString *url = @"https://sina.cn/index/feed?from=touch&Ver=50&wm=4007";
    SecondViewController *vc = [[SecondViewController alloc] initWithUrl:url];
    [self.navigationController pushViewController:vc animated:YES];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test.html" ofType:nil];
//    SecondViewController *vc = [[SecondViewController alloc] initWithUrl:path];
//    [self.navigationController pushViewController:vc animated:YES];
    
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
