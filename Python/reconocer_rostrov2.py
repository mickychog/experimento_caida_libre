# reconocer_rostro.py
import face_recognition
import cv2
import pickle
import sys

# Cargar todos los embeddings y nombres
with open("D:\\Tareas USFX\\2024\Ing. Electronica\ProyectoFinal Caida libre\embeddings.pkl", "rb") as f:
    data = pickle.load(f)  # {'Juan': encoding1, 'Maria': encoding2, ...}

known_names = list(data.keys())
known_embeddings = list(data.values())

cap = cv2.VideoCapture(0)
match_found = False
matched_name = "Desconocido"

for _ in range(30):
    ret, frame = cap.read()
    if not ret:
        continue
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    locations = face_recognition.face_locations(rgb)
    encodings = face_recognition.face_encodings(rgb, locations)

    for encoding in encodings:
        distances = face_recognition.face_distance(known_embeddings, encoding)
        min_distance = min(distances)
        best_match_index = distances.tolist().index(min_distance)

        if min_distance < 0.45:
            match_found = True
            matched_name = known_names[best_match_index]
            break
    if match_found:
        break

cap.release()

# Salida para MATLAB
if match_found:
    print(f"1:{matched_name}")  # Ej: "1:Juan"
else:
    print("0")
