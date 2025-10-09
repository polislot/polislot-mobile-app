import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkirScreen extends StatefulWidget {
  const ParkirScreen({super.key});

  @override
  State<ParkirScreen> createState() => _ParkirScreenState();
}

class _ParkirScreenState extends State<ParkirScreen> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullImageScreen(imagePath: pickedFile.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text('Parkiran Kampus', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Layanan Parkir',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D91)),
            ),
            const SizedBox(height: 10),
            _buildMapCard(context),
            const SizedBox(height: 16),
            _buildUploadCard(context),
            const SizedBox(height: 16),
            _buildDetailCard(context),
            const SizedBox(height: 16),
            _buildSlotCard(context), // 🔥 Tambahan baru
            const SizedBox(height: 16),
            _buildKomentarCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParkingMapScreen()),
        ),
        child: _menuCard(
          icon: Icons.map,
          title: 'Peta Parkiran Kampus',
          color: const Color(0xFF0A3D91),
        ),
      );

  Widget _buildUploadCard(BuildContext context) => GestureDetector(
        onTap: _pickImage,
        child: _menuCard(
          icon: Icons.upload_file,
          title: 'Upload Bukti Slot Parkir',
          color: Colors.green,
        ),
      );

  Widget _buildDetailCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParkingDetailScreen()),
        ),
        child: _menuCard(
          icon: Icons.info_outline,
          title: 'Detail Parkiran',
          color: Colors.orange,
        ),
      );

  Widget _buildSlotCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ParkingSlotDetailScreen()),
        ),
        child: _menuCard(
          icon: Icons.directions_car,
          title: 'Slot Parkir (A1 - A30)',
          color: Colors.blue,
        ),
      );

  Widget _buildKomentarCard(BuildContext context) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KomentarCommunityScreen()),
        ),
        child: _menuCard(
          icon: Icons.comment,
          title: 'Komentar & Komunitas',
          color: Colors.purple,
        ),
      );

  Widget _menuCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ✅ Halaman Detail Umum
class ParkingDetailScreen extends StatelessWidget {
  const ParkingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FA),
      appBar: AppBar(
        title: const Text('Detail Parkiran',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDetailItem(Icons.local_parking, 'Slot Tersedia', '35 dari 50'),
          _buildDetailItem(Icons.location_on, 'Lokasi', 'Gedung A, B, dan C'),
          _buildDetailItem(Icons.access_time, 'Jam Operasional', '06.00 - 22.00 WIB'),
          _buildDetailItem(Icons.payment, 'Tarif', 'Rp 2.000 / jam'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0A3D91)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// ✅ Halaman Detail Slot Parkir
class ParkingSlotDetailScreen extends StatefulWidget {
  const ParkingSlotDetailScreen({super.key});

  @override
  State<ParkingSlotDetailScreen> createState() => _ParkingSlotDetailScreenState();
}

class _ParkingSlotDetailScreenState extends State<ParkingSlotDetailScreen> {
  final List<Map<String, dynamic>> slots = List.generate(
    30,
    (i) => {
      "slot": "A${i + 1}",
      "available": i % 4 != 0, // tiap 4 slot, 1 penuh
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Slot Parkir A1 - A30", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFF2F4FA),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(slot["available"]
                    ? "Slot ${slot["slot"]} masih kosong ✅"
                    : "Slot ${slot["slot"]} sedang terisi ❌"),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                color: slot["available"] ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: slot["available"] ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Center(
                child: Text(
                  slot["slot"],
                  style: TextStyle(
                    color: slot["available"] ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ✅ Komentar Komunitas
class KomentarCommunityScreen extends StatefulWidget {
  const KomentarCommunityScreen({super.key});

  @override
  State<KomentarCommunityScreen> createState() =>
      _KomentarCommunityScreenState();
}

class _KomentarCommunityScreenState extends State<KomentarCommunityScreen> {
  final List<String> _komentarList = [];
  final TextEditingController _controller = TextEditingController();

  void _tambahKomentar() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _komentarList.insert(0, _controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FA),
      appBar: AppBar(
        title: const Text('Komentar & Komunitas',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: _komentarList.isEmpty
                ? const Center(child: Text('Belum ada komentar.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _komentarList.length,
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(_komentarList[i]),
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _tambahKomentar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D91),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Full Image View
class FullImageScreen extends StatelessWidget {
  final String imagePath;
  const FullImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black87)),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

// ✅ Halaman Peta Google Maps
class ParkingMapScreen extends StatefulWidget {
  const ParkingMapScreen({super.key});

  @override
  State<ParkingMapScreen> createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  late GoogleMapController mapController;
  final LatLng _kampusCenter = const LatLng(-6.9825, 110.4091);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Parkiran Kampus',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition:
            CameraPosition(target: _kampusCenter, zoom: 17),
        markers: {
          const Marker(
            markerId: MarkerId('kampus_parkir'),
            position: LatLng(-6.9825, 110.4091),
            infoWindow: InfoWindow(title: 'Parkiran Kampus Utama'),
          ),
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
