const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

// In-memory task storage
let tasks = [
  { id: 1, title: 'Setup EKS Cluster', completed: false },
  { id: 2, title: 'Build Docker Images', completed: false }
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    version: '1.0.0',
    color: 'blue',
    timestamp: new Date().toISOString()
  });
});

// Get all tasks
app.get('/api/tasks', (req, res) => {
  res.json({ version: '1.0.0', tasks });
});

// Create task
app.post('/api/tasks', (req, res) => {
  const task = {
    id: tasks.length + 1,
    title: req.body.title,
    completed: false
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
  console.log(`🔵 Blue version running on port ${PORT}`);
});
