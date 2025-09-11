//
//  ICEkycCameraInteractor.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 8/20/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICEkycCameraProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICEkycCameraInteractor : NSObject<ICEkycCameraInteractorInputProtocol>

@property (nonatomic, weak, nullable) id<ICEkycCameraInteractorOutputProtocol> output;

@end

NS_ASSUME_NONNULL_END
