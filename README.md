# ⚙️ Proyecto de Medición de Caída Libre con Reconocimiento Facial y Control por Voz

Este proyecto consiste en un sistema automatizado para experimentos de física, específicamente medición de caída libre. Combina reconocimiento facial, control por voz y motores paso a paso en una GUI desarrollada en MATLAB.

---

## 🧠 Funcionalidades principales

- ✅ Reconocimiento facial de usuarios antes de ejecutar.
- 🎤 Comandos de voz: "subir", "bajar", "activar", "desactivar", "iniciar".
- 🧲 Control de electroimán para liberar el proyectil.
- 📉 Medición de velocidad de caída con dos sensores IR.
- 📊 Cálculo automático de regresión lineal tras 10 lanzamientos.
- 📋 Tabla de datos, exportación a Excel y reporte automático.

---

## 🔧 Requisitos

### 🔌 Hardware

- Arduino UNO o Nano
- Driver A4988 (motor paso a paso)
- Motor NEMA 17 o similar
- 2 sensores infrarrojos
- Electroimán de 12V
- Fuente externa de alimentación (12V para el imán)

### 💻 Software

- MATLAB R2022a o superior
- Python 3.8 a 3.11
- Arduino IDE
- Navegador con acceso a micrófono (opcional para voz)
- Librerías de Python:
  - `face_recognition`
  - `opencv-python`
  - `speechrecognition`
  - `pyaudio` (para entrada de voz)

---
## 📦 Estructura Completa del Proyecto 
```bash
📦 experimento_caida_libre/
├── 📁 Arduino/
│   └── caida_libre.ino                       # Código para control del hardware (motor, sensores)
│
├── 📁 MATLAB/
│   ├── interfaz_gui.m                        # Interfaz gráfica principal
│   └── registrar_rostro.m                    # Llama al script Python para registrar rostro

│
├── 📁 Python/
│   ├── registrar_rostro.py                   # Guarda embedding facial con nombre
│   ├── reconocer_rostro.py                   # Compara rostro actual con base de datos
│   └── reconocer_comando.py                  # Reconocimiento de voz para comandos

│
├── 📁 Documentacion/
│   ├── informe_proyecto.pdf                  # Informe completo del proyecto
│   └── imagenes/
│       ├── placa_.BMP                        # Imagen del diseño en PCB
│       ├── circuito.png                      # Diseño esquemático del sistema
│       └── gui.png                           # Captura de la GUI de MATLAB
│
├── requirements.txt                          # Dependencias de Python
├── README.md                                 # Este archivo
```

## 🧪 Instalación paso a paso

### 1. Python

1. Instala Python desde: https://www.python.org
2. Abre una terminal y ejecuta:

```bash
pip install face_recognition opencv-python speechrecognition pyaudio
