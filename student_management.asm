INCLUDE Irvine32.inc

; ================= STRUCT =================
Student STRUCT
    sid     DWORD ?
    sname   BYTE 20 DUP(0)
    grade   BYTE ?
    gpa     BYTE ?
Student ENDS

; ================= DATA ===================
.data
MAX_STUDENTS = 20
students Student MAX_STUDENTS DUP(<>)
count DWORD 0

menu BYTE "STUDENT MANAGEMENT SYSTEM",0Dh,0Ah
     BYTE "1. Add Student",0Dh,0Ah
     BYTE "2. View Students",0Dh,0Ah
     BYTE "3. Search Student",0Dh,0Ah
     BYTE "4. Delete Student",0Dh,0Ah
     BYTE "0. Exit",0Dh,0Ah
     BYTE "Choice: ",0

msgId    BYTE "ID: ",0
msgName  BYTE "Name: ",0
msgGrade BYTE "Grade: ",0
msgGPA   BYTE "GPA: ",0
msgFound BYTE "Found",0
msgNot   BYTE "Not found",0
msgNoId  BYTE "ID not exist",0
msgKey   BYTE "Press key...",0
msgDel   BYTE "Delete ID: ",0
msgDelSucc BYTE "Deleted",0
msgFull  BYTE "Full",0
msgEmpty BYTE "Empty",0

hdr BYTE "ID   Name              Grade  GPA",0Dh,0Ah
    BYTE "-----------------------------------",0

; ================= CODE ===================
.code

; -----------------------------------------
WaitKey PROC
    call Crlf
    mov edx, OFFSET msgKey
    call WriteString
    call ReadChar
    call WriteChar
    ret
WaitKey ENDP

; -----------------------------------------
AddStudent PROC
    mov eax, count
    cmp eax, MAX_STUDENTS
    jl add_ok
    mov edx, OFFSET msgFull
    call WriteString
    call WaitKey
    ret

add_ok:
    mov esi, OFFSET students
    mov eax, count
    mov ebx, SIZEOF Student
    mul ebx
    add esi, eax

    mov edx, OFFSET msgId
    call WriteString
    call ReadInt
    mov (Student PTR [esi]).sid, eax
    call Crlf

    mov edx, OFFSET msgName
    call WriteString
    lea edx, (Student PTR [esi]).sname
    mov ecx, 19
    call ReadString
    call Crlf

    mov edx, OFFSET msgGrade
    call WriteString
    call ReadChar
    call WriteChar
    mov (Student PTR [esi]).grade, al
    call Crlf

gpa_input:
    mov edx, OFFSET msgGPA
    call WriteString
    call ReadInt
    cmp eax, 0
    jl gpa_input
    cmp eax, 4
    jg gpa_input
    mov (Student PTR [esi]).gpa, al
    call Crlf

    inc count
    call WaitKey
    ret
AddStudent ENDP

; -----------------------------------------
ViewStudents PROC
    call Clrscr
    cmp count, 0
    jne show
    mov edx, OFFSET msgEmpty
    call WriteString
    call WaitKey
    ret

show:
    mov edx, OFFSET hdr
    call WriteString
    call Crlf

    mov esi, OFFSET students
    mov ecx, count

view_loop:
    mov eax, (Student PTR [esi]).sid
    call WriteDec
    call PadSpaces4

    lea edx, (Student PTR [esi]).sname
    call WriteString
    call PadName

    mov al, (Student PTR [esi]).grade
    call WriteChar
    mov al, ' '
    call WriteChar
    call WriteChar

    movzx eax, (Student PTR [esi]).gpa
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, '0'
    call WriteChar

    call Crlf
    add esi, SIZEOF Student
    loop view_loop

    call WaitKey
    ret
ViewStudents ENDP

; -----------------------------------------
PadSpaces4 PROC
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    ret
PadSpaces4 ENDP

; -----------------------------------------
PadName PROC
    push eax
    push ebx
    call StrLength
    mov ebx, 18
    sub ebx, eax
pad_loop:
    cmp ebx, 0
    jle done
    mov al, ' '
    call WriteChar
    dec ebx
    jmp pad_loop
done:
    mov al, ' '
    call WriteChar
    call WriteChar
    pop ebx
    pop eax
    ret
PadName ENDP

; -----------------------------------------
SearchStudent PROC
    cmp count, 0
    jne search_ok
    mov edx, OFFSET msgNoId
    call WriteString
    call WaitKey
    ret

search_ok:
    mov edx, OFFSET msgId
    call WriteString
    call ReadInt
    mov ebx, eax
    call Crlf

    mov esi, OFFSET students
    mov ecx, count

search_loop:
    cmp ebx, (Student PTR [esi]).sid
    je found
    add esi, SIZEOF Student
    loop search_loop

    mov edx, OFFSET msgNot
    call WriteString
    call WaitKey
    ret

found:
    mov edx, OFFSET msgFound
    call WriteString
    call Crlf

    mov edx, OFFSET msgName
    call WriteString
    lea edx, (Student PTR [esi]).sname
    call WriteString
    call Crlf

    mov edx, OFFSET msgGrade
    call WriteString
    mov al, (Student PTR [esi]).grade
    call WriteChar
    call Crlf

    mov edx, OFFSET msgGPA
    call WriteString
    movzx eax, (Student PTR [esi]).gpa
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, '0'
    call WriteChar

    call WaitKey
    ret
SearchStudent ENDP

; -----------------------------------------
DeleteStudent PROC
    cmp count, 0
    jne del_ok
    mov edx, OFFSET msgEmpty
    call WriteString
    call WaitKey
    ret

del_ok:
    mov edx, OFFSET msgDel
    call WriteString
    call ReadInt
    mov ebx, eax

    mov esi, OFFSET students
    mov ecx, count

find:
    cmp ebx, (Student PTR [esi]).sid
    je found_del
    add esi, SIZEOF Student
    loop find

    mov edx, OFFSET msgNot
    call WriteString
    call WaitKey
    ret

found_del:
    mov edi, esi
    add esi, SIZEOF Student
    mov ecx, (count - 1)
shift:
    rep movsb
    dec count

    mov edx, OFFSET msgDelSucc
    call WriteString
    call WaitKey
    ret
DeleteStudent ENDP

; -----------------------------------------
main PROC
    call Clrscr
main_loop:
    mov edx, OFFSET menu
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf

    cmp al, '0'
    je quit
    cmp al, '1'
    je add1
    cmp al, '2'
    je view
    cmp al, '3'
    je search
    cmp al, '4'
    je delete
    jmp main_loop

add1:    call AddStudent
         jmp main_loop
view:    call ViewStudents
         jmp main_loop
search:  call SearchStudent
         jmp main_loop
delete:  call DeleteStudent
         jmp main_loop

quit:
    exit
main ENDP

END main
