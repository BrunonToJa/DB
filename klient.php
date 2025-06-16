<?php
session_start();


require_once 'db_connect.php';

// Pobieranie ID użytkownika z sesji
$user_id = $_SESSION['user_id'];

// Pobranie danych klienta
$klient_stmt = $mysqli->prepare("SELECT id, imie, nazwisko, numer_konta, saldo FROM klienci WHERE uzytkownik_id = ?");
$klient_stmt->bind_param('i', $user_id);
$klient_stmt->execute();
$klient_result = $klient_stmt->get_result();

if ($klient_result->num_rows !== 1) {
    echo "Nie znaleziono danych klienta.";
    exit();
}

$klient = $klient_result->fetch_assoc();
$klient_id = $klient['id'];

// Pobranie kart klienta
$karty_stmt = $mysqli->prepare("SELECT numer_karty, data_waznosci, cvv FROM karty WHERE klient_id = ?");
$karty_stmt->bind_param('i', $klient_id);
$karty_stmt->execute();
$karty_result = $karty_stmt->get_result();

?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel klienta</title>
    <link rel="stylesheet" href="style/style2.css">
</head>
<body>
<div class="container">
    <h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>!</h1>

            <a href="historia.php">Historia</a>
                <a href="przelew.php">Przelew</a>
                    <a href="kredyt.php">Kredyt</a>
    <h2>Dane konta:</h2>
    <table class="dane-tabela">
        <tr>
            <th>Imię</th>
            <th>Nazwisko</th>
            <th>Numer konta</th>
            <th>Saldo</th>
        </tr>
        <tr>
            <td><?php echo htmlspecialchars($klient['imie']); ?></td>
            <td><?php echo htmlspecialchars($klient['nazwisko']); ?></td>
            <td><?php echo htmlspecialchars($klient['numer_konta']); ?></td>
            <td><?php echo htmlspecialchars($klient['saldo']); ?> PLN</td>
        </tr>
    </table>

    <h2>Twoje karty:</h2>
    <?php if ($karty_result->num_rows > 0): ?>
        <table class="dane-tabela">
            <tr>
                <th>Numer karty</th>
                <th>Data ważności</th>
                <th>CVV</th>
            </tr>
            <?php while ($karta = $karty_result->fetch_assoc()): ?>
                <tr>
                    <td><?php echo htmlspecialchars($karta['numer_karty']); ?></td>
                    <td><?php echo htmlspecialchars($karta['data_waznosci']); ?></td>
                    <td><?php echo htmlspecialchars($karta['cvv']); ?></td>
                </tr>
            <?php endwhile; ?>
        </table>
    <?php else: ?>
        <p class="no-data">Nie znaleziono żadnych kart.</p>
    <?php endif; ?>

    <a href="wylogowanie.php">Wyloguj</a>
</div>
</body>
</html>
