from django.contrib.auth.hashers import make_password
from django.db import migrations


def seed_test_data(apps, schema_editor):
    User = apps.get_model("auth", "User")
    StaffProfile = apps.get_model("restaurant", "StaffProfile")
    DiningTable = apps.get_model("restaurant", "DiningTable")
    MenuCategory = apps.get_model("restaurant", "MenuCategory")
    MenuItem = apps.get_model("restaurant", "MenuItem")

    director, _ = User.objects.get_or_create(
        username="direktor",
        defaults=dict(
            first_name="Aziz",
            last_name="Direktorov",
            is_staff=True,
            password=make_password("99999"),
        ),
    )
    StaffProfile.objects.get_or_create(user=director, defaults=dict(role="director", phone="+998901234567", shift="1", experience="3 yil"))

    waiter, _ = User.objects.get_or_create(
        username="azizbek",
        defaults=dict(
            first_name="Azizbek",
            last_name="Abdullayev",
            password=make_password("12345"),
        ),
    )
    StaffProfile.objects.get_or_create(user=waiter, defaults=dict(role="waiter", phone="+998901234568", shift="1", experience="1 yil"))

    cashier, _ = User.objects.get_or_create(
        username="kassir",
        defaults=dict(
            first_name="Kassir",
            last_name="Kassirov",
            password=make_password("kassir"),
        ),
    )
    StaffProfile.objects.get_or_create(user=cashier, defaults=dict(role="cashier", phone="+998901234569", shift="1", experience="2 yil"))

    tables = []
    for i in range(1, 13):
        t = DiningTable.objects.create(
            number=i,
            seats=4 if i % 3 != 0 else 6,
            location="Zal" if i <= 8 else "Veranda",
        )
        tables.append(t)

    cat1 = MenuCategory.objects.create(name="Milliy taomlar", sort_order=1)
    cat2 = MenuCategory.objects.create(name="Turk taomlari", sort_order=2)
    cat3 = MenuCategory.objects.create(name="Ichimliklar", sort_order=3)
    cat4 = MenuCategory.objects.create(name="Salatlar", sort_order=4)
    cat5 = MenuCategory.objects.create(name="Desertlar", sort_order=5)

    menu_items = [
        MenuItem.objects.create(name="Osh", category=cat1, description="An'anaviy palov", price=25000),
        MenuItem.objects.create(name="Manti", category=cat1, description="Bug'da pishgan manti", price=20000),
        MenuItem.objects.create(name="Kabob", category=cat1, description="Go'shtli kabob", price=30000),
        MenuItem.objects.create(name="Sho'rva", category=cat1, description="Issiq sho'rva", price=15000),
        MenuItem.objects.create(name="Lavash", category=cat2, description="Turk lavashi", price=28000),
        MenuItem.objects.create(name="Shaurma", category=cat2, description="Tandir shaurma", price=22000),
        MenuItem.objects.create(name="Pide", category=cat2, description="Turk pidesi", price=35000),
        MenuItem.objects.create(name="Kola", category=cat3, description="Sovuq ichimlik", price=5000),
        MenuItem.objects.create(name="Choy", category=cat3, description="Ko'k choy", price=3000),
        MenuItem.objects.create(name="Suv", category=cat3, description="Mineral suv", price=2000),
        MenuItem.objects.create(name="Sneakers", category=cat4, description="Sneakers salat", price=18000),
        MenuItem.objects.create(name="Sezar", category=cat4, description="Sezar salat", price=22000),
        MenuItem.objects.create(name="Napoleon", category=cat5, description="Napoleon tort", price=15000),
        MenuItem.objects.create(name="Muzqaymoq", category=cat5, description="Vanilli muzqaymoq", price=10000),
    ]

    tables[0].assigned_waiters.add(waiter)
    tables[1].assigned_waiters.add(waiter)


class Migration(migrations.Migration):

    dependencies = [
        ("restaurant", "0002_orderitem_note"),
    ]

    operations = [
        migrations.RunPython(seed_test_data, migrations.RunPython.noop),
    ]
