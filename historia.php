<?php
session_start();
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'klient') {
    header('Location: index.php');
    exit();
}
require_once 'db_connect.php';

$username = $_SESSION['username'];

$stmt = $mysqli->prepare('SELECT id FROM uzytkownicy WHERE nazwa_uzytkownika = ?');
$stmt->bind_param('s', $username);
$stmt->execute();
$stmt->bind_result($user_id);
$stmt->fetch();
$stmt->close();

$stmt = $mysqli->prepare('SELECT id FROM klienci WHERE uzytkownik_id = ?');
$stmt->bind_param('i', $user_id);
$stmt->execute();
$stmt->bind_result($klient_id);
$stmt->fetch();
$stmt->close();

$stmt = $mysqli->prepare('SELECT kwota, typ_transakcji, data_transakcji, opis FROM transakcje WHERE klient_id = ? ORDER BY data_transakcji DESC');
$stmt->bind_param('i', $klient_id);
$stmt->execute();
$result = $stmt->get_result();
$transakcje = $result->fetch_all(MYSQLI_ASSOC);
$stmt->close();
$mysqli->close();
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Historia transakcji</title>
</head>
<body>
<h1>Historia transakcji</h1>
<table border="1">
    <tr>
        <th>Kwota</th>
        <th>Typ</th>
        <th>Data</th>
        <th>Opis</th>
    </tr>
    <?php foreach ($transakcje as $t): ?>
    <tr>
        <td><?php echo htmlspecialchars($t['kwota']); ?></td>
        <td><?php echo htmlspecialchars($t['typ_transakcji']); ?></td>
        <td><?php echo htmlspecialchars($t['data_transakcji']); ?></td>
        <td><?php echo htmlspecialchars($t['opis']); ?></td>
    </tr>
    <?php endforeach; ?>
</table>
<a href="klient.php">Powrót</a>
</body>
</html>