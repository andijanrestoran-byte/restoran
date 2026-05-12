# Andijan Flutter

This project is a full Flutter rewrite of the original native Android prototype.

Core flows:

- waiter login
- table assignment and order creation
- director dashboard with table to waiter mapping
- waiter directory with active and rejected orders
- director sales report preview

## Backend bilan ulash

Android emulator uchun default API manzil:

```text
http://10.0.2.2:8000/api
```

Backend boshqa manzilda bo'lsa:

```powershell
flutter run --dart-define=API_BASE_URL=http://SERVER_IP:8000/api
```

Ilova backend ishlayotgan bo'lsa JWT login qiladi, menyu va stollarni backenddan oladi, buyurtmalarni API orqali yuboradi. Backend ishlamayotgan bo'lsa demo rejimda ishlashda davom etadi.
