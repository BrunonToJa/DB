<?php
session_start();

// Sprawdzenie, czy użytkownik to administrator
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'administrator') {
    header('Location: index.php');
    exit();
}

// Połączenie z bazą danych
require_once 'db_connect.php';

// Ustawienie aktywnej tabeli
$aktywnyWidok = $_GET['tabela'] ?? 'transakcje';

?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel administratora</title>
    <link rel="stylesheet" href="klient_style.css">
    <script>
        function refreshPage() {
            location.reload();
        }
    </script>
</head>
<body>

<h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>! To jest panel administratora.</h1>

<!-- Przełączniki widoku -->
<div style="margin-bottom: 20px;">
    <a href="admin.php?tabela=transakcje"><button>Transakcje</button></a>
    <a href="admin.php?tabela=logi"><button>Logi Dostępu</button></a>
    <button onclick="refreshPage()">Odśwież</button>
</div>

<?php if ($aktywnyWidok === 'transakcje'): ?>

    <?php
    $sql = "SELECT id, klient_id, kwota, typ_transakcji, data_transakcji, opis FROM transakcje";
    $result = $mysqli->query($sql);
    ?>

    <h2>Transakcje</h2>
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

<?php elseif ($aktywnyWidok === 'logi'): ?>

    <?php
    $sql_logs = "SELECT id, uzytkownik_id, data_logowania, sukces FROM logi_dostepu";
    $result_logs = $mysqli->query($sql_logs);
    ?>

    <h2>Logi dostępu</h2>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Użytkownik ID</th>
                <th>Data logowania</th>
                <th>Sukces</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($result_logs && $result_logs->num_rows > 0): ?>
                <?php while ($log = $result_logs->fetch_assoc()): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($log["id"]); ?></td>
                        <td><?php echo htmlspecialchars($log["uzytkownik_id"]); ?></td>
                        <td><?php echo htmlspecialchars($log["data_logowania"]); ?></td>
                        <td><?php echo $log["sukces"] ? 'Tak' : 'Nie'; ?></td>
                    </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr><td colspan="4">Brak logów dostępu do wyświetlenia.</td></tr>
            <?php endif; ?>
        </tbody>
    </table>

<?php else: ?>

    <p>Nieznany widok.</p>

<?php endif; ?>

<form action="wylogowanie.php" method="post" style="margin-top: 20px;">
    <button type="submit">Wyloguj</button>
</form>

</body>
</html>
