//
//  ViewController.m
//  HMNetworkMonitor
//
//  Created by humiao on 2019/8/6.
//  Copyright © 2019 syc. All rights reserved.
//

#import "ViewController.h"
#import "HMNetworkMonitor.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 90, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-90)];
    [self.view addSubview:self.webView];
    
    
    HMNetworkMonitor *netMonitor = [HMNetworkMonitor shareNetworkMonitor];
    [netMonitor networkMonitorOnView:self.view];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@[@"http://www.baidu.com",@"http://github.com/Andy-Miao",@"https://github.com/Andy-Miao/HMNetworkMonitor.git"][arc4random()%3]]];
    [self.webView loadRequest:request];
}

@end
