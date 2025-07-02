mport face_recognition
import cv2
import pickle
import sys
import os

# Obtener nombre desde argumento
if len(sys.argv) < 2:
    print("Debes proporcionar un nombre como argumento.")
    sys.exit(1)

nombre = sys.argv[1]

# Verifica si ya existe el archivo con embeddings
archivo_embeddings = "embeddings.pkl"
if os.path.exists(archivo_embeddings):
    with open(archivo_embeddings, "rb") as f:
        embeddings = pickle.load(f)  # Diccionario existente
else:
    embeddings = {}

# Captura de rostro
cap = cv2.VideoCapture(0)
print("Presiona 's' para capturar tu rostro")

while True:
    ret, frame = cap.read()
    if not ret:
        continue
    cv2.imshow("Registrar Rostro", frame)
    if cv2.waitKey(1) & 0xFF == ord('s'):
        break

cap.release()
cv2.destroyAllWindows()

# Procesar imagen
rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
locations = face_recognition.face_locations(rgb)
encodings = face_recognition.face_encodings(rgb, locations)

# Verifica si se detectó un rostro
if encodings:
    embeddings[nombre] = encodings[0]  # Guardar bajo el nombre
    with open(archivo_embeddings, "wb") as f:
        pickle.dump(embeddings, f)
    print(f"Rostro de '{nombre}' registrado correctamente.")
else:
    print("No se detectó rostro. Intenta de nuevo.")
