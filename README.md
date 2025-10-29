AROGA – Intelligent Pesticide Sprinkling System :-
AROGA is an AI + IoT-based drone system that detects crop diseases using a deep learning model trained on a public Kaggle dataset and automatically sprays pesticides only on infected areas, reducing chemical use by up to 60 % and promoting smart, sustainable farming.

Overview :-
AROGA integrates **AI, IoT, and Cloud Computing** to help farmers monitor crops and automate pesticide spraying.
A drone equipped with **ESP32-CAM** and sensors captures crop images and sends data to **Firebase Cloud** via a **GSM module**.
A cloud-hosted **deep learning model** analyzes infection severity and triggers an automated **sprinkler system** mounted on the drone.

System Architecture:-
-Hardware: ESP32-CAM, GSM Module, DHT11/22 (Temp-Humidity Sensor), Light Sensor, Drone Frame, Sprinkler Nozzle
-Cloud Backend: Firebase (Storage, Realtime DB, Cloud Functions)
-AI Model: CNN trained on **Kaggle rice leaf disease dataset** (accuracy > 91 %)
-Mobile App: Flutter + Firebase for alerts, infection reports, and spray logs

Features :-
-Real-time crop disease detection
-Confidence-based pesticide spraying
-Cloud-integrated mobile monitoring
-Offline data caching for poor networks
-Up to 60 % pesticide reduction

 Tech Stack:=
Hardware: ESP32-CAM · GSM · Sensors
Software: Firebase · Flutter · Python (TensorFlow/Keras) · Figma
Dataset: Public Kaggle dataset for rice leaf disease

 Impact :-
 Protects soil and water by reducing chemical overuse
 Enhances farmer profit through precision spraying
 Supports sustainable and smart agriculture

Kaggle Competition
A subset of the dataset can be used in the Kaggle competition - https://www.kaggle.com/c/paddy-disease-classification/

IEEE DataPort
The Paddy Doctor dataset submitted in an IEEE DataPort - https://ieee-dataport.org/documents/paddy-doctor-visual-image-dataset-automated-paddy-disease-classification-and-benchmarking

