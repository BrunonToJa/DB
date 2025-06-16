-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Cze 16, 2025 at 09:41 PM
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

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `aktualizuj_ilosc_kart` ()   BEGIN
    UPDATE klienci k
    SET k.ilosc_kart = (
        SELECT COUNT(*) 
        FROM karty c 
        WHERE c.klient_id = k.id
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DodajKredyt` (IN `in_klient_id` INT, IN `in_kwota_kredytu` DECIMAL(15,2), IN `in_liczba_rat` INT)   BEGIN
    DECLARE in_pozostale_raty INT DEFAULT in_liczba_rat;
    DECLARE in_pozostala_kwota DECIMAL(15,2) DEFAULT in_kwota_kredytu;

    INSERT INTO kredyty (
        klient_id, kwota_kredytu, liczba_rat, pozostale_raty, pozostala_kwota
    )
    VALUES (
        in_klient_id, in_kwota_kredytu, in_liczba_rat, in_pozostale_raty, in_pozostala_kwota
    );

    UPDATE klienci
    SET saldo = saldo + in_kwota_kredytu
    WHERE id = in_klient_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PrzelewNaNumerKonta` (IN `in_nadawca_konto` VARCHAR(30), IN `in_odbiorca_konto` VARCHAR(30), IN `in_kwota` DECIMAL(15,2), IN `in_opis` VARCHAR(255))   BEGIN
    DECLARE nadawca_id INT;
    DECLARE odbiorca_id INT;
    DECLARE saldo_nadawcy DECIMAL(15,2);

    -- Pobierz ID klientów
    SELECT id, saldo INTO nadawca_id, saldo_nadawcy
    FROM klienci
    WHERE numer_konta = in_nadawca_konto;

    SELECT id INTO odbiorca_id
    FROM klienci
    WHERE numer_konta = in_odbiorca_konto;

    -- Sprawdź, czy nadawca ma wystarczające środki
    IF saldo_nadawcy >= in_kwota THEN
        -- Odejmij środki nadawcy
        UPDATE klienci
        SET saldo = saldo - in_kwota
        WHERE id = nadawca_id;

        -- Dodaj środki odbiorcy
        UPDATE klienci
        SET saldo = saldo + in_kwota
        WHERE id = odbiorca_id;

        -- Zapisz transakcję u nadawcy
        INSERT INTO transakcje (klient_id, kwota, typ_transakcji, opis)
        VALUES (nadawca_id, in_kwota, 'przelew', CONCAT('Przelew do ', in_odbiorca_konto, ' TYTUŁ: ', in_opis));

        -- Zapisz transakcję u odbiorcy
        INSERT INTO transakcje (klient_id, kwota, typ_transakcji, opis)
        VALUES (odbiorca_id, in_kwota, 'wplata', CONCAT('Otrzymano przelew od ', in_nadawca_konto, ' TYTUŁ: ', in_opis));
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ZalogujUzytkownika` (IN `in_uzytkownik_id` INT, IN `in_sukces` TINYINT(1))   BEGIN
    INSERT INTO logi_dostepu (uzytkownik_id, sukces)
    VALUES (in_uzytkownik_id, in_sukces);
END$$

DELIMITER ;

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

--
-- Wyzwalacze `karty`
--
DELIMITER $$
CREATE TRIGGER `karta_po_dodaniu` AFTER INSERT ON `karty` FOR EACH ROW BEGIN
    UPDATE klienci
    SET ilosc_kart = ilosc_kart + 1
    WHERE id = NEW.klient_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `karty_po_usunieciu` AFTER DELETE ON `karty` FOR EACH ROW BEGIN
    UPDATE klienci
    SET ilosc_kart = GREATEST(ilosc_kart - 1, 0)
    WHERE id = OLD.klient_id;
END
$$
DELIMITER ;

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
  `saldo` decimal(15,2) DEFAULT 0.00,
  `ilosc_kart` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `klienci`
--

INSERT INTO `klienci` (`id`, `uzytkownik_id`, `imie`, `nazwisko`, `numer_konta`, `saldo`, `ilosc_kart`) VALUES
(3, 5, 'Karol', 'Grajek', '51162946997417335010881787', 40227.65, 1),
(5, 7, 'Anita', 'Anita', '10950320095511098488059314', 7956676.00, 0);

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

--
-- Dumping data for table `kredyty`
--

INSERT INTO `kredyty` (`id`, `klient_id`, `kwota_kredytu`, `liczba_rat`, `pozostale_raty`, `pozostala_kwota`, `data_udzielenia`) VALUES
(1, 3, 23.00, 2, 2, 23.00, '2025-06-15'),
(2, 5, 7856675.00, 2147483647, 2147483647, 7856675.00, '2025-06-16');

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

--
-- Dumping data for table `logi_dostepu`
--

INSERT INTO `logi_dostepu` (`id`, `uzytkownik_id`, `data_logowania`, `sukces`) VALUES
(3, 5, '2025-06-15 18:00:02', 1),
(4, 5, '2025-06-15 18:08:00', 1),
(5, 2, '2025-06-15 18:16:28', 1),
(6, 2, '2025-06-16 11:49:56', 1),
(7, 5, '2025-06-16 16:49:52', 1),
(8, 2, '2025-06-16 17:48:24', 1),
(9, 5, '2025-06-16 17:59:07', 1),
(10, 5, '2025-06-16 18:25:00', 0),
(11, 5, '2025-06-16 18:25:12', 0),
(12, 2, '2025-06-16 18:25:41', 0),
(13, 2, '2025-06-16 18:26:43', 1),
(14, 5, '2025-06-16 18:26:54', 1),
(15, 5, '2025-06-16 18:34:45', 1),
(16, 2, '2025-06-16 19:03:04', 1),
(17, 5, '2025-06-16 19:03:32', 1),
(18, 2, '2025-06-16 19:04:34', 1),
(19, 5, '2025-06-16 19:05:27', 1),
(20, 5, '2025-06-16 19:08:43', 1),
(21, 7, '2025-06-16 19:12:11', 1),
(22, 2, '2025-06-16 19:12:45', 1),
(23, 7, '2025-06-16 19:14:15', 1),
(24, 7, '2025-06-16 19:15:30', 1),
(25, 7, '2025-06-16 19:15:41', 1),
(26, 7, '2025-06-16 19:16:46', 0),
(27, 7, '2025-06-16 19:16:50', 0),
(28, 5, '2025-06-16 19:16:55', 0),
(29, 2, '2025-06-16 19:17:34', 0),
(30, 5, '2025-06-16 19:25:23', 1),
(31, 2, '2025-06-16 19:36:43', 1);

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
(18, 5, 4.00, 'przelew', '2025-05-07 14:46:24', 'Przelew na konto nr 51162946997417335010881787'),
(21, 3, 23.00, 'wplata', '2025-06-15 17:50:27', '213123'),
(22, 3, 23.00, 'wplata', '2025-06-15 17:52:29', '213123'),
(23, 3, 23.00, 'wplata', '2025-06-15 17:52:34', '3'),
(24, 3, 1.00, 'wplata', '2025-06-15 17:52:46', '23'),
(25, 5, 4.00, 'przelew', '2025-06-15 18:10:23', 'Przelew do 51162946997417335010881787: 213123'),
(26, 3, 4.00, 'wplata', '2025-06-15 18:10:23', 'Otrzymano przelew od 10950320095511098488059314: 213123'),
(27, 3, 2.00, 'przelew', '2025-06-15 18:11:15', 'Przelew do 10950320095511098488059314: 213123'),
(28, 5, 2.00, 'wplata', '2025-06-15 18:11:15', 'Otrzymano przelew od 51162946997417335010881787: 213123'),
(29, 3, -9.00, 'przelew', '2025-06-15 18:12:54', 'Przelew do 10950320095511098488059314: -2'),
(30, 5, -9.00, 'wplata', '2025-06-15 18:12:54', 'Otrzymano przelew od 51162946997417335010881787: -2'),
(31, 3, 23.00, 'przelew', '2025-06-15 18:15:18', 'Przelew do 10950320095511098488059314TYTUŁ: 4'),
(32, 5, 23.00, 'wplata', '2025-06-15 18:15:18', 'Otrzymano przelew od 51162946997417335010881787TYTUŁ: 4'),
(33, 5, 3.00, 'przelew', '2025-06-16 19:12:23', 'Przelew do 51162946997417335010881787 TYTUŁ: 21312312312'),
(34, 3, 3.00, 'wplata', '2025-06-16 19:12:23', 'Otrzymano przelew od 10950320095511098488059314 TYTUŁ: 21312312312'),
(35, 3, 123.00, 'przelew', '2025-06-16 19:32:05', 'Przelew do 51162946997417335010881787 TYTUŁ: 321'),
(36, 3, 123.00, 'wplata', '2025-06-16 19:32:05', 'Otrzymano przelew od 51162946997417335010881787 TYTUŁ: 321');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `logi_dostepu`
--
ALTER TABLE `logi_dostepu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `transakcje`
--
ALTER TABLE `transakcje`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

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
