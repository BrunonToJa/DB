<?php
session_start();
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'klient') {
    header('Location: index.php');
    exit();
}
require_once 'db_connect.php';

$username = $_SESSION['username'];

// Pobierz identyfikator uzytkownika
$stmt = $mysqli->prepare('SELECT id FROM uzytkownicy WHERE nazwa_uzytkownika = ?');
$stmt->bind_param('s', $username);
$stmt->execute();
$stmt->bind_result($user_id);
$stmt->fetch();
$stmt->close();

// Pobierz numer konta nadawcy
$stmt = $mysqli->prepare('SELECT numer_konta FROM klienci WHERE uzytkownik_id = ?');
$stmt->bind_param('i', $user_id);
$stmt->execute();
$stmt->bind_result($konto_nadawcy);
$stmt->fetch();
$stmt->close();

$success = false;
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $konto_odbiorcy = $_POST['konto_odbiorcy'] ?? '';
    $kwota = floatval($_POST['kwota'] ?? 0);
    $opis = $_POST['opis'] ?? '';

    if ($kwota <= 0) {
        $error = 'Kwota musi by\u0107 dodatnia.';
    } else {
        $proc = $mysqli->prepare('CALL PrzelewNaNumerKonta(?, ?, ?, ?)');
        $proc->bind_param('ssds', $konto_nadawcy, $konto_odbiorcy, $kwota, $opis);
        if ($proc->execute()) {
            $success = true;
        } else {
            $error = 'Nie uda\u0142o si\u0119 wykonac przelewu.';
        }
        $proc->close();
    }
}
$mysqli->close();
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <link rel="stylesheet" href="style/style.css">
    <meta charset="UTF-8">
    <title>Przelew</title>
</head>
<body>
<h1>Nowy przelew</h1>
<?php if ($success): ?>
<p style="color: green;">Przelew wykonany prawidłowo.</p>
<?php elseif ($error): ?>
<p style="color: red;"><?php echo $error; ?></p>
<?php endif; ?>
<form method="post" action="przelew.php">
    <label>Numer konta odbiorcy: <input type="text" name="konto_odbiorcy" required></label><br>
    <label>Kwota: <input type="number" step="0.01" min="0.01" name="kwota" required></label><br>
    <label>Tytuł/Opis: <input type="text" name="opis"></label><br>
    <input type="submit" value="Wyślij">
</form>
<a href="klient.php">Powrót</a>
</body>
</html>