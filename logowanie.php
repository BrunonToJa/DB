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
if ($stmt->num_rows === 1) 
    $stmt->bind_result($user_id, $db_password, $role);
    $stmt->fetch();

    if ($password === $db_password) {
    $success = ($password === $db_password) ? 1 : 0;

    if ($success) {
        $_SESSION['username'] = $username;
        $_SESSION['role'] = $role;
        $proc = $mysqli->prepare('CALL ZalogujUzytkownika(?, ?)');
        $proc->bind_param('ii', $user_id, $success);
        $proc->execute();
        $proc->close();;
        if ($role === 'administrator') {
            $redirect = 'admin.php';
        } else {
            $redirect = 'klient.php';
        }
    }
}

$stmt->close();

$mysqli->close();
header("Location: $redirect");
exit();
?>
?>