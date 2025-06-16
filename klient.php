<?php
session_start();
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'klient') {
    header('Location: index.php');
    exit();
}
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel klienta</title>
</head>
<body>
<h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>! To jest panel klienta.</h1>
    <a href="karty.php">Przeglądaj karty</a><br>
    <a href="kredyt.php">Kredyt</a><br>
    <a href="przelew.php">Przelew</a><br>
    <a href="wylogowanie.php">Wyloguj</a>
</body>
</html>