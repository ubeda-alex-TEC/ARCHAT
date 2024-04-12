INCLUDE Irvine32.inc

.data
artLine1 db ' ______     ______     ______     __  __     ______     ______  ', 0Ah,0
artLine2 db '/\  __ \   /\  == \   /\  __\   /\ \\ \   /\  __ \   /\__  _\ ', 0Ah,0
artLine3 db '\ \  __ \  \ \  _<   \ \ \___  \ \  __ \  \ \  __ \  \/_/\ \/ ', 0Ah,0
artLine4 db ' \ \\ \\  \ \\ \\  \ \\  \ \\ \\  \ \\ \\    \ \\ ', 0Ah,0
artLine5 db '  \//\//   \// //   \//   \//\//   \//\//     \// ', 0Ah,0
artLine6 db '                             By Team 7                          ', 0Ah, 0 ; Espacio adicional para separar del menú

mainMenuPrompt db "Menu Principal:", 0Ah, "1. Registro", 0Ah, "2. Enviar Mensaje", 0Ah, "3. Ver Mensajes", 0Ah, "4. Salir", 0Ah, "Seleccione una opcion: ", 0
nicknamePrompt db "Ingrese su Nickname: ", 0
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

    ; Guardar el nombre del chat en el archivo
    invoke WRITE_FILE, ADDR fileNameView, ADDR viewBuffer

    call DELAY_15_SECONDS

    ; Limpiar receivedMsgBuffer antes de leer
    lea edi, receivedMsgBuffer            ; Cargar la dirección de inicio de receivedMsgBuffer en edi
    mov ecx, SIZEOF receivedMsgBuffer     ; Cargar la longitud de receivedMsgBuffer en ecx
    xor al, al                            ; Establecer al a 0 (el valor con el que se llenará el búfer)
    rep stosb                             ; Llenar el búfer con ceros

    ; Continuar con la lógica para leer y mostrar mensajes
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
    mov edx, OFFSET artLine6 ; Línea vacía para espaciar
    call WriteString
    ret
ShowArt endp
  
main PROC
menu_loop:
    call Clrscr 
    call ShowArt          ; Mostrar el arte ASCII al inicio
    mov edx, OFFSET mainMenuPrompt
    call WriteString
    mov ecx, SIZEOF userInput
    mov edx, OFFSET userInput
    call ReadString

    cmp userInput, "1"
    je registration_flow
    cmp userInput, "2"
    je message_flow
    cmp userInput, "3"
    je view_messages_flow
    cmp userInput, "4"
    je exit_program
    jmp menu_loop

registration_flow:
    call Clrscr           ; Limpia la pantalla para el flujo de registro
    call REGISTER_USER
    jmp menu_loop

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