<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Logowanie</title>
</head>
<body>
<h1>Logowanie do systemu</h1>
<form action="login.php" method="post">
    <label for="username">Nazwa użytkownika:</label>
    <input type="text" id="username" name="username" required>
    <br>
    <label for="password">Hasło:</label>
    <input type="password" id="password" name="password" required>
    <br>
    <input type="submit" value="Zaloguj">
</form>
</body>
</html>