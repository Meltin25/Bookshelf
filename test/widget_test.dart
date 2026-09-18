import 'package:bookshelf/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows library content', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    expect(find.text('Bookshelf'), findsOneWidget);
    expect(find.text('Find your next great read'), findsOneWidget);
    expect(find.text('Clean Code'), findsWidgets);
  });

  testWidgets('search filters books', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    await tester.enterText(find.byType(TextField), 'Mindset');
    await tester.pump();
    expect(find.text('Mindset'), findsWidgets);
    expect(find.text('Clean Code'), findsNothing);
  });

  testWidgets('can bookmark and view saved books', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    await tester.tap(find.byTooltip('Bookmark').first);
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved books'), findsOneWidget);
    expect(find.text('Clean Code'), findsWidgets);
  });

  testWidgets('opens reader and changes text size', (tester) async {
    await tester.pumpWidget(const BookshelfApp());
    await tester.tap(find.text('Clean Code').first);
    await tester.pumpAndSettle();
    expect(find.text('Mark as read'), findsOneWidget);
    await tester.tap(find.byTooltip('Increase text size'));
    await tester.pump();
  });
}
