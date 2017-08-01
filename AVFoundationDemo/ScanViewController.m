//
//  ScanViewController.m
//  AVFoundationDemo
//
//  Created by sdw on 17/7/21.
//  Copyright © 2017年 ai.com. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ScanViewController ()<UITabBarDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *scanLineImageView;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanLineTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *customLabel;
@property (weak, nonatomic) IBOutlet UIView *customContainerView;

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;

/*** 专门用于保存描边的图层 ***/
@property (nonatomic,strong) CALayer *containerLayer;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    [self startScan];
}
- (IBAction)closeButtonClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)useResult:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate dealScanResult:self.customLabel.text];
    }];
}

#pragma mark -------- 懒加载---------
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.orientation = UIDeviceOrientationLandscapeLeft;
    }
    return _previewLayer;
}

// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // 1.获取屏幕的frame
        CGRect viewRect = self.view.frame;
        // 2.获取扫描容器的frame
        CGRect containerRect = self.customContainerView.frame;
        
        CGFloat x = containerRect.origin.y / viewRect.size.height;
        CGFloat y = containerRect.origin.x / viewRect.size.width;
        CGFloat width = containerRect.size.height / viewRect.size.height;
        CGFloat height = containerRect.size.width / viewRect.size.width;
        
        // CGRect outRect = CGRectMake(x, y, width, height);
        // [_output rectForMetadataOutputRectOfInterest:outRect];
        _output.rectOfInterest = CGRectMake(x, y, width, height);
    }
    return _output;
}
-(void)resetOutputRectOfInterest{
    // 1.获取屏幕的frame
    CGRect viewRect = self.view.frame;
    // 2.获取扫描容器的frame
    CGRect containerRect = self.customContainerView.frame;
    
    CGFloat x = containerRect.origin.y / viewRect.size.height;
    CGFloat y = containerRect.origin.x / viewRect.size.width;
    CGFloat width = containerRect.size.height / viewRect.size.height;
    CGFloat height = containerRect.size.width / viewRect.size.width;
    
    // CGRect outRect = CGRectMake(x, y, width, height);
    // [_output rectForMetadataOutputRectOfInterest:outRect];
    _output.rectOfInterest = CGRectMake(x, y, width, height);
}

- (CALayer *)containerLayer
{
    if (_containerLayer == nil) {
        _containerLayer = [[CALayer alloc] init];
    }
    return _containerLayer;
}
/*---------------------------- 分割线 ---------------------------- */
- (void)startScan
{
    // 1.判断输入能否添加到会话中
    if (![self.session canAddInput:self.input]) return;
    [self.session addInput:self.input];
    
    
    // 2.判断输出能够添加到会话中
    if (![self.session canAddOutput:self.output]) return;
    [self.session addOutput:self.output];
    
    // 4.设置输出能够解析的数据类型
    // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
    self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes;
    
    
    // 5.设置监听监听输出解析到的数据
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 6.添加预览图层
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    self.previewLayer.frame = self.view.bounds;
    // self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // 7.添加容器图层
    [self.view.layer addSublayer:self.containerLayer];
    self.containerLayer.frame = self.view.bounds;
    
    // 8.开始扫描
    [self.session startRunning];
}

#pragma mark --------AVCaptureMetadataOutputObjectsDelegate ---------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    //  if (metadataObjects.count > 0) {
    // id 类型不能点语法,所以要先去取出数组中对象
    AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
    
    if (object == nil) return;
    // 只要扫描到结果就会调用
    self.customLabel.text = object.stringValue;
    [self.customLabel setTextColor:[UIColor blueColor]];
    
    [self clearLayers];
    
    // [self.previewLayer removeFromSuperlayer];
    
    // 2.对扫描到的二维码进行描边
    AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:object];
    
    [self drawLine:obj];
    // 停止扫描
    //        [self.session stopRunning];
    //
    //        // 将预览图层移除
    //        [self.previewLayer removeFromSuperlayer];
    //    } else {
    //        NSLog(@"没有扫描到数据");
    //    }
    
}

// 绘制描边
- (void)drawLine:(AVMetadataMachineReadableCodeObject *)objc
{
    NSArray *array = objc.corners;
    
    // 1.创建形状图层, 用于保存绘制的矩形
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    // 设置线宽
    layer.lineWidth = 2;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    // 2.创建UIBezierPath, 绘制矩形
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    int index = 0;
    
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    
    [path moveToPoint:point];
    
    // 2.2连接其它线段
    for (int i = 1; i<array.count; i++) {
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[i], &point);
        [path addLineToPoint:point];
    }
    // 2.3关闭路径
    [path closePath];
    
    layer.path = path.CGPath;
    // 3.将用于保存矩形的图层添加到界面上
    [self.containerLayer addSublayer:layer];
    
}

- (void)clearLayers
{
    if (self.containerLayer.sublayers)
    {
        for (CALayer *subLayer in self.containerLayer.sublayers)
        {
            [subLayer removeFromSuperlayer];
        }
    }
}

//注意，在界面消失的时候关闭session
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

// 界面显示,开始动画
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startAnimation];
}

// 开启冲击波动画
- (void)startAnimation
{
    // 1.设置冲击波底部和容器视图顶部对齐
    CGRect scanLineRect = self.scanLineImageView.frame;
    scanLineRect.size.height=0;
    self.scanLineImageView.frame = scanLineRect;
//    self.scanLineTopConstraint.constant = - self.containerHeightConstraint.constant;
    // 刷新UI
    [self.view layoutIfNeeded];
    
    // 2.执行扫描动画
    [UIView animateWithDuration:1.0 animations:^{
        // 无线重复动画
        [UIView setAnimationRepeatCount:MAXFLOAT];
        CGRect containerRect = self.customContainerView.frame;
        CGRect scanLineRect = self.scanLineImageView.frame;
        scanLineRect.size.height=containerRect.size.height;
        self.scanLineImageView.frame = scanLineRect;
        // 刷新UI
        [self.view layoutIfNeeded];
    } completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
