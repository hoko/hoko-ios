//
//  Hoko+Nullability.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/06/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#ifndef _Hoko_Nullability_h

    #define _Hoko_Nullability_h

    #if __has_feature(nullability)
        #define hk_nonnull nonnull
        #define hk_nullable nullable
        #define __hk_nonnull __nonnull
        #define __hk_nullable __nullable
    #else
        #define hk_nonnull
        #define hk_nullable
        #define __hk_nonnull
        #define __hk_nullable
    #endif

#endif
