import 'package:flutter_test/flutter_test.dart';
import 'package:bookshelf/main.dart';

void main() {
  testWidgets('renders the bookshelf library', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    expect(find.text('Bookshelf'), findsOneWidget);
    expect(find.text('Find your next great read'), findsOneWidget);
    expect(find.text('Clean Code'), findsWidgets);
  });

  testWidgets('can switch to saved books', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved books'), findsOneWidget);
  });
}
