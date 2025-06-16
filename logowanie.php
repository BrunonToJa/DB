<?php
session_start();
require_once 'db_connect.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$stmt = $mysqli->prepare("SELECT id, haslo_hash, rola FROM uzytkownicy WHERE nazwa_uzytkownika = ?");
$stmt->bind_param('s', $username);
$stmt->execute();
$stmt->store_result();

$redirect = 'index.php?error=1';
if ($stmt->num_rows === 1) {
    $stmt->bind_result($user_id, $db_password, $role);
    $stmt->fetch();

    if ($password === $db_password) {
        $_SESSION['username'] = $username;
        $_SESSION['role'] = $role;
        $_SESSION['user_id'] = $user_id; 

        $log_stmt = $mysqli->prepare("INSERT INTO logi_dostepu (uzytkownik_id, sukces) VALUES (?, 1)");
        $log_stmt->bind_param('i', $user_id);
        $log_stmt->execute();
        if ($role === 'administrator') {
            $redirect = 'admin.php';
        } else {
            $redirect = 'klient.php';
        }
    } else {
        $log_stmt = $mysqli->prepare("INSERT INTO logi_dostepu (uzytkownik_id, sukces) VALUES (?, 0)");
        $log_stmt->bind_param('i', $user_id);
        $log_stmt->execute();
    }
}

$mysqli->close();
header("Location: $redirect");
exit();
?>
