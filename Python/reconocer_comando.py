import speech_recognition as sr
import sys
import os

def procesar_audio(archivo):
    r = sr.Recognizer()
    try:
        with sr.AudioFile(archivo) as source:
            # Ajuste avanzado de ruido (recomendado)
            r.adjust_for_ambient_noise(source, duration=0.8)
            audio = r.record(source, duration=2)  # Limita a 2 segundos
            
        # Configuración para español con timeout
        texto = r.recognize_google(audio, 
                                language="es-ES",
                                show_all=False)
        return texto.lower()
        
    except sr.UnknownValueError:
        return "error_ruido"
    except sr.RequestError:
        return "error_conexion"
    except Exception as e:
        return f"error_interno: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) > 1 and os.path.exists(sys.argv[1]):
        print(procesar_audio(sys.argv[1]))
    else:
        print("error_archivo")