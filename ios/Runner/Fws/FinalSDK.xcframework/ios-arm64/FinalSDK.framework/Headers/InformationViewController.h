//
//  InformationViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 9/3/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycCameraProtocols.h"
#import "ICEkycBaseViewController.h"
#import "ViewImageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol InformationDelegate <NSObject>

- (void) closeInformation;

@end


@interface InformationViewController : ICEkycBaseViewController

@property (weak, nonatomic) id<InformationDelegate> delegate;

@property (nonatomic) id ocrInformation;
@property (nonatomic) id livenessFaceInformation;
@property (nonatomic) id livenessFrontCardInformation;
@property (nonatomic) id livenessBackCardInformation;
@property (nonatomic) id compareFaceInformation;
@property (nonatomic) id verifyFaceInformation;
@property (nonatomic) id searchFaceInformation;
@property (nonatomic) id addFaceInformation;
@property (nonatomic) id maskFaceInformation;
@property (nonatomic) NSString *valueQRCode;

@property (nonatomic) BOOL isDone;

@property (nonatomic) UIImage *imageFrontInformation;
@property (nonatomic) UIImage *imageBackInformation;
@property (nonatomic) UIImage *imageFaceInformation;


@property (nonatomic) VersionSdk isVersionInformation;
@property (nonatomic) TypeDocument isTypeInformation;
@property (nonatomic) ProgessStep stepNowInformation;

@property (nonatomic) NSString *languageApplicationInformation;

@property (nonatomic) UIImage *imageLogoTrademarkInformation;

@property (nonatomic) BOOL isShowTrademarkInformation;
@property (nonatomic) BOOL isScanQRCode;



- (void) updateViewInformation;


@end

NS_ASSUME_NONNULL_END
