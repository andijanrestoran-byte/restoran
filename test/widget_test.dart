import 'package:andijan_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Demo store `static` — har test boshida tozalanmasa, oldingi testlarda
  // yaratilgan buyurtmalar keyingilariga "oqib" o'tadi.
  setUp(RestaurantApiClient.resetDemoStore);

  Future<void> loginAs(
    WidgetTester tester,
    String username,
    String password,
  ) async {
    await tester.enterText(find.byKey(const Key('login_username')), username);
    await tester.enterText(find.byKey(const Key('login_password')), password);
    await tester.tap(find.byKey(const Key('login_submit')));
    await tester.pumpAndSettle();
  }

  Future<void> pressFilledButtonByKey(WidgetTester tester, String key) async {
    // Tugma FilledButton ham, IconButton ham bo'lishi mumkin (masalan
    // miqdorni oshirish IconButton). Ikkalasini ham qo'llab-quvvatlaymiz.
    final widget = tester.widget(find.byKey(Key(key)));
    final onPressed = (widget as dynamic).onPressed as VoidCallback?;
    onPressed?.call();
    await tester.pumpAndSettle();
  }

  Future<void> logout(WidgetTester tester) async {
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    expect(find.text('DASTURXON'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);
  });

  testWidgets('waiter can login, create order and logout', (tester) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    await loginAs(tester, 'azizbek', '12345');

    expect(find.text('Buyurtma berish'), findsOneWidget);
    await tester.tap(find.byKey(const Key('table_card_1')));
    await tester.pumpAndSettle();

    expect(find.text('Stol #1 buyurtmasi'), findsOneWidget);
    await pressFilledButtonByKey(tester, 'increase_item_1');
    await pressFilledButtonByKey(tester, 'submit_order');

    expect(find.text('Stol raqamini tanlang'), findsOneWidget);

    await logout(tester);
    expect(find.text('DASTURXON'), findsOneWidget);
  });

  testWidgets('waiter can add optional note to a menu item', (tester) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    await loginAs(tester, 'azizbek', '12345');
    await tester.tap(find.byKey(const Key('table_card_1')));
    await tester.pumpAndSettle();

    await pressFilledButtonByKey(tester, 'increase_item_1');
    await tester.enterText(
      find.byKey(const Key('note_item_1')),
      'Achchiqsiz qilib bering',
    );
    await pressFilledButtonByKey(tester, 'submit_order');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faol'));
    await tester.pumpAndSettle();

    expect(find.text('Izoh: Achchiqsiz qilib bering'), findsOneWidget);
  });

  testWidgets('director can see waiter orders and reject them', (tester) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    await loginAs(tester, 'azizbek', '12345');
    await tester.tap(find.byKey(const Key('table_card_2')));
    await tester.pumpAndSettle();
    await pressFilledButtonByKey(tester, 'increase_item_1');
    await pressFilledButtonByKey(tester, 'submit_order');
    await logout(tester);

    await loginAs(tester, 'direktor', '99999');

    expect(find.text('Direktor paneli'), findsOneWidget);
    await tester.tap(find.text('Ofitsantlar'));
    await tester.pumpAndSettle();

    expect(find.text("Ofitsantlar bo'limi"), findsOneWidget);

    await tester.tap(find.byKey(const Key('waiter_card_azizbek')));
    await tester.pumpAndSettle();

    expect(find.text('Bugungi olingan buyurtmalar'), findsOneWidget);
    expect(find.text('Rad etish'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Rad etish'));
    await tester.pumpAndSettle();

    // "Rad etish" dialogni yopadi va buyurtmani rad etadi. Rad etilganini
    // tasdiqlash uchun ofitsant dialogini qayta ochamiz: endi buyurtma
    // "Rad etilgan" deb ko'rinishi va "Rad etish" tugmasi yo'qolishi kerak.
    await tester.tap(find.byKey(const Key('waiter_card_azizbek')));
    await tester.pumpAndSettle();

    expect(find.text('Rad etilgan'), findsOneWidget);
    expect(find.text('Rad etish'), findsNothing);
  });

  testWidgets('director can edit menu item and waiter sees changes', (
    tester,
  ) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    await loginAs(tester, 'direktor', '99999');
    await tester.tap(find.text('Menyu'));
    await tester.pumpAndSettle();

    expect(find.text('Menyu boshqaruvi'), findsOneWidget);
    await tester.tap(find.byKey(const Key('menu_category_Milliy taomlar')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('menu_name_1')),
      'Qovurilgan osh',
    );
    await tester.enterText(find.byKey(const Key('menu_price_1')), '99000');
    await pressFilledButtonByKey(tester, 'menu_save_1');

    await logout(tester);
    await loginAs(tester, 'azizbek', '12345');
    await tester.tap(find.byKey(const Key('table_card_1')));
    await tester.pumpAndSettle();

    expect(find.text('Qovurilgan osh'), findsOneWidget);
    expect(find.text("99000 so'm"), findsWidgets);
  });

  testWidgets('wrong demo password is rejected in offline mode', (
    tester,
  ) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    // Testda server yo'q. Demo userning paroli xato bo'lsa, demo login
    // bo'lmaydi va ilova login ekranida qoladi (soxta "parol" xatosi
    // o'rniga halol ulanish xabari ko'rsatiladi).
    await loginAs(tester, 'azizbek', 'xato');

    expect(find.text('Kirish'), findsOneWidget);
    expect(find.text('DASTURXON'), findsOneWidget);
  });

  testWidgets('correct demo credentials still log in offline', (tester) async {
    await tester.pumpWidget(const AndijanFlutterApp());

    await loginAs(tester, 'azizbek', '12345');

    expect(find.text('Buyurtma berish'), findsOneWidget);
  });
}
