//
//  HKAnalytics.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HKDeeplinking.h"

/**
 *  The HKAnalytics module provides all the necessary APIs to manage user and application behavior.
 *  Users should be identified to this module, as well as key events (e.g. sales, referrals, etc) in order
 *  to track campaign value and allow user segmentation.
 */
@interface HKAnalytics : NSObject <HKHandlerProcotol>

@end

