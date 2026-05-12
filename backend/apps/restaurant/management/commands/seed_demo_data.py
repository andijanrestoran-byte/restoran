from decimal import Decimal

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from apps.restaurant.models import DiningTable, MenuCategory, MenuItem, StaffProfile, StaffRole


class Command(BaseCommand):
    help = "Seeds demo users, tables and menu items for the restaurant API."

    def handle(self, *args, **options):
        staff_data = [
            {
                "username": "azizbek",
                "password": "12345",
                "first_name": "Azizbek",
                "last_name": "Karimov",
                "role": StaffRole.WAITER,
                "phone": "+998 90 123 45 67",
                "shift": "10:00 - 22:00",
                "experience": "4 yil",
            },
            {
                "username": "javohir",
                "password": "11111",
                "first_name": "Javohir",
                "last_name": "Rasulov",
                "role": StaffRole.WAITER,
                "phone": "+998 91 111 22 33",
                "shift": "09:00 - 21:00",
                "experience": "3 yil",
            },
            {
                "username": "direktor",
                "password": "99999",
                "first_name": "Kamoliddin",
                "last_name": "Ahmedov",
                "role": StaffRole.DIRECTOR,
                "phone": "+998 90 555 77 88",
                "shift": "09:00 - 18:00",
                "experience": "10 yil",
            },
            {
                "username": "kassa",
                "password": "55555",
                "first_name": "Kassa",
                "last_name": "Operator",
                "role": StaffRole.CASHIER,
                "phone": "+998 90 777 00 11",
                "shift": "09:00 - 23:00",
                "experience": "6 yil",
            },
        ]

        for payload in staff_data:
            user, created = User.objects.get_or_create(
                username=payload["username"],
                defaults={
                    "first_name": payload["first_name"],
                    "last_name": payload["last_name"],
                },
            )
            if created:
                user.set_password(payload["password"])
                user.save(update_fields=["password"])
            StaffProfile.objects.update_or_create(
                user=user,
                defaults={
                    "role": payload["role"],
                    "phone": payload["phone"],
                    "shift": payload["shift"],
                    "experience": payload["experience"],
                },
            )

        tables = [
            (1, 2, "Deraza yonida", False),
            (2, 4, "Asosiy zal", False),
            (3, 4, "Asosiy zal", False),
            (4, 6, "Oilaviy zona", True),
            (5, 2, "Ayvon", False),
            (6, 8, "VIP xona", False),
        ]
        for number, seats, location, is_busy in tables:
            DiningTable.objects.update_or_create(
                number=number,
                defaults={"seats": seats, "location": location, "is_busy": is_busy},
            )

        category_map = {
            "Milliy taomlar": [
                ("To'y oshi", "Mol go'shtli, sabzili va bedanali", Decimal("42000")),
                ("Manti", "8 dona, qatiq va maxsus qayla bilan", Decimal("32000")),
            ],
            "Ichimliklar": [
                ("Moxito", "Limon, yalpiz va gazli suv", Decimal("22000")),
                ("Amerikano", "Yangi damlangan qahva", Decimal("18000")),
            ],
        }
        for index, (category_name, items) in enumerate(category_map.items(), start=1):
            category, _ = MenuCategory.objects.update_or_create(
                name=category_name,
                defaults={"sort_order": index},
            )
            for item_name, description, price in items:
                MenuItem.objects.update_or_create(
                    category=category,
                    name=item_name,
                    defaults={"description": description, "price": price, "is_active": True},
                )

        self.stdout.write(self.style.SUCCESS("Demo restaurant data seeded successfully."))
