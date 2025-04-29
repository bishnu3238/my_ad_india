-- Conversations table to track chat threads between customers and merchants
CREATE TABLE IF NOT EXISTS `conversations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `merchant_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_message` TEXT,
  `last_message_time` TIMESTAMP NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`merchant_id`) REFERENCES `merchant`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_conversation` (`customer_id`, `merchant_id`)
);

-- Messages table to store all messages
CREATE TABLE IF NOT EXISTS `messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `conversation_id` INT NOT NULL,
  `sender_type` ENUM('customer', 'merchant') NOT NULL,
  `sender_id` INT NOT NULL,
  `message` TEXT NOT NULL,
  `message_type` ENUM('text', 'image', 'file', 'location', 'inquiry') NOT NULL DEFAULT 'text',
  `file_url` VARCHAR(255) NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE CASCADE
);

-- Call logs table to track calls between users
CREATE TABLE IF NOT EXISTS `call_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `conversation_id` INT NOT NULL,
  `caller_type` ENUM('customer', 'merchant') NOT NULL,
  `caller_id` INT NOT NULL,
  `receiver_type` ENUM('customer', 'merchant') NOT NULL,
  `receiver_id` INT NOT NULL,
  `call_type` ENUM('audio', 'video') NOT NULL,
  `start_time` TIMESTAMP NULL,
  `end_time` TIMESTAMP NULL,
  `status` ENUM('missed', 'answered', 'rejected', 'ongoing') NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE CASCADE
);

-- User online status tracking
CREATE TABLE IF NOT EXISTS `user_status` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_type` ENUM('customer', 'merchant') NOT NULL,
  `user_id` INT NOT NULL,
  `is_online` BOOLEAN DEFAULT FALSE,
  `last_active` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `socket_id` VARCHAR(255) NULL,
  UNIQUE KEY `unique_user` (`user_type`, `user_id`)
);

-- Inquiries table for service inquiries
CREATE TABLE IF NOT EXISTS `inquiries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `conversation_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `merchant_id` INT NOT NULL,
  `inquiry_text` TEXT NOT NULL,
  `status` ENUM('pending', 'responded', 'closed') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`conversation_id`) REFERENCES `conversations`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`merchant_id`) REFERENCES `merchant`(`id`) ON DELETE CASCADE
);