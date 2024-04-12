import os
import time
import hashlib
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

# Inicializa la aplicación de Firebase
cred = credentials.Certificate('número del certificado.json')
firebase_admin.initialize_app(cred, {'databaseURL': 'url de firebase'})

# Función para enviar un mensaje
def enviar_mensaje():
    # Leer el remitente del archivo Remitente.txt
    with open('Remitente.txt', 'r') as remitente_file:
        remitente = remitente_file.read().strip()

    # Leer el destinatario del archivo Destinatario.txt
    with open('Destinatario.txt', 'r') as destinatario_file:
        destinatario = destinatario_file.read().strip()

    # Leer el mensaje del archivo Mensaje.txt
    with open('Mensaje.txt', 'r') as mensaje_file:
        mensaje = mensaje_file.read().strip()

    # Ordenar alfabéticamente los nombres de los participantes del chat
    nombres_ordenados = sorted([remitente, destinatario])
    nombre_chat = '-'.join(nombres_ordenados)

    # Referencia al nodo del chat en la base de datos
    ref_chat = db.reference(f'/Mensajes/Chats/{nombre_chat}')

    # Obtener el número total de mensajes en el chat para generar una clave descriptiva
    total_mensajes = len(ref_chat.get() or [])

    # Guardar el mensaje en el chat con una clave descriptiva
    ref_chat.child(f'mensaje{total_mensajes + 1}').set({'Remitente': remitente, 'Mensaje': mensaje})

    print("El mensaje se ha enviado correctamente.")

# Función para recibir mensajes
def recibir_mensajes():
    # Leer el remitente del archivo Remitente.txt
    with open('Remitente.txt', 'r') as remitente_file:
        remitente = remitente_file.read().strip()

    # Leer el destinatario del archivo Destinatario.txt
    with open('Destinatario.txt', 'r') as destinatario_file:
        destinatario = destinatario_file.read().strip()

    # Ordenar alfabéticamente los nombres de los participantes del chat
    nombres_ordenados = sorted([remitente, destinatario])
    nombre_chat = '-'.join(nombres_ordenados)

    # Referencia al nodo del chat en la base de datos
    ref_chat = db.reference(f'/Mensajes/Chats/{nombre_chat}')

    # Obtener los mensajes del chat
    mensajes = ref_chat.get()

    if mensajes:
        # Abre el archivo para escritura
        with open('MsgRecibido.txt', 'w') as archivo:
            archivo.write(f'Mensajes en el chat {nombre_chat}:\n\n')
            for mensaje_id, mensaje_data in mensajes.items():
                remitente = mensaje_data.get('Remitente')  # Obtenemos el nombre del remitente
                destinatario = mensaje_data.get('Destinatario')
                mensaje_texto = mensaje_data.get('Mensaje', 'Mensaje vacío')
                archivo.write(f"{remitente}: {mensaje_texto}\n\n")  # Escribe el mensaje en el archivo
        print("Los mensajes se han guardado en MsgRecibido.txt")
    else:
        with open('MsgRecibido.txt', 'w') as archivo:
            archivo.write(f'Mensajes en el chat {nombre_chat}:\n\n')


            archivo.write("No hay mensajes\n")  # Escribe el mensaje en el archivo
        print(f'No hay mensajes en el chat {nombre_chat}')

# Función para generar la lista de chats
def generar_lista_chats():
    # Obtener el nombre del usuario actual del archivo Remitente.txt
    with open('Remitente.txt', 'r') as remitente_file:
        usuario_actual = remitente_file.read().strip()

    # Obtener una lista de todos los destinatarios disponibles en los chats
    destinatarios = set()
    ref_chats = db.reference('/Mensajes/Chats')
    for chat_key in ref_chats.get() or {}:
        nombres_chat = chat_key.split('-')
        destinatarios.update(nombres_chat)

    # Remover al usuario actual de la lista de destinatarios
    if usuario_actual in destinatarios:
        destinatarios.remove(usuario_actual)

    # Escribir la lista de destinatarios en el archivo chats.txt
    with open('chats.txt', 'w') as archivo:
        archivo.write("Esta es tu lista de Chats:\n\n")
        for destinatario in destinatarios:
            archivo.write(f"{destinatario}\n")

    # Agregar un mensaje para crear un nuevo chat
    with open('chats.txt', 'a') as archivo:
        archivo.write("\nSi quieres crear un chat nuevo solo escribe el nombre de la persona:\n")

    print("Se ha generado la lista de chats en el archivo chats.txt")

# Función para limpiar el archivo de mensajes
def limpiar_mensajes():
    with open('Mensaje.txt', 'w') as mensaje_file:
        mensaje_file.write('')

# Función para calcular el hash del archivo
def calcular_hash(filename):
    with open(filename, 'rb') as f:
        file_hash = hashlib.md5()
        while chunk := f.read(8192):
            file_hash.update(chunk)
    return file_hash.hexdigest()

# Función para ejecutar las operaciones iniciales
def inicio():
    recibir_mensajes()
    generar_lista_chats()
    limpiar_mensajes()
inicio()
# Obtener el hash inicial del archivo de mensajes
mensaje_hash = calcular_hash('Mensaje.txt')

# Obtener el hash inicial del archivo de destinatario
destinatario_hash = calcular_hash('Destinatario.txt')

# Bucle principal de monitoreo
while True:
    # Verificar si el archivo de mensajes ha cambiado
    if calcular_hash('Mensaje.txt') != mensaje_hash:
        # Actualizar el hash del archivo
        mensaje_hash = calcular_hash('Mensaje.txt')

        # Ejecutar las funciones necesarias
        enviar_mensaje()
        recibir_mensajes()
        generar_lista_chats()
        

    # Verificar si el archivo de destinatario ha cambiado
    if calcular_hash('Destinatario.txt') != destinatario_hash:
        # Actualizar el hash del archivo
        destinatario_hash = calcular_hash('Destinatario.txt')
        
        # Ejecutar la función de inicio
        inicio()

    # Esperar 1 segundo antes de volver a verificar
    time.sleep(1)
