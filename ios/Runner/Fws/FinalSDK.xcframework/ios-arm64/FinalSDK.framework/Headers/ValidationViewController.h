//
//  ValidationViewController.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 9/3/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycCameraProtocols.h"
#import "ICEkycBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ValidationViewController : ICEkycBaseViewController

@property (nonatomic) id ocrValidation;
@property (nonatomic) id livenessFaceValidation;
@property (nonatomic) id livenessFrontCardValidation;
@property (nonatomic) id livenessBackCardValidation;
@property (nonatomic) id compareFaceValidation;
@property (nonatomic) id verifyFaceValidation;
@property (nonatomic) id searchFaceValidation;
@property (nonatomic) id addFaceValidation;
@property (nonatomic) id maskFaceValidation;


@property (nonatomic) VersionSdk isVersionValidation;
@property (nonatomic) TypeDocument isTypeValidation;
@property (nonatomic) ProgessStep stepNowValidation;

@property (nonatomic) NSString *languageApplicationValidation;

@property (nonatomic) UIImage *imageLogoTrademarkValidation;

@property (nonatomic) BOOL isShowTrademarkValidation;



- (void) updateViewValidation;

@end

NS_ASSUME_NONNULL_END
