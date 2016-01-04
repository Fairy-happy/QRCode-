//
//  CreatViewController.m
//  二维码扫描
//
//  Created by fairy on 16/1/4.
//  Copyright © 2016年 fairy. All rights reserved.
//

#import "CreatViewController.h"

@interface CreatViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *creatButton;
@property (weak, nonatomic) IBOutlet UITextField *creatMessage;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

@end

@implementation CreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.creatMessage.delegate = self;
    [self.creatButton addTarget:self action:@selector(creatCode) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dealTap:)];
    [self.view addGestureRecognizer:tap];
    //[self creatCode];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)creatCode
{
    self.codeImage.image =nil;
    NSString *text = _creatMessage.text;
    NSData *stringData = [text dataUsingEncoding:NSUTF8StringEncoding];
    //生成
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:stringData forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    UIColor *onColor = [UIColor redColor];
    UIColor *offColor = [UIColor blueColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage",filter.outputImage,@"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor], nil];
    CIImage *Image = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(200, 200);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil]createCGImage:Image fromRect:Image.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    self.codeImage.image = codeImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.creatMessage resignFirstResponder];
    return YES;
}

-(void)dealTap:(UITapGestureRecognizer *)tap
{
    //回收键盘
    [self.creatMessage resignFirstResponder];
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
