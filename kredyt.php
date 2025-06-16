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

// Pobierz identyfikator klienta
$stmt = $mysqli->prepare('SELECT id FROM klienci WHERE uzytkownik_id = ?');
$stmt->bind_param('i', $user_id);
$stmt->execute();
$stmt->bind_result($klient_id);
$stmt->fetch();
$stmt->close();

$success = false;
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $kwota = floatval($_POST['kwota'] ?? 0);
    $liczba_rat = intval($_POST['liczba_rat'] ?? 0);

    if ($kwota <= 0 || $liczba_rat <= 0) {
        $error = 'Kwota i liczba rat musz\u0105 by\u0107 dodatnie.';
    } else {
        $proc = $mysqli->prepare('CALL DodajKredyt(?, ?, ?)');
        $proc->bind_param('idi', $klient_id, $kwota, $liczba_rat);
        if ($proc->execute()) {
            $success = true;
        } else {
            $error = 'Nie uda\u0142o si\u0119 doda\u0107 kredytu.';
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
    <title>Kredyt</title>
</head>
<body>
<h1>Złóż wniosek o kredyt</h1>
<?php if ($success): ?>
<p style="color: green;">Kredyt został dodany.</p>
<?php elseif ($error): ?>
<p style="color: red;"><?php echo $error; ?></p>
<?php endif; ?>
<form method="post" action="kredyt.php">
    <label>Kwota kredytu: <input type="number" step="0.01" min="0.01" name="kwota" required></label><br>
    <label>Liczba rat: <input type="number" min="1" name="liczba_rat" required></label><br>
    <input type="submit" value="Wyślij">
</form>
<a href="klient.php">Powrót</a>
</body>
</html>