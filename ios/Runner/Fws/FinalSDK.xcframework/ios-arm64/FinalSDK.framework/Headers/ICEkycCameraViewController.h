//
//  ICEkycCameraViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 8/20/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import <AVFoundation/AVFoundation.h>
#import "ICEkycCameraProtocols.h"
#import "ICEkycCameraPresenter.h"
#import "SaveData.h"
#import "ICEkycBaseViewController.h"
#import "MainDisplayViewController.h"
#import "InformationViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define LANGUAGE_APPLICATION_DEFAULT @"vi"


@protocol ICEkycCameraDelegate <NSObject>

@required
- (void) getResult;
@optional
- (void) closeSDK:(ScreenType)type;

@end


@interface ICEkycCameraViewController : ICEkycBaseViewController<ICEkycCameraViewProtocol, MainDisplayDelegate, InformationDelegate>

@property (nonatomic) VersionSdk isVersion;
@property (nonatomic) TypeDocument isType;
@property (nonatomic) FlowType flowType;
@property (nonatomic) ProgessStep stepNow;

@property (nonatomic) NSString *languageApplication; // "vi"
@property (nonatomic) NSString *inputIDVerifyFace;
@property (nonatomic) NSString *idTypeVerifyFace; // "CARD_ID"
@property (nonatomic) NSString *challengeCode; // "11111"
@property (nonatomic) NSString *unitCustomer;
@property (nonatomic) NSString *resourceCustomer;
@property (nonatomic) NSString *hashFrontCompareFace;
@property (nonatomic) NSString *clientSession; // "vi"

@property (nonatomic) NSString *hashFaceCompare;
@property (nonatomic) NSDictionary *objectAddFace;
@property (nonatomic) UIImage *imageFaceToCompare;
@property (nonatomic) NSString *hashFaceVoice;


@property (nonatomic) BOOL isShowHelp;
@property (nonatomic) BOOL isShowResult;
@property (nonatomic) BOOL isShowResultCheckLiveness3DScan;
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
@property (nonatomic) BOOL isVersionPro2D;
@property (nonatomic) BOOL isSkipVoiceVideo;
@property (nonatomic) BOOL isValidateDocument;

@property (nonatomic) UIColor *buttonTitleColor;
@property (nonatomic) UIColor *buttonReTakeColor;
@property (nonatomic) UIColor *buttonBackgroundColor;
////Help 1
@property (nonatomic) UIColor *colorEkycBackgroundButtonNext;
@property (nonatomic) UIColor *colorEkycTextButtonNext;
@property (nonatomic) UIColor *colorEkycPrimaryBackground;
//Camera chup giấy tơ
@property (nonatomic) UIColor *colorEkycTitleScreen;
@property (nonatomic) UIColor *colorEkycTitleImageDocument;
@property (nonatomic) UIColor *colorEkycGuideDocumentCapture;
//Giao dien canh bao chup lai
@property (nonatomic) UIColor *colorEkycTextButtonConfirm;
@property (nonatomic) UIColor *colorEkycBackgroundButtonConfirm;
@property (nonatomic) UIColor *colorEkycTextMainDialog; //text anh chup giấy tơ không hợp lệ
@property (nonatomic) UIColor *colorEkycBackgroundDialog; //Background

//Man kêt quả chup giấy tờ
@property (nonatomic) UIColor *colorEkycTextRetake;
@property (nonatomic) UIColor *colorEkycTitleImageDocumentResult;
@property (nonatomic) UIColor *colorEkycTextDocumentResult;
@property (nonatomic) UIColor *colorEkycDotBeforeTextDocumentResult;

//Man hinh xac thực khuôn mặt
@property (nonatomic) UIColor *colorEkycTextHelpVideoGuide;
@property (nonatomic) UIColor *colorDisableTextButtonSkipVideo;

//Man hinh Oval

@property (nonatomic) UIColor *colorEkycOvalMessage;
@property (nonatomic) UIColor *colorEkycBorderOval;
@property (nonatomic) UIColor *colorEkycText3DGuide;

//Man hinh xoay mat
@property (nonatomic) UIColor *colorEkycProgressNoFill;
@property (nonatomic) UIColor *colorEkycProgressFill;
@property (nonatomic) UIImage *imageBgBottom;
@property (nonatomic) UIImage *imageBgTop;
@property (nonatomic) UIImage *imageZoneBorderDocument;
@property (nonatomic) UIImage *imageZoneBorderDocumentPreview;
@property (strong,nonatomic) NSBundle *bundleOvalAnimation;
@property (strong,nonatomic) NSBundle *bundleFeedbackAnimation;
@property (strong,nonatomic) NSBundle *bundleHelpVideoOval;
@property (strong,nonatomic) NSBundle *bundleBorderImagePreviewDocument;
@property (strong,nonatomic) NSBundle *languageBundle;



//Man
//=================================

@property (nonatomic) UIImage *logoTrademarkImage;

@property (nonatomic) UIImage *defaultFrontImage;
@property (nonatomic) UIImage *defaultBackImage;
@property (nonatomic) UIImage *defaultFaceImage;

@property (nonatomic) NSString *defaultHashFrontImage;
@property (nonatomic) NSString *defaultHashBackImage;
@property (nonatomic) NSString *defaultHashFaceImage;
@property (nonatomic) BOOL isVersionProOval;
@property (nonatomic) BOOL isVersionQRCode;

@property (nonatomic) BOOL isVoiceOval;
@property (nonatomic) BOOL isProVoiceOval;


@property (nonatomic) NSBundle *nameOvalAnimation;
@property (nonatomic) NSBundle *nameFeedbackAnimation;
@property (nonatomic) NSBundle *nameHelpVideoFullScreen;


/* camera Delegate */
@property (weak, nonatomic) id<ICEkycCameraDelegate> cameraDelegate;

@property (nonatomic) ICEkycCameraPresenter *presenter;

- (void) addFaceObject:(NSDictionary *)object bbox:(NSString *)bbox landmark:(NSString *)landmark;

@end

NS_ASSUME_NONNULL_END
