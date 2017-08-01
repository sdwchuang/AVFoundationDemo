//
//  ViewController.m
//  AVFoundationDemo
//
//  Created by sdw on 17/7/20.
//  Copyright © 2017年 ai.com. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
@interface ViewController ()<ScanViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *scanResult;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)scan:(id)sender {
    ScanViewController * scanController = [[ScanViewController alloc]init];
    scanController.delegate = self;
    [self presentViewController:scanController animated:YES completion:nil];
}
-(void)dealScanResult:(NSString*)result{
    NSLog(@"扫描结果为：%@",result);
    self.scanResult.text =result;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
