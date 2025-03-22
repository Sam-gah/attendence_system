import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/employee.dart';
import 'project_board_view.dart';
// import 'project_list_view.dart';
import 'project_timeline_view.dart';
import 'project_calendar_view.dart';

enum ProjectView { list, board, timeline, calendar }

class ProjectDashboard extends StatefulWidget {
  final List<Project> projects;
  final List<Employee> employees;

  const ProjectDashboard({
    super.key,
    required this.projects,
    required this.employees,
  });

  @override
  State<ProjectDashboard> createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  ProjectView _currentView = ProjectView.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildViewToggle(),
                _buildFilterBar(),
                Expanded(child: _buildCurrentView()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Projects'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: () => _showAnalytics(),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return NavigationRail(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Handle navigation
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.work),
          label: Text('Projects'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Teams'),
        ),
        NavigationRailDestination(icon: Icon(Icons.task), label: Text('Tasks')),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today),
          label: Text('Calendar'),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return SegmentedButton<ProjectView>(
      selected: {_currentView},
      onSelectionChanged: (Set<ProjectView> selection) {
        setState(() => _currentView = selection.first);
      },
      segments: const [
        ButtonSegment(
          value: ProjectView.list,
          icon: Icon(Icons.list),
          label: Text('List'),
        ),
        ButtonSegment(
          value: ProjectView.board,
          icon: Icon(Icons.dashboard),
          label: Text('Board'),
        ),
        ButtonSegment(
          value: ProjectView.timeline,
          icon: Icon(Icons.timeline),
          label: Text('Timeline'),
        ),
        ButtonSegment(
          value: ProjectView.calendar,
          icon: Icon(Icons.calendar_month),
          label: Text('Calendar'),
        ),
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
        // case ProjectView.list:
        //   return ProjectListView(projects: widget.projects);
      case ProjectView.board:
        return ProjectBoardView(projects: widget.projects);
      case ProjectView.timeline:
        return ProjectTimelineView(projects: widget.projects);
      case ProjectView.calendar:
        return ProjectCalendarView(projects: widget.projects);
      default:
        return const Center(child: Text('Unknown view'));
    }
  }

  void _showCreateMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('New Project'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateProjectDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.task),
                title: const Text('New Task'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateTaskDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('New Milestone'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateMilestoneDialog();
                },
              ),
            ],
          ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Implement search
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<ProjectStatus>(
            hint: const Text('Status'),
            onChanged: (value) {
              // Implement filter
            },
            items:
                ProjectStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Advanced Search'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Team Member'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement search
                  Navigator.pop(context);
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }

  void _showFilterDialog() {
    // Implement filter dialog
  }

  void _showAnalytics() {
    // Implement analytics view
  }

  void _showCreateProjectDialog() {
    // Implement project creation
  }

  void _showCreateTaskDialog() {
    // Implement task creation
  }

  void _showCreateMilestoneDialog() {
    // Implement milestone creation
  }
}
