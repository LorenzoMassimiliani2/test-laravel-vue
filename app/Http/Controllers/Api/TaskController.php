<?php

namespace App\Http\Controllers\Api;

use App\Models\Task;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class TaskController extends Controller
{
    public function index()
    {
        $tasks = auth()->user()->tasks()->orderBy('created_at','desc')->get();
        return view('tasks.index', compact('tasks'));
    }

    public function create()
    {
        return view('tasks.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);
        $data['user_id'] = auth()->id();
        Task::create($data);
        return redirect()->route('tasks.index');
    }

    public function edit(Task $task)
    {
        $this->authorizeOwnership($task);
        return view('tasks.edit', compact('task'));
    }

    public function update(Request $request, Task $task)
    {
        $this->authorizeOwnership($task);
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'completed' => 'sometimes|boolean',
        ]);
        $task->update($data);
        return redirect()->route('tasks.index');
    }

    public function destroy(Task $task)
    {
        $this->authorizeOwnership($task);
        $task->delete();
        return redirect()->route('tasks.index');
    }

    protected function authorizeOwnership(Task $task)
    {
        if ($task->user_id !== auth()->id()) {
            abort(403);
        }
    }
}