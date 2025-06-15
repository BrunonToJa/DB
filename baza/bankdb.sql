-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Cze 14, 2025 at 01:07 PM
-- Wersja serwera: 10.4.32-MariaDB
-- Wersja PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bankdb`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `karty`
--

CREATE TABLE `karty` (
  `id` int(11) NOT NULL,
  `klient_id` int(11) NOT NULL,
  `numer_karty` varchar(16) NOT NULL,
  `data_waznosci` date NOT NULL,
  `cvv` varchar(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `karty`
--

INSERT INTO `karty` (`id`, `klient_id`, `numer_karty`, `data_waznosci`, `cvv`) VALUES
(9, 3, '1234567812345678', '2028-12-31', '123');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `klienci`
--

CREATE TABLE `klienci` (
  `id` int(11) NOT NULL,
  `uzytkownik_id` int(11) NOT NULL,
  `imie` varchar(50) NOT NULL,
  `nazwisko` varchar(50) NOT NULL,
  `numer_konta` varchar(30) NOT NULL,
  `saldo` decimal(15,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`id`, `uzytkownik_id`, `imie`, `nazwisko`, `numer_konta`, `saldo`) VALUES
(3, 5, 'Karol', 'Grajek', '51162946997417335010881787', 316008.00),
(5, 7, 'Anita', 'Anita', '10950320095511098488059314', 99992.00);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `kredyty`
--

CREATE TABLE `kredyty` (
  `id` int(11) NOT NULL,
  `klient_id` int(11) NOT NULL,
  `kwota_kredytu` decimal(15,2) NOT NULL,
  `liczba_rat` int(11) NOT NULL,
  `pozostale_raty` int(11) NOT NULL,
  `pozostala_kwota` decimal(15,2) NOT NULL,
  `data_udzielenia` date DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `logi_dostepu`
--

CREATE TABLE `logi_dostepu` (
  `id` int(11) NOT NULL,
  `uzytkownik_id` int(11) NOT NULL,
  `data_logowania` timestamp NOT NULL DEFAULT current_timestamp(),
  `sukces` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `transakcje`
--

CREATE TABLE `transakcje` (
  `id` int(11) NOT NULL,
  `klient_id` int(11) NOT NULL,
  `kwota` decimal(15,2) NOT NULL,
  `typ_transakcji` enum('wplata','wyplata','przelew') NOT NULL,
  `data_transakcji` timestamp NOT NULL DEFAULT current_timestamp(),
  `opis` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transakcje`
--

INSERT INTO `transakcje` (`id`, `klient_id`, `kwota`, `typ_transakcji`, `data_transakcji`, `opis`) VALUES
(12, 5, 1.00, 'przelew', '2025-05-07 14:43:34', 'Przelew na konto nr 51162946997417335010881787'),
(13, 5, 1.00, 'przelew', '2025-05-07 14:43:43', 'Przelew na konto nr 51162946997417335010881787'),
(14, 5, 1.00, 'przelew', '2025-05-07 14:44:39', 'Przelew na konto nr 51162946997417335010881787'),
(15, 5, 1.00, 'przelew', '2025-05-07 14:44:51', 'Przelew na konto nr 51162946997417335010881787'),
(16, 3, 4.00, 'przelew', '2025-05-07 14:45:57', 'Przelew na konto nr 51162946997417335010881787'),
(17, 3, 4.00, 'przelew', '2025-05-07 14:46:08', 'Przelew na konto nr 51162946997417335010881787'),
(18, 5, 4.00, 'przelew', '2025-05-07 14:46:24', 'Przelew na konto nr 51162946997417335010881787');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `uzytkownicy`
--

CREATE TABLE `uzytkownicy` (
  `id` int(11) NOT NULL,
  `nazwa_uzytkownika` varchar(50) NOT NULL,
  `haslo_hash` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `rola` enum('administrator','klient') NOT NULL,
  `data_utworzenia` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `uzytkownicy`
--

INSERT INTO `uzytkownicy` (`id`, `nazwa_uzytkownika`, `haslo_hash`, `email`, `rola`, `data_utworzenia`) VALUES
(2, 'admin1', 'admin123', 'admin@bank.com', 'administrator', '2025-03-06 15:38:30'),
(5, 'Karol', '123', 'karolcostam@wp.pl', 'klient', '2025-03-06 18:48:33'),
(7, 'Anita', '123', 'anita@anita.anita', 'klient', '2025-05-07 14:37:29');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `karty`
--
ALTER TABLE `karty`
  ADD PRIMARY KEY (`id`),
  ADD KEY `klient_id` (`klient_id`);

--
-- Indeksy dla tabeli `klienci`
--
ALTER TABLE `klienci`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uzytkownik_id` (`uzytkownik_id`),
  ADD UNIQUE KEY `numer_konta` (`numer_konta`);

--
-- Indeksy dla tabeli `kredyty`
--
ALTER TABLE `kredyty`
  ADD PRIMARY KEY (`id`),
  ADD KEY `klient_id` (`klient_id`);

--
-- Indeksy dla tabeli `logi_dostepu`
--
ALTER TABLE `logi_dostepu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uzytkownik_id` (`uzytkownik_id`);

--
-- Indeksy dla tabeli `transakcje`
--
ALTER TABLE `transakcje`
  ADD PRIMARY KEY (`id`),
  ADD KEY `klient_id` (`klient_id`);

--
-- Indeksy dla tabeli `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nazwa_uzytkownika` (`nazwa_uzytkownika`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `karty`
--
ALTER TABLE `karty`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `klienci`
--
ALTER TABLE `klienci`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `kredyty`
--
ALTER TABLE `kredyty`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logi_dostepu`
--
ALTER TABLE `logi_dostepu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transakcje`
--
ALTER TABLE `transakcje`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `uzytkownicy`
--
ALTER TABLE `uzytkownicy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `karty`
--
ALTER TABLE `karty`
  ADD CONSTRAINT `karty_ibfk_1` FOREIGN KEY (`klient_id`) REFERENCES `klienci` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `klienci`
--
ALTER TABLE `klienci`
  ADD CONSTRAINT `klienci_ibfk_1` FOREIGN KEY (`uzytkownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kredyty`
--
ALTER TABLE `kredyty`
  ADD CONSTRAINT `kredyty_ibfk_1` FOREIGN KEY (`klient_id`) REFERENCES `klienci` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `logi_dostepu`
--
ALTER TABLE `logi_dostepu`
  ADD CONSTRAINT `logi_dostepu_ibfk_1` FOREIGN KEY (`uzytkownik_id`) REFERENCES `uzytkownicy` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transakcje`
--
ALTER TABLE `transakcje`
  ADD CONSTRAINT `transakcje_ibfk_1` FOREIGN KEY (`klient_id`) REFERENCES `klienci` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
