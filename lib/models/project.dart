import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Fields follow `ProjectSerializer` in the Django project: `technologies`
/// and `repository_url` are used instead of the tutorial's `tech_stack` and
/// `project_image_url`.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.technologies,
    this.projectUrl = '',
    this.repositoryUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID assigned by Django, so it is never sent in a POST body.
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String description;
  final String technologies;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  @JsonKey(defaultValue: '')
  final String repositoryUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
