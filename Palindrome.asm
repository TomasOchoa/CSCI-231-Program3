INCLUDE Irvine32.inc
TITLE Palindrome Checker              (Palindrome.asm)
;// PROGRAM 3
;//
;// AUTHOR: Tomas Ochoa
;// DUE DATE: 22 October 2015

;// This program will take keyboard input using character strings and punctuations.
;// The program will then decide wheter or not the input is a palindrome and then 
;// display the results. 
;// Include file for Irvine32 functions

.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword
;//******************* Data Segment ********************
.data
;// Prompts
Prompt1			BYTE "Please enter a string: ", 0
Prompt3			BYTE "Colors have been set back to default!", 0
Prompt4			BYTE	"Goodbye!", 0
Prompt2			BYTE "Original String:  ", 0
Prompt5			BYTE "Copy of String:   ", 0
Prompt7			BYTE "Reversed String:  ", 0
Prompt8			BYTE "Would you like to check another string? (y/n): ",0
Prompt9			BYTE "Invalid Input! Try again: ", 0
IS_Palindrome		BYTE "--> This string is a palindrome", 0
NOT_Palindrome		BYTE "--> This string is not a palindrome", 0

;// String Stuff
StringInput		BYTE 30 dup(0), 0					;// Max of 30 chars + 1 for null terminated 
StringInputCopy	BYTE SIZEOF StringInput DUP(0), 0		;// Size of StringInput and initilize with '#'s
StringInputCopyRed	BYTE SIZEOF StringInputCopy DUP(0), 0
StringInputCopyRev	BYTE SIZEOF StringInputCopyRed DUP(0), 0
StringInputReversed	BYTE	SIZEOF StringInput DUP(0),0
StringByteCount	DWORD 0		;// Counter for Strings
RevByteCount		DWORD 0		;// variablr hold offset elements 
CharsRemoved		DWORD 0		;// # of Removed Characters
Flag				BYTE  0		;// Status flag	
Decision			BYTE	 ?		;// to hold a decision from user

;// Constants
TRUE				EQU	 1		;// "on"
FALSE			EQU	 0		;// "off" 

;// Stuff for colors
GreyTextOnBlue		= lightGray + (blue * 16)
DefaultColor		= white + (black * 16)

;//******************* Code Segment ********************
.code
;//######################################## Main Routine ########################################
main		PROC	
mov		eax, 0
mov		ebx, 0
mov		ecx, 0
mov		edx, 0
mov		esi, 0
mov		edi, 0

;// Change the FG and BG Colors
	call		ColorChange	
	;// Recieve Input 
	call		Input
	
	;// Call Palindrome Procedure 
	call		Palindrome 
	
	;// Display Results 
	call		Display 
		;// Prompt user and ask to try again
	call		Crlf 
	mov		edx, OFFSET Prompt8
	call		WriteString 
AL1:	;// Recieve input
	call		ReadChar 
	mov		Decision, al
 
	.IF(al == 'y') || (al == 'Y')
		jmp	main 
	.ELSEIF(al == 'n') || (al == 'N')
		jmp	NO  
	.ELSE
		mov	edx, OFFSET Prompt9 
		call WriteString 
		jmp	AL1 
	.ENDIF
NO:
	;// PAUSE FOR 2 SECINDS
	mov		eax, 5000	
	call		Delay 	
	;// RIGHT BEFORE EXITING CHANGE BACK THE SYSTEM CALLERS
	call		DefaultColorChange
	mov		edx, OFFSET Prompt4 
	call		WriteString
	call		Crlf 	
	;// PAUSE FOR 2 SECONDS (System"Pause")
	mov		eax, 2000	
	call		Delay 	
	;// END MAIN
	invoke	ExitProcess, 0
main		ENDP
;//###################################### End Main Routine ######################################
;// ---------------------------------------------------------
;// Name: Again
;//
;// Description: Procedure to check if user wants to check a 
;//			different string
;// ---------------------------------------------------------
Again	PROC
	ret 
Again	ENDP 
;// ---------------------------------------------------------
;// Name: CharAnalyzer
;//
;// Description: This process is to analyze each char and 
;//			remove unwanted chars and reduce a letter to 
;//			if said letter happens to be upper caselower 
;//			case 
;// ---------------------------------------------------------
CharAnalyzer	PROC
	PUSHAD 
	;// Load addresses of StringInput and StringInputCopy
	mov 		esi, OFFSET StringInputCopy 
	mov		edi, OFFSET StringInputCopyRed 
	;// Load two counts, one for String Loop and one for amount of chars removed
	mov		ecx, StringByteCount 
	;// Check what range the char belongs in
	CAL1:
		mov	al, [esi]								;// mov current content of address esi to al		
		.IF (al >= 'A') && (al <= 'Z')				 
			;// The current letter is upper case
			;// Reduce to lower case
			ADD		al, 32 
			mov		[edi],al						
			inc		edi							
			inc		esi 
			LOOP CAL1 
		.ELSEIF (al >= 'a') && (al <= 'z')
			;// This current character is a lower case letter
			;// Copy letter to StringInputCopy
			;// Move to next element for both string and copy
			mov		[edi], al 
			inc		edi
			inc		esi 
			LOOP CAL1 
		.ELSEIF (al > 0) && (al < 'A') 
			;// This current element is not a letter
			;// Ignore element
			;// move to next element
			inc		esi 
			add 		CharsRemoved, 1 
			LOOP CAL1 			
		.ELSEIF (al > 'Z') && (al < 'a') 
			;// This current element is not a letter
			;// Ignore element
			;// move to next element
			inc		esi 
			add 		ebx, 1 
			LOOP CAL1 	
		.ELSEIF (al > 'z')
			;// This current element is not a letter
			;// Ignore element
			;// move to next element
			inc		esi
			add 		ebx, 1  
			LOOP CAL1 	
		.ENDIF
		;// Terminate the string by adding a zero 	
		mov		al, 0
		mov		[edi], al
	POPAD
	ret			
CharAnalyzer	ENDP 
;// ---------------------------------------------------------
;// Name: ColorChange
;//
;// Description: Changes the forground and background color
;//			 by calling an irvine32 function that takes 
;//			 numerical values as color settings for FG & BG 
;// ---------------------------------------------------------
ColorChange	PROC	
	PUSHAD   
	mov		EAX, GreyTextOnBlue	
	call		SetTextColor			
	call		Clrscr
	POPAD 
	ret			
ColorChange	ENDP 
;// ---------------------------------------------------------
;// Name: Copy
;//
;// Description: The procedure that copies the original string
;//			(StringInput) to another string (StringInputCopy)
;// ---------------------------------------------------------
CopyString		PROC
	PUSHAD
	mov		ecx, StringByteCount 
	mov		esi, OFFSET StringInput 
	mov		edi, OFFSET StringInputCopy
	;// Loop to copy string
	CSL1:
		mov		eax, [esi]
		mov		[edi], eax
		inc		esi 
		inc		edi
	LOOP CSL1
	;// Null Terminate the String Copy 
	mov		al, 0
	mov		[edi], al 
	POPAD
	ret 
CopyString		ENDP
;// ---------------------------------------------------------
;// Name: DefaultColorChange
;//
;// Description: The purpose of this procedure is to revert any
;// forground and background colors to their original states(White text on Black BG)
;// ---------------------------------------------------------
DefaultColorChange		PROC
	PUSHAD
	mov		eax, DefaultColor   	
	call		SetTextColor			
	call		Clrscr
	mov		edx, OFFSET Prompt3
	call		WriteString
	call		Crlf
	POPAD
	ret 
DefaultColorChange		ENDP
;// ---------------------------------------------------------
;// Name: Display
;//
;// Description: This procedure will ONLY display the original
;//			string and the original reversed
;// ---------------------------------------------------------
Display		PROC
	PUSHAD
	;// Display Original 
	mov		edx, OFFSET Prompt2
	call		WriteString 
	mov		edx, OFFSET StringInput   
	call		WriteString 
	call		Crlf
	;// Display Reversed String
	mov		edx, OFFSET Prompt7
	call		WriteString 
	mov		edx, OFFSET StringInputReversed
	call		WriteString 
	call		Crlf	
	;// Display if its a palindrome if not 
	mov	al, Flag  							;// al = flag
	.IF (al == 1) ;// if true
		mov		edx, OFFSET IS_Palindrome
		call		WriteString 
		call		Crlf 
	.ELSE ;// else Display its not
		mov		edx, OFFSET NOT_Palindrome
		call		WriteString 
		call		Crlf			
	.ENDIF
	POPAD 
	ret  
Display		ENDP 
;// ---------------------------------------------------------
;// Name: Input
;//
;// Description: Process that prompts user for string input
;//			which will then be used to check if the string
;//			is a palinrome
;// ---------------------------------------------------------
Input		PROC 
	PUSHAD
	;// Prompt User for input
	mov		edx, OFFSET Prompt1 
	call		WriteString 
	;// Now Read a string from keyboard
	mov		edx, OFFSET StringInput		;// beggining address of the variable to store the incoming string
	mov		ecx, SIZEOF StringInput		;// specify the max characters
	call		ReadString 
	mov		StringByteCount, eax		;// number of characters stored into StringByteCount
	POPAD 
	ret 
Input		ENDP 
;// ---------------------------------------------------------
;// Name: Palindrome
;//
;// Description: The purpose of this procedure is to first 
;//			unwanted characters (non-letters) from the string,
;//			reduce all caps to lower case, make a copy of the 
;//			string to be analyzied, reverse that copy and 
;//			compare them. If the original is equal to the copy
;//			backwards, then it is a palindrome and display the results
;// ---------------------------------------------------------
PalindRome	PROC
	PUSHAD
	;// First Copy the String
	call		CopyString 
	;// Reduce the string to only letters and make any Uppercase lower
	call		CharAnalyzer 
	;// Reverse the String
	call		ReverseString 
	;// Compare the original with the reversed copy
	;// First load strings to regs
	mov		esi, OFFSET StringInputCopyRed 
	mov		edi, OFFSET StringInputCopyRev
	mov		bl, Flag 	
	;// Compare Each element. If the String = itself reversed, ZF = 1 
	P1: ;// Null terminator checker
		mov		al, [esi]
		mov		dl, [edi]
		cmp		al, 0
		jne		P2
		cmp		dl, 0
		jne		P2 
		jmp		P5
	P2: ;// Current String Element checker 
		inc		esi 
		inc		edi
		cmp		al, dl
		jz		P3
		jnz		P4 		
	P3: ;// Mark flag
		mov		bl, 1 
		jmp		P1 	
	P4: 
		mov		bl, 0  
		jmp		P1 	
	P5:
		mov		Flag, bl 
		POPAD 
		ret
PalindRome	ENDP
;// ---------------------------------------------------------
;// Name: ReverseString
;//
;// Description: Procedure that reverses the string
;// ---------------------------------------------------------
ReverseString	PROC
	PUSHAD
	mov		eax, 31				;// eax = 31
	sub		eax, StringByteCount	;// eax = 31 - StringByteCount (This will equal to number of elements off of max)	
	mov		RevByteCount, eax 
	mov		esi, OFFSET StringInputCopyRev - 3 
	sub		esi, RevByteCount
	sub		esi, CharsRemoved 
	mov		edi, OFFSET StringInputCopyRev 
	mov		ecx, StringByteCount 
	add		ecx, 2  
	RSL1:
		mov		eax, [esi]
		mov		[edi], eax 
		dec		esi 
		inc		edi 
	LOOP RSL1	
	;// Reverse Original String 
	mov		eax, 31				;// eax = 31
	sub		eax, StringByteCount	;// eax = 31 - StringByteCount (This will equal to number of elements off of max)	
	mov		RevByteCount, eax 
	mov		esi, OFFSET StringInputCopy - 1 
	sub		esi, RevByteCount
	mov		edi, OFFSET StringInputReversed 
	mov		ecx, StringByteCount 
	add		ecx, 2 
	RSL2:
		mov		eax, [esi]
		mov		[edi], eax 
		dec		esi 
		inc		edi 
	LOOP RSL2
		
	POPAD 
	ret
ReverseString	ENDP
;//************************************* End Sub routines ****************************************

;// Terminate main process
end		main