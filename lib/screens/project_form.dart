import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir tambah proyek yang dikirim ke `POST /api/v1/projects/`.
///
/// Field mengikuti `ProjectSerializer` di Django: title, description,
/// technologies, serta project_url dan repository_url yang opsional.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _description = "";
  String _technologies = "";
  String _projectUrl = "";
  String _repositoryUrl = "";
  bool _isSubmitting = false;

  /// Field teks wajib: tolak nilai kosong atau yang hanya berisi spasi.
  static String? Function(String?) _required(String message) {
    return (String? value) =>
        value == null || value.trim().isEmpty ? message : null;
  }

  /// URL opsional, tetapi jika diisi harus berupa tautan http/https lengkap.
  static String? _validateUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWebUrl ? null : "URL harus diawali http:// atau https://";
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final auth = context.read<AuthState>();
    final newProject = Project(
      title: _title,
      description: _description,
      technologies: _technologies,
      projectUrl: _projectUrl,
      repositoryUrl: _repositoryUrl,
    );
    setState(() {
      _isSubmitting = true;
    });
    try {
      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: auth.token!,
      );
      if (!mounted) return;
      _showCreatedDialog(created);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        // Token sudah tidak berlaku: buang token lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showSnackBar("Sesi berakhir. Silakan login lagi, lalu tekan Save.");
        await ensureLoggedIn(context);
      } else if (error.statusCode == 403) {
        _showSnackBar("Hanya pemilik portofolio yang dapat menambah proyek.");
      } else {
        _showSnackBar("Gagal menyimpan proyek (status ${error.statusCode}).");
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar("Tidak dapat terhubung ke server.");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showCreatedDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: ${project.title}'),
                Text('Deskripsi: ${project.description}'),
                Text('Teknologi: ${project.technologies}'),
                Text(
                  'Project URL: ${project.projectUrl.isEmpty ? '-' : project.projectUrl}',
                ),
                Text(
                  'Repository URL: ${project.repositoryUrl.isEmpty ? '-' : project.repositoryUrl}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _field({
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint ?? label,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onChanged: (value) => setState(() => onChanged(value.trim())),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                label: "Title",
                hint: "Nama proyek",
                onChanged: (value) => _title = value,
                validator: _required("Title tidak boleh kosong!"),
              ),
              _field(
                label: "Description",
                hint: "Deskripsi proyek",
                maxLines: 5,
                onChanged: (value) => _description = value,
                validator: _required("Description tidak boleh kosong!"),
              ),
              _field(
                label: "Technologies",
                hint: "Contoh: Flutter, Django, Figma",
                onChanged: (value) => _technologies = value,
                validator: _required("Technologies tidak boleh kosong!"),
              ),
              _field(
                label: "Project URL (Optional)",
                hint: "https://contoh.com",
                keyboardType: TextInputType.url,
                onChanged: (value) => _projectUrl = value,
                validator: _validateUrl,
              ),
              _field(
                label: "Repository URL (Optional)",
                hint: "https://github.com/...",
                keyboardType: TextInputType.url,
                onChanged: (value) => _repositoryUrl = value,
                validator: _validateUrl,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
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
