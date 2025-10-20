<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Login</title>
</head>
<body>
  <h1>Login</h1>

  @if($errors->any())
    <div style="color:red">{{ $errors->first() }}</div>
  @endif

  <form method="POST" action="{{ route('login.post') }}">
    @csrf
    <div>
      <label>Email</label>
      <input name="email" value="{{ old('email','admin@example.com') }}" required />
    </div>
    <div>
      <label>Password</label>
      <input name="password" type="password" value="" required />
    </div>
    <button type="submit">Login</button>
  </form>
</body>
</html>