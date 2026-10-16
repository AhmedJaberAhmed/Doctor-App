
<div align="center">

# 🩺 Doctor & Clinic Appointment Booking System

### Flutter • Supabase • PostgreSQL • PayPal

A modern doctor appointment booking and clinic management
application developed using **Flutter and Supabase**.

The system connects patients with doctors, simplifies
appointment scheduling, and provides dedicated interfaces
for patients and healthcare professionals.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![PayPal](https://img.shields.io/badge/PayPal-003087?logo=paypal&logoColor=white)

</div>

---

## 📸 Project Preview

<div align="center">

<a href="b0dd238a-d42c-400e-a16e-deff2cdd25ca.png">
  <img
    src="b0dd238a-d42c-400e-a16e-deff2cdd25ca.png"
    alt="Doctor and Clinic Appointment App Preview"
    width="100%"
  />
</a>

</div>

---

## 📖 About the Project

**Doctor & Clinic Appointment Booking System** is
a Flutter-based application designed to simplify
the process of finding doctors and scheduling
medical appointments.

The platform provides two main experiences:

- **Patient Application:** Allows patients to
  discover doctors and clinics, explore available
  appointments, and book consultations.

- **Doctor Application:** Enables doctors to
  manage their schedules, appointment availability,
  and patient bookings.

Supabase provides backend services and
database management, while PayPal supports
payment-related functionality.

---

## ✨ Key Features

### 👤 Authentication & User Management

- User registration and login.
- Supabase Authentication.
- Doctor and patient accounts.
- User profile management.

### 🩺 Doctor Discovery

- Browse available doctors.
- Explore medical specialties.
- View doctor information.
- Discover clinics.
- Search for healthcare professionals.

### 📅 Appointment Booking

- Browse available appointment slots.
- Select preferred appointment dates.
- Book doctor appointments.
- View appointment information.
- Manage scheduled appointments.

### 👨‍⚕️ Doctor Management

- Doctor profile management.
- Appointment schedule management.
- Availability configuration.
- View patient bookings.
- Manage appointment records.

### 🏥 Clinic Information

- Browse clinics.
- View clinic details.
- Explore available healthcare services.
- Find doctors associated with clinics.

### 💳 Payment Integration

- PayPal integration.
- Appointment-related payment workflows.
- Online payment support.

### 📱 User Experience

- Modern Flutter UI.
- Responsive layouts.
- Intuitive navigation.
- Dedicated patient and doctor interfaces.
- Reusable UI components.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform application |
| Dart | Application development |
| Supabase | Backend services |
| PostgreSQL | Database |
| Supabase Auth | Authentication |
| PayPal | Payment integration |
| Git & GitHub | Version control |

---

## 🏗️ System Architecture

The application connects patient and
doctor interfaces to a shared backend.

```text
       Doctor Appointment System
                  |
         +--------+--------+
         |                 |
         v                 v
    Patient App        Doctor App
         |                 |
         +--------+--------+
                  |
                  v
           Supabase Backend
                  |
        +---------+---------+
        |         |         |
        v         v         v
       Auth    Database   Storage
                  |
                  v
       Doctors / Patients /
       Clinics / Appointments
                  |
                  v
             PayPal
```

---

## 🔄 Appointment Booking Workflow

### Patient Workflow

```text
      Patient Registration
               |
               v
         Browse Doctors
               |
               v
         Select Doctor
               |
               v
       Check Availability
               |
               v
       Select Appointment
               |
               v
        Confirm Booking
               |
               v
       Payment Processing
               |
               v
        View Appointment
```

### Doctor Workflow

```text
       Doctor Registration
               |
               v
        Manage Profile
               |
               v
       Configure Schedule
               |
               v
       Set Available Slots
               |
               v
       Receive Appointments
               |
               v
        Manage Bookings
```

---

## 👥 User Roles

### Patient

Patients can:

- Browse doctors and clinics.
- Explore medical specialties.
- View appointment availability.
- Schedule appointments.
- Manage bookings.
- Complete supported payments.

### Doctor

Doctors can:

- Manage professional profiles.
- Configure available schedules.
- Review patient appointments.
- Manage booking information.
- Update appointment availability.

---

## 🚀 Getting Started

### Prerequisites

Before running the project, install:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Git
- Supabase project
- PayPal developer account for payment testing

### 1. Clone the Repository

```bash
git clone <YOUR_DOCTOR_APP_REPOSITORY_URL>
```

Replace the placeholder with your
actual GitHub repository URL.

### 2. Open the Project

```bash
cd <YOUR_PROJECT_FOLDER>
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Supabase

Create a Supabase project and configure
the application with:

- Supabase Project URL.
- Supabase publishable/anon key.
- Required PostgreSQL database tables.
- Authentication settings.
- Row Level Security policies.
- Storage buckets, if required.

Ensure the database structure matches
the application's existing data models.

Never expose a Supabase service-role
key in the Flutter application.

### 5. Configure PayPal

Configure the payment integration
according to the project's implementation.

Use PayPal Sandbox credentials for testing.

Keep payment secret credentials
on a secure backend.

### 6. Run the Application

```bash
flutter run
```

Note: The application requires its
corresponding Supabase database schema,
access policies, and payment configuration
to function correctly.

---

## 💡 Development Highlights

This project demonstrates experience in:

- Flutter mobile development.
- Building appointment booking systems.
- Designing patient and doctor workflows.
- Integrating Supabase backend services.
- Managing relational database records.
- Implementing authentication.
- Managing scheduling and availability.
- Integrating online payments.
- Developing responsive interfaces.

---

## 🎯 Project Goals

- Simplify medical appointment booking.
- Help patients discover doctors and clinics.
- Improve appointment schedule management.
- Provide dedicated patient and doctor experiences.
- Support convenient online payments.
- Create an intuitive healthcare booking interface.

---

## 👨‍💻 Developer

**Ahmed Jaber Ahmed**

Flutter Developer | Mobile App Developer

B.Sc. Computer Science & Artificial Intelligence

📍 Cairo, Egypt

- [GitHub](https://github.com/AhmedJaberAhmed)
- [Portfolio](https://ahmedjaberahmed.github.io/Jaber-website/)
- [LinkedIn](https://www.linkedin.com/in/ahmedjaberahmed/)

---

<div align="center">

### ⭐ Support the Project

If you find this project interesting,
consider giving it a star!

**Built with Flutter 💙**

</div>
