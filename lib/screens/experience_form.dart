import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir tambah pengalaman yang mengikuti model `Experience` di Django:
/// judul, deskripsi, kategori, URL gambar opsional, serta tanggal mulai dan
/// tanggal selesai (kosong berarti pengalaman masih berlangsung).
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  /// Pasangan nilai dan label yang sama dengan `EXPERIENCE_CHOICES` di Django.
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  /// Batas panjang `title` sesuai `CharField(max_length=255)` di Django.
  static const int titleMaxLength = 255;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _title = "";
  String _description = "";
  String _category = "full-time"; // default sama dengan model Django
  String _thumbnail = "";
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// URL opsional, tetapi jika diisi harus berupa tautan http/https lengkap.
  static String? _validateThumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWebUrl ? null : "URL harus diawali http:// atau https://";
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startedAt : _endedAt) ?? _startedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endedAt = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _title = "";
      _description = "";
      _category = "full-time";
      _thumbnail = "";
      _startedAt = null;
      _endedAt = null;
      _isOngoing = false;
    });
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role/Posisi: $_title'),
                Text('Deskripsi: $_description'),
                Text('Kategori: ${ExperienceFormPage.categories[_category]}'),
                Text('URL Gambar: ${_thumbnail.isEmpty ? '-' : _thumbnail}'),
                Text('Mulai: ${_formatDate(_startedAt!)}'),
                Text(
                  'Selesai: ${_isOngoing ? 'Sedang berlangsung' : _formatDate(_endedAt!)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView menjaga semua field dan tombol Simpan tetap
        // dapat digulir pada layar sempit atau saat papan ketik tampil.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Role/Posisi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLength: ExperienceFormPage.titleMaxLength,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    "Role atau Posisi",
                    hint: "Contoh: Software Engineer Intern",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!.trim();
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Role atau posisi tidak boleh kosong!";
                    }
                    if (value.trim().length >
                        ExperienceFormPage.titleMaxLength) {
                      return "Maksimal ${ExperienceFormPage.titleMaxLength} karakter.";
                    }
                    return null;
                  },
                ),
              ),

              // === Deskripsi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration(
                    "Deskripsi",
                    hint: "Ceritakan kontribusi atau tanggung jawab",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!.trim();
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Deskripsi tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // === Kategori ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration("Kategori"),
                  initialValue: _category,
                  items: ExperienceFormPage.categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === URL Gambar (opsional) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "URL Gambar (opsional)",
                    hint: "https://contoh.com/gambar.jpg",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value!.trim();
                    });
                  },
                  validator: _validateThumbnail,
                ),
              ),

              // === Tanggal Mulai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _decoration(
                    "Tanggal Mulai",
                    hint: "Pilih tanggal",
                    suffix: const Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) => _startedAt == null
                      ? "Tanggal mulai wajib dipilih!"
                      : null,
                ),
              ),

              // === Status berlangsung ===
              SwitchListTile(
                title: const Text('Masih berlangsung'),
                value: _isOngoing,
                onChanged: (bool value) {
                  setState(() {
                    _isOngoing = value;
                    if (value) {
                      _endedAt = null;
                      _endDateController.clear();
                    }
                  });
                },
              ),

              // === Tanggal Selesai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  enabled: !_isOngoing,
                  decoration: _decoration(
                    "Tanggal Selesai",
                    hint: "Pilih tanggal",
                    suffix: const Icon(Icons.event_available),
                  ),
                  onTap: () => _pickDate(isStart: false),
                  validator: (_) {
                    if (_isOngoing) return null;
                    if (_endedAt == null) {
                      return "Pilih tanggal selesai atau aktifkan 'Masih berlangsung'.";
                    }
                    if (_startedAt != null && _endedAt!.isBefore(_startedAt!)) {
                      return "Tanggal selesai tidak boleh sebelum tanggal mulai.";
                    }
                    return null;
                  },
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSummary();
                      }
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
