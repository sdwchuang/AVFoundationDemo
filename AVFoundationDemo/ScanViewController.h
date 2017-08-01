//
//  ScanViewController.h
//  AVFoundationDemo
//
//  Created by sdw on 17/7/21.
//  Copyright © 2017年 ai.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScanViewControllerDelegate;

@interface ScanViewController : UIViewController
@property (nonatomic ,assign) id<ScanViewControllerDelegate> delegate;

@end

@protocol ScanViewControllerDelegate<NSObject>
-(void)dealScanResult:(NSString*)result;
@end
