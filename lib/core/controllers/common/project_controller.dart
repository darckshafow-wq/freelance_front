import 'package:flutter/material.dart';

import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> projects = [];
  List<ProjectModel> clientProjects = [];
  List<ProjectModel> publicProjects = [];
  List<ProposalModel> currentProjectProposals = [];
  
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchProjects() async {
    _setLoading(true);
    try {
      projects = await _projectService.getProjects();
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des tâches.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchClientProjects({String? status}) async {
    _setLoading(true);
    try {
      clientProjects = await _projectService.getClientProjects(status: status);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement de vos projets.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPublicProjects() async {
    _setLoading(true);
    try {
      publicProjects = await _projectService.getPublicProjects();
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des missions publiques.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchProposals(int projectId) async {
    _setLoading(true);
    try {
      currentProjectProposals = await _projectService.getProjectProposals(projectId);
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des propositions.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createProject(ProjectModel project) async {
    _setLoading(true);
    try {
      await _projectService.createProject(project);
      await fetchClientProjects();
      return true;
    } catch (e) {
      errorMessage = 'Erreur lors de la création du projet.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (value) errorMessage = null;
    notifyListeners();
  }
}
