const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

// In-memory task storage with priority feature (NEW!)
let tasks = [
  { id: 1, title: 'Setup EKS Cluster', completed: false, priority: 'high' },
  { id: 2, title: 'Build Docker Images', completed: false, priority: 'medium' }
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    version: '2.0.0',
    color: 'green',
    timestamp: new Date().toISOString(),
    features: ['priority-support', 'enhanced-ui']
  });
});

// Get all tasks
app.get('/api/tasks', (req, res) => {
  res.json({ version: '2.0.0', tasks });
});

// Create task with priority (NEW FEATURE)
app.post('/api/tasks', (req, res) => {
  const task = {
    id: tasks.length + 1,
    title: req.body.title,
    completed: false,
    priority: req.body.priority || 'low'
  };
  tasks.push(task);
  res.status(201).json(task);
});

// Toggle task completion
app.patch('/api/tasks/:id', (req, res) => {
  const task = tasks.find(t => t.id === parseInt(req.params.id));
  if (task) {
    task.completed = !task.completed;
    res.json(task);
  } else {
    res.status(404).json({ error: 'Task not found' });
  }
});

// Update task priority (NEW FEATURE)
app.put('/api/tasks/:id/priority', (req, res) => {
  const task = tasks.find(t => t.id === parseInt(req.params.id));
  if (task) {
    task.priority = req.body.priority;
    res.json(task);
  } else {
    res.status(404).json({ error: 'Task not found' });
  }
});

// Delete task
app.delete('/api/tasks/:id', (req, res) => {
  const index = tasks.findIndex(t => t.id === parseInt(req.params.id));
  if (index !== -1) {
    tasks.splice(index, 1);
    res.status(204).send();
  } else {
    res.status(404).json({ error: 'Task not found' });
  }
});

app.listen(PORT, () => {
  console.log(`🟢 Green version running on port ${PORT}`);
});
