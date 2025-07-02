// Pines del motor paso a paso
const int motorPinStep = 4;
const int motorPinDir = 5;

// Pin del imán (antes era ledPin)
const int imanPin = 6;

// Pines de sensores IR
const int sensor1Pin = 2;
const int sensor2Pin = 3;

// Límites del movimiento del motor
const float limiteInferiorVueltas = -180.0;
const float limiteSuperiorVueltas = 180.0;
float totalVueltas = 0.0;

// Estado anterior de sensores
int estadoAnteriorSensor1 = HIGH;
int estadoAnteriorSensor2 = HIGH;

// Cronómetro
unsigned long tiempoInicio = 0;
unsigned long tiempoTranscurrido = 0;
boolean cronometroActivo = false;

// Control de sensores
bool sensoresActivos = false;
unsigned long tiempoSensorInicio = 0;
const unsigned long duracionSensado = 2000; // 2 segundos para medir
bool yaDetectado = false;

void setup() {
  Serial.begin(9600);

  pinMode(motorPinStep, OUTPUT);
  pinMode(motorPinDir, OUTPUT);

  pinMode(imanPin, OUTPUT);
  digitalWrite(imanPin, LOW); // Imán apagado

  pinMode(sensor1Pin, INPUT_PULLUP);
  pinMode(sensor2Pin, INPUT_PULLUP);
}

// Ajusta velocidad del motor (más lento y estable)
void moveStepper(float turns, int dir) {
  digitalWrite(motorPinDir, dir);
  int steps = abs(turns * 200);
  for (int i = 0; i < steps; i++) {
    digitalWrite(motorPinStep, HIGH);
    delayMicroseconds(1000);  // Más lento
    digitalWrite(motorPinStep, LOW);
    delayMicroseconds(1000);
  }
}

void iniciarCronometro() {
  tiempoInicio = millis();
  cronometroActivo = true;
}

void detenerCronometro() {
  tiempoTranscurrido = millis() - tiempoInicio;
  cronometroActivo = false;
  Serial.print("Tiempo transcurrido: ");
  Serial.print(tiempoTranscurrido);
  Serial.println(" ms");
}

void loop() {
  // Sensado condicionado al estado
  if (sensoresActivos && !yaDetectado) {
    int estadoSensor1 = digitalRead(sensor1Pin);
    int estadoSensor2 = digitalRead(sensor2Pin);

    if (estadoSensor1 == LOW && estadoAnteriorSensor1 == HIGH) {
      Serial.println("Sensor 1 activado");
      if (!cronometroActivo) {
        iniciarCronometro();
      }
    }

    if (estadoSensor2 == LOW && estadoAnteriorSensor2 == HIGH) {
      Serial.println("Sensor 2 activado");
      if (cronometroActivo) {
        detenerCronometro();
        yaDetectado = true; // No seguir midiendo
      }
    }

    // Desactivar automáticamente si pasa el tiempo
    if (millis() - tiempoSensorInicio > duracionSensado) {
      sensoresActivos = false;
      Serial.println("Tiempo de sensado finalizado.");
    }

    estadoAnteriorSensor1 = estadoSensor1;
    estadoAnteriorSensor2 = estadoSensor2;
  }

  // Comando serial desde MATLAB
  if (Serial.available() > 0) {
    String comando = Serial.readStringUntil('\n');
    comando.trim();  // Eliminar espacios

    if (comando == "subir") {
      float vueltas = 5.0;
      if (totalVueltas + vueltas > limiteSuperiorVueltas) {
        vueltas = limiteSuperiorVueltas - totalVueltas;
      }
      totalVueltas += vueltas;
      moveStepper(vueltas, LOW); // LOW = sentido horario
      Serial.println("Motor subiendo");
      //Serial.print("Total vueltas actuales: ");
      //Serial.println(totalVueltas);


    } else if (comando == "bajar") {
      float vueltas = -4.0;
      if (totalVueltas + vueltas < limiteInferiorVueltas) {
        vueltas = limiteInferiorVueltas - totalVueltas;
      }
      totalVueltas += vueltas;
      moveStepper(vueltas, HIGH); // HIGH = sentido antihorario
      Serial.println("Motor bajando");
      //Serial.print("Total vueltas actuales: ");
      //Serial.println(totalVueltas);


    } else if (comando == "activar") {
      digitalWrite(imanPin, HIGH);
      Serial.println("Iman ACTIVADO");

    } else if (comando == "desactivar") {
      digitalWrite(imanPin, LOW);
      Serial.println("Iman DESACTIVADO");

    } else if (comando == "iniciar") {
      digitalWrite(imanPin, HIGH);
      Serial.println("Iman activado por 5 segundos...");
      delay(5000);
      digitalWrite(imanPin, LOW);
      Serial.println("Iniciando sensado entre sensores...");

      sensoresActivos = true;
      yaDetectado = false;
      tiempoSensorInicio = millis();
      cronometroActivo = false;
    } else {
      Serial.println("Comando desconocido.");
    }
  }
}
