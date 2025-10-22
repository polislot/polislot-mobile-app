// parkir_final_all_pages.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

/// ---------------- Palet Warna ----------------
const Color _primaryColor = Color(0xFF1565C0); // Biru Tua
const Color _accentColor = Color(0xFF2196F3); // Biru Muda
const Color _backgroundColor = Color(0xFFFFFFFF); // Putih
const Color _lightGray = Color(0xFFE0E0E0); // Abu Muda
// ignore: unused_element
const Color _darkText = Color(0xFF212121); // Hitam Abu

void main() {
  runApp(const MaterialApp(
    home: AreaParkirScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

/// ---------------- MAIN SCREEN ----------------
class AreaParkirScreen extends StatefulWidget {
  const AreaParkirScreen({super.key});

  @override
  State<AreaParkirScreen> createState() => _AreaParkirScreenState();
}

class _AreaParkirScreenState extends State<AreaParkirScreen> {
  final ImagePicker _picker = ImagePicker();

  // contoh data area
  final List<Map<String, dynamic>> _areas = [
    {
      'id': 'A',
      'name': 'Parkir Gedung Utama',
      'services': ['Cuci Mobil', 'Tambal Ban', 'Servis'],
      'slots': [
        {'name': 'A1', 'status': 'Tersedia'},
        {'name': 'A2', 'status': 'Terisi'},
        {'name': 'A3', 'status': 'Tersedia'},
        {'name': 'A4', 'status': 'Tersedia'},
      ],
      'capacity': 100,
      'used': 15,
      'lat': -6.200000,
      'lng': 106.816666,
      'validations': <Map<String, dynamic>>[],
    },
    {
      'id': 'B',
      'name': 'Parkir Gedung Tecno',
      'services': ['Cuci Mobil', 'Servis'],
      'slots': [
        {'name': 'B1', 'status': 'Tersedia'},
        {'name': 'B2', 'status': 'Terisi'},
      ],
      'capacity': 50,
      'used': 8,
      'lat': -6.201000,
      'lng': 106.817500,
      'validations': <Map<String, dynamic>>[],
    },
  ];

  int _countAvailableSlots(List<dynamic> slots) =>
      slots.where((s) => s['status'] == 'Tersedia').length;

  int _getTotalCapacity() =>
      _areas.fold<int>(0, (sum, area) => sum + (area['capacity'] as int));

  int _getTotalAvailable() => _areas.fold<int>(
        0,
        (sum, area) => sum + _countAvailableSlots(area['slots']),
      );

  @override
  Widget build(BuildContext context) {
    final totalCapacity = _getTotalCapacity();
    final totalAvailable = _getTotalAvailable();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Parkir Kampus',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Card total kapasitas kampus
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryColor, _accentColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_parking,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalAvailable Slot Tersedia',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dari $totalCapacity kapasitas',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _areas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) {
                    final area = _areas[index];
                    return _ParkirAreaCard(
                      area: area,
                      onOpenKomunitas: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              KomunitasPage(area: area, picker: _picker),
                        ),
                      ),
                      onOpenTambah: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TambahSlotPage(
                            area: area,
                            picker: _picker,
                            onValidate: (v) =>
                                setState(() => area['validations'].add(v)),
                            onUpdate: () => setState(() {}),
                          ),
                        ),
                      ),
                      onOpenMaps: () => _openMaps(area['lat'], area['lng']),
                      onOpenDetail: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailAreaPage(
                            area: area,
                            picker: _picker,
                            onValidate: (v) =>
                                setState(() => area['validations'].add(v)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Maps')),
      );
    }
  }
}

/// ---------- Card Area Parkir ----------
class _ParkirAreaCard extends StatelessWidget {
  final Map<String, dynamic> area;
  final VoidCallback onOpenKomunitas;
  final VoidCallback onOpenTambah;
  final VoidCallback onOpenMaps;
  final VoidCallback onOpenDetail;

  const _ParkirAreaCard({
    required this.area,
    required this.onOpenKomunitas,
    required this.onOpenTambah,
    required this.onOpenMaps,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final int used = area['used'] as int;
    final int capacity = area['capacity'] as int;
    final double usedPct = capacity > 0 ? used / capacity : 0;
    final slots = area['slots'] as List;
    final availableCount =
        slots.where((s) => s['status'] == 'Tersedia').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_primaryColor, _accentColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_city, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(area['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    // usage bar (small)
                    Stack(children: [
                      Container(
                          height: 8,
                          decoration: BoxDecoration(
                              color: _lightGray,
                              borderRadius: BorderRadius.circular(6))),
                      FractionallySizedBox(
                        widthFactor: usedPct,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [_primaryColor, _accentColor]),
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text("$used dari $capacity terpakai",
                        style:
                            const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                  onPressed: onOpenMaps,
                  icon: const Icon(Icons.map_outlined, color: _accentColor)),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onOpenDetail,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primaryColor, _accentColor]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_parking, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text("$availableCount Slot Tersedia",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // layanan (ikon + label kecil)
          _LayananList(services: List<String>.from(area['services'] as List)),
          const SizedBox(height: 8),
          Row(
            children: [
              _SmallIconAction(
                  icon: Icons.forum_outlined,
                  label: 'Komunitas',
                  onTap: onOpenKomunitas),
              const SizedBox(width: 8),
              _SmallIconAction(
                  icon: Icons.add_circle_outline,
                  label: 'Tambah',
                  onTap: onOpenTambah),
              const SizedBox(width: 8),
              _SmallIconAction(icon: Icons.map, label: 'Maps', onTap: onOpenMaps),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------- Small Icon ----------
class _SmallIconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SmallIconAction(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: SizedBox(
            width: 44,
            height: 44,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: _primaryColor),
              ],
            )));
  }
}

/// ---------- Layanan List (ikon + teks kecil) ----------
class _LayananList extends StatelessWidget {
  final List<String> services;
  // ignore: use_super_parameters
  const _LayananList({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: services.map((s) {
        final icon = _serviceIcon(s);
        final color = _serviceColor(s);
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(s, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        );
      }).toList(),
    );
  }

  IconData _serviceIcon(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('cuci')) return Icons.local_laundry_service;
    if (lower.contains('tambal')) return Icons.build;
    if (lower.contains('servis')) return Icons.car_repair;
    return Icons.miscellaneous_services;
  }

  Color _serviceColor(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('cuci')) return Colors.orange;
    if (lower.contains('tambal')) return Colors.green;
    if (lower.contains('servis')) return Colors.purple;
    return _accentColor;
  }
}

/// ---------- DETAIL AREA PAGE ----------
class DetailAreaPage extends StatefulWidget {
  final Map<String, dynamic> area;
  final ImagePicker picker;
  final Function(Map<String, dynamic>) onValidate;

  const DetailAreaPage({
    super.key,
    required this.area,
    required this.picker,
    required this.onValidate,
  });

  @override
  State<DetailAreaPage> createState() => _DetailAreaPageState();
}

class _DetailAreaPageState extends State<DetailAreaPage> {
  @override
  Widget build(BuildContext context) {
    final area = widget.area;
    final int used = area['used'] as int;
    final int capacity = area['capacity'] as int;
    final slots = area['slots'] as List;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(area['name'],
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // kartu status kapasitas (judul changed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primaryColor, _accentColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status Kapasitas Area",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text("$used / $capacity terpakai",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  // UsageBarChart uses different gradient (green -> blue)
                  UsageBarChart(used: used, capacity: capacity),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("Daftar Slot",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, idx) {
                  final slot = slots[idx] as Map<String, dynamic>;
                  final isAvailable = slot['status'] == 'Tersedia';
                  final validations =
                      List<Map<String, dynamic>>.from(widget.area['validations'] as List);
                  final slotValidations = validations
                      .where((v) => v['slot'] == slot['name'])
                      .toList();

                  return Card(
                    color: isAvailable ? Colors.white : Colors.grey[100],
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: isAvailable
                                  ? _accentColor
                                  : Colors.redAccent,
                              child: Icon(
                                  isAvailable ? Icons.check : Icons.close,
                                  color: Colors.white),
                            ),
                            title: Text(slot['name']),
                            subtitle:
                                Text("Status: ${slot['status']}", style: const TextStyle(fontSize: 13)),
                            trailing: isAvailable
                                ? ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TambahSlotPage(
                                          area: widget.area,
                                          picker: widget.picker,
                                          onValidate: widget.onValidate,
                                          onUpdate: () => setState(() {}),
                                          preselectedSlot: slot['name'],
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Validasi Slot Ini'),
                                  )
                                : TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            '❌ Slot ini sedang terisi, tidak bisa divalidasi.'),
                                        backgroundColor: Colors.redAccent,
                                      ));
                                    },
                                    child: const Text('Tidak Bisa'),
                                  ),
                          ),
                          if (slotValidations.isNotEmpty) ...[
                            const Divider(),
                            const Text("📸 Validasi Terakhir:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            for (final v in slotValidations)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // safety: cek path dan file exist
                                  if (v['photoPath'] != null &&
                                      (v['photoPath'] as String).isNotEmpty &&
                                      File(v['photoPath'] as String).existsSync())
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(v['photoPath'] as String),
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  if (v['desc'] != null &&
                                      (v['desc'] as String).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '📝 ${v['desc']}',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  Text(
                                    '⏰ ${_formatTimestamp(v['timestamp'])}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Object? ts) {
    try {
      if (ts is DateTime) {
        final t = ts;
        return '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}';
      }
      return ts?.toString() ?? '';
    } catch (_) {
      return ts?.toString() ?? '';
    }
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

/// =============================
///  WIDGET: Usage Bar Chart (green -> blue so different from header)
/// =============================
class UsageBarChart extends StatelessWidget {
  final int used;
  final int capacity;

  const UsageBarChart({
    super.key,
    required this.used,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final double usagePercent =
        capacity == 0 ? 0 : (used / capacity).clamp(0.0, 1.0).toDouble();
    final fullWidth = MediaQuery.of(context).size.width - 64; // approx padding compensation

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: _lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Container(
              height: 14,
              width: fullWidth * usagePercent,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF43A047), // green
                    Color(0xFF64B5F6), // light blue
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$used / $capacity slot terpakai",
          style: const TextStyle(
              fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

/// ---------- TAMBAH SLOT PAGE ----------
class TambahSlotPage extends StatefulWidget {
  final Map<String, dynamic> area;
  final ImagePicker picker;
  final Function(Map<String, dynamic>) onValidate;
  final VoidCallback onUpdate;
  final String? preselectedSlot;

  const TambahSlotPage({
    super.key,
    required this.area,
    required this.picker,
    required this.onValidate,
    required this.onUpdate,
    this.preselectedSlot,
  });

  @override
  State<TambahSlotPage> createState() => _TambahSlotPageState();
}

class _TambahSlotPageState extends State<TambahSlotPage> {
  String? _selectedSlot;
  // ignore: unused_field, prefer_final_fields
  String _selectedStatus = 'Tersedia';
  final TextEditingController _descController = TextEditingController();
  File? _photo;

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.preselectedSlot; // auto isi jika dikirim dari detail
  }

  Future<void> _pickCamera() async {
    final XFile? photo = await widget.picker.pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (photo != null) {
      setState(() {
        _photo = File(photo.path);
      });
    }
  }

  void _onSave() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih slot terlebih dahulu!'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final slots = widget.area['slots'] as List;
    final existing = slots.where((s) => s['name'] == _selectedSlot).toList();

    if (existing.isNotEmpty &&
        existing.first['status'].toString() == 'Terisi') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('❌ Slot ini sedang terisi.'),
          backgroundColor: Colors.redAccent));
      return;
    }

    final validation = {
      'slot': _selectedSlot,
      'photoPath': _photo?.path,
      'desc': _descController.text.trim(),
      'timestamp': DateTime.now(),
    };

    widget.onValidate(validation);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Validasi parkir berhasil disimpan.'),
        backgroundColor: Colors.green));
    widget.onUpdate();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final areaName = widget.area['name'] ?? '';
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.preselectedSlot != null
              ? 'Validasi ${widget.preselectedSlot}'
              : 'Tambah/Validasi Slot - $areaName',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.preselectedSlot == null) ...[
            const Text('Pilih Slot:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSlot,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: (widget.area['slots'] as List)
                  .map((s) => DropdownMenuItem<String>(
                      value: s['name'], child: Text(s['name'])))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSlot = v),
            ),
            const SizedBox(height: 12),
          ],
          const Text('📸 Foto Validasi:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton.icon(
                onPressed: _pickCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: _primaryColor)),
            const SizedBox(width: 12),
            if (_photo != null)
              Expanded(
                child: Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_photo!,
                          height: 80, fit: BoxFit.cover, width: double.infinity)),
                  Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                          onTap: () => setState(() => _photo = null),
                          child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child:
                                  Icon(Icons.close, size: 14, color: Colors.white))))
                ]),
              ),
          ]),
          const SizedBox(height: 16),
          const Text('📝 Deskripsi Pengguna:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText: 'Tulis keterangan kondisi slot...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _onSave,
            style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Simpan Validasi'),
          ),
        ]),
      ),
    );
  }
}

/// ---------- KOMUNITAS PAGE ----------
class KomunitasPage extends StatefulWidget {
  final Map<String, dynamic> area;
  final ImagePicker picker;

  const KomunitasPage({super.key, required this.area, required this.picker});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  final TextEditingController _postController = TextEditingController();
  final List<Map<String, dynamic>> _posts = [];
  File? _pickedImage;

  void _addPost({required String text, File? image}) {
    if (text.isEmpty && image == null) return;
    setState(() {
      _posts.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'image': image,
        'likes': 0,
        'dislikes': 0,
        'replies': <Map<String, dynamic>>[],
        'timestamp': DateTime.now(),
      });
      _postController.clear();
      _pickedImage = null;
    });
  }

  Future<void> _pickCamera() async {
    final XFile? photo = await widget.picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _pickedImage = File(photo.path);
      });
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    return "${diff.inDays} hari lalu";
  }

  void _toggleLike(Map<String, dynamic> post, bool isLike) {
    setState(() {
      if (isLike) {
        post['likes'] = (post['likes'] as int) + 1;
      } else {
        post['dislikes'] = (post['dislikes'] as int) + 1;
      }
    });
  }

  void _deletePost(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Postingan'),
        content: const Text('Yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _posts.removeWhere((p) => p['id'] == id));
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> post) {
    final TextEditingController replyController = TextEditingController();
    File? replyImage;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Balas Komentar'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: replyController,
                    decoration:
                        const InputDecoration(hintText: 'Tulis balasan...'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  if (replyImage != null)
                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(replyImage!, height: 120, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => setState(() => replyImage = null),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final XFile? photo =
                          await widget.picker.pickImage(source: ImageSource.camera);
                      if (photo != null) {
                        setState(() => replyImage = File(photo.path));
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload Foto'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  if (replyController.text.isNotEmpty || replyImage != null) {
                    setState(() {
                      post['replies'].add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'text': replyController.text,
                        'image': replyImage,
                        'likes': 0,
                        'dislikes': 0,
                        'replies': [],
                        'timestamp': DateTime.now(),
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                child: const Text('Kirim'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildReplies(List replies, int depth) {
    if (replies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(left: 22.0 * depth),
      child: Column(
        children: replies
            .map<Widget>((r) => _buildPostCard(r, isReply: true, depth: depth))
            .toList(),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post,
      {bool isReply = false, int depth = 0}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(
              backgroundColor: _primaryColor,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('User ${post['id'].substring(post['id'].length - 4)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Text(_timeAgo(post['timestamp']),
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            IconButton(
              onPressed: () => _deletePost(post['id']),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ]),
          const SizedBox(height: 8),
          if (post['text'] != null && post['text'] != "")
            Text(post['text'], style: const TextStyle(fontSize: 14)),
          if (post['image'] != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                post['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(children: [
            IconButton(
                onPressed: () => _toggleLike(post, true),
                icon: const Icon(Icons.thumb_up_alt_outlined),
                color: _accentColor),
            Text("${post['likes']}"),
            const SizedBox(width: 16),
            IconButton(
                onPressed: () => _toggleLike(post, false),
                icon: const Icon(Icons.thumb_down_alt_outlined),
                color: Colors.redAccent),
            Text("${post['dislikes']}"),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showReplyDialog(post),
              icon: const Icon(Icons.reply, size: 18),
              label: const Text('Balas'),
            ),
          ]),
          if (post['replies'] != null && post['replies'].isNotEmpty)
            _buildReplies(post['replies'], depth + 1),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Komunitas - ${widget.area['name']}',
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: _posts.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada postingan.\nTulis sesuatu untuk memulai!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _buildPostCard(post);
                  },
                ),
        ),
        const Divider(height: 0),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            IconButton(
              onPressed: _pickCamera,
              icon: const Icon(Icons.camera_alt),
              color: _primaryColor,
            ),
            Expanded(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: _postController,
                  decoration: const InputDecoration(
                      hintText: 'Tulis sesuatu...', border: InputBorder.none),
                ),
                if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _pickedImage!,
                          height: 100,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: InkWell(
                          onTap: () => setState(() => _pickedImage = null),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ]),
                  ),
              ]),
            ),
            IconButton(
              onPressed: () {
                if (_postController.text.isNotEmpty || _pickedImage != null) {
                  _addPost(text: _postController.text, image: _pickedImage);
                }
              },
              icon: const Icon(Icons.send),
              color: _primaryColor,
            ),
          ]),
        ),
      ]),
    );
  }
}