//
//  MainDisplayViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 9/3/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycPagerView.h"
#import "ICEkycBaseViewController.h"
#import "ICEkycCameraProtocols.h"
#import "InformationViewController.h"
#import "ValidationViewController.h"
#import "QRCoderResultViewController.h"


NS_ASSUME_NONNULL_BEGIN

@protocol MainDisplayDelegate <NSObject>

- (void) closeMainDisplay;

@end


@interface MainDisplayViewController : ICEkycBaseViewController <ICEkycPagerViewDelegate>

@property (weak, nonatomic) id<MainDisplayDelegate> delegate;

@property (nonatomic) id ocr;
@property (nonatomic) id livenessFace;
@property (nonatomic) id livenessFrontCard;
@property (nonatomic) id livenessBackCard;
@property (nonatomic) id compareFace;
@property (nonatomic) id verifyFace;
@property (nonatomic) id searchFace;
@property (nonatomic) id addFace;
@property (nonatomic) id maskFace;

@property (nonatomic) NSString *stringQRCode;

@property (nonatomic) BOOL isDone;

@property (nonatomic) UIImage *imageFront;
@property (nonatomic) UIImage *imageBack;
@property (nonatomic) UIImage *imageFace;

@property (nonatomic) VersionSdk isVersion;
@property (nonatomic) TypeDocument typePaper;
@property (nonatomic) ProgessStep stepNow;
@property (nonatomic) BOOL isScanQRCode;

@property (nonatomic) NSString *languageApplication;

@property (nonatomic) UIImage *imageLogoTrademark;

@property (nonatomic) BOOL isShowTrademark;


- (void) updateInformation;

@end

NS_ASSUME_NONNULL_END
