//
//  ICScanQRCodeViewController.h
//  FinalSDK
//
//  Created by IC iOS Team's Macbook Pro on 3/12/21.
//  Copyright © 2021 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ScanQRCodeDelegate <NSObject>

- (void) pressDismissScanQRCode;
- (void) dismissAfterScanSucceedWithValue:(NSString *)value;

@end

@interface ICScanQRCodeViewController : ICEkycBaseViewController

@property (weak, nonatomic) id<ScanQRCodeDelegate> scanQRCodeDelegate;
@property (nonatomic) NSString *languageApplication;
@property (nonatomic) BOOL isShowTrademark;
@property (nonatomic) UIImage *imageTrademark;
@property (nonatomic) BOOL isShowHelp;
@property (nonatomic) UIColor *buttonTitleColor;
@property (nonatomic) UIColor *buttonBackgroundColor;

@property (nonatomic) UIColor *colorEkycTitleScreen;
@property (nonatomic) UIColor *colorEkycTitleImageDocument;
@property (nonatomic) UIColor *colorEkycGuideDocumentCapture;


@property (nonatomic) UIColor *colorEkycTextButtonConfirm;
@property (nonatomic) UIColor *colorEkycBackgroundButtonConfirm;

@property (nonatomic) UIColor *colorEkycBackgroundDialog;

- (void) deallocSessionQRCode;

@end

NS_ASSUME_NONNULL_END
