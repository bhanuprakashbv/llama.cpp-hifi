#ifndef _XTENSA_HIFI_H_
#define _XTENSA_HIFI_H_

// xtensa_hifi.h — Xtensa HiFi DSP convenience header for llama.cpp bare-metal port
//
// Include this instead of sprinkling individual Xtensa headers across source files.
// All definitions are gated on HIFI5_OPT so the file is safe to include unconditionally.

#undef HIFIIQ_OPT
#undef HIFI5S_OPT

#if XCHAL_HAVE_HIFIN
#define HIFIIQ_OPT
#endif

#ifdef HIFIIQ_OPT
#define HIFIIQ_VEC_DOT_F32
#define HIFIIQ_VEC_DOT_F16
#define HIFIIQ_MATMUL_Q8_V2
#define HIFIIQ_MUL_MAT
#endif

#if XCHAL_HAVE_HIFI5S
#define HIFI5S_OPT
#endif

#endif // _XTENSA_HIFI_H_
