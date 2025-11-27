const int trigPin = 9;
const int echoPin = 10;

float duration, distance;

enum State { NONE, IN, OUT };
State lastState = NONE;

unsigned long lastEvent = 0;
const unsigned long debounceMs = 1500;

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  Serial.begin(9600);
}

void loop() {
  // trigger pulse
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH, 30000);
  distance = (duration * 0.0343) / 2;

  State newState = NONE;

  if (distance >= 0.5 && distance <= 7.0) {
    newState = IN;
  } 
  else if (distance >= 7.1 && distance <= 15.0) {
    newState = OUT;
  }

  unsigned long now = millis();

  if (newState != lastState && (now - lastEvent) > debounceMs) {
    if (newState == IN) {
      Serial.println(1);
    } else if (newState == OUT) {
      Serial.println(2);
    }

    lastState = newState;
    lastEvent = now;
  }

  delay(100);
}
