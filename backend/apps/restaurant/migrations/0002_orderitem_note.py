from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("restaurant", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="orderitem",
            name="note",
            field=models.CharField(blank=True, max_length=255),
        ),
    ]
