import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  List<Map<String, String>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadCounter();
    _loadTasks();
  }

  // Load counter
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('counter') ?? 0;
    });
  }

  // Save counter
  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _counter);
  }

  // Increment
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _saveCounter();
  }

  // Decrement
  void _decrementCounter() {
    setState(() {
      _counter--;
    });
    _saveCounter();
  }

  // Load tasks
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('tasks') ?? [];

    setState(() {
      _tasks = savedList.map((item) {
        final parts = item.split('|');
        return {
          'title': parts[0],
          'time': parts.length > 1 ? parts[1] : 'No time',
        };
      }).toList();
    });
  }

  // Save tasks
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = _tasks.map((task) => '${task['title']}|${task['time']}').toList();
    await prefs.setStringList('tasks', stringList);
  }

  // Add task
  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty || _selectedTime == null) return;

    setState(() {
      _tasks.add({
        'title': title,
        'time': _selectedTime!.format(context),
      });
      _taskController.clear();
      _selectedTime = null;
    });

    _saveTasks();
  }

  // Pick time
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Delete task
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 89, 28, 100),
        title: const Text('Counter & To-Do App',style:TextStyle(color:Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Counter section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const Text('Counter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('$_counter', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _decrementCounter,
                          icon: const Icon(Icons.remove_circle, color: Colors.red, size: 32),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: _incrementCounter,
                          icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // To-Do input section
            const Text('Add Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.task),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _pickTime,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null ? 'No time selected' : 'Time: ${_selectedTime!.format(context)}'),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Task list
            const Text('Your Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('No tasks yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          child: ListTile(
                            title: Text(task['title'] ?? ''),
                            subtitle: Text('Time: ${task['time'] ?? ''}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
