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
        #define hok_nonnull nonnull
        #define hok_nullable nullable
        #define __hok_nonnull __nonnull
        #define __hok_nullable __nullable
    #else
        #define hok_nonnull
        #define hok_nullable
        #define __hok_nonnull
        #define __hok_nullable
    #endif

#endif
