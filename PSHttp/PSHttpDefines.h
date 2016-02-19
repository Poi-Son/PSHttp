//
//  PSHttpDefines.h
//  PSHttp
//
//  Created by PoiSon on 16/2/19.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#ifndef PSHttpDefines_h
#define PSHttpDefines_h

#if defined(__cplusplus)
#define PSHTTP_EXTERN extern "C"
#else
#define PSHTTP_EXTERN extern
#endif

#define PSHTTP_EXTERN_STRING(KEY, COMMENT) PSHTTP_EXTERN NSString * const _Nonnull KEY;
#define PSHTTP_EXTERN_STRING_IMP(KEY) NSString * const KEY = @#KEY;
#define PSHTTP_EXTERN_STRING_IMP2(KEY, VAL) NSString * const KEY = VAL;

#define PSHTTP_ENUM_OPTION(ENUM, VAL, COMMENT) ENUM = VAL

#define PSHTTP_API_UNAVAILABLE(INFO) __attribute__((unavailable(INFO)))

#endif /* PSHttpDefines_h */
