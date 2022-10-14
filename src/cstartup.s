;;; Startup variant, change attribute value if you make your own
              .rtmodel cstartup,"petit-fatfs"

              .rtmodel version, "1"

              .rtmodel core, "*"

              .section stack
              .section cstack
              .section heap
              .section data_init_table

              .extern main, exit
              .extern _Zp, _Vsp, _Vfp

;;; ***************************************************************************
;;;
;;; __program_start - actual start point of the program
;;;
;;; Set up CPU stack, C stack, initialize sections and call main().
;;; You can override this with your own routine, or tailor it as needed.
;;;
;;; ***************************************************************************

              .section programStart
              .pubweak __program_root_section
              .pubweak __program_start
__program_root_section:
__program_start:

              lda     #.byte0(.sectionEnd cstack)
              sta     zp:_Vsp
              lda     #.byte1(.sectionEnd cstack)
              sta     zp:_Vsp+1

;;; **** Initialize data sections if needed.
              .section code, noroot, noreorder
              .pubweak __data_initialization_needed
              .extern __initialize_sections
__data_initialization_needed:
              lda     #.byte0 (.sectionStart data_init_table)
              sta     zp:_Zp
              lda     #.byte1 (.sectionStart data_init_table)
              sta     zp:_Zp+1
              lda     #.byte0 (.sectionEnd data_init_table)
              sta     zp:_Zp+2
              lda     #.byte1 (.sectionEnd data_init_table)
              sta     zp:_Zp+3
              jsr     __initialize_sections

;;; **** Initialize streams if needed.
              .section code, noroot, noreorder
              .pubweak __call_initialize_global_streams
              .extern __initialize_global_streams
__call_initialize_global_streams:
              jsr     __initialize_global_streams

;;; **** Initialize heap if needed.
              .section code, noroot, noreorder
              .pubweak __call_heap_initialize
              .extern __heap_initialize, __default_heap
__call_heap_initialize:
              lda     #.byte0 __default_heap
              sta     zp:_Zp+0
              lda     #.byte1 __default_heap
              sta     zp:_Zp+1
              lda     #.byte0 (.sectionStart heap)
              sta     zp:_Zp+2
              lda     #.byte1 (.sectionStart heap)
              sta     zp:_Zp+3
              lda     #.byte0 (.sectionSize heap)
              sta     zp:_Zp+4
              lda     #.byte1 (.sectionSize heap)
              sta     zp:_Zp+5
              jsr     __heap_initialize

              .section code, root, noreorder
              .extern disk_initialize
              jmp     disk_initialize
