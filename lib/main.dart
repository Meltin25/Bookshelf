import 'package:flutter/material.dart';

void main() => runApp(const BookshelfApp());

class BookshelfApp extends StatefulWidget {
  const BookshelfApp({super.key});

  @override
  State<BookshelfApp> createState() => _BookshelfAppState();
}

class _BookshelfAppState extends State<BookshelfApp> {
  final List<Book> _books = demoBooks;
  final Set<String> _bookmarks = <String>{};
  bool _darkMode = false;

  void _toggleBookmark(Book book) {
    setState(() {
      _bookmarks.contains(book.id)
          ? _bookmarks.remove(book.id)
          : _bookmarks.add(book.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookshelf',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: HomePage(
        books: _books,
        bookmarkedIds: _bookmarks,
        onBookmark: _toggleBookmark,
        darkMode: _darkMode,
        onDarkModeChanged: (value) => setState(() => _darkMode = value),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    required this.books,
    required this.bookmarkedIds,
    required this.onBookmark,
    required this.darkMode,
    required this.onDarkModeChanged,
    super.key,
  });

  final List<Book> books;
  final Set<String> bookmarkedIds;
  final ValueChanged<Book> onBookmark;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  String _query = '';
  String _filter = 'All';

  List<Book> get _visibleBooks {
    final query = _query.trim().toLowerCase();
    return widget.books.where((book) {
      final matchesQuery = query.isEmpty ||
          '${book.title} ${book.author} ${book.category}'
              .toLowerCase()
              .contains(query);
      final matchesFilter = _filter == 'All' || book.category == _filter;
      final matchesTab = _tab != 1 || widget.bookmarkedIds.contains(book.id);
      return matchesQuery && matchesFilter && matchesTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookshelf'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => widget.onDarkModeChanged(!widget.darkMode),
            icon: Icon(widget.darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => _showAbout(context),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _buildLibrary(context),
          _buildBookmarks(context),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildLibrary(BuildContext context) {
    final categories = <String>{'All', ...widget.books.map((book) => book.category)}.toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final category = categories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: category == _filter,
                  onSelected: (_) => setState(() => _filter = category),
                );
              },
            ),
          ),
        ),
        _bookGrid(context, _visibleBooks),
      ],
    );
  }

  Widget _buildBookmarks(BuildContext context) {
    final saved = _visibleBooks;
    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 20)),
        SliverToBoxAdapter(child: _sectionTitle('Saved books')),
        if (saved.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: EmptyState())
        else
          _bookGrid(context, saved),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Good morning', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Find your next great read', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(hintText: 'Search books, authors, topics', prefixIcon: Icon(Icons.search), suffixIcon: Icon(Icons.tune)),
        ),
        const SizedBox(height: 24),
        _sectionTitle('Featured books'),
        const SizedBox(height: 12),
        SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.books.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => FeaturedCard(book: widget.books[index], onTap: () => _openBook(context, widget.books[index])),
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Explore the library'),
      ]),
    );
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)));

  SliverGrid _bookGrid(BuildContext context, List<Book> books) {
    if (books.isEmpty) return const SliverGrid(delegate: SliverChildListDelegate([EmptyState()]), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 3));
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 420, mainAxisExtent: 145, crossAxisSpacing: 14, mainAxisSpacing: 14),
        itemCount: books.length,
        itemBuilder: (_, index) {
          final book = books[index];
          return BookCard(book: book, saved: widget.bookmarkedIds.contains(book.id), onBookmark: () => widget.onBookmark(book), onTap: () => _openBook(context, book));
        },
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReaderPage(book: book, saved: widget.bookmarkedIds.contains(book.id), onBookmark: () => widget.onBookmark(book))));
  }

  void _showAbout(BuildContext context) => showAboutDialog(context: context, applicationName: 'Bookshelf', applicationVersion: '1.0.0', children: const [Text('A focused reading library with search, saved books, theme support, and a distraction-free reader.')]);
}

class BookCard extends StatelessWidget {
  const BookCard({required this.book, required this.saved, required this.onBookmark, required this.onTap, super.key});
  final Book book;
  final bool saved;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Row(children: [BookCover(book: book, width: 92), Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(book.author, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 9), Row(children: [Rating(rating: book.rating), const Spacer(), IconButton(onPressed: onBookmark, icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline), tooltip: 'Save book')])])))])),
      );
}

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({required this.book, required this.onTap, super.key});
  final Book book;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(width: 290, child: Card(color: book.color, child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('FEATURED', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(book.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(book.author)])), const SizedBox(width: 12), BookCover(book: book, width: 70)]))));
}

class BookCover extends StatelessWidget {
  const BookCover({required this.book, this.width = 100, super.key});
  final Book book;
  final double width;
  @override
  Widget build(BuildContext context) => Container(width: width, height: width * 1.28, decoration: BoxDecoration(color: book.color, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(1, 2))]), child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(book.category.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)), const Spacer(), Text(book.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9))])));
}

class Rating extends StatelessWidget {
  const Rating({required this.rating, super.key});
  final double rating;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, size: 15, color: Colors.amber), const SizedBox(width: 3), Text(rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall)]);
}

class ReaderPage extends StatefulWidget {
  const ReaderPage({required this.book, required this.saved, required this.onBookmark, super.key});
  final Book book;
  final bool saved;
  final VoidCallback onBookmark;
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  double _fontSize = 18;
  late bool _saved;
  @override
  void initState() { super.initState(); _saved = widget.saved; }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.book.title), actions: [IconButton(onPressed: () { setState(() => _saved = !_saved); widget.onBookmark(); }, icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_outline)), PopupMenuButton<String>(onSelected: (value) { if (value == 'font') setState(() => _fontSize = _fontSize >= 24 ? 16 : _fontSize + 2); }, itemBuilder: (_) => const [PopupMenuItem(value: 'font', child: Text('Change text size'))])]), body: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 40), children: [Text(widget.book.category.toUpperCase(), style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(widget.book.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('By ${widget.book.author}'), const Divider(height: 36), Text(widget.book.content, style: TextStyle(fontSize: _fontSize, height: 1.7)), const SizedBox(height: 28), FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Progress saved'))), icon: const Icon(Icons.check), label: const Text('Mark as read'))]));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.menu_book_outlined, size: 56, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), const Text('No books found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 5), const Text('Try another search or save a book for later.', textAlign: TextAlign.center)])));
}

class Book {
  const Book({required this.id, required this.title, required this.author, required this.category, required this.rating, required this.color, required this.content});
  final String id, title, author, category, content;
  final double rating;
  final Color color;
}

const demoBooks = <Book>[
  Book(id: 'clean-code', title: 'Clean Code', author: 'Robert C. Martin', category: 'Software', rating: 4.8, color: Color(0xFFB8E3D0), content: 'Clean code is simple and direct. It reads like well-written prose. Each function, class, and module has a clear responsibility, names reveal intent, and complexity is kept under control. The best code is not clever; it is easy to change, test, and explain.'),
  Book(id: 'atomic-habits', title: 'Atomic Habits', author: 'James Clear', category: 'Growth', rating: 4.7, color: Color(0xFFFFD6A5), content: 'Small habits compound into remarkable results. Focus on systems rather than goals: make good habits obvious, attractive, easy, and satisfying. A tiny improvement repeated consistently can transform the direction of a life.'),
  Book(id: 'design-everyday', title: 'The Design of Everyday Things', author: 'Don Norman', category: 'Design', rating: 4.6, color: Color(0xFFCDE7FF), content: 'Good design communicates its purpose. Discoverability, feedback, constraints, and clear mappings help people understand what actions are possible. When something is difficult to use, the problem is often the design, not the person.'),
  Book(id: 'pragmatic', title: 'The Pragmatic Programmer', author: 'David Thomas', category: 'Software', rating: 4.8, color: Color(0xFFE8D7FF), content: 'Care about your craft. Take responsibility for your work, automate repetitive tasks, and keep knowledge in plain text. Software should be adaptable because requirements, tools, and assumptions will change.'),
  Book(id: 'mindset', title: 'Mindset', author: 'Carol S. Dweck', category: 'Growth', rating: 4.5, color: Color(0xFFFFC6D9), content: 'A growth mindset treats ability as something that can be developed. Challenges, effort, and feedback become opportunities to learn rather than evidence of a fixed limit.'),
];

class AppTheme {
  static ThemeData get light => ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF376B58), brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFF7F9F7), inputDecorationTheme: const InputDecorationTheme(filled: true, border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16)))));
  static ThemeData get dark => ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF75D7B0), brightness: Brightness.dark, inputDecorationTheme: const InputDecorationTheme(filled: true, border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(16)))));
}
