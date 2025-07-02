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

---

### 1. 🔌 Instalación del entorno de Arduino

#### 📥 Instalar Arduino IDE

1. Descarga el IDE desde: [https://www.arduino.cc/en/software](https://www.arduino.cc/en/software)
2. Instálalo y abre el archivo `Arduino/caida_libre.ino`.
3. Configura:
   - `Herramientas > Placa > Arduino UNO`
   - `Herramientas > Puerto > COMx` (donde x es el puerto del Arduino)

#### 🧪 Verificación

Conecta el Arduino y sube el programa con `Ctrl + U`. Si no hay errores, está listo.

---

### 2. 🧠 Instalación de MATLAB y Toolboxes necesarios

#### 📥 Instalar MATLAB

1. Descarga MATLAB desde: [https://www.mathworks.com/downloads/](https://www.mathworks.com/downloads/)
2. Instala y activa con una cuenta de MathWorks.

#### 🧰 Toolboxes requeridos

Instala desde el *Add-On Explorer*:

- MATLAB Support Package for Arduino Hardware
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- MATLAB Compiler (opcional)
- Curve Fitting Toolbox

#### 🧪 Verificación

Abre MATLAB y escribe:

```matlab
a = arduino()
```
---

### 3. 🐍 Instalación de Python y librerías

#### 📥 Instalar Python

1. Descarga el instalador desde: [https://www.python.org/downloads/](https://www.python.org/downloads/)
2. Durante la instalación, **marca la casilla "Add Python to PATH"**.
3. Finaliza la instalación.

#### 📦 Instalar librerías necesarias

Abre la terminal (CMD o PowerShell) y ejecuta:

```bash
pip install face_recognition opencv-python speechrecognition pyaudio
```
⚠️ Nota sobre PyAudio:
Si falla la instalación de PyAudio, descarga el archivo .whl correspondiente desde
```bash
https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio
```
y luego instálalo así:
```bash
pip install PyAudio‑0.2.11‑cp39‑cp39‑win_amd64.whl
```
🧪 Verificación
Prueba estos dos scripts desde consola:

```bash
python Python/registrar_rostro.py "TuNombre"
python Python/reconocer_comando.py
```
---

### 4. 🚀 Ejecución del sistema completo
🟢 Paso a paso
Entrar a matlab y correr:
### 1. Registrar usuario (facial):

```matlab
registrar_rostro
```
Esto generará un archivo .pkl en la carpeta embeddings/ con tu nombre.
### 2. Iniciar GUI desde MATLAB:

```matlab
interfaz_gui
```
La GUI controlará el motor, activará el imán y mostrará la gráfica y los resultados.

### 3.Verificación Facial automática:
Al ejecutar el sistema, se llama automáticamente a reconocer_rostro.py para autenticar al usuario.
Si se reconoce un rostro previamente registrado, se permite continuar.

### 4. Control por voz (opcional):
Usa la opción "Control por Voz" para emitir comandos como:

activar
subir
bajar
iniciar
resetear

Ejemplo:
```bash
python Python/reconocer_comando.py
El comando reconocido será enviado automáticamente a la interfaz.
```
### 5. Durante el experimento:

El usuario presiona "Iniciar".

El sistema desactiva el imán y el objeto cae.

Se registran los tiempos de cruce por sensores IR.

Se calcula la velocidad de caída y se guarda el resultado.

### 6. Después de 10 experimentos:

Se genera una regresión lineal automática.

Se exportan los datos a Excel (resultados.xlsx).

Se muestra la ecuación, curva, intervalos y estadísticas.


