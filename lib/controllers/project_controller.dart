import 'package:get/get.dart';
import '../services/project_service.dart'; // Use ProjectService instead
import '../models/project.dart';

class ProjectController extends GetxController {
  final ProjectService _projectService = Get.find<ProjectService>(); // Use ProjectService
  
  final RxList<Project> projects = <Project>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      isLoading.value = true;
      error.value = '';
      final allProjects = await _projectService.getProjects(); // Use ProjectService
      projects.assignAll(allProjects);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProject(Project project) async {
    try {
      await _projectService.addProject(project); // Use ProjectService
      await loadProjects();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _projectService.updateProject(project); // Use ProjectService
      await loadProjects();
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId); // Use ProjectService
      await loadProjects();
    } catch (e) {
      error.value = e.toString();
    }
  }
}