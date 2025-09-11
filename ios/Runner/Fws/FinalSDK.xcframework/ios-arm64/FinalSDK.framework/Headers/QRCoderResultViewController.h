//
//  QRCoderResultViewController.h
//  FinalSDK
//
//  Created by IC iOS Team's Macbook Pro on 3/12/21.
//  Copyright © 2021 Minh Nguyễn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEkycBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface QRCoderResultViewController : ICEkycBaseViewController

@property (nonatomic) id ocrQRCoderResult;
@property (nonatomic) NSString *valueQRCode;

- (void) updateViewQRCoderResult;

@end

NS_ASSUME_NONNULL_END
