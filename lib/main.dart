import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ===================== WARNA (dari DESIGN.md) =====================
const Color kPrimary = Color(0xFF2D5A43); // Rainforest Sage
const Color kPrimaryDalam = Color(0xFF14422D); // primary gelap
const Color kCoral = Color(0xFFE06D53); // Wild Orchid Coral
const Color kOchre = Color(0xFFD4A373); // Sunlit Pollen
const Color kNeutral = Color(0xFF222B25); // Deep Chlorophyll
const Color kCanvas = Color(0xFFFAFAF7); // Petal cream
const Color kPermukaan = Color(0xFFF4F6F0); // Surface muted
const Color kGaris = Color(0x262D5A43); // outline 15%

Color get kTeksMuted => kNeutral.withValues(alpha: 0.62);

const List<BoxShadow> kBayang = [
  BoxShadow(
    color: Color(0x142D5A43),
    blurRadius: 24,
    spreadRadius: -4,
    offset: Offset(0, 8),
  ),
];

TextStyle gayaSerif({
  double size = 20,
  FontWeight weight = FontWeight.w700,
  Color? warna,
  FontStyle? gaya,
}) {
  return GoogleFonts.playfairDisplay(
    fontSize: size,
    fontWeight: weight,
    color: warna ?? kNeutral,
    fontStyle: gaya,
    height: 1.15,
  );
}

// ===================== KEGEMARAN =====================
/// Nama bunga yang dipilih sebagai kegemaran (hilang bila app ditutup).
final ValueNotifier<Set<String>> kegemaran = ValueNotifier<Set<String>>({});

void togolKegemaran(String nama) {
  final baru = Set<String>.from(kegemaran.value);
  if (!baru.remove(nama)) {
    baru.add(nama);
  }
  kegemaran.value = baru;
}

void mesej(BuildContext context, String teks) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(teks),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
}

// ===================== APP =====================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildBloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kCoral,
          tertiary: kOchre,
          surface: kCanvas,
          onSurface: kNeutral,
        ),
        scaffoldBackgroundColor: kCanvas,
        textTheme:
            GoogleFonts.plusJakartaSansTextTheme().apply(
          bodyColor: kNeutral,
          displayColor: kNeutral,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

// ===================== DATA =====================
class Bunga {
  final String letter;
  final String name;
  final String? description;
  final String? habitat;
  final String? season;
  final String? conservation;
  final String? photo;

  Bunga({
    required this.letter,
    required this.name,
    this.description,
    this.habitat,
    this.season,
    this.conservation,
    this.photo,
  });

  factory Bunga.fromJson(Map<String, dynamic> json) {
    return Bunga(
      letter: json['letter'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      habitat: json['habitat'] as String?,
      season: json['season'] as String?,
      conservation: json['conservation'] as String?,
      photo: json['photo'] as String?,
    );
  }
}

Future<List<Bunga>> muatBunga() async {
  final raw = await rootBundle.loadString('assets/flora.json');
  final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
  return data
      .map((e) => Bunga.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<List<Bunga>>? _cacheBunga;

/// Data dimuat sekali sahaja dan dikongsi antara skrin.
Future<List<Bunga>> dataBunga() => _cacheBunga ??= muatBunga();

/// Jenis berdasarkan nama: Famili (…aceae / Family), Spesies (2 perkataan), Genus.
String jenisBunga(Bunga b) {
  final n = b.name.trim();
  if (n.endsWith('aceae') || n.contains('Family')) return 'Famili';
  if (n.contains(' ')) return 'Spesies';
  return 'Genus';
}

String tagFoto(Bunga b, {String awalan = 'foto'}) => '$awalan-${b.name}';

Widget gambarBunga(Bunga b) {
  if (b.photo == null) {
    return Container(
      color: kPrimary.withValues(alpha: 0.10),
      child: Icon(
        Icons.local_florist_outlined,
        color: kPrimary.withValues(alpha: 0.6),
        size: 36,
      ),
    );
  }
  return Image.asset(b.photo!, fit: BoxFit.cover);
}

void bukaDetail(BuildContext context, Bunga b) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => BungaDetailPage(bunga: b)),
  );
}

// ===================== SHELL (navigasi bawah) =====================
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: const [
            SenaraiBungaPage(), // 0 Teroka
            HalamanAkanDatang(
              tajuk: 'Pengecaman AI',
              ikon: Icons.center_focus_strong_outlined,
            ), // 1
            HerbariumPage(), // 2
            HalamanAkanDatang(
              tajuk: 'Profil Pengkaji',
              ikon: Icons.person_outline,
            ), // 3
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Imbas bunga',
        backgroundColor: kPrimaryDalam,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => setState(() => _tab = 1),
        child: const Icon(Icons.photo_camera_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        child: Row(
          children: [
            Expanded(
              child: NavItem(
                ikon: Icons.explore_outlined,
                ikonAktif: Icons.explore,
                label: 'Teroka',
                aktif: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
            ),
            Expanded(
              child: NavItem(
                ikon: Icons.center_focus_weak_outlined,
                ikonAktif: Icons.center_focus_strong,
                label: 'Pengecaman',
                aktif: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: NavItem(
                ikon: Icons.menu_book_outlined,
                ikonAktif: Icons.menu_book,
                label: 'Herbarium',
                aktif: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
            ),
            Expanded(
              child: NavItem(
                ikon: Icons.person_outline,
                ikonAktif: Icons.person,
                label: 'Profil',
                aktif: _tab == 3,
                onTap: () => setState(() => _tab = 3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData ikon;
  final IconData ikonAktif;
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.ikon,
    required this.ikonAktif,
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: aktif ? kPrimary.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                aktif ? ikonAktif : ikon,
                size: 22,
                color: aktif ? kPrimaryDalam : kTeksMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                color: aktif ? kPrimaryDalam : kTeksMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HalamanAkanDatang extends StatelessWidget {
  final String tajuk;
  final IconData ikon;

  const HalamanAkanDatang({super.key, required this.tajuk, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 64, color: kPrimary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(tajuk, style: gayaSerif(size: 22)),
          const SizedBox(height: 4),
          Text('Akan datang', style: GoogleFonts.plusJakartaSans(color: kTeksMuted)),
        ],
      ),
    );
  }
}

// ===================== KOMPONEN KECIL =====================

/// Animasi masuk satu-satu (fade + slide).
class Muncul extends StatelessWidget {
  final int index;
  final Widget child;

  const Muncul({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index < 8 ? index : 8) * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, ch) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: ch,
        ),
      ),
      child: child,
    );
  }
}

class PilJenis extends StatelessWidget {
  final String teks;

  const PilJenis(this.teks, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimary.withValues(alpha: 0.18)),
      ),
      child: Text(
        teks.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: kPrimaryDalam,
        ),
      ),
    );
  }
}

class BntKegemaran extends StatelessWidget {
  final String nama;
  final double saiz;

  const BntKegemaran({super.key, required this.nama, this.saiz = 22});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: kegemaran,
      builder: (context, favs, _) {
        final ada = favs.contains(nama);
        return InkResponse(
          radius: 24,
          onTap: () => togolKegemaran(nama),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                ada ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(ada),
                size: saiz,
                color: ada ? kCoral : kNeutral.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BulatanKaca extends StatelessWidget {
  final IconData ikon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? warnaIkon;
  final bool aktif;

  const BulatanKaca({
    super.key,
    required this.ikon,
    required this.onTap,
    this.tooltip,
    this.warnaIkon,
    this.aktif = false,
  });

  @override
  Widget build(BuildContext context) {
    final butang = Material(
      color: aktif ? kPrimary : Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(side: BorderSide(color: kGaris)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            ikon,
            size: 20,
            color: aktif ? Colors.white : (warnaIkon ?? kNeutral),
          ),
        ),
      ),
    );
    return tooltip == null ? butang : Tooltip(message: tooltip!, child: butang);
  }
}

class ChipAbjad extends StatelessWidget {
  final String label;
  final bool aktif;
  final bool ikonCheck;
  final VoidCallback onTap;

  const ChipAbjad({
    super.key,
    required this.label,
    required this.aktif,
    required this.onTap,
    this.ikonCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: aktif ? kPrimaryDalam : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: aktif ? kPrimaryDalam : kGaris),
              boxShadow: aktif
                  ? const [
                      BoxShadow(
                        color: Color(0x4D14422D),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aktif && ikonCheck) ...[
                  const Icon(Icons.check, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: aktif ? FontWeight.w700 : FontWeight.w600,
                    color: aktif ? Colors.white : kNeutral,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== SKRIN 1: TEROKA (senarai) =====================
class SenaraiBungaPage extends StatefulWidget {
  const SenaraiBungaPage({super.key});

  @override
  State<SenaraiBungaPage> createState() => _SenaraiBungaPageState();
}

class _SenaraiBungaPageState extends State<SenaraiBungaPage> {
  final TextEditingController _carian = TextEditingController();
  String? _huruf; // null = semua
  String _kata = '';
  bool _hanyaKegemaran = false;
  bool _paparanGrid = false;

  @override
  void dispose() {
    _carian.dispose();
    super.dispose();
  }

  List<Bunga> _tapis(List<Bunga> semua, Set<String> favs) {
    final q = _kata.trim().toLowerCase();
    return semua.where((b) {
      if (_huruf != null && b.letter != _huruf) return false;
      if (_hanyaKegemaran && !favs.contains(b.name)) return false;
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return FutureBuilder<List<Bunga>>(
      future: dataBunga(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ralat: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final semua = snapshot.data!;
        final huruf = semua.map((b) => b.letter).toSet().toList()..sort();

        return ValueListenableBuilder<Set<String>>(
          valueListenable: kegemaran,
          builder: (context, favs, _) {
            final senarai = _tapis(semua, favs);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kepala
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: kPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'FLORA & HERBARIUM MALAYSIA',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.3,
                                    color: kPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Senarai Bunga WildBloom',
                              style: gayaSerif(size: 27),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Koleksi Botani & Khazanah Flora Hutan Tropika',
                              style: tema.textTheme.bodySmall
                                  ?.copyWith(color: kTeksMuted),
                            ),
                          ],
                        ),
                      ),
                      BulatanKaca(
                        ikon: _hanyaKegemaran
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        tooltip: 'Tapis kegemaran',
                        aktif: _hanyaKegemaran,
                        onTap: () =>
                            setState(() => _hanyaKegemaran = !_hanyaKegemaran),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Carian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _carian,
                    decoration: InputDecoration(
                      hintText: 'Cari nama bunga, genus, atau famili...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: kTeksMuted,
                      ),
                      prefixIcon: const Icon(Icons.search, color: kPrimary),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_kata.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _carian.clear();
                                setState(() => _kata = '');
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.mic_none_outlined,
                                color: kPrimary),
                            onPressed: () =>
                                mesej(context, 'Carian suara belum tersedia'),
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: kGaris),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(color: kGaris),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide:
                            const BorderSide(color: kPrimary, width: 1.5),
                      ),
                    ),
                    onChanged: (v) => setState(() => _kata = v),
                  ),
                ),
                const SizedBox(height: 12),

                // Chip abjad
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ChipAbjad(
                        label: 'Semua',
                        aktif: _huruf == null,
                        ikonCheck: true,
                        onTap: () => setState(() => _huruf = null),
                      ),
                      ...huruf.map((h) => ChipAbjad(
                            label: h,
                            aktif: _huruf == h,
                            onTap: () => setState(() => _huruf = h),
                          )),
                    ],
                  ),
                ),

                // Kiraan + toggle paparan
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 8, 6),
                  child: Row(
                    children: [
                      Text(
                        'Dipaparkan:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kTeksMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${senarai.length} daripada ${semua.length} bunga',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kPrimaryDalam,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Paparan senarai',
                        onPressed: () => setState(() => _paparanGrid = false),
                        icon: Icon(
                          Icons.view_agenda_outlined,
                          color: !_paparanGrid ? kPrimaryDalam : kTeksMuted,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Paparan grid',
                        onPressed: () => setState(() => _paparanGrid = true),
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: _paparanGrid ? kPrimaryDalam : kTeksMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Senarai / grid
                Expanded(
                  child: senarai.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _hanyaKegemaran
                                    ? Icons.bookmark_border
                                    : Icons.search_off,
                                size: 56,
                                color: kPrimary.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _hanyaKegemaran && favs.isEmpty
                                    ? 'Belum ada kegemaran.\nTekan ikon hati pada bunga.'
                                    : 'Tiada bunga dijumpai',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _paparanGrid
                          ? GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.74,
                              ),
                              itemCount: senarai.length,
                              itemBuilder: (context, index) {
                                final b = senarai[index];
                                return Muncul(
                                  key: ValueKey(b.name),
                                  index: index,
                                  child: _KadGrid(
                                    bunga: b,
                                    awalanTag: 'foto',
                                    onTap: () => bukaDetail(context, b),
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                              itemCount: senarai.length,
                              itemBuilder: (context, index) {
                                final b = senarai[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Muncul(
                                    key: ValueKey(b.name),
                                    index: index,
                                    child: _KadSenarai(
                                      bunga: b,
                                      awalanTag: 'foto',
                                      onTap: () => bukaDetail(context, b),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _KadSenarai extends StatelessWidget {
  final Bunga bunga;
  final String awalanTag;
  final VoidCallback onTap;

  const _KadSenarai({
    required this.bunga,
    required this.awalanTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGaris),
            boxShadow: kBayang,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Hero(
                    tag: tagFoto(bunga, awalan: awalanTag),
                    child: gambarBunga(bunga),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PilJenis(jenisBunga(bunga)),
                        const Spacer(),
                        BntKegemaran(nama: bunga.name, saiz: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bunga.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: gayaSerif(size: 18),
                    ),
                    if (bunga.habitat != null)
                      Text(
                        bunga.habitat!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: kTeksMuted,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      bunga.description ?? 'Belum ada penerangan',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KadGrid extends StatelessWidget {
  final Bunga bunga;
  final String awalanTag;
  final VoidCallback onTap;

  const _KadGrid({
    required this.bunga,
    required this.awalanTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGaris),
            boxShadow: kBayang,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: tagFoto(bunga, awalan: awalanTag),
                      child: gambarBunga(bunga),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: BntKegemaran(nama: bunga.name, saiz: 18),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PilJenis(jenisBunga(bunga)),
                    const SizedBox(height: 6),
                    Text(
                      bunga.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: gayaSerif(size: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== SKRIN 2: HERBARIUM (kegemaran) =====================
class HerbariumPage extends StatelessWidget {
  const HerbariumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Bunga>>(
      future: dataBunga(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ralat: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final semua = snapshot.data!;
        return ValueListenableBuilder<Set<String>>(
          valueListenable: kegemaran,
          builder: (context, favs, _) {
            final koleksi = semua.where((b) => favs.contains(b.name)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HERBARIUM SAYA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                          color: kPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Koleksi Kegemaran', style: gayaSerif(size: 27)),
                      const SizedBox(height: 4),
                      Text(
                        '${koleksi.length} bunga disimpan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: kTeksMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: koleksi.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_border,
                                    size: 56,
                                    color: kPrimary.withValues(alpha: 0.35)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum ada koleksi.\nTekan ikon hati pada bunga untuk simpan.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                          itemCount: koleksi.length,
                          itemBuilder: (context, index) {
                            final b = koleksi[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Muncul(
                                key: ValueKey(b.name),
                                index: index,
                                child: _KadSenarai(
                                  bunga: b,
                                  awalanTag: 'herb',
                                  onTap: () => bukaDetail(context, b),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ===================== SKRIN 3: BUTIRAN =====================
class BungaDetailPage extends StatelessWidget {
  final Bunga bunga;

  const BungaDetailPage({super.key, required this.bunga});

  @override
  Widget build(BuildContext context) {
    final atas = MediaQuery.paddingOf(context).top;
    final bawah = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Gambar hero
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 420,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: bunga.photo == null
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GambarPenuh(bunga: bunga),
                                  ),
                                ),
                        child: Hero(
                          tag: tagFoto(bunga),
                          child: gambarBunga(bunga),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.transparent,
                              kCanvas,
                            ],
                            stops: [0, 0.25, 0.7, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: atas + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            BulatanKaca(
                              ikon: Icons.arrow_back_ios_new,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            const Spacer(),
                            BulatanKaca(
                              ikon: Icons.share_outlined,
                              tooltip: 'Salin nama',
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: '${bunga.name} - WildBloom'));
                                mesej(context, 'Nama bunga disalin');
                              },
                            ),
                            const SizedBox(width: 8),
                            ValueListenableBuilder<Set<String>>(
                              valueListenable: kegemaran,
                              builder: (context, favs, _) {
                                final ada = favs.contains(bunga.name);
                                return BulatanKaca(
                                  ikon: ada
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  warnaIkon: ada ? kCoral : null,
                                  tooltip: ada
                                      ? 'Buang kegemaran'
                                      : 'Tambah kegemaran',
                                  onTap: () => togolKegemaran(bunga.name),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Kandungan
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kCanvas,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: EdgeInsets.fromLTRB(20, 4, 20, bawah + 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PilJenis(jenisBunga(bunga)),
                        const SizedBox(height: 10),
                        Text(bunga.name, style: gayaSerif(size: 34)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: KadMetrik(
                                index: 0,
                                ikon: Icons.park_outlined,
                                label: 'Habitat',
                                nilai: bunga.habitat,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: KadMetrik(
                                index: 1,
                                ikon: Icons.wb_sunny_outlined,
                                label: 'Musim Mekar',
                                nilai: bunga.season,
                              ),
                            ),
                          ],
                        ),
                        Seksyen(
                          index: 2,
                          tajuk: 'Penerangan',
                          child: KadTeks(
                            teks: bunga.description ?? 'Tiada maklumat',
                            besar: true,
                          ),
                        ),
                        Seksyen(
                          index: 3,
                          tajuk: 'Habitat & Taburan',
                          child: KadTeks(
                            teks: bunga.habitat ?? 'Tiada maklumat',
                          ),
                        ),
                        Seksyen(
                          index: 4,
                          tajuk: 'Musim Berbunga',
                          child: KadTeks(
                            teks: bunga.season ?? 'Tiada maklumat',
                          ),
                        ),
                        Seksyen(
                          index: 5,
                          tajuk: 'Status Pemuliharaan',
                          child: KadTeks(
                            teks: bunga.conservation ?? 'Tiada maklumat',
                            warna: kOchre.withValues(alpha: 0.14),
                            sempadan: kOchre.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Dock bawah (glass)
          Positioned(
            left: 16,
            right: 16,
            bottom: bawah + 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: kGaris),
                boxShadow: kBayang,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          mesej(context, 'Peta taburan belum tersedia'),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(
                        'Peta Taburan',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryDalam,
                        side: const BorderSide(color: kGaris),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: kegemaran,
                      builder: (context, favs, _) {
                        final ada = favs.contains(bunga.name);
                        return FilledButton.icon(
                          onPressed: () => togolKegemaran(bunga.name),
                          icon: Icon(ada ? Icons.check : Icons.add, size: 18),
                          label: Text(
                            ada ? 'Disimpan' : 'Simpan Koleksi',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimaryDalam,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KadMetrik extends StatelessWidget {
  final int index;
  final IconData ikon;
  final String label;
  final String? nilai;

  const KadMetrik({
    super.key,
    required this.index,
    required this.ikon,
    required this.label,
    this.nilai,
  });

  @override
  Widget build(BuildContext context) {
    return Muncul(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kGaris),
          boxShadow: kBayang,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ikon, color: kPrimary, size: 22),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: kTeksMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nilai ?? 'Tiada maklumat',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Seksyen extends StatelessWidget {
  final int index;
  final String tajuk;
  final Widget child;

  const Seksyen({
    super.key,
    required this.index,
    required this.tajuk,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Muncul(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(tajuk, style: gayaSerif(size: 20)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class KadTeks extends StatelessWidget {
  final String teks;
  final bool besar;
  final Color? warna;
  final Color? sempadan;

  const KadTeks({
    super.key,
    required this.teks,
    this.besar = false,
    this.warna,
    this.sempadan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: sempadan ?? kGaris),
        boxShadow: warna == null ? kBayang : null,
      ),
      child: Text(
        teks,
        style: GoogleFonts.plusJakartaSans(
          fontSize: besar ? 15 : 14,
          height: 1.6,
          color: kNeutral.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

// ===================== GAMBAR PENUH =====================
class GambarPenuh extends StatelessWidget {
  final Bunga bunga;

  const GambarPenuh({super.key, required this.bunga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(bunga.name),
      ),
      body: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: Image.asset(bunga.photo!, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
