//
//  SDKRootViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 9/3/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ICEkycCameraRouter.h"
#import "ICEkycCameraViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SDKRootViewController : UIViewController

@property (nonatomic) VersionSdk isVersion;
@property (nonatomic) TypeDocument isType;
@property (nonatomic) FlowType flowType;
@property (nonatomic) ProgessStep stepNow;

@property (nonatomic) NSString *titleSelect;
@property (nonatomic) NSString *subTitleSelect;

@property (nonatomic) NSString *languageApplication;
@property (nonatomic) NSString *inputIDVerifyFace;
@property (nonatomic) NSString *idTypeVerifyFace;
@property (nonatomic) NSString *challengeCode;
@property (nonatomic) NSString *unitCustomer;
@property (nonatomic) NSString *resourceCustomer;
@property (nonatomic) NSString *hashFrontCompareFace;

@property (nonatomic) BOOL isShowHelp;
@property (nonatomic) BOOL isShowResult;
@property (nonatomic) BOOL isShowRotateCamera;
@property (nonatomic) BOOL isWantRotateCameraBack;
@property (nonatomic) BOOL isValidatePostcode;
@property (nonatomic) BOOL isCompare;
@property (nonatomic) BOOL isAddFace;
@property (nonatomic) BOOL isShowTrademark;
@property (nonatomic) BOOL isCheckLivenessFace;
@property (nonatomic) BOOL isCheckLivenessCard;
@property (nonatomic) BOOL isCheckMaskFace;
@property (nonatomic) BOOL isCustomize;

@property (nonatomic) UIColor *buttonTitleColor;
@property (nonatomic) UIColor *buttonReTakeColor;
@property (nonatomic) UIColor *buttonBackgroundColor;

@property (nonatomic) UIImage *logoTrademarkImage;
@property (weak, nonatomic) id<ICEkycCameraDelegate> cameraDelegate;


@end

NS_ASSUME_NONNULL_END
