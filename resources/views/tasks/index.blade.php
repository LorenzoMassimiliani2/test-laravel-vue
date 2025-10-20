<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Tasks</title>
</head>
<body>
  <h1>Tasks</h1>
  <form method="POST" action="{{ route('logout') }}" style="float:right">
    @csrf
    <button type="submit">Logout</button>
  </form>

  <h2>Nuovo task</h2>
  <form method="POST" action="{{ route('tasks.store') }}">
    @csrf
    <input name="title" placeholder="Titolo" required />
    <input name="description" placeholder="Descrizione" />
    <button type="submit">Aggiungi</button>
  </form>

  <h2>Elenco</h2>
  <ul>
    @foreach($tasks as $t)
      <li>
        <form method="POST" action="{{ route('tasks.update', $t) }}" style="display:inline">
          @csrf
          @method('PUT')
          <input name="title" value="{{ $t->title }}" />
          <label>
            <input type="checkbox" name="completed" value="1" {{ $t->completed ? 'checked' : '' }} onchange="this.form.submit()">
            Fatto
          </label>
        </form>

        <a href="{{ route('tasks.edit', $t) }}">Modifica</a>

        <form method="POST" action="{{ route('tasks.destroy', $t) }}" style="display:inline">
          @csrf
          @method('DELETE')
          <button type="submit">Elimina</button>
        </form>
      </li>
    @endforeach
  </ul>
</body>
</html>