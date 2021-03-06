/*********************************************************************/
/*                                                                   */
/*             Optimized BLAS libraries                              */
/*                     By Kazushige Goto <kgoto@tacc.utexas.edu>     */
/*                                                                   */
/* Copyright (c) The University of Texas, 2009. All rights reserved. */
/* UNIVERSITY EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES CONCERNING  */
/* THIS SOFTWARE AND DOCUMENTATION, INCLUDING ANY WARRANTIES OF      */
/* MERCHANTABILITY, FITNESS FOR ANY PARTICULAR PURPOSE,              */
/* NON-INFRINGEMENT AND WARRANTIES OF PERFORMANCE, AND ANY WARRANTY  */
/* THAT MIGHT OTHERWISE ARISE FROM COURSE OF DEALING OR USAGE OF     */
/* TRADE. NO WARRANTY IS EITHER EXPRESS OR IMPLIED WITH RESPECT TO   */
/* THE USE OF THE SOFTWARE OR DOCUMENTATION.                         */
/* Under no circumstances shall University be liable for incidental, */
/* special, indirect, direct or consequential damages or loss of     */
/* profits, interruption of business, or related expenses which may  */
/* arise from use of Software or Documentation, including but not    */
/* limited to those resulting from defects in Software and/or        */
/* Documentation, or loss or inaccuracy of data of any kind.         */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"

#define STACK	12
#define ARGS     0
	
#define RESULT		 4 + STACK + ARGS(%esp)
#define STACK_N		 8 + STACK + ARGS(%esp)
#define STACK_X		12 + STACK + ARGS(%esp)
#define STACK_INCX	16 + STACK + ARGS(%esp)
#define STACK_Y		20 + STACK + ARGS(%esp)
#define STACK_INCY	24 + STACK + ARGS(%esp)

#define N	%ebx
#define X	%esi
#define INCX	%ecx
#define Y	%edi
#define INCY	%edx

#include "l1param.h"

#undef movsd

#ifndef OPTERON
#define movlps	movsd
#endif

	PROLOGUE
	PROFCODE

	pushl	%edi
	pushl	%esi
	pushl	%ebx

	movl	STACK_N,     N
	movl	STACK_X,     X
	movl	STACK_INCX,  INCX
	movl	STACK_Y,     Y
	movl	STACK_INCY,  INCY

	sall	$ZBASE_SHIFT, INCX
	sall	$ZBASE_SHIFT, INCY

	xorps	%xmm0, %xmm0
	xorps	%xmm1, %xmm1

	cmpl	$0, N
	jle	.L999

	cmpl	$2 * SIZE, INCX
	jne	.L50
	cmpl	$2 * SIZE, INCY
	jne	.L50

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y

	testl	$SIZE, Y
	jne	.L30

	testl	$SIZE, X
	jne	.L20

	movl	N,  %eax
	sarl	$3, %eax
	jle	.L15

	movaps	-16 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6
	movaps	-14 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	decl	%eax
	jle	.L12
	ALIGN_3

.L11:
#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-12 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	-10 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -8 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	 -6 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(X)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -4 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	 -2 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	  0 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	  0 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	  2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	  2 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y

	decl	%eax
	jg	.L11
	ALIGN_3

.L12:
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-12 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	-10 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -8 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	 -6 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -4 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	 -2 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y
	ALIGN_3

.L15:
	testl	$4, N
	jle	.L16

	movaps	-16 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6
	movaps	-14 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-12 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movaps	-10 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L16:
	testl	$2, N
	jle	.L17

	movaps	-16 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6
	movaps	-14 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L17:
	testl	$1, N
	jle	.L98

	movaps	-16 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6

	pshufd	$0x4e,  %xmm6, %xmm3 
	mulpd	%xmm4,  %xmm6
	addpd	%xmm6,  %xmm0
	mulpd	%xmm4,  %xmm3
	addpd	%xmm3, %xmm1
	jmp	.L98
	ALIGN_3

.L20:
	movl	N,  %eax
	sarl	$3, %eax
	jle	.L25

	movlps	-16 * SIZE(X), %xmm4
	movhps	-15 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6

	movlps	-14 * SIZE(X), %xmm5
	movhps	-13 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	decl	%eax
	jle	.L22
	ALIGN_3

.L21:
#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(X), %xmm4
	movhps	-11 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(X), %xmm5
	movhps	 -9 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -8 * SIZE(X), %xmm4
	movhps	 -7 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -6 * SIZE(X), %xmm5
	movhps	 -5 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(X)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -4 * SIZE(X), %xmm4
	movhps	 -3 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -2 * SIZE(X), %xmm5
	movhps	 -1 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	  0 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	  0 * SIZE(X), %xmm4
	movhps	  1 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	  2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	  2 * SIZE(X), %xmm5
	movhps	  3 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y

	decl	%eax
	jg	.L21
	ALIGN_3

.L22:
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(X), %xmm4
	movhps	-11 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(X), %xmm5
	movhps	 -9 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -8 * SIZE(X), %xmm4
	movhps	 -7 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -6 * SIZE(X), %xmm5
	movhps	 -5 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -4 * SIZE(X), %xmm4
	movhps	 -3 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -2 * SIZE(X), %xmm5
	movhps	 -1 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y
	ALIGN_3

.L25:
	testl	$4, N
	jle	.L26

	movlps	-16 * SIZE(X), %xmm4
	movhps	-15 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6

	movlps	-14 * SIZE(X), %xmm5
	movhps	-13 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(X), %xmm4
	movhps	-11 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(Y), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(X), %xmm5
	movhps	 -9 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L26:
	testl	$2, N
	jle	.L27

	movlps	-16 * SIZE(X), %xmm4
	movhps	-15 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	movlps	-14 * SIZE(X), %xmm5
	movhps	-13 * SIZE(X), %xmm5
	movaps	-14 * SIZE(Y), %xmm7

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L27:
	testl	$1, N
	jle	.L98

	movlps	-16 * SIZE(X), %xmm4
	movhps	-15 * SIZE(X), %xmm4
	movaps	-16 * SIZE(Y), %xmm6

	pshufd	$0x4e,  %xmm6, %xmm3 
	mulpd	%xmm4,  %xmm6
	addpd	%xmm6,  %xmm0
	mulpd	%xmm4,  %xmm3
	addpd	%xmm3, %xmm1
	jmp	.L98
	ALIGN_3

.L30:
	testl	$SIZE, X
	jne	.L40

	movl	N,  %eax
	sarl	$3, %eax
	jle	.L35

	movlps	-16 * SIZE(Y), %xmm4
	movhps	-15 * SIZE(Y), %xmm4
	movaps	-16 * SIZE(X), %xmm6

	movlps	-14 * SIZE(Y), %xmm5
	movhps	-13 * SIZE(Y), %xmm5
	movaps	-14 * SIZE(X), %xmm7

	decl	%eax
	jle	.L32
	ALIGN_3

.L31:
#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(Y), %xmm4
	movhps	-11 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(Y), %xmm5
	movhps	 -9 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -8 * SIZE(Y), %xmm4
	movhps	 -7 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -6 * SIZE(Y), %xmm5
	movhps	 -5 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(Y)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -4 * SIZE(Y), %xmm4
	movhps	 -3 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -2 * SIZE(Y), %xmm5
	movhps	 -1 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(X)
#endif

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	  0 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	  0 * SIZE(Y), %xmm4
	movhps	  1 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	  2 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	  2 * SIZE(Y), %xmm5
	movhps	  3 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y

	decl	%eax
	jg	.L31
	ALIGN_3

.L32:
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(Y), %xmm4
	movhps	-11 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(Y), %xmm5
	movhps	 -9 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -8 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -8 * SIZE(Y), %xmm4
	movhps	 -7 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -6 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -6 * SIZE(Y), %xmm5
	movhps	 -5 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -4 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	 -4 * SIZE(Y), %xmm4
	movhps	 -3 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	 -2 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	 -2 * SIZE(Y), %xmm5
	movhps	 -1 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y
	ALIGN_3

.L35:
	testl	$4, N
	jle	.L36

	movlps	-16 * SIZE(Y), %xmm4
	movhps	-15 * SIZE(Y), %xmm4
	movaps	-16 * SIZE(X), %xmm6

	movlps	-14 * SIZE(Y), %xmm5
	movhps	-13 * SIZE(Y), %xmm5
	movaps	-14 * SIZE(X), %xmm7

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-12 * SIZE(X), %xmm6
	mulpd	%xmm4, %xmm3
	movlps	-12 * SIZE(Y), %xmm4
	movhps	-11 * SIZE(Y), %xmm4
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movaps	-10 * SIZE(X), %xmm7
	mulpd	%xmm5, %xmm3
	movlps	-10 * SIZE(Y), %xmm5
	movhps	 -9 * SIZE(Y), %xmm5
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L36:
	testl	$2, N
	jle	.L37

	movlps	-16 * SIZE(Y), %xmm4
	movhps	-15 * SIZE(Y), %xmm4
	movaps	-16 * SIZE(X), %xmm6

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	movlps	-14 * SIZE(Y), %xmm5
	movhps	-13 * SIZE(Y), %xmm5
	movaps	-14 * SIZE(X), %xmm7

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L37:
	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm3, %xmm3

	testl	$1, N
	jle	.L98

	movlps	-16 * SIZE(Y), %xmm4
	movhps	-15 * SIZE(Y), %xmm4
	movaps	-16 * SIZE(X), %xmm6

	pshufd	$0x4e,  %xmm6, %xmm3 
	mulpd	%xmm4,  %xmm6
	addpd	%xmm6,  %xmm0
	mulpd	%xmm4,  %xmm3
	SHUFPD_1 %xmm3, %xmm3
	addpd	%xmm3, %xmm1
	jmp	.L98
	ALIGN_3

.L40:
	movhps	-16 * SIZE(X), %xmm4
	addl	$SIZE, X
	movhps	-16 * SIZE(Y), %xmm6
	addl	$SIZE, Y

	movl	N,  %eax
	sarl	$3, %eax
	jle	.L45

	movaps	-16 * SIZE(X), %xmm5
	movaps	-16 * SIZE(Y), %xmm7

	decl	%eax
	jle	.L42
	ALIGN_3

.L41:
#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(Y)
#endif

#ifdef PREFETCH
	PREFETCH (PREFETCHSIZE +  0) - PREOFFSET(X)
#endif


#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(Y)
#endif


#if defined(PREFETCH) && !defined(FETCH128)
	PREFETCH (PREFETCHSIZE +  64) - PREOFFSET(X)
#endif

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-14 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-14 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	-12 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	-12 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-10 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-10 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	 -8 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	 -8 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -6 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -6 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	 -4 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	 -4 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -2 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -2 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	  0 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	  0 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y

	decl	%eax
	jg	.L41
	ALIGN_3

.L42:
	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-14 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-14 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	-12 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	-12 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-10 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-10 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	 -8 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	 -8 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -6 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -6 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	 -4 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	 -4 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	 -2 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	 -2 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	mulpd	%xmm5,  %xmm3
	addpd	%xmm3, %xmm1

	subl	$-16 * SIZE, X
	subl	$-16 * SIZE, Y
	ALIGN_3

.L45:
	testl	$4, N
	jle	.L46

	movaps	-16 * SIZE(X), %xmm5
	movaps	-16 * SIZE(Y), %xmm7

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-14 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-14 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	movaps	-12 * SIZE(Y), %xmm7
	mulpd	%xmm5,  %xmm3
	movaps	-12 * SIZE(X), %xmm5
	addpd	%xmm3, %xmm1

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-10 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-10 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	mulpd	%xmm5,  %xmm3
	addpd	%xmm3, %xmm1

	addl	$8 * SIZE, X
	addl	$8 * SIZE, Y
	ALIGN_3

.L46:
	testl	$2, N
	jle	.L47

	movaps	-16 * SIZE(X), %xmm5
	movaps	-16 * SIZE(Y), %xmm7

	movsd	%xmm7, %xmm6
	pshufd	$0x4e, %xmm6, %xmm3 
	movsd	%xmm5, %xmm4
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movaps	-14 * SIZE(Y), %xmm6
	mulpd	%xmm4, %xmm3
	movaps	-14 * SIZE(X), %xmm4
	addpd	%xmm3, %xmm1

	movsd	%xmm6, %xmm7
	pshufd	$0x4e,  %xmm7, %xmm3 
	movsd	%xmm4,  %xmm5
	mulpd	%xmm5,  %xmm7
	addpd	%xmm7,  %xmm0
	mulpd	%xmm5,  %xmm3
	addpd	%xmm3, %xmm1

	addl	$4 * SIZE, X
	addl	$4 * SIZE, Y
	ALIGN_3

.L47:
	testl	$1, N
	jle	.L48

	movlps	-16 * SIZE(X), %xmm4
	movlps	-16 * SIZE(Y), %xmm6

	pshufd	$0x4e,  %xmm6, %xmm3 
	mulpd	%xmm4,  %xmm6
	addpd	%xmm6,  %xmm0
	mulpd	%xmm4,  %xmm3
	addpd	%xmm3, %xmm1
	ALIGN_3

.L48:
	SHUFPD_1 %xmm0, %xmm0
	SHUFPD_1 %xmm1, %xmm1
	SHUFPD_1 %xmm2, %xmm2
	SHUFPD_1 %xmm3, %xmm3
	jmp	.L98	
	ALIGN_3

.L50:
	movl	N,  %eax
	sarl	$3, %eax
	jle	.L55

	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y

	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y

	decl	%eax
	jle	.L54
	ALIGN_3

.L53:
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	decl	%eax
	jg	.L53
	ALIGN_3

.L54:
	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1
	ALIGN_3

.L55:
	testl	$4, N
	jle	.L56

	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y

	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y
	mulpd	%xmm4, %xmm3
	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y
	mulpd	%xmm5, %xmm3
	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1
	ALIGN_3

.L56:
	testl	$2, N
	jle	.L57

	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6
	addl	INCY, Y

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1

	movlps	0 * SIZE(X), %xmm5
	movhps	1 * SIZE(X), %xmm5
	addl	INCX, X
	movlps	0 * SIZE(Y), %xmm7
	movhps	1 * SIZE(Y), %xmm7
	addl	INCY, Y

	pshufd	$0x4e, %xmm7, %xmm3 
	mulpd	%xmm5, %xmm7
	addpd	%xmm7, %xmm0
	mulpd	%xmm5, %xmm3
	addpd	%xmm3, %xmm1
	ALIGN_3

.L57:
	testl	$1, N
	jle	.L98

	movlps	0 * SIZE(X), %xmm4
	movhps	1 * SIZE(X), %xmm4
	movlps	0 * SIZE(Y), %xmm6
	movhps	1 * SIZE(Y), %xmm6

	pshufd	$0x4e, %xmm6, %xmm3 
	mulpd	%xmm4, %xmm6
	addpd	%xmm6, %xmm0
	mulpd	%xmm4, %xmm3
	addpd	%xmm3, %xmm1
	ALIGN_3

.L98:
	pshufd	$0x4e, %xmm0, %xmm2
	pshufd	$0x4e, %xmm1, %xmm3

#ifndef CONJ
	subsd	 %xmm2, %xmm0
	addsd	 %xmm3, %xmm1
#else
	addsd	 %xmm2, %xmm0
	subsd	 %xmm3, %xmm1
#endif

.L999:
	movl	RESULT, %eax

	movlps	%xmm0, 0 * SIZE(%eax)
	movlps	%xmm1, 1 * SIZE(%eax)

	popl	%ebx
	popl	%esi
	popl	%edi
	ret
	EPILOGUE
