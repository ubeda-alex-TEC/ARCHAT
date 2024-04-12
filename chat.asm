INCLUDE Irvine32.inc

.data
artLine1 db '  /$$$$$$  /$$$$$$$   /$$$$$$  /$$   /$$  /$$$$$$  /$$$$$$$$', 0Ah,0
artLine2 db ' /$$__  $$| $$__  $$ /$$__  $$| $$  | $$ /$$__  $$|__  $$__/', 0Ah,0
artLine3 db '| $$  \ $$| $$  \ $$| $$  \__/| $$  | $$| $$  \ $$   | $$   ', 0Ah,0
artLine4 db '| $$$$$$$$| $$$$$$$/| $$      | $$$$$$$$| $$$$$$$$   | $$   ', 0Ah,0
artLine5 db '| $$__  $$| $$__  $$| $$      | $$__  $$| $$__  $$   | $$   ', 0Ah,0
artLine6 db '| $$__  $$| $$__  $$| $$      | $$__  $$| $$__  $$   | $$   ', 0Ah,0
artLine7 db '| $$  | $$| $$  | $$|  $$$$$$/| $$  | $$| $$  | $$   | $$   ', 0Ah,0
artLine8 db '|__/  |__/|__/  |__/ \______/ |__/  |__/|__/  |__/   |__/   ', 0Ah,0
artLine9 db '                                                               ', 0Ah,0

artLinereg1 db '  ___          _    _           ', 0Ah,0
artLinereg2 db ' | _ \___ __ _(_)__| |_ _ _ ___ ', 0Ah,0
artLinereg3 db ' |   / -_/ _  | (_-|  _| _ / _ \', 0Ah,0
artLinereg4 db ' |_|_\___\__, |_/__/\__|_| \___/', 0Ah,0
artLinereg5 db '         |___/                  ', 0Ah,0
artLinereg6 db '                                  ', 0Ah,0

messagebar1 db ' ---------------------------------------------------------------', 0Ah, 0
messagebar2 db '|                                                               |', 0Ah, 0
messagebar3 db ' ---------------------------------------------------------------', 0Ah, 0


mainMenuPrompt db "�Bienvenido a Archat! �Que deseas hacer?:", 0Ah, 0Ah, "1. Enviar Mensaje", 0Ah, "2. Ver Mensajes", 0Ah, "3. Salir", 0Ah, "Seleccione una opcion: ", 0
nicknamePrompt db "Ingrese su nombre: ", 0
passwordPrompt db "Ingrese su contrasena: ", 0
nicknameInput db 20 DUP(0)
passwordInput db 20 DUP(0)

fileName1 db "D:\Assembly Chat\ARCHAT\Data\Remitente.txt", 0
fileName2 db "D:\Assembly Chat\ARCHAT\Data\Destinatario.txt", 0
fileName3 db "D:\Assembly Chat\ARCHAT\Data\Mensaje.txt", 0
fileName4 db "D:\Assembly Chat\ARCHAT\Data\Contrasena.txt", 0
fileNameView db "D:\Assembly Chat\ARCHAT\Data\Recibidor.txt", 0
msgReceivedFile db "D:\Assembly Chat\ARCHAT\Data\MsgRecivido.txt", 0

prompt2 db "Digita el contacto: ", 0
prompt3 db "Mensaje: ", 0
viewPrompt db "Digita el chat que quieres ver: ", 0

userBuffer1 db 4096 dup(0)
userBuffer2 db 4096 dup(0)
userBuffer3 db 4096 dup(0)
viewBuffer db 500 DUP(0)
receivedMsgBuffer db 4096 DUP(0)

errMsgFileOpen db "Error al abrir el archivo.", 0
errMsgWriteFile db "Error al escribir en el archivo.", 0
successMsg db "Datos guardados correctamente!", 0
bytesWritten dd ?
bytesRead dd ?

encryptionKey db 'X'

userInput db 2 dup(0)

.code

WRITE_FILE PROC uses ebx esi ecx, fileName:PTR BYTE, fileContent:PTR BYTE
    invoke CreateFile, fileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je file_open_error
    mov ebx, eax

    mov esi, fileContent
    xor ecx, ecx

calculate_length:
    lodsb
    test al, al
    jz end_of_string
    inc ecx
    jmp calculate_length

end_of_string:
    dec esi
    mov esi, fileContent
    invoke WriteFile, ebx, esi, ecx, ADDR bytesWritten, NULL
    test eax, eax
    jz write_error
    invoke CloseHandle, ebx
    jmp end_proc

file_open_error:
    mov edx, OFFSET errMsgFileOpen
    call WriteString
    jmp end_proc

write_error:
    mov edx, OFFSET errMsgWriteFile
    call WriteString

end_proc:
    ret
WRITE_FILE ENDP

REGISTER_USER PROC
    call ShowArtReg
    mov edx, OFFSET nicknamePrompt
    call WriteString
    mov ecx, SIZEOF nicknameInput
    mov edx, OFFSET nicknameInput
    call ReadString
    invoke WRITE_FILE, ADDR fileName1, ADDR nicknameInput

    mov edx, OFFSET passwordPrompt
    call WriteString
    mov ecx, SIZEOF passwordInput
    mov edx, OFFSET passwordInput
    call ReadString
    invoke WRITE_FILE, ADDR fileName4, ADDR passwordInput
    ret
REGISTER_USER ENDP

SEND_MESSAGE PROC
    mov edx, OFFSET prompt2
    call WriteString
    mov ecx, SIZEOF userBuffer2
    mov edx, OFFSET userBuffer2
    call ReadString
    invoke WRITE_FILE, ADDR fileName2, ADDR userBuffer2

    mov edx, OFFSET prompt3
    call WriteString
    mov ecx, SIZEOF userBuffer3
    mov edx, OFFSET userBuffer3
    call ReadString

    ; Se ha quitado la llamada a ENCRYPT_MESSAGE
    ; El mensaje se guarda directamente sin encriptar
    invoke WRITE_FILE, ADDR fileName3, ADDR userBuffer3
    ret
SEND_MESSAGE ENDP

VIEW_MESSAGES PROC
    mov edx, OFFSET viewPrompt             ; Pide al usuario el nombre del chat
    call WriteString
    mov ecx, SIZEOF viewBuffer
    mov edx, OFFSET viewBuffer
    call ReadString
    call messagevar

    ; Guardar el nombre del chat en el archivo
    invoke WRITE_FILE, ADDR fileNameView, ADDR viewBuffer

    call DELAY_15_SECONDS

    ; Limpiar receivedMsgBuffer antes de leer
    lea edi, receivedMsgBuffer            ; Cargar la direcci�n de inicio de receivedMsgBuffer en edi
    mov ecx, SIZEOF receivedMsgBuffer     ; Cargar la longitud de receivedMsgBuffer en ecx
    xor al, al                            ; Establecer al a 0 (el valor con el que se llenar� el b�fer)
    rep stosb                             ; Llenar el b�fer con ceros

    ; Continuar con la l�gica para leer y mostrar mensajes
    invoke CreateFile, ADDR msgReceivedFile, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je file_open_error_VM

    mov ebx, eax ; Handle del archivo
    mov esi, OFFSET receivedMsgBuffer
    invoke ReadFile, ebx, esi, SIZEOF receivedMsgBuffer, ADDR bytesRead, NULL
    cmp eax, 0
    je file_read_error_VM
    invoke CloseHandle, ebx

    mov edx, OFFSET receivedMsgBuffer
    call WriteString
    call ReadChar

    jmp end_proc_VM

file_open_error_VM:
    mov edx, OFFSET errMsgFileOpen
    call WriteString
    jmp end_proc_VM

file_read_error_VM:
    mov edx, OFFSET errMsgWriteFile
    call WriteString

end_proc_VM:
    ret
VIEW_MESSAGES ENDP

DELAY_15_SECONDS PROC
    pushad                      ; Guardar el estado de los registros
    call GetTickCount           ; Obtener el conteo de ticks actual
    mov ebx, eax                ; Guardar el valor inicial en ebx

WaitLoop:
    call GetTickCount           ; Obtener el conteo de ticks actual
    sub eax, ebx                ; Calcular la diferencia en milisegundos
    cmp eax, 6000              ; Verificar si han pasado 6000 ms (6 segundos)
    jb WaitLoop                 ; Si no, seguir esperando

    popad                       ; Restaurar el estado de los registros
    ret
DELAY_15_SECONDS ENDP

Messagevar proc
	mov edx, OFFSET messagebar1
	call WriteString
	mov edx, OFFSET messagebar2
	call WriteString
	mov edx, OFFSET messagebar3
	call WriteString
	ret
Messagevar endp

ShowArtReg proc
	mov edx, OFFSET artLinereg1
	call WriteString
	mov edx, OFFSET artLinereg2
	call WriteString
	mov edx, OFFSET artLinereg3
	call WriteString
	mov edx, OFFSET artLinereg4
	call WriteString
	mov edx, OFFSET artLinereg5
	call WriteString
	mov edx, OFFSET artLinereg6
	call WriteString
	ret
ShowArtReg endp


ShowArt proc
    mov edx, OFFSET artLine1
    call WriteString
    mov edx, OFFSET artLine2
    call WriteString
    mov edx, OFFSET artLine3
    call WriteString
    mov edx, OFFSET artLine4
    call WriteString
    mov edx, OFFSET artLine5
    call WriteString
    mov edx, OFFSET artLine6 
    call WriteString
    mov edx, OFFSET artLine7
    call WriteString
    mov edx, OFFSET artLine8
    call WriteString
    mov edx, OFFSET artLine9
    call WriteString
    ret
ShowArt endp
  
main PROC
    ; Llamar a la funci�n REGISTER_USER al iniciar
    call REGISTER_USER

menu_loop:
    call Clrscr 
    call ShowArt          
    mov edx, OFFSET mainMenuPrompt
    call WriteString
    mov ecx, SIZEOF userInput
    mov edx, OFFSET userInput
    call ReadString


    cmp userInput, "1"
    je message_flow
    cmp userInput, "2"
    je view_messages_flow
    cmp userInput, "3"
    je exit_program
    jmp menu_loop

registration_flow:
    call Clrscr           
    call REGISTER_USER   ; Mantener el flujo de registro aqu� si el usuario lo elige
    jmp menu_loop       ; Volver al men� principal despu�s de completar el registro

message_flow:
    call Clrscr           ; Limpia la pantalla para el flujo de mensajes
    call SEND_MESSAGE
    jmp menu_loop

view_messages_flow:
    call Clrscr           ; Limpia la pantalla para ver mensajes
    call VIEW_MESSAGES
    jmp menu_loop

exit_program:
    invoke ExitProcess, 0

main ENDP

END main