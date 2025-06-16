<?php
session_start();

// Sprawdzenie, czy użytkownik to administrator
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'administrator') {
    header('Location: index.php');
    exit();
}

// Połączenie z bazą danych
require_once 'db_connect.php';

// Zapytanie do bazy
$sql = "SELECT id, klient_id, kwota, typ_transakcji, data_transakcji, opis FROM transakcje";
$result = $mysqli->query($sql);
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel administratora</title>
    <link rel="stylesheet" href="style/style2.css">
    <script>
        function refreshPage() {
            location.reload();
        }
    </script>
</head>
<body>

<h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>! To jest panel administratora.</h1>

<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Klient ID</th>
            <th>Kwota</th>
            <th>Typ transakcji</th>
            <th>Data transakcji</th>
            <th>Opis</th>
        </tr>
    </thead>
    <tbody>
        <?php if ($result && $result->num_rows > 0): ?>
            <?php while ($row = $result->fetch_assoc()): ?>
                <tr>
                    <td><?php echo htmlspecialchars($row["id"]); ?></td>
                    <td><?php echo htmlspecialchars($row["klient_id"]); ?></td>
                    <td><?php echo htmlspecialchars($row["kwota"]); ?></td>
                    <td><?php echo htmlspecialchars($row["typ_transakcji"]); ?></td>
                    <td><?php echo htmlspecialchars($row["data_transakcji"]); ?></td>
                    <td><?php echo htmlspecialchars($row["opis"]); ?></td>
                </tr>
            <?php endwhile; ?>
        <?php else: ?>
            <tr><td colspan="6">Brak danych do wyświetlenia.</td></tr>
        <?php endif; ?>
    </tbody>
</table>

<form action="wylogowanie.php" method="post">
    <button type="submit">Wyloguj</button>
    <button onclick="refreshPage()">Odśwież Logi</button>
</form>



</body>
</html>
