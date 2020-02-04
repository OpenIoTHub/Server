//+build !noasm !appengine !gccgo

// Copyright 2015, Klaus Post, see LICENSE for details.
// Copyright 2019, Minio, Inc.

//
// Process 2 output rows in parallel from a total of 8 input rows
//
// func _galMulAVX512Parallel82(in, out [][]byte, matrix *[matrixSize82]byte, addTo bool)
TEXT ·_galMulAVX512Parallel82(SB), 7, $0
	MOVQ  in+0(FP), SI     //
	MOVQ  8(SI), R9        // R9: len(in)
	SHRQ  $6, R9           // len(in) / 64
	TESTQ R9, R9
	JZ    done_avx512_parallel82

	MOVQ matrix+48(FP), SI
	LONG $0x48fee162; WORD $0x066f // VMOVDQU64 ZMM16, 0x000[rsi]
	LONG $0x48fee162; WORD $0x4e6f; BYTE $0x01 // VMOVDQU64 ZMM17, 0x040[rsi]
	LONG $0x48fee162; WORD $0x566f; BYTE $0x02 // VMOVDQU64 ZMM18, 0x080[rsi]
	LONG $0x48fee162; WORD $0x5e6f; BYTE $0x03 // VMOVDQU64 ZMM19, 0x0c0[rsi]
	LONG $0x48fee162; WORD $0x666f; BYTE $0x04 // VMOVDQU64 ZMM20, 0x100[rsi]
	LONG $0x48fee162; WORD $0x6e6f; BYTE $0x05 // VMOVDQU64 ZMM21, 0x140[rsi]
	LONG $0x48fee162; WORD $0x766f; BYTE $0x06 // VMOVDQU64 ZMM22, 0x180[rsi]
	LONG $0x48fee162; WORD $0x7e6f; BYTE $0x07 // VMOVDQU64 ZMM23, 0x1c0[rsi]

	MOVQ         $15, BX
	MOVQ         BX, X5
	LONG $0x487df262; WORD $0xd578 // VPBROADCASTB ZMM2, XMM5

	MOVB addTo+56(FP), AX
	LONG $0xffc0c749; WORD $0xffff; BYTE $0xff // mov r8, -1
	WORD $0xf749; BYTE $0xe0 // mul r8
	LONG $0x92fbe1c4; BYTE $0xc8 // kmovq k1, rax
	MOVQ in+0(FP), SI  //  SI: &in
	MOVQ in_len+8(FP), AX  // number of inputs
	XORQ R11, R11
	MOVQ out+24(FP), DX
	MOVQ 24(DX), CX    //  CX: &out[1][0]
	MOVQ (DX), DX      //  DX: &out[0][0]

loopback_avx512_parallel82:
	LONG $0xc9fef162; WORD $0x226f // VMOVDQU64 ZMM4{k1}{z}, [rdx]
	LONG $0xc9fef162; WORD $0x296f // VMOVDQU64 ZMM5{k1}{z}, [rcx]

	MOVQ (SI), BX      //  BX: &in[0][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40fd3362; WORD $0xf043; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM16, ZMM16, 0x00
	LONG $0x40fd3362; WORD $0xf843; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM16, ZMM16, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40dd3362; WORD $0xe443; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM20, ZMM20, 0x00
	LONG $0x40dd3362; WORD $0xec43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM20, ZMM20, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $1
    JE skip_avx512_parallel82

 	MOVQ 24(SI), BX    //  BX: &in[1][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40fd3362; WORD $0xf043; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM16, ZMM16, 0xaa
	LONG $0x40fd3362; WORD $0xf843; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM16, ZMM16, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40dd3362; WORD $0xe443; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM20, ZMM20, 0xaa
	LONG $0x40dd3362; WORD $0xec43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM20, ZMM20, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $2
    JE skip_avx512_parallel82

	MOVQ 48(SI), BX    //  BX: &in[2][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40f53362; WORD $0xf143; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM17, ZMM17, 0x00
	LONG $0x40f53362; WORD $0xf943; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM17, ZMM17, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40d53362; WORD $0xe543; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM21, ZMM21, 0x00
	LONG $0x40d53362; WORD $0xed43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM21, ZMM21, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $3
    JE skip_avx512_parallel82

	MOVQ 72(SI), BX    // BX: &in[3][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40f53362; WORD $0xf143; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM17, ZMM17, 0xaa
	LONG $0x40f53362; WORD $0xf943; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM17, ZMM17, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40d53362; WORD $0xe543; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM21, ZMM21, 0xaa
	LONG $0x40d53362; WORD $0xed43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM21, ZMM21, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $4
    JE skip_avx512_parallel82

	MOVQ 96(SI), BX    // BX: &in[4][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40ed3362; WORD $0xf243; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM18, ZMM18, 0x00
	LONG $0x40ed3362; WORD $0xfa43; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM18, ZMM18, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40cd3362; WORD $0xe643; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM22, ZMM22, 0x00
	LONG $0x40cd3362; WORD $0xee43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM22, ZMM22, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $5
    JE skip_avx512_parallel82

	MOVQ 120(SI), BX   // BX: &in[5][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40ed3362; WORD $0xf243; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM18, ZMM18, 0xaa
	LONG $0x40ed3362; WORD $0xfa43; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM18, ZMM18, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40cd3362; WORD $0xe643; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM22, ZMM22, 0xaa
	LONG $0x40cd3362; WORD $0xee43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM22, ZMM22, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $6
    JE skip_avx512_parallel82

	MOVQ 144(SI), BX   // BX: &in[6][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40e53362; WORD $0xf343; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM19, ZMM19, 0x00
	LONG $0x40e53362; WORD $0xfb43; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM19, ZMM19, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40c53362; WORD $0xe743; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM23, ZMM23, 0x00
	LONG $0x40c53362; WORD $0xef43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM23, ZMM23, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

    CMPQ AX, $7
    JE skip_avx512_parallel82

	MOVQ 168(SI), BX   //  BX: &in[7][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40e53362; WORD $0xf343; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM19, ZMM19, 0xaa
	LONG $0x40e53362; WORD $0xfb43; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM19, ZMM19, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40c53362; WORD $0xe743; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM23, ZMM23, 0xaa
	LONG $0x40c53362; WORD $0xef43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM23, ZMM23, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

skip_avx512_parallel82:
	LONG $0x48fef162; WORD $0x227f // VMOVDQU64 [rdx], ZMM4
	LONG $0x48fef162; WORD $0x297f // VMOVDQU64 [rcx], ZMM5

	ADDQ $64, R11 // in4+=64

	ADDQ $64, DX  // out+=64
	ADDQ $64, CX  // out2+=64

	SUBQ $1, R9
	JNZ  loopback_avx512_parallel82

done_avx512_parallel82:
	VZEROUPPER
	RET

//
// Process 4 output rows in parallel from a total of 8 input rows
//
// func _galMulAVX512Parallel84(in, out [][]byte, matrix *[matrixSize84]byte, addTo bool)
TEXT ·_galMulAVX512Parallel84(SB), 7, $0
	MOVQ  in+0(FP), SI     //
	MOVQ  8(SI), R9        // R9: len(in)
	SHRQ  $6, R9           // len(in) / 64
	TESTQ R9, R9
	JZ    done_avx512_parallel84

	MOVQ matrix+48(FP), SI
	LONG $0x48fee162; WORD $0x066f // VMOVDQU64 ZMM16, 0x000[rsi]
	LONG $0x48fee162; WORD $0x4e6f; BYTE $0x01 // VMOVDQU64 ZMM17, 0x040[rsi]
	LONG $0x48fee162; WORD $0x566f; BYTE $0x02 // VMOVDQU64 ZMM18, 0x080[rsi]
	LONG $0x48fee162; WORD $0x5e6f; BYTE $0x03 // VMOVDQU64 ZMM19, 0x0c0[rsi]
	LONG $0x48fee162; WORD $0x666f; BYTE $0x04 // VMOVDQU64 ZMM20, 0x100[rsi]
	LONG $0x48fee162; WORD $0x6e6f; BYTE $0x05 // VMOVDQU64 ZMM21, 0x140[rsi]
	LONG $0x48fee162; WORD $0x766f; BYTE $0x06 // VMOVDQU64 ZMM22, 0x180[rsi]
	LONG $0x48fee162; WORD $0x7e6f; BYTE $0x07 // VMOVDQU64 ZMM23, 0x1c0[rsi]
	LONG $0x48fe6162; WORD $0x466f; BYTE $0x08 // VMOVDQU64 ZMM24, 0x200[rsi]
	LONG $0x48fe6162; WORD $0x4e6f; BYTE $0x09 // VMOVDQU64 ZMM25, 0x240[rsi]
	LONG $0x48fe6162; WORD $0x566f; BYTE $0x0a // VMOVDQU64 ZMM26, 0x280[rsi]
	LONG $0x48fe6162; WORD $0x5e6f; BYTE $0x0b // VMOVDQU64 ZMM27, 0x2c0[rsi]
	LONG $0x48fe6162; WORD $0x666f; BYTE $0x0c // VMOVDQU64 ZMM28, 0x300[rsi]
	LONG $0x48fe6162; WORD $0x6e6f; BYTE $0x0d // VMOVDQU64 ZMM29, 0x340[rsi]
	LONG $0x48fe6162; WORD $0x766f; BYTE $0x0e // VMOVDQU64 ZMM30, 0x380[rsi]
	LONG $0x48fe6162; WORD $0x7e6f; BYTE $0x0f // VMOVDQU64 ZMM31, 0x3c0[rsi]

	MOVQ         $15, BX
	MOVQ         BX, X5
	LONG $0x487df262; WORD $0xd578 // VPBROADCASTB ZMM2, XMM5

	MOVB addTo+56(FP), AX
	LONG $0xffc0c749; WORD $0xffff; BYTE $0xff // mov r8, -1
	WORD $0xf749; BYTE $0xe0 // mul r8
	LONG $0x92fbe1c4; BYTE $0xc8 // kmovq k1, rax
	MOVQ in+0(FP), SI  //  SI: &in
	MOVQ in_len+8(FP), AX  // number of inputs
	XORQ R11, R11
	MOVQ out+24(FP), DX
	MOVQ 24(DX), CX    //  CX: &out[1][0]
	MOVQ 48(DX), R10   // R10: &out[2][0]
	MOVQ 72(DX), R12   // R12: &out[3][0]
	MOVQ (DX), DX      //  DX: &out[0][0]

loopback_avx512_parallel84:
	LONG $0xc9fef162; WORD $0x226f // VMOVDQU64 ZMM4{k1}{z}, [rdx]
	LONG $0xc9fef162; WORD $0x296f // VMOVDQU64 ZMM5{k1}{z}, [rcx]
	LONG $0xc9fed162; WORD $0x326f // VMOVDQU64 ZMM6{k1}{z}, [r10]
	LONG $0xc9fed162; WORD $0x3c6f; BYTE $0x24 // VMOVDQU64 ZMM7{k1}{z}, [r12]

	MOVQ (SI), BX      //  BX: &in[0][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40fd3362; WORD $0xf043; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM16, ZMM16, 0x00
	LONG $0x40fd3362; WORD $0xf843; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM16, ZMM16, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40dd3362; WORD $0xe443; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM20, ZMM20, 0x00
	LONG $0x40dd3362; WORD $0xec43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM20, ZMM20, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40bd1362; WORD $0xd043; BYTE $0x00 // VSHUFI64x2 ZMM10, ZMM24, ZMM24, 0x00
	LONG $0x40bd1362; WORD $0xd843; BYTE $0x55 // VSHUFI64x2 ZMM11, ZMM24, ZMM24, 0x55
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x409d1362; WORD $0xc443; BYTE $0x00 // VSHUFI64x2 ZMM8, ZMM28, ZMM28, 0x00
	LONG $0x409d1362; WORD $0xcc43; BYTE $0x55 // VSHUFI64x2 ZMM9, ZMM28, ZMM28, 0x55
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $1
	JE skip_avx512_parallel84

     MOVQ 24(SI), BX    //  BX: &in[1][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40fd3362; WORD $0xf043; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM16, ZMM16, 0xaa
	LONG $0x40fd3362; WORD $0xf843; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM16, ZMM16, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40dd3362; WORD $0xe443; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM20, ZMM20, 0xaa
	LONG $0x40dd3362; WORD $0xec43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM20, ZMM20, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40bd1362; WORD $0xd043; BYTE $0xaa // VSHUFI64x2 ZMM10, ZMM24, ZMM24, 0xaa
	LONG $0x40bd1362; WORD $0xd843; BYTE $0xff // VSHUFI64x2 ZMM11, ZMM24, ZMM24, 0xff
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x409d1362; WORD $0xc443; BYTE $0xaa // VSHUFI64x2 ZMM8, ZMM28, ZMM28, 0xaa
	LONG $0x409d1362; WORD $0xcc43; BYTE $0xff // VSHUFI64x2 ZMM9, ZMM28, ZMM28, 0xff
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $2
	JE skip_avx512_parallel84

	MOVQ 48(SI), BX    //  BX: &in[2][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40f53362; WORD $0xf143; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM17, ZMM17, 0x00
	LONG $0x40f53362; WORD $0xf943; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM17, ZMM17, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40d53362; WORD $0xe543; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM21, ZMM21, 0x00
	LONG $0x40d53362; WORD $0xed43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM21, ZMM21, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40b51362; WORD $0xd143; BYTE $0x00 // VSHUFI64x2 ZMM10, ZMM25, ZMM25, 0x00
	LONG $0x40b51362; WORD $0xd943; BYTE $0x55 // VSHUFI64x2 ZMM11, ZMM25, ZMM25, 0x55
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x40951362; WORD $0xc543; BYTE $0x00 // VSHUFI64x2 ZMM8, ZMM29, ZMM29, 0x00
	LONG $0x40951362; WORD $0xcd43; BYTE $0x55 // VSHUFI64x2 ZMM9, ZMM29, ZMM29, 0x55
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $3
	JE skip_avx512_parallel84

	MOVQ 72(SI), BX    // BX: &in[3][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40f53362; WORD $0xf143; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM17, ZMM17, 0xaa
	LONG $0x40f53362; WORD $0xf943; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM17, ZMM17, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40d53362; WORD $0xe543; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM21, ZMM21, 0xaa
	LONG $0x40d53362; WORD $0xed43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM21, ZMM21, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40b51362; WORD $0xd143; BYTE $0xaa // VSHUFI64x2 ZMM10, ZMM25, ZMM25, 0xaa
	LONG $0x40b51362; WORD $0xd943; BYTE $0xff // VSHUFI64x2 ZMM11, ZMM25, ZMM25, 0xff
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x40951362; WORD $0xc543; BYTE $0xaa // VSHUFI64x2 ZMM8, ZMM29, ZMM29, 0xaa
	LONG $0x40951362; WORD $0xcd43; BYTE $0xff // VSHUFI64x2 ZMM9, ZMM29, ZMM29, 0xff
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $4
	JE skip_avx512_parallel84

	MOVQ 96(SI), BX    // BX: &in[4][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40ed3362; WORD $0xf243; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM18, ZMM18, 0x00
	LONG $0x40ed3362; WORD $0xfa43; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM18, ZMM18, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40cd3362; WORD $0xe643; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM22, ZMM22, 0x00
	LONG $0x40cd3362; WORD $0xee43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM22, ZMM22, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40ad1362; WORD $0xd243; BYTE $0x00 // VSHUFI64x2 ZMM10, ZMM26, ZMM26, 0x00
	LONG $0x40ad1362; WORD $0xda43; BYTE $0x55 // VSHUFI64x2 ZMM11, ZMM26, ZMM26, 0x55
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x408d1362; WORD $0xc643; BYTE $0x00 // VSHUFI64x2 ZMM8, ZMM30, ZMM30, 0x00
	LONG $0x408d1362; WORD $0xce43; BYTE $0x55 // VSHUFI64x2 ZMM9, ZMM30, ZMM30, 0x55
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $5
	JE skip_avx512_parallel84

	MOVQ 120(SI), BX   // BX: &in[5][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40ed3362; WORD $0xf243; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM18, ZMM18, 0xaa
	LONG $0x40ed3362; WORD $0xfa43; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM18, ZMM18, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40cd3362; WORD $0xe643; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM22, ZMM22, 0xaa
	LONG $0x40cd3362; WORD $0xee43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM22, ZMM22, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40ad1362; WORD $0xd243; BYTE $0xaa // VSHUFI64x2 ZMM10, ZMM26, ZMM26, 0xaa
	LONG $0x40ad1362; WORD $0xda43; BYTE $0xff // VSHUFI64x2 ZMM11, ZMM26, ZMM26, 0xff
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x408d1362; WORD $0xc643; BYTE $0xaa // VSHUFI64x2 ZMM8, ZMM30, ZMM30, 0xaa
	LONG $0x408d1362; WORD $0xce43; BYTE $0xff // VSHUFI64x2 ZMM9, ZMM30, ZMM30, 0xff
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $6
	JE skip_avx512_parallel84

	MOVQ 144(SI), BX   // BX: &in[6][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40e53362; WORD $0xf343; BYTE $0x00 // VSHUFI64x2 ZMM14, ZMM19, ZMM19, 0x00
	LONG $0x40e53362; WORD $0xfb43; BYTE $0x55 // VSHUFI64x2 ZMM15, ZMM19, ZMM19, 0x55
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40c53362; WORD $0xe743; BYTE $0x00 // VSHUFI64x2 ZMM12, ZMM23, ZMM23, 0x00
	LONG $0x40c53362; WORD $0xef43; BYTE $0x55 // VSHUFI64x2 ZMM13, ZMM23, ZMM23, 0x55
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40a51362; WORD $0xd343; BYTE $0x00 // VSHUFI64x2 ZMM10, ZMM27, ZMM27, 0x00
	LONG $0x40a51362; WORD $0xdb43; BYTE $0x55 // VSHUFI64x2 ZMM11, ZMM27, ZMM27, 0x55
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x40851362; WORD $0xc743; BYTE $0x00 // VSHUFI64x2 ZMM8, ZMM31, ZMM31, 0x00
	LONG $0x40851362; WORD $0xcf43; BYTE $0x55 // VSHUFI64x2 ZMM9, ZMM31, ZMM31, 0x55
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

	CMPQ AX, $7
	JE skip_avx512_parallel84

	MOVQ 168(SI), BX   //  BX: &in[7][0]
	LONG $0x48feb162; WORD $0x046f; BYTE $0x1b // VMOVDQU64 ZMM0, [rbx+r11]
	LONG $0x40e53362; WORD $0xf343; BYTE $0xaa // VSHUFI64x2 ZMM14, ZMM19, ZMM19, 0xaa
	LONG $0x40e53362; WORD $0xfb43; BYTE $0xff // VSHUFI64x2 ZMM15, ZMM19, ZMM19, 0xff
	LONG $0x48f5f162; WORD $0xd073; BYTE $0x04 // VPSRLQ   ZMM1, ZMM0, 4     ; high input
	LONG $0x48fdf162; WORD $0xc2db // VPANDQ   ZMM0, ZMM0, ZMM2  ; low input
	LONG $0x48f5f162; WORD $0xcadb // VPANDQ   ZMM1, ZMM1, ZMM2  ; high input
	LONG $0x480d7262; WORD $0xf000 // VPSHUFB  ZMM14, ZMM14, ZMM0  ; mul low part
	LONG $0x48057262; WORD $0xf900 // VPSHUFB  ZMM15, ZMM15, ZMM1  ; mul high part
	LONG $0x488d5162; WORD $0xf7ef // VPXORQ   ZMM14, ZMM14, ZMM15  ; result
	LONG $0x48ddd162; WORD $0xe6ef // VPXORQ   ZMM4, ZMM4, ZMM14

	LONG $0x40c53362; WORD $0xe743; BYTE $0xaa // VSHUFI64x2 ZMM12, ZMM23, ZMM23, 0xaa
	LONG $0x40c53362; WORD $0xef43; BYTE $0xff // VSHUFI64x2 ZMM13, ZMM23, ZMM23, 0xff
	LONG $0x481d7262; WORD $0xe000 // VPSHUFB  ZMM12, ZMM12, ZMM0  ; mul low part
	LONG $0x48157262; WORD $0xe900 // VPSHUFB  ZMM13, ZMM13, ZMM1  ; mul high part
	LONG $0x489d5162; WORD $0xe5ef // VPXORQ   ZMM12, ZMM12, ZMM13  ; result
	LONG $0x48d5d162; WORD $0xecef // VPXORQ   ZMM5, ZMM5, ZMM12

	LONG $0x40a51362; WORD $0xd343; BYTE $0xaa // VSHUFI64x2 ZMM10, ZMM27, ZMM27, 0xaa
	LONG $0x40a51362; WORD $0xdb43; BYTE $0xff // VSHUFI64x2 ZMM11, ZMM27, ZMM27, 0xff
	LONG $0x482d7262; WORD $0xd000 // VPSHUFB  ZMM10, ZMM10, ZMM0  ; mul low part
	LONG $0x48257262; WORD $0xd900 // VPSHUFB  ZMM11, ZMM11, ZMM1  ; mul high part
	LONG $0x48ad5162; WORD $0xd3ef // VPXORQ   ZMM10, ZMM10, ZMM11  ; result
	LONG $0x48cdd162; WORD $0xf2ef // VPXORQ   ZMM6, ZMM6, ZMM10

	LONG $0x40851362; WORD $0xc743; BYTE $0xaa // VSHUFI64x2 ZMM8, ZMM31, ZMM31, 0xaa
	LONG $0x40851362; WORD $0xcf43; BYTE $0xff // VSHUFI64x2 ZMM9, ZMM31, ZMM31, 0xff
	LONG $0x483d7262; WORD $0xc000 // VPSHUFB  ZMM8, ZMM8, ZMM0  ; mul low part
	LONG $0x48357262; WORD $0xc900 // VPSHUFB  ZMM9, ZMM9, ZMM1  ; mul high part
	LONG $0x48bd5162; WORD $0xc1ef // VPXORQ   ZMM8, ZMM8, ZMM9  ; result
	LONG $0x48c5d162; WORD $0xf8ef // VPXORQ   ZMM7, ZMM7, ZMM8

skip_avx512_parallel84:
	LONG $0x48fef162; WORD $0x227f // VMOVDQU64 [rdx], ZMM4
	LONG $0x48fef162; WORD $0x297f // VMOVDQU64 [rcx], ZMM5
	LONG $0x48fed162; WORD $0x327f // VMOVDQU64 [r10], ZMM6
	LONG $0x48fed162; WORD $0x3c7f; BYTE $0x24 // VMOVDQU64 [r12], ZMM7

	ADDQ $64, R11 // in4+=64

	ADDQ $64, DX  // out+=64
	ADDQ $64, CX  // out2+=64
	ADDQ $64, R10 // out3+=64
	ADDQ $64, R12 // out4+=64

	SUBQ $1, R9
	JNZ  loopback_avx512_parallel84

done_avx512_parallel84:
	VZEROUPPER
	RET