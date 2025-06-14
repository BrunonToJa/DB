<?php
session_start();
if (!isset($_SESSION['username']) || $_SESSION['role'] !== 'administrator') {
    header('Location: index.php');
    exit();
}
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Panel administratora</title>
</head>
<body>
<h1>Witaj, <?php echo htmlspecialchars($_SESSION['username']); ?>! To jest panel administratora.</h1>
<a href="wylogowanie.php">Wyloguj</a>
</body>
</html>