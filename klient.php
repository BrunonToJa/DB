<?php
session_start();
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'klient') {
    header('Location: index.php');
    exit();
}
require_once 'db_connect.php';

$username = $_SESSION['username'];
$stmt = $mysqli->prepare('SELECT k.saldo FROM klienci k JOIN uzytkownicy u ON k.uzytkownik_id = u.id WHERE u.nazwa_uzytkownika = ?');
$stmt->bind_param('s', $username);
$stmt->execute();
$stmt->bind_result($saldo);
$stmt->fetch();
$stmt->close();
$mysqli->close();
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel klienta</title>
<link rel="stylesheet" href="style/style.css">
</head>
<body>
<h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>! To jest panel klienta.</h1>
<p>Aktualny stan konta: <?php echo htmlspecialchars($saldo); ?> PLN</p>
    <a href="karty.php">Przeglądaj karty</a><br>
    <a href="kredyty.php">Kredyt</a><br>
    <a href="przelew.php">Przelew</a><br>
    <a href="historia.php">Historia transakcji</a><br>
    <a href="wylogowanie.php">Wyloguj</a>
</body>
</html>