<?php
require_once 'laczenie.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$stmt = $mysqli->prepare("SELECT id, haslo_hash, rola FROM uzytkownicy WHERE nazwa_uzytkownika = ?");
$stmt->bind_param('s', $username);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows === 1) {
    $stmt->bind_result($user_id, $db_password, $role);
    $stmt->fetch();

    if ($password === $db_password) {
        echo "Zalogowano jako {$username} ({$role})";
        $log_stmt = $mysqli->prepare("INSERT INTO logi_dostepu (uzytkownik_id, sukces) VALUES (?, 1)");
        $log_stmt->bind_param('i', $user_id);
        $log_stmt->execute();
    } else {
        echo "Nieprawidłowe hasło.";
        $log_stmt = $mysqli->prepare("INSERT INTO logi_dostepu (uzytkownik_id, sukces) VALUES (?, 0)");
        $log_stmt->bind_param('i', $user_id);
        $log_stmt->execute();
    }
} else {
    echo "Nie znaleziono użytkownika.";
}
?>