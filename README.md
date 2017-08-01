# AVFoundationDemo
苹果的AVFoundation出世之后，Zbar就可以渐渐告别舞台。最近项目的扫描扫描条形码的效果不好，故此才想起来投入苹果爸爸原生的怀抱！
此demo实际上是参考同行的demo~在其基础上把界面独立出来，新增委托，将扫描结果交给调用者来实现，方便进行下一步的检验等操作！
下面就是集成步骤了~ 很简单的几步：
 1.将QRCode文件夹的图片拷贝到自己的应用中
 2.将我们控件，也就是
     a）ScanViewController.h
     b)ScanViewController.m
     c)ScanViewController.xib
   这三个控件拷贝到我们自己的项目中
 3.调用
     调用方法
	- (IBAction)scan:(id)sender {
    ScanViewController * scanController = [[ScanViewController alloc]init];
    scanController.delegate = self;
    [self presentViewController:scanController animated:YES completion:nil];
     }
     委托实现 记得引用头文件和继承委托 详见ViewController.m文件
   -(void)dealScanResult:(NSString*)result{
       NSLog(@"扫描结果为：%@",result);
      self.scanResult.text =result;
    }
 4.假如原项目中没有调用过相机的，需要在info.plist文件中，加入以下一列 
    Privacy - Camera Usage Description：是否允许使用相机    