# Archat

Archat es una aplicación de chat desarrollada en ensamblador x86 y Python como parte del curso de Arquitectura de Computadores del Instituto Tecnológico de Costa Rica en la sede San Carlos. Permite a los usuarios enviar y recibir mensajes de forma segura utilizando Firebase como backend para el almacenamiento de mensajes.

## Características

- **Envío de mensajes:** Los usuarios pueden enviar mensajes a otros usuarios registrados en la plataforma.
- **Recepción de mensajes:** Los usuarios pueden recibir mensajes de otros usuarios registrados en la plataforma.
- **Listado de chats:** Genera una lista de chats disponibles para el usuario.
- **Seguridad:** Utiliza Firebase para el almacenamiento de mensajes, garantizando la seguridad y la integridad de los datos.

## Requisitos

- **Python 3:** Se requiere Python 3 para ejecutar el script de Python.
- **MARS (MIPS Assembler and Runtime Simulator):** Se recomienda tener instalado MARS para ensamblar y ejecutar el código ensamblador x86.

## Instalación

1. Clona este repositorio en tu máquina local.
2. Instala las dependencias de Python utilizando pip:

```bash
pip install -r requirements.txt
```

## Configuración

Antes de ejecutar la aplicación, asegúrate de configurar correctamente Firebase. Necesitarás un archivo JSON de credenciales de Firebase que se llame `firebase_credentials.json`. Puedes obtener este archivo desde la consola de Firebase.

## Uso

1. Ejecuta el script `chat.asm` utilizando un ensamblador x86 compatible, como MARS.
2. Ejecuta el script `firebasepy.py` utilizando Python:

```bash
python firebasepy.py
```

## Contribución

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar este proyecto, por favor, crea una nueva solicitud de extracción.

## Licencia

Este proyecto se ofrece bajo la licencia Creative Commons Legal Code CC0 1.0 Universal. Para más detalles, consulta el archivo [LICENSE](LICENSE).

## Creadores

* Alexander Ubeda
* Alejandro Abarca
