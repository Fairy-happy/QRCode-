//
//  ViewController.m
//  二维码扫描
//
//  Created by fairy on 15/12/29.
//  Copyright © 2015年 fairy. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CreatViewController.h"

#define Width [UIScreen mainScreen].bounds.size.width
#define Hight [UIScreen mainScreen].bounds.size.height
#define MAXFLOAT    0x1.fffffep+127f

@interface ViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) UIView *maskView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.view.clipsToBounds = YES;
    
    //1.遮罩
    [self setupMaskView];
    
    //2.下边栏
    [self setupBottomBar];
    
    //3.提示文本
    [self setupTipTitleView];
    
    //4.顶部导航
    [self setupNavView];
    
    //5.扫描区域
    [self setupScanWindowView];
    
    //6.开始动画
    [self beginScanning];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeAnimation) name:@"EnterForeground" object:nil];

    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
    [self resumeAnimation];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

-(void)setupTipTitleView
{
    //遮罩
    UIView *mask = [[UIView alloc]initWithFrame:CGRectMake(0, _maskView.frame.origin.y+_maskView.frame.size.height, self.view.frame.size.width, Hight*0.9-(_maskView.frame.origin.y+_maskView.frame.size.height))];
    mask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    //mask.backgroundColor = [UIColor redColor];
    [self.view addSubview:mask];
    
    //操作
    UILabel *tiplabel = [[UILabel alloc]initWithFrame:CGRectMake(0, Hight*0.9-100*2, Width, 100)];
    tiplabel.text = @"取景框对准二维码，即可自动扫描";
    tiplabel.textColor = [UIColor whiteColor];
    tiplabel.textAlignment = NSTextAlignmentCenter;
    tiplabel.lineBreakMode = NSLineBreakByWordWrapping;
    tiplabel.numberOfLines = 2;
    tiplabel.font = [UIFont systemFontOfSize:12];
    tiplabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tiplabel];
    
}

-(void)setupNavView
{
    //返回
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 30, 25, 25);
    //backButton.backgroundColor = [UIColor redColor];
    [backButton setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeScaleAspectFill ;
    [backButton addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //相册
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    albumButton.frame = CGRectMake(0, 0, 35, 49);
    albumButton.center = CGPointMake(Width/2, 20+49/2.0);
    [albumButton setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumButton.contentMode = UIViewContentModeScaleAspectFit;
    [albumButton addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumButton];
    
    //闪关灯
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake(Width-55, 20, 35, 49);
    [flashButton setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashButton.contentMode = UIViewContentModeScaleAspectFit;
    [flashButton addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashButton];
}

- (void)setupMaskView
{
    UIView *mask = [[UIView alloc]init];
    _maskView = mask;
    //mask.backgroundColor = [UIColor redColor];
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    //mask.layer.borderColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:1].CGColor;
    //mask.backgroundColor = [UIColor yellowColor];
    mask.layer.borderWidth = 100;
    mask.bounds = CGRectMake(0, 0, Width+100+30+5, Width+100+5+30);
    NSLog(@"%f",Width+130);
    mask.center = CGPointMake(Width*0.5, Hight*0.5);
    //NSLog(@"%f",Hight*0.5);
    CGRect temp = mask.frame;
    temp.origin.y = 0;
    mask.frame = temp;
    
    [self.view addSubview:mask];
    
    
}

- (void)setupBottomBar
{
    //下边栏
    UIView *bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, Hight*0.9, Width, Hight*0.1)];
    bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:bottomBar];
    
    //我的二维码
    UIButton *myCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myCodeButton.frame = CGRectMake(0, 0, Hight*0.1*35/49, Hight*0.1);
    myCodeButton.center = CGPointMake(Width/2, Hight*0.1/2);
    [myCodeButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_down"] forState:UIControlStateNormal];
    myCodeButton.contentMode=UIViewContentModeScaleAspectFit;
    
    [myCodeButton addTarget:self action:@selector(myCode) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:myCodeButton];
}

- (void)setupScanWindowView
{
    CGFloat scanWindowH = Width-60;
    CGFloat scanWindowW = Width-60;
    _scanWindow = [[UIView alloc]initWithFrame:CGRectMake(30, 99, scanWindowW, scanWindowH)];
    //_scanWindow.center = CGPointMake(Width/2, Hight/2);
    _scanWindow.clipsToBounds = YES;
    [self.view addSubview:_scanWindow];
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18;
    
    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topLeft];
    
    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomRight];

}

- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) {
        return;
    }
    
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:_scanWindow.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;
    
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    
    //设置扫码支持的编码格式（下方支持二维码和条形码）
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    //开始捕获
    [_session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:metadataObject.stringValue preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //[self disMiss];
            [_session startRunning];
        }];

        UIAlertAction *againAction = [UIAlertAction actionWithTitle:@"再次扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [_session startRunning];
        }];
        
        [alert addAction:okAction];
        [alert addAction:againAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

#pragma mark 我的相册
-(void)myAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc]init];
        controller.delegate = self;
        //设置图片来源
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        //设置转场动画
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:nil];
        
        
    }else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark-> imagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取选择的图片
    UIImage *image = info [UIImagePickerControllerOriginalImage];
    //初始化一个检测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        //检测到结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count>=1) {
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:scannedResult preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该图片没有包含一个二维码！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark-> 闪光灯
-(void)openFlash:(UIButton*)button{
    
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}

#pragma mark-> 我的二维码
-(void)myCode{
    
    NSLog(@"我的二维码");
    CreatViewController*vc=[[CreatViewController alloc]init];
    //[self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:vc animated:YES completion:nil];
    
    
}

#pragma mark-> 开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass !=nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            }else
            {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark 恢复动画
- (void)resumeAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if (anim) {
        //将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseYime = _scanNetImageView.layer.timeOffset;
        //根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTimer = CACurrentMediaTime()-pauseYime;
        
        //把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        //设置图层开始动画
        [_scanNetImageView.layer setBeginTime:beginTimer];
        [_scanNetImageView.layer setSpeed:1.0];
    }else
    {
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH = Width-60;
        CGFloat scanNetImageViewW = _scanWindow.frame.size.width;
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
}

#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}
#pragma mark-> 返回
- (void)disMiss
{
     exit(0);
    //[self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - UIAlertViewDelegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) {
//        [self disMiss];
//    } else if (buttonIndex == 1) {
//        [_session startRunning];
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
