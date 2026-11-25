import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Shows every attribute of a single [Project].
///
/// The Django `Project` model has no image field, so the project and
/// repository links are shown instead, and only when they are not empty.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Chip(label: Text(project.technologies)),
            const SizedBox(height: 16),
            Text(project.description),
            if (project.projectUrl.isNotEmpty)
              _LinkRow(
                icon: Icons.public,
                label: 'Project URL',
                url: project.projectUrl,
              ),
            if (project.repositoryUrl.isNotEmpty)
              _LinkRow(
                icon: Icons.code,
                label: 'Repository URL',
                url: project.repositoryUrl,
              ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.url});

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(url),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
