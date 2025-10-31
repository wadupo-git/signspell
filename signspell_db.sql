-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 02, 2025 at 03:21 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `signspell_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `fingerspelling_letters`
--

CREATE TABLE `fingerspelling_letters` (
  `id` int(11) NOT NULL,
  `letter` char(1) NOT NULL,
  `video_url` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fingerspelling_letters`
--

INSERT INTO `fingerspelling_letters` (`id`, `letter`, `video_url`, `description`, `created_at`, `updated_at`) VALUES
(1, 'A', 'Hand_A.mp4', NULL, '2025-05-13 14:38:28', '2025-05-13 15:36:05'),
(2, 'B', 'Hand_B.mp4', NULL, '2025-05-13 14:38:28', '2025-05-13 15:36:05'),
(3, 'C', 'Hand_C.mp4', NULL, '2025-05-13 14:38:28', '2025-05-13 15:36:05'),
(4, 'D', 'Hand_D.mp4', NULL, '2025-05-13 14:38:28', '2025-05-13 15:36:05'),
(5, 'E', 'Hand_E.mp4', NULL, '2025-05-13 14:38:28', '2025-05-13 15:36:05'),
(6, 'F', 'Hand_F.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(7, 'G', 'Hand_G.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(8, 'H', 'Hand_H.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(9, 'I', 'Hand_I.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(10, 'J', 'Hand_J.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(11, 'K', 'Hand_K.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(12, 'L', 'Hand_L.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(13, 'M', 'Hand_M.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(14, 'N', 'Hand_N.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(15, 'O', 'Hand_O.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(16, 'P', 'Hand_P.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(17, 'Q', 'Hand_Q.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(18, 'R', 'Hand_R.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(19, 'S', 'Hand_S.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(20, 'T', 'Hand_T.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(21, 'U', 'Hand_U.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(22, 'V', 'Hand_V.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(23, 'W', 'Hand_W.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(24, 'X', 'Hand_X.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(25, 'Y', 'Hand_Y.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04'),
(26, 'Z', 'Hand_Z.mp4', NULL, '2025-05-31 15:22:04', '2025-05-31 15:22:04');

-- --------------------------------------------------------

--
-- Table structure for table `fingerspelling_words`
--

CREATE TABLE `fingerspelling_words` (
  `id` int(11) NOT NULL,
  `word` varchar(255) NOT NULL,
  `category` enum('greetings','family','numbers') NOT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fingerspelling_words`
--

INSERT INTO `fingerspelling_words` (`id`, `word`, `category`, `video_url`, `created_at`) VALUES
(1, 'hello', 'greetings', 'hello_sign.mp4', '2025-06-30 06:35:28'),
(2, 'thank you', 'greetings', 'thankyou_sign.mp4', '2025-06-30 06:35:28'),
(3, 'goodbye', 'greetings', 'goodbye_sign.mp4', '2025-06-30 06:35:28'),
(4, 'mother', 'family', 'mother_sign.mp4', '2025-06-30 06:35:28'),
(5, 'father', 'family', 'father_sign.mp4', '2025-06-30 06:35:28'),
(6, 'brother', 'family', 'brother_sign.mp4', '2025-06-30 06:35:28'),
(7, 'one', 'numbers', NULL, '2025-06-30 06:35:28'),
(8, 'ten', 'numbers', NULL, '2025-06-30 06:35:28'),
(9, 'hundred', 'numbers', NULL, '2025-06-30 06:35:28'),
(10, 'two', 'numbers', NULL, '2025-06-30 06:35:28'),
(11, 'twenty', 'numbers', NULL, '2025-06-30 06:35:28');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `profile_picture`, `created_at`) VALUES
(1, 'test', 'test@mail.com', '$2y$10$Y4R2L1N6hKrWNEdS5k1cDexaWuOPDPVw1Z2LT1LFkKYxFq7PJd.j.', NULL, '2025-03-02 08:03:13'),
(2, 'Ikhwan', 'test@gmail.com', '$2y$10$pN8IDBB5Z/PRkKwTkDvjIePCOuv8EpJYrotFihv2eNc5gn1IgA.zG', NULL, '2025-03-03 06:33:14'),
(4, 'admin', 'admin@mail.com', '$2y$10$xNjKifOyF.kNNd0jT3oF7u85mX4DT2Rcvhf.fZhp0QqJPXusFIu..', NULL, '2025-06-02 16:52:19'),
(5, 'Ikhwan Syafiq', 'test@email.com', '$2y$10$oATU4B6v7YATx03YkpWqHOT0XO9nP1hkDPzFezopZz5WvDNf71s2a', NULL, '2025-06-03 14:58:28');

-- --------------------------------------------------------

--
-- Table structure for table `user_spelled_words`
--

CREATE TABLE `user_spelled_words` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `word` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_spelled_words`
--

INSERT INTO `user_spelled_words` (`id`, `user_id`, `word`, `created_at`) VALUES
(1, 1, 'TEST', '2025-06-28 14:35:23'),
(2, 1, 'BOOK', '2025-06-28 14:36:39'),
(3, 1, 'SIGN', '2025-06-28 14:37:00'),
(4, 5, 'BOSS', '2025-06-28 14:37:42'),
(5, 1, 'PO', '2025-06-28 14:42:44'),
(6, 1, 'LIGHT', '2025-06-28 14:42:52'),
(7, 1, 'WADUPO', '2025-06-28 14:48:02'),
(8, 1, 'HELLO', '2025-06-28 15:24:49'),
(9, 1, 'HI', '2025-06-28 16:09:47'),
(10, 1, 'PO', '2025-06-30 06:04:11'),
(11, 1, 'HELLO', '2025-06-30 06:16:48'),
(12, 1, 'HELLO', '2025-06-30 06:22:06'),
(13, 1, 'GOODBYE', '2025-06-30 06:47:16'),
(14, 1, 'BROTHER', '2025-06-30 06:53:05'),
(15, 1, 'HUNDRED', '2025-06-30 06:53:16'),
(16, 1, 'PO', '2025-06-30 06:57:21'),
(17, 1, 'HELLO', '2025-06-30 07:08:00'),
(18, 1, 'HELLO', '2025-06-30 07:08:31'),
(19, 1, 'GOODBYE', '2025-06-30 07:10:37'),
(20, 1, 'HELLO', '2025-06-30 07:10:40'),
(21, 1, 'HELLO', '2025-06-30 07:10:48'),
(22, 1, 'HELLO', '2025-06-30 07:13:01'),
(23, 1, 'HELLO', '2025-06-30 07:15:00'),
(24, 1, 'HELLO', '2025-06-30 07:15:41'),
(25, 1, 'HELLO', '2025-06-30 07:22:10'),
(26, 1, 'HELLO', '2025-06-30 07:24:10'),
(27, 1, 'HELLO', '2025-06-30 07:24:21'),
(28, 1, 'BROTHER', '2025-06-30 07:28:33');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `fingerspelling_letters`
--
ALTER TABLE `fingerspelling_letters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `letter` (`letter`);

--
-- Indexes for table `fingerspelling_words`
--
ALTER TABLE `fingerspelling_words`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_spelled_words`
--
ALTER TABLE `user_spelled_words`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `fingerspelling_letters`
--
ALTER TABLE `fingerspelling_letters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `fingerspelling_words`
--
ALTER TABLE `fingerspelling_words`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_spelled_words`
--
ALTER TABLE `user_spelled_words`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `user_spelled_words`
--
ALTER TABLE `user_spelled_words`
  ADD CONSTRAINT `user_spelled_words_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
