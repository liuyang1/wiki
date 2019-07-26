/* File: startup_ARMCM4.S
 * Purpose: startup file for Cortex-M4 devices. Should use with
 *   GCC for ARM Embedded Processors
 * Version: V2.0
 * Date: 16 August 2013
 *
/* Copyright (c) 2011 - 2013 ARM LIMITED

   All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
   - Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
   - Neither the name of ARM nor the names of its contributors may be used
     to endorse or promote products derived from this software without
     specific prior written permission.
   *
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
   ---------------------------------------------------------------------------*/
	.syntax	unified
	.arch	armv7e-m

	.extern __SRAM_segment_end__
	/*.extern xPortSysTickHandler
	.extern xPortPendSVHandler
	.extern vPortSVCHandler
	.extern xPortSysTickHandler
	.extern NMI_Handler
	.extern HardFault_Handler
	.extern MemManage_Handler
	.extern BusFault_Handler
	.extern UsageFault_Handler
	.extern DummyHandler*/
	.extern vMbInterrupt

	.section .isr_vector
	.align	4
	.globl	__isr_vector
	.global __Vectors
__Vectors:
__isr_vector:
	.long	__SRAM_segment_end__ - 512  /* Top of Stack at top of RAM*/
	.long	Reset_Handler         /* Reset Handler */
	.long	NMI_Handler           /* NMI Handler */
	.long	HardFault_Handler     /* Hard Fault Handler */
	.long	MemManage_Handler     /* MPU Fault Handler */
	.long	BusFault_Handler      /* Bus Fault Handler */
	.long	UsageFault_Handler    /* Usage Fault Handler */
	.long	0                     /* Reserved */
	.long	0                     /* Reserved */
	.long	0                     /* Reserved */
	.long	0                     /* Reserved */
	.long	vPortSVCHandler       /* SVCall Handler */
	.long	DebugMon_Handler      /* Debug Monitor Handler */
	.long	0                     /* Reserved */
	.long	xPortPendSVHandler        /* PendSV Handler */
	.long	xPortSysTickHandler       /* SysTick Handler */

	/* External interrupts */
	.long	DummyHandler          /* 0  */
	.long	DummyHandler          /* 1  */
	.long	DummyHandler          /* 2  */
	.long	DummyHandler          /* 3  */
	.long	DummyHandler          /* 4  */
	.long	DummyHandler          /* 5  */
	.long	DummyHandler          /* 6  */
	.long	DummyHandler          /* 7  */
	.long	DummyHandler          /* 8  */
	.long	DummyHandler          /* 9  */
	.long	DummyHandler          /* 10 */
	.long	DummyHandler          /* 11 */
	.long	DummyHandler          /* 12 */
	.long	DummyHandler          /* 13 */
	.long	DummyHandler          /* 14 */
	.long	DummyHandler          /* 15 */
	.long	DummyHandler          /* 16 */
	.long	DummyHandler          /* 17 */
	.long	DummyHandler          /* 18 */
	.long	DummyHandler          /* 19 */
	.long	DummyHandler          /* 20 */
	.long	DummyHandler          /* 21 */
	.long	DummyHandler          /* 22 */
	.long	DummyHandler          /* 23 */
	.long	DummyHandler          /* 24 */
	.long	DummyHandler          /* 25 */
	.long	DummyHandler          /* 26 */
	.long	DummyHandler          /* 27 */
	.long	DummyHandler          /* 28 */
	.long	DummyHandler          /* 29 */
	.long	DummyHandler          /* 30 */
	.long	DummyHandler          /* 31 */
	.long	DummyHandler          /* 32 */
	.long	DummyHandler          /* 33 */
	.long	DummyHandler          /* 34 */
	.long	DummyHandler          /* 35 */
	.long	DummyHandler          /* 36 */
	.long	DummyHandler          /* 37 */
	.long	DummyHandler          /* 38 */
	.long	DummyHandler          /* 39 */
	.long	DummyHandler          /* 40 */
	.long	DummyHandler          /* 41 */
	.long	DummyHandler          /* 42 */
	.long	DummyHandler          /* 43 */
	.long	DummyHandler          /* 44 */
	.long	DummyHandler          /* 45 */
	.long	DummyHandler          /* 46 */
	.long	DummyHandler          /* 47 */
	.long	DummyHandler          /* 48 */
	.long	DummyHandler          /* 49 */
	.long	DummyHandler          /* 50 */
	.long	DummyHandler          /* 51 */
	.long	DummyHandler          /* 52 */
	.long	DummyHandler          /* 53 */
	.long	DummyHandler          /* 54 */
	.long	DummyHandler          /* 55 */
	.long	DummyHandler          /* 56 */
	.long	DummyHandler          /* 57 */
	.long	DummyHandler          /* 58 */
	.long	DummyHandler          /* 59 */
	.long	DummyHandler          /* 60 */
	.long	DummyHandler          /* 61 */
	.long	DummyHandler          /* 62 */
	.long	DummyHandler          /* 63 */
	.long	DummyHandler          /* 64 */
	.long	DummyHandler          /* 65 */
	.long	DummyHandler          /* 66 */
	.long	DummyHandler          /* 67 */
	.long	DummyHandler          /* 68 */
	.long	DummyHandler          /* 69 */
	.long	DummyHandler          /* 70 */
	.long	DummyHandler          /* 71 */
	.long	DummyHandler          /* 72 */
	.long	DummyHandler          /* 73 */
	.long	DummyHandler          /* 74 */
	.long	DummyHandler          /* 75 */
	.long	DummyHandler          /* 76 */
	.long	DummyHandler          /* 77 */
	.long	DummyHandler          /* 78 */
	.long	DummyHandler          /* 79 */
	.long	DummyHandler          /* 80 */
	.long	DummyHandler          /* 81 */
	.long	DummyHandler          /* 82 */
	.long	DummyHandler          /* 83 */
	.long	DummyHandler          /* 84 */
	.long	DummyHandler          /* 85 */
	.long	DummyHandler          /* 86 */
	.long	DummyHandler          /* 87 */
	.long	DummyHandler          /* 88 */
	.long	DummyHandler          /* 89 */
	.long	DummyHandler          /* 90 */
	.long	DummyHandler          /* 91 */


	.text
	.thumb
	.thumb_func
	.align	2
	.globl _start
	.extern main
	.globl	Reset_Handler
	.type	Reset_Handler, %function
_start:
Reset_Handler:
/*  Firstly it copies data from read only memory to RAM. There are two schemes
 *  to copy. One can copy more than one sections. Another can only copy
 *  one section.  The former scheme needs more instructions and read-only
 *  data to implement than the latter.
 *  Macro __STARTUP_COPY_MULTIPLE is used to choose between two schemes.  */

/*  Single section scheme.
 *
 *  The ranges of copy from/to are specified by following symbols
 *    __etext: LMA of start of the section to copy from. Usually end of text
 *    __data_start__: VMA of start of the section to copy to
 *    __data_end__: VMA of end of the section to copy to
 *
 *  All addresses must be aligned to 4 bytes boundary.
 */
	ldr	r1, =__etext
	ldr	r2, =__data_start__
	ldr	r3, =__data_end__

.L_loop1:
	cmp	r2, r3				# compare R2, R3, store result to APSR
	ittt	lt				# If-Then-Then-Then, If condition, then do 3 instructions
							# condtional-jump, there are ITT, ITE, ITTET, many format
	ldrlt	r0, [r1], #4	# loader
	strlt	r0, [r2], #4	# store
	blt	.L_loop1			# B: jump

/*  This part of work usually is done in C library startup code. Otherwise,
 *  define this macro to enable it in this startup.
 *
 *  There are two schemes too. One can clear multiple BSS sections. Another
 *  can only clear one section. The former is more size expensive than the
 *  latter.
 *
 *  Define macro __STARTUP_CLEAR_BSS_MULTIPLE to choose the former.
 *  Otherwise efine macro __STARTUP_CLEAR_BSS to choose the later.
 */

 /*  Single BSS section scheme.
 *
 *  The BSS section is specified by following symbols
 *    __bss_start__: start of the BSS section.
 *    __bss_end__: end of the BSS section.
 *
 *  Both addresses must be aligned to 4 bytes boundary.
 */
	ldr	r1, =__bss_start__
	ldr	r2, =__bss_end__

	movs	r0, 0		# set R0 <= 0
.L_loop3:
	cmp	r1, r2
	itt	lt
	strlt	r0, [r1], #4	# set [R1] to 0
	blt	.L_loop3

#ifndef __NO_SYSTEM_INIT
/*	bl	SystemInit */
#endif

	bl	main

	.pool
	.size	Reset_Handler, . - Reset_Handler

	.align	1
	.thumb_func
	.weak	Default_Handler
	.type	Default_Handler, %function
Default_Handler:
	b	.
	.size	Default_Handler, . - Default_Handler

/*    Macro to define default handlers. Default handler
 *    will be weak symbol and just dead loops. They can be
 *    overwritten by other handlers */
	.macro	def_irq_handler	handler_name
	.weak	\handler_name
	.set	\handler_name, Default_Handler
	.endm

	/*def_irq_handler	NMI_Handler*/
	/*def_irq_handler	HardFault_Handler*/
	/*def_irq_handler	MemManage_Handler*/
	/*def_irq_handler	BusFault_Handler*/
	/*def_irq_handler	UsageFault_Handler*/
	/*def_irq_handler	vPortSVCHandler*/
	def_irq_handler	DebugMon_Handler
	/*def_irq_handler	xPortPendSVHandler*/
	/*def_irq_handler	xPortSysTickHandler*/
	/*def_irq_handler	DEF_IRQHandler*/
	def_irq_handler	DummyHandler


	.end
