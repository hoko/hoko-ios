//
//  Hoko+Macros.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/06/15.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#ifndef _Hoko_Macros_h

    #define _Hoko_Macros_h

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

    #if __has_feature(objc_generics)
        #define hok_generic(x) <x>
        #define hok_generic2(x, y) <x, y>
    #else
        #define hok_generic(x)
        #define hok_generic2(x, y)
    #endif

#endif
