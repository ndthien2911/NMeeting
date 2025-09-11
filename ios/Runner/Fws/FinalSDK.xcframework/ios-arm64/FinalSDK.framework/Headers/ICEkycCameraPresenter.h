//
// ICEkycCameraPresenter.h
// FinalSDK
//
// Created by Minh Nguyễn on 8/20/20.
// Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycCameraProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICEkycCameraPresenter : NSObject<ICEkycCameraInteractorOutputProtocol, ICEkycCameraPresenterProtocol>

@property (nonatomic, weak, nullable) id<ICEkycCameraViewProtocol> view;
@property (nonatomic) id<ICEkycCameraInteractorInputProtocol> interactor;
@property (nonatomic) id<ICEkycCameraWireframeProtocol> router;

- (instancetype)initWithInterface:(id<ICEkycCameraViewProtocol>)interface
                       interactor:(id<ICEkycCameraInteractorInputProtocol>)interactor
                           router:(id<ICEkycCameraWireframeProtocol>)router;

- (void) callApiUploadFrontImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadBackImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadLeftFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadRightFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadNearFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadVoiceFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadFarFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadFaceCompareImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) callApiUploadLogData:(NSData *)logData title:(NSString *)title description:(NSString *)description;


- (void) callApiGetInfoFrontCard:(NSString *)front challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) callApiGetInfoBackCard:(NSString *)back challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) callApiGetInformationCard:(NSString *)front back:(NSString *)back challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) callApiCompareImageCard:(NSString *)front face:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiCompareImageNearWithImageVoice:(NSString *)front face:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;




- (void) callApiCheckLivenessFace:(NSString *)face faceLeft:(NSString *)faceLeft faceRight:(NSString *)faceRight challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiVerifyFace:(NSString *)face idCard:(NSString *)idCard type:(NSString *)type unit:(NSString *)unit challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiAddFace:(NSString *)face information:(NSDictionary *)information unit:(NSString *)unit challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiSearchFace:(NSString *)face unit:(NSString *)unit challengeCode:(NSString *)code;

- (void) callApiCheckMaskFace:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiCheckLivenessFrontCard:(NSString *)card cropParam:(NSString *)cropParam challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiCheckLivenessBackCard:(NSString *)card cropParam:(NSString *)cropParam challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) callApiCheckLiveness3DScanImageNear:(NSString *)imageNear imageFar:(NSString *)imageFar logData:(NSString *)logData challengeCode:(NSString *)code resource:(NSString *)resource;


- (void) resetSaveData;

- (void) callApiVerifyVoice:(NSString *)num audio_hash:(NSString *)audio_hash action:(NSString *)action;

- (void) callApiUploadVoice:(NSString *)bucket x_amz_date:(NSString *)x_amz_date x_amz_signature:(NSString *)x_amz_signature key:(NSString *)key x_amz_algorithm:(NSString *)x_amz_algorithm content_type:(NSString *)content_type x_amz_credential:(NSString *)x_amz_credential policy:(NSString *)policy file:(NSData *)file urlUpload:(NSString *)urlUpload ;

- (void) callApiInfoToUploadVideo:(NSString *)fileName title:(NSString *)title description:(NSString *)description content_type:(NSString *)contentType ;
- (void) callApiUploadVideo:(NSString *)bucket x_amz_date:(NSString *)x_amz_date x_amz_signature:(NSString *)x_amz_signature key:(NSString *)key x_amz_algorithm:(NSString *)x_amz_algorithm content_type:(NSString *)content_type x_amz_credential:(NSString *)x_amz_credential policy:(NSString *)policy file:(NSData *)file urlUpload:(NSString *)urlUpload ;

- (void) callApiInfoToUploadVoice:(NSString *)fileName title:(NSString *)title description:(NSString *)description content_type:(NSString *)contentType ;


-(void) callApiLogVoiceData:(NSString *)audio_hash length:(NSInteger)length volumn:(float )volumn datavoice:(NSString*)datavoice client_session:(NSString *)client_session video_hash:(NSString *)video_hash;


@end

NS_ASSUME_NONNULL_END
