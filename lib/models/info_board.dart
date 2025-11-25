// models/info_board.dart
class InfoBoard {
  final String judul;
  final String isi;
  final String tanggal;

  InfoBoard({
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  factory InfoBoard.fromJson(Map<String, dynamic> json) {
    return InfoBoard(
      judul: json['judul']?.toString() ?? 'Pengumuman',
      isi: json['isi']?.toString() ?? 'Tidak ada detail',
      tanggal: json['tanggal']?.toString() ?? '',
    );
  }
}