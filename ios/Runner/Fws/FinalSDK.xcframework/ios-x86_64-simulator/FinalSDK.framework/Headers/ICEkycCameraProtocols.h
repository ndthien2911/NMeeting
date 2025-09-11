//
//  ICEkycCameraProtocols.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 8/20/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    Normal,
    Pro,
} VersionSdk;



typedef enum : NSUInteger {
    cmt,
    cmtganchip,
    hochieu,
    banglaixe,
    cmtquandoi,
    khac,
} TypeDocument;


typedef enum : NSUInteger {
    full,
    ocrFront,
    ocrBack,
    ocrFrontAndBack,
    compare,
    compareWithImage,
    addFace,
    verifyFace,
    searchFace,
    onlyLivenessFace,
} FlowType;


typedef enum : NSUInteger {
    stepQRCode,
    stepFront,
    stepBack,
    stepFace,
} ProgessStep;


typedef enum : NSUInteger {
    BirthPlace,
    RecentLocation,
    OriginLocation,
    IssuePlace,
} PostCodeType;



typedef enum : NSUInteger {
    HelpDocument,
    CaptureFront,
    PreviewFront,
    CaptureBack,
    PreviewBack,
    HelpOval,
    AuthenFarFace,
    AuthenNearFace,
    Processing,
    Done,
    ScanQR,
    CaptureFaceBasic,
    PreviewFaceBasic,
    HelpFaceBasic,
} ScreenType;


#pragma mark - WireFrameProtocol

@protocol ICEkycCameraWireframeProtocol <NSObject>

@end

#pragma mark - ICEkycCameraPresenterProtocol

@protocol ICEkycCameraPresenterProtocol <NSObject>

@end

#pragma mark - ICEkycCameraInteractorProtocol

@protocol ICEkycCameraInteractorOutputProtocol <NSObject>

/** Interactor -> Presenter */

- (void) sendResultUploadSucceedFrontImage:(NSString *)hash;
- (void) sendResultUploadSucceedBackImage:(NSString *)hash;
- (void) sendResultUploadSucceedFaceImage:(NSString *)hash;
- (void) sendResultUploadSucceedNearFaceImage:(NSString *)hash;
- (void) sendResultUploadSucceedFaceCompareImage:(NSString *)hash;
- (void) sendResultUploadSucceedFarFaceImage:(NSString *)hash;
- (void) sendResultUploadSucceedLogDataImage:(NSString *)hash;
- (void) sendResultUploadSucceedVoiceFaceImage:(NSString *)hash;

- (void) sendResultCheckLivenessFrontCard:(id)resultCheck;

- (void) sendResultCheckLivenessBackCard:(id)resultCheck;

- (void) sendResultGetInformationCard:(id)resultGetInformationCard;

- (void) sendResultCompare:(id)resultCompare;
- (void) sendResultCompareImageNearWithImageVoice:(id)resultCompare;

- (void) sendResultCheckLivenessFace:(id)resultCheckLivenessFace;

- (void) sendResultCheckLiveness3DScan:(id)resultCheckLiveness3DScan;

- (void) sendResultCheckMaskFace:(id)resultCheckMaskFace;

- (void) sendResultVerifyFace:(id)verifyFace;

- (void) sendResultAddFace:(id)addFace;

- (void) sendResultSearchFace:(id)searchFace;

//Ham tra ket qua Voice

- (void) sendResultInfoUploadVoice:(id)result;
- (void) sendResultInfoUploadVideo:(id)result;

- (void) sendResultVerifyVoice:(id)result;
- (void) sendResultLogVoice:(id)result;


- (void) sendResultUploadVoice:(id)result;
- (void) sendResultUploadVideo:(id)result;




@end

@protocol ICEkycCameraInteractorInputProtocol <NSObject>

- (void)setOutput:(id<ICEkycCameraInteractorOutputProtocol>)output;
- (id<ICEkycCameraInteractorOutputProtocol>)getOutputProtocol;

/** Presenter -> Interactor */
- (void) handleUploadFrontImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadBackImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadLeftFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadRightFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadNearFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;
- (void) handleUploadVoiceFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadFaceCompareImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadFarFaceImage:(UIImage *)image title:(NSString *)title description:(NSString *)description;

- (void) handleUploadLogData:(NSData *)logData title:(NSString *)title description:(NSString *)description;


- (void) handleGetInfoFrontCard:(NSString *)front challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) handleGetInfoBackCard:(NSString *)back challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) handleGetInformationCard:(NSString *)front back:(NSString *)back challengeCode:(NSString *)code cropParam:(NSString *)cropParam type:(NSString *)type resource:(NSString *)resource validate:(BOOL)validate;

- (void) handleCompareImageCard:(NSString *)front face:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleCompareImageNearWithImageVoice:(NSString *)front face:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleCheckLivenessFace:(NSString *)face faceLeft:(NSString *)faceLeft faceRight:(NSString *)faceRight challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleVerifyFace:(NSString *)face idCard:(NSString *)idCard type:(NSString *)type unit:(NSString *)unit challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleAddFace:(NSString *)face information:(NSDictionary *)information unit:(NSString *)unit challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleSearchFace:(NSString *)face unit:(NSString *)unit challengeCode:(NSString *)code;

- (void) handleCheckMaskFace:(NSString *)face challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleCheckLivenessFrontCard:(NSString *)card cropParam:(NSString *)cropParam challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleCheckLivenessBackCard:(NSString *)card cropParam:(NSString *)cropParam challengeCode:(NSString *)code resource:(NSString *)resource;

- (void) handleCheckLiveness3DScanImageNear:(NSString *)imageNear imageFar:(NSString *)imageFar logData:(NSString *)logData challengeCode:(NSString *)code resource:(NSString *)resource;


- (void) handleResetSaveData;
//Xư ly cac hàm voice

- (void) handleVerifyVoice:(NSString *)num audio_hash:(NSString *)audio_hash action:(NSString *)action ;


- (void) handleLogVoiceData:(NSString *)audio_hash length:(NSInteger)length volumn:(float )volumn datavoice:(NSString*)datavoice client_session:(NSString *)client_session video_hash:(NSString *)video_hash ;

- (void) handleUploadVoice:(NSString *)bucket x_amz_date:(NSString *)x_amz_date x_amz_signature:(NSString *)x_amz_signature key:(NSString *)key x_amz_algorithm:(NSString *)x_amz_algorithm content_type:(NSString *)content_type x_amz_credential:(NSString *)x_amz_credential policy:(NSString *)policy file:(NSData *)file urlUpload:(NSString *)urlUpload;
- (void) handleUploadVideo:(NSString *)bucket x_amz_date:(NSString *)x_amz_date x_amz_signature:(NSString *)x_amz_signature key:(NSString *)key x_amz_algorithm:(NSString *)x_amz_algorithm content_type:(NSString *)content_type x_amz_credential:(NSString *)x_amz_credential policy:(NSString *)policy file:(NSData *)file urlUpload:(NSString *)urlUpload;

- (void) handleInfoToUploadVoice:(NSString *)fileName title:(NSString *)title description:(NSString *)description content_type:(NSString *)contentType;
- (void) handleInfoToUploadVideo:(NSString *)fileName title:(NSString *)title description:(NSString *)description content_type:(NSString *)contentType;


@end

#pragma mark - ICEkycCameraViewProtocol

@protocol ICEkycCameraViewProtocol <NSObject>

/** Presenter -> ViewController */

- (void) showResultUploadSucceedFrontImage:(NSString *)hash;
- (void) showResultUploadSucceedBackImage:(NSString *)hash;
- (void) showResultUploadSucceedFaceImage:(NSString *)hash;
- (void) showResultUploadSucceedNearFaceImage:(NSString *)hash;
- (void) showResultUploadSucceedVoiceFaceImage:(NSString *)hash;
- (void) showResultUploadSucceedFarFaceImage:(NSString *)hash;
- (void) showResultUploadSucceedLogDataImage:(NSString *)hash;
- (void) showResultUploadSucceedFaceCompareImage:(NSString *)hash;


- (void) showResultCheckLivenessFrontCard:(id)resultCheck;

- (void) showResultCheckLivenessBackCard:(id)resultCheck;

- (void) showResultGetInformationCard:(id)resultGetInformationCard;

- (void) showResultCompare:(id)resultCompare;
- (void) showResultCompareImageNearWithImageVoice:(id)resultCompare;

- (void) showResultCheckLivenessFace:(id)resultCheckLivenessFace;

- (void) showResultCheckLiveness3DScan:(id)resultCheckLiveness3DScan;

- (void) showResultCheckMaskFace:(id)resultCheckMaskFace;

- (void) showResultVerifyFace:(id)verifyFace;

- (void) showResultAddFace:(id)addFace;

- (void) showResultSearchFace:(id)searchFace;

//Cac ham xu ly voice
- (void) showResultGetInfoToUploadVideo:(id)result;
- (void) showResultGetInfoToUploadVoice:(id)result;

- (void) showResultVerifyVoice:(id)result;

- (void) showResultUploadVoice:(id)result;
- (void) showResultUploadVideo:(id)result;
- (void) showResultLogVoiceData:(id)result;

@end
