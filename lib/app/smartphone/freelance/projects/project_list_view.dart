import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freelance_front/core/controllers/common/project_controller.dart';

class ProjectListView extends StatefulWidget {
  const ProjectListView({super.key});

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProjectController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tâches Disponibles')),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
              ? Center(child: Text(controller.errorMessage!))
              : ListView.builder(
                  itemCount: controller.projects.length,
                  itemBuilder: (context, index) {
                    final project = controller.projects[index];
                    return ListTile(
                      title: Text(project.title),
                      subtitle: Text(project.description),
                      trailing: Chip(label: Text(project.status)),
                    );
                  },
                ),
    );
  }
}
