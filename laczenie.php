<?php
$host = 'localhost';
$db   = 'db';
$user = 'root';
$pass = '';

$mysqli = new mysqli($host, $user, $pass, $db);
if ($mysqli->connect_errno) {
    die("Database connection failed: " . $mysqli->connect_error);
}
?>