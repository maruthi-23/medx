# MedX – Smart Medicine Reminder 💊

MedX is a **Smart Medicine Reminder System** designed to help users remember to take their medicines on time. The system combines a **Flutter mobile application**, **ESP32 hardware**, and **Firebase cloud services** to ensure medication adherence.

The mobile app allows users to add medicines and schedule reminders. A smart medicine box powered by **ESP32** detects whether the user has taken the medicine. The device updates the status to the cloud as **taken** or **missed**, helping users and caretakers track medication usage.



# 🚀 Features

 📅 Medicine Scheduling

Users can add medicines and set reminder times easily through the mobile app.

 🔔 Smart Notifications

The app sends timely reminders so users never miss their medication.

 ☁️ Firebase Cloud Integration

All medicine schedules and statuses are stored securely using Firebase.

 📡 ESP32 Smart Device

The ESP32 device connects to WiFi and updates medicine status:

* **Taken** → When the user presses the device button.
* **Missed** → If the user does not press the button within the allowed time.

 📱 User-Friendly Mobile App

A simple and clean Flutter interface designed for easy usage.

 🔐 User Authentication

Secure login and signup using Firebase Authentication.



🏗️ System Architecture


Flutter Mobile App
        │
        │
        ▼
   Firebase Backend
   (Auth + Firestore)
        │
        │
        ▼
     ESP32 Device
 (Smart Medicine Box)




⚙️ Workflow

1. User logs in to the mobile app.
2. User adds medicine schedules.
3. Data is stored in **Firebase Firestore**.
4. The app sends reminder notifications at scheduled times.
5. User presses the **ESP32 button** after taking medicine.
6. ESP32 updates the medicine status in Firebase:

   * taken
   * missed
7. The updated status is reflected in the mobile app.



🛠️ Tech Stack

## Mobile Application

* Flutter
* Dart
* Local Notifications

## Backend

* Firebase Authentication
* Cloud Firestore

## Hardware

* ESP32 / ESP32-C3
* Push Button
* WiFi Connectivity


🔧 ESP32 Functionality

The ESP32 smart medicine box performs the following tasks:

* Connects to WiFi
* Communicates with Firebase Firestore
* Updates medicine status

Status updates:

* **taken** → When the user presses the button
* **missed** → When the user does not press the button within the set time



🎯 Problem Statement

Many patients forget to take medicines on time, especially elderly people and patients with strict medication schedules. Missing doses can lead to serious health complications.

MedX solves this problem by providing a **smart reminder system with cloud tracking**, ensuring medicines are taken on time.






