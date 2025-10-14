// lib/parkir_full_final.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1976D2),
      ),
      home: const ParkirFullScreen(),
    ),
  );
}

class ParkirFullScreen extends StatefulWidget {
  const ParkirFullScreen({super.key});

  @override
  State<ParkirFullScreen> createState() => _ParkirFullScreenState();
}

class _ParkirFullScreenState extends State<ParkirFullScreen> {
  final ImagePicker _picker = ImagePicker();

  static const LatLng _polibatamLatLng = LatLng(1.1464, 104.0077);

  final List<Map<String, dynamic>> _areas = [
    {
      'id': 'A',
      'name': 'Parkiran Gedung Utama',
      'services': ['Cuci Mobil', 'Tambal Ban', 'Servis'],
      'slots': [
        {'name': 'A1', 'status': 'Tersedia'},
        {'name': 'A2', 'status': 'Terisi'},
      ],
      'posts': <Map<String, dynamic>>[],
    },
    {
      'id': 'B',
      'name': 'Parkiran Gedung Tecno',
      'services': ['Cuci Mobil', 'Servis'],
      'slots': [
        {'name': 'B1', 'status': 'Tersedia'},
        {'name': 'B2', 'status': 'Terisi'},
      ],
      'posts': <Map<String, dynamic>>[],
    },
    {
      'id': 'C',
      'name': 'Parkiran Gedung RTF',
      'services': ['Tambal Ban'],
      'slots': [
        {'name': 'C1', 'status': 'Tersedia'},
      ],
      'posts': <Map<String, dynamic>>[],
    },
  ];

  // --- FUNGSI ANIMASI TRANSISI FADE ---
  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  // --- MAP MODAL ---
  void _openMapModal(String areaName) {
    Navigator.of(context).push(_fadeRoute(
      Scaffold(
        appBar: AppBar(
          title: Text('Lokasi - $areaName'),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: const CameraPosition(
            target: _polibatamLatLng,
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('polibatam'),
              position: _polibatamLatLng,
              infoWindow: const InfoWindow(title: 'Politeknik Negeri Batam'),
            ),
          },
        ),
      ),
    ));
  }

  // --- LAYANAN MODAL ---
  void _showServicesModal(String areaName, List<String> services) {
    Navigator.of(context).push(_fadeRoute(
      Scaffold(
        appBar: AppBar(
          title: Text('Layanan - $areaName'),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: services.isEmpty
                  ? [const Text('Tidak ada layanan tersedia')]
                  : services.map((s) {
                      IconData ic = Icons.miscellaneous_services;
                      Color c = Colors.blue;
                      if (s.contains('Cuci')) {
                        ic = Icons.local_car_wash;
                        c = Colors.lightBlue;
                      } else if (s.contains('Tambal')) {
                        ic = Icons.build;
                        c = Colors.orange;
                      } else if (s.contains('Servis')) {
                        ic = Icons.settings;
                        c = Colors.green;
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                              radius: 30,
                              backgroundColor: c.withOpacity(0.12),
                              child: Icon(ic, color: c, size: 26)),
                          const SizedBox(height: 8),
                          Text(s, textAlign: TextAlign.center),
                        ],
                      );
                    }).toList(),
            ),
          ),
        ),
      ),
    ));
  }

  // --- TAMBAH SLOT ---
  void _openAddSlotModal(int areaIndex) {
    String? selectedSlot;
    String status = 'Tersedia';
    File? selectedImage;
    final TextEditingController descCtrl = TextEditingController();
    final String areaId = _areas[areaIndex]['id'] as String;
    final List<String> generatedSlots =
        List.generate(6, (i) => '$areaId${i + 1}');

    showDialog(
      context: context,
      builder: (ctx) => FadeTransition(
        opacity: CurvedAnimation(
          parent: ModalRoute.of(ctx)!.animation!,
          curve: Curves.easeInOut,
        ),
        child: AlertDialog(
          title: const Text('Tambah Slot Parkir'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedSlot,
                  hint: const Text('Pilih Slot (mis: A3)'),
                  onChanged: (v) => selectedSlot = v,
                  items: generatedSlots
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(
                        value: 'Tersedia', child: Text('Tersedia')),
                    DropdownMenuItem(value: 'Terisi', child: Text('Terisi')),
                  ],
                  onChanged: (v) => status = v!,
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Deskripsi (opsional)')),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final x = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (x != null) {
                      selectedImage = File(x.path);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Ambil Foto'),
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
                if (selectedSlot != null) {
                  setState(() {
                    _areas[areaIndex]['slots'].add({
                      'name': selectedSlot,
                      'status': status,
                      'photo': selectedImage,
                      'desc': descCtrl.text,
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  // --- SLOT GRID ---
  Widget _buildSlotGrid(Map<String, dynamic> area) {
    final slots = area['slots'] as List<dynamic>;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: screenWidth < 350 ? 1.1 : 1.5,
      ),
      itemBuilder: (ctx, i) {
        final slot = slots[i] as Map<String, dynamic>;
        final bool isAvailable = (slot['status'] as String?) == 'Tersedia';
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (i * 50)),
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: GestureDetector(
            onTap: () => _showSlotInfo(slot),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.local_parking
                          : Icons.car_repair,
                      color: isAvailable ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(height: 6),
                    Text(slot['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(slot['status'] ?? '',
                        style: TextStyle(
                            color: isAvailable
                                ? Colors.green
                                : Colors.red)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- INFO SLOT ---
  void _showSlotInfo(Map<String, dynamic> slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: 1,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Slot ${slot['name']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (slot['photo'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(slot['photo'] as File,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 8),
                  Text('Status: ${slot['status'] ?? '-'}'),
                  const SizedBox(height: 6),
                  Text('Deskripsi: ${slot['desc'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Tutup'))),
                ]),
          ),
        ),
      ),
    );
  }

  // --- AREA CARD ---
  Widget _buildAreaCard(int index) {
    final area = _areas[index];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 120)),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2),
                  child: Text(area['id'],
                      style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(area['name'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(
                  onPressed: () => _openMapModal(area['name']),
                  icon: const Icon(Icons.map_outlined,
                      color: Color(0xFF1976D2))),
              IconButton(
                  onPressed: () => _showServicesModal(
                      area['name'], List<String>.from(area['services'])),
                  icon: const Icon(Icons.room_service,
                      color: Colors.deepPurple)),
              IconButton(
                  onPressed: () => _openCommunityScreen(index),
                  icon: const Icon(Icons.people, color: Color(0xFF1976D2))),
            ]),
            const SizedBox(height: 10),
            _buildSlotGrid(area),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white),
                onPressed: () => _openAddSlotModal(index),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Slot Parkir'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Area Parkir Kampus',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _areas.length,
        itemBuilder: (ctx, i) => _buildAreaCard(i),
      ),
    );
  }

  // --- KOMUNITAS ---
  void _openCommunityScreen(int index) {
    Navigator.push(
      context,
      _fadeRoute(CommunityScreen(
        areaName: _areas[index]['name'],
        posts: _areas[index]['posts'],
      )),
    ).then((posts) {
      if (posts != null) {
        setState(() => _areas[index]['posts'] = posts);
      }
    });
  }
}

// --- KOMUNITAS SCREEN ---
class CommunityScreen extends StatefulWidget {
  final String areaName;
  final List<Map<String, dynamic>> posts;
  const CommunityScreen({super.key, required this.areaName, required this.posts});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ImagePicker _picker = ImagePicker();
  late List<Map<String, dynamic>> posts;

  @override
  void initState() {
    super.initState();
    posts = List<Map<String, dynamic>>.from(widget.posts);
  }

  Future<void> _createPostWithCamera() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo == null) return;
    final caption = TextEditingController();

    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Buat Postingan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(photo.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover)),
                const SizedBox(height: 12),
                TextField(
                    controller: caption,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Keterangan (opsional)')),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Posting',
                              style: TextStyle(color: Colors.white)))),
                  const SizedBox(width: 12),
                  OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal')),
                ])
              ]),
            ),
          ),
        );
      },
    );

    if (posted != true) return;

    setState(() {
      posts.insert(0, {
        'user': 'Saya',
        'text': caption.text.trim(),
        'photo': File(photo.path),
        'likes': 0,
        'dislikes': 0,
        'createdAt': DateTime.now(),
      });
    });
  }

  String _friendlyTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komunitas - ${widget.areaName}'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: posts.isEmpty
          ? Center(
              child: Text('Belum ada postingan',
                  style: TextStyle(color: Colors.grey.shade600)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (ctx, i) {
                final post = posts[i];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + (i * 80)),
                  builder: (_, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)), child: child),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF1976D2),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(post['user'] ?? 'Anonim',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(_friendlyTime(
                                        post['createdAt'] ?? DateTime.now()),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                  ])),
                            ]),
                            const SizedBox(height: 10),
                            if (post['photo'] != null)
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(post['photo'] as File,
                                      width: double.infinity,
                                      fit: BoxFit.cover)),
                            if ((post['text'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(post['text']),
                            ],
                            const SizedBox(height: 8),
                            Row(children: [
                              IconButton(
                                  onPressed: () => setState(
                                      () => post['likes'] = post['likes'] + 1),
                                  icon: const Icon(Icons.thumb_up_alt_outlined,
                                      size: 20, color: Colors.green)),
                              Text('${post['likes']}'),
                              const SizedBox(width: 16),
                              IconButton(
                                  onPressed: () => setState(() =>
                                      post['dislikes'] =
                                          post['dislikes'] + 1),
                                  icon: const Icon(Icons.thumb_down_alt_outlined,
                                      size: 20, color: Colors.red)),
                              Text('${post['dislikes']}'),
                            ]),
                          ]),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPostWithCamera,
        label: const Text('Posting'),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    Navigator.pop(context, posts);
    super.dispose();
  }
}
