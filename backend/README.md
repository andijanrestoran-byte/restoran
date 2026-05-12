# Django Backend API

Bu backend Flutter restoran ilovasini va Django kassasi sahifasini bitta ma'lumot manbaiga ulash uchun tayyorlangan.

## Nimalar bor

- JWT login: `api/auth/login/`
- Foydalanuvchi profili: `api/auth/me/`
- Stollar CRUD va waiter join endpointi
- Menyu kategoriya va item endpointlari
- Buyurtma yaratish va ko'rish endpointlari
- Kassa uchun to'lov endpointlari
- Direktor/kassa uchun dashboard summary endpointi

## Tavsiya etilgan ishga tushirish

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_demo_data
python manage.py runserver
```

## Web kassa paneli

Lokal backendga GitHub dagi funksional oqimga mos `apps.cashier` moduli qo'shildi.

Kirish sahifasi:

```text
/accounts/login/
```

Kassa sahifalari:

```text
/cashier/
/cashier/orders/
/cashier/rejected/
/cashier/tables/
```

Frontend yoki alohida web klient uchun kerak bo'lsa CORS sozlamalari environment orqali beriladi:

```env
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
CSRF_TRUSTED_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

## Asosiy endpointlar

### Auth

- `POST /api/auth/login/`
- `POST /api/auth/refresh/`
- `GET /api/auth/me/`

### Dashboard

- `GET /api/dashboard/summary/`

### Staff / Waiter / Director

- `GET|POST /api/staff/tables/`
- `POST /api/staff/tables/{id}/join/`
- `GET|POST /api/staff/menu/categories/`
- `GET|POST /api/staff/menu/items/`
- `GET|POST /api/staff/orders/`
- `POST /api/staff/orders/{id}/reject/`
- `POST /api/staff/orders/{id}/cancel/`

### Cashier

- `GET /api/cashier/payments/`
- `GET /api/cashier/payments/{id}/`
- `PATCH /api/cashier/payments/{id}/`

`PATCH /api/cashier/payments/{id}/` body misoli:

```json
{
  "payment_method": "cash",
  "amount": "84000.00"
}
```

## Flutter bilan ulash uchun minimal order payload

```json
{
  "table_id": 1,
  "note": "",
  "order_items": [
    { "menu_item": 1, "quantity": 2 },
    { "menu_item": 17, "quantity": 1 }
  ]
}
```

## Eslatma

Bu workspace ichida Python o'rnatilmagan edi, shuning uchun migration va runtime tekshiruvini shu yerda ishga tushirib bo'lmadi.
