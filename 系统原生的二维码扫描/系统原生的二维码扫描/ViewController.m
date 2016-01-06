//
//  ViewController.m
//  系统原生的二维码扫描
//
//  Created by mac on 16/1/6.
//  Copyright © 2016年 dqy. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>//用于信息采集的处理
{
    AVCaptureSession * _session;//输入输出的中间桥梁
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //扫描
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame = CGRectMake(20, 20, 100, 40);
    [btn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 1;
    [self.view addSubview:btn];
    
    
    //生成
    UIButton * btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn1.frame = CGRectMake(150, 20, 100, 40);
    [btn1 setTitle:@"生成二维码" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    btn1.tag = 2;
    [self.view addSubview:btn1];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnAction:(UIButton *) sender {
    
    if (sender.tag == 1) {
        
        //获取摄影设备
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //创建输入流
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        //创建输出流
        AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
        
        
        //设置代理 在主线程刷新
        
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //初始化链接对象
        _session = [[AVCaptureSession alloc] init];
        
        //设置高质量采集
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [_session addInput:input];
        [_session addOutput:output];
        
        //设置扫码支持的编码格式
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        
        AVCaptureVideoPreviewLayer * layer =[AVCaptureVideoPreviewLayer layerWithSession:_session];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        layer.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 100, 100, 100);
        [self.view.layer insertSublayer:layer atIndex:0];
        
        //开始捕捉
        [_session startRunning];
    }
    else {
        
        
        UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
        
        [self.view addSubview:imageview];
        
        
        //二维码滤镜
        CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        //恢复滤镜的默认属性
        [filter setDefaults];
        
        //将字符串转为data
        NSString * name = @"戴庆云";
        
        NSData * data = [name dataUsingEncoding:NSUTF8StringEncoding];
        
        
        //通过kvc设置滤镜inputmessage数据
        [filter setValue:data forKey:@"inputMessage"];
        
        
        //获得滤镜输出的图像
        CIImage * image = [filter outputImage];
        
        
       //
        imageview.image = [self createUIImageFromCIImage:image withSize:200];
       
        
        
    }
    
}

//将CIImage 转换为 UIImage
- (UIImage *)createUIImageFromCIImage:(CIImage *) image withSize:(CGFloat) size {
    
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    
    
    AVMetadataMachineReadableCodeObject * string = [metadataObjects objectAtIndex:0];
    
    NSLog(@"%@",string.stringValue);
    
    [_session stopRunning];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
