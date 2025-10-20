<!doctype html>
<html>
<head><meta charset="utf-8"><title>Modifica</title></head>
<body>
  <h1>Modifica Task</h1>
  <form method="POST" action="{{ route('tasks.update', $task) }}">
    @csrf
    @method('PUT')
    <div>
      <label>Titolo</label>
      <input name="title" value="{{ old('title', $task->title) }}" required />
    </div>
    <div>
      <label>Descrizione</label>
      <textarea name="description">{{ old('description', $task->description) }}</textarea>
    </div>
    <div>
      <label>
        <input type="checkbox" name="completed" value="1" {{ $task->completed ? 'checked' : '' }} />
        Fatto
      </label>
    </div>
    <button type="submit">Salva</button>
  </form>
  <a href="{{ route('tasks.index') }}">Torna</a>
</body>
</html>