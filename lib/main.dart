import 'package:flutter/material.dart';

void main() => runApp(const BookshelfApp());

class BookshelfApp extends StatefulWidget {
  const BookshelfApp({super.key});
  @override
  State<BookshelfApp> createState() => _BookshelfAppState();
}

class _BookshelfAppState extends State<BookshelfApp> {
  final Set<String> saved = <String>{};
  bool dark = false;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bookshelf',
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: LibraryPage(
          saved: saved,
          dark: dark,
          onThemeChanged: (value) => setState(() => dark = value),
          onSaved: (book) => setState(() => saved.contains(book.id) ? saved.remove(book.id) : saved.add(book.id)),
        ),
      );

  ThemeData _theme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorSchemeSeed: const Color(0xFF376B58),
        scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF7F9F7) : null,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({required this.saved, required this.dark, required this.onThemeChanged, required this.onSaved, super.key});
  final Set<String> saved;
  final bool dark;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Book> onSaved;
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int tab = 0;
  String query = '';
  String category = 'All';

  List<Book> get books => demoBooks.where((book) {
        final text = '${book.title} ${book.author} ${book.category}'.toLowerCase();
        return (query.isEmpty || text.contains(query.toLowerCase())) &&
            (category == 'All' || book.category == category) &&
            (tab == 0 || widget.saved.contains(book.id));
      }).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bookshelf'), actions: [
          IconButton(tooltip: 'Toggle theme', onPressed: () => widget.onThemeChanged(!widget.dark), icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode)),
          IconButton(tooltip: 'About Bookshelf', onPressed: () => showAboutDialog(context: context, applicationName: 'Bookshelf', applicationVersion: '1.0.0'), icon: const Icon(Icons.info_outline)),
        ]),
        body: IndexedStack(index: tab, children: [_library(context), _saved(context)]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) => setState(() => tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Library'),
            NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
          ],
        ),
      );

  Widget _library(BuildContext context) => CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _header(context)),
        SliverToBoxAdapter(child: _filters()),
        _grid(context, books),
      ]);

  Widget _saved(BuildContext context) => CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _sectionTitle(context, 'Saved books')),
        books.isEmpty ? const SliverFillRemaining(hasScrollBody: false, child: EmptyState()) : _grid(context, books),
      ]);

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good morning', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Find your next great read', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          TextField(onChanged: (value) => setState(() => query = value), decoration: const InputDecoration(hintText: 'Search books, authors, topics', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 22),
          _sectionTitle(context, 'Featured books'),
          const SizedBox(height: 12),
          SizedBox(height: 178, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 3, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => FeaturedCard(book: demoBooks[i], onTap: () => _open(context, demoBooks[i])))),
          const SizedBox(height: 22),
          _sectionTitle(context, 'Explore the library'),
        ]),
      );

  Widget _filters() {
    final categories = <String>{'All', ...demoBooks.map((book) => book.category)}.toList();
    return SizedBox(height: 52, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: category == categories[i], onSelected: (_) => setState(() => category = categories[i]))));
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)));

  SliverGrid _grid(BuildContext context, List<Book> items) => items.isEmpty
      ? const SliverGrid(delegate: SliverChildListDelegate([EmptyState()]), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 3))
      : SliverPadding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), sliver: SliverGrid.builder(gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 420, mainAxisExtent: 145, crossAxisSpacing: 14, mainAxisSpacing: 14), itemCount: items.length, itemBuilder: (_, i) => BookCard(book: items[i], saved: widget.saved.contains(items[i].id), onSaved: () => widget.onSaved(items[i]), onTap: () => _open(context, items[i]))));

  void _open(BuildContext context, Book book) => Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderPage(book: book, saved: widget.saved.contains(book.id), onSaved: () => widget.onSaved(book))));
}

class BookCard extends StatelessWidget {
  const BookCard({required this.book, required this.saved, required this.onSaved, required this.onTap, super.key});
  final Book book; final bool saved; final VoidCallback onSaved; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: onTap, child: Row(children: [Cover(book: book, width: 92), Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(book.author, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 7), Row(children: [Rating(value: book.rating), const Spacer(), IconButton(tooltip: saved ? 'Remove bookmark' : 'Bookmark', onPressed: onSaved, icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline))])])))]));
}

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({required this.book, required this.onTap, super.key});
  final Book book; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: 290, child: Card(color: book.color, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('FEATURED', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(book.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(book.author)])), const SizedBox(width: 12), Cover(book: book, width: 70)]))));
}

class Cover extends StatelessWidget {
  const Cover({required this.book, this.width = 100, super.key});
  final Book book; final double width;
  @override
  Widget build(BuildContext context) => Container(width: width, height: width * 1.28, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: book.color, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(1, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(book.category.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)), const Spacer(), Text(book.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9))]);
}

class Rating extends StatelessWidget {
  const Rating({required this.value, super.key}); final double value;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 15, color: Colors.amber), const SizedBox(width: 3), Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall)]);
}

class ReaderPage extends StatefulWidget {
  const ReaderPage({required this.book, required this.saved, required this.onSaved, super.key});
  final Book book; final bool saved; final VoidCallback onSaved;
  @override State<ReaderPage> createState() => _ReaderPageState();
}
class _ReaderPageState extends State<ReaderPage> {
  double fontSize = 18; late bool saved;
  @override void initState() { super.initState(); saved = widget.saved; }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.book.title), actions: [IconButton(tooltip: 'Bookmark', onPressed: () { setState(() => saved = !saved); widget.onSaved(); }, icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline)), IconButton(tooltip: 'Increase text size', onPressed: () => setState(() => fontSize = fontSize >= 26 ? 16 : fontSize + 2), icon: const Icon(Icons.text_fields))]), body: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 40), children: [Text(widget.book.category.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(widget.book.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('By ${widget.book.author}'), const Divider(height: 36), Text(widget.book.content, style: TextStyle(fontSize: fontSize, height: 1.7)), const SizedBox(height: 28), FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress saved'))), icon: const Icon(Icons.check), label: const Text('Mark as read'))]));
}

class EmptyState extends StatelessWidget { const EmptyState({super.key}); @override Widget build(BuildContext context) => const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No books found', textAlign: TextAlign.center))); }
class Book { const Book({required this.id, required this.title, required this.author, required this.category, required this.rating, required this.color, required this.content}); final String id, title, author, category, content; final double rating; final Color color; }
const demoBooks = <Book>[
  Book(id: 'clean-code', title: 'Clean Code', author: 'Robert C. Martin', category: 'Software', rating: 4.8, color: Color(0xFFB8E3D0), content: 'Clean code is simple and direct. It reads like well-written prose. Each function, class, and module has a clear responsibility, names reveal intent, and complexity is kept under control.'),
  Book(id: 'atomic-habits', title: 'Atomic Habits', author: 'James Clear', category: 'Growth', rating: 4.7, color: Color(0xFFFFD6A5), content: 'Small habits compound into remarkable results. Focus on systems rather than goals: make good habits obvious, attractive, easy, and satisfying.'),
  Book(id: 'design-everyday', title: 'The Design of Everyday Things', author: 'Don Norman', category: 'Design', rating: 4.6, color: Color(0xFFCDE7FF), content: 'Good design communicates its purpose. Discoverability, feedback, constraints, and clear mappings help people understand what actions are possible.'),
  Book(id: 'pragmatic', title: 'The Pragmatic Programmer', author: 'David Thomas', category: 'Software', rating: 4.8, color: Color(0xFFE8D7FF), content: 'Care about your craft. Take responsibility for your work, automate repetitive tasks, and keep knowledge in plain text.'),
  Book(id: 'mindset', title: 'Mindset', author: 'Carol S. Dweck', category: 'Growth', rating: 4.5, color: Color(0xFFFFC6D9), content: 'A growth mindset treats ability as something that can be developed. Challenges, effort, and feedback become opportunities to learn.'),
];
