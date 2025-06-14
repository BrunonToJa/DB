<?php
session_start();
if (isset($_SESSION['username'])) {
    if ($_SESSION['role'] === 'administrator') {
        header('Location: admin.php');
        exit();
    } else {
        header('Location: klient.php');
        exit();
    }
}
$error = isset($_GET['error']);
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Logowanie</title>
</head>
<body>
<h1>Logowanie do systemu</h1>
<?php if ($error): ?>
<p style="color:red;">Nieprawidłowa nazwa użytkownika lub hasło.</p>
<?php endif; ?>
<form action="logowanie.php" method="post">
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