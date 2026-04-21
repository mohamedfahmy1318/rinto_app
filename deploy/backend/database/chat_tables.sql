-- Chat System Tables for RentoGo
-- Run this SQL to add chat functionality

-- Conversations table (chat threads)
CREATE TABLE IF NOT EXISTS conversations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    listing_type ENUM('property', 'car') NOT NULL,
    listing_id INT NOT NULL,
    user1_id INT NOT NULL COMMENT 'The user who initiated the chat (interested party)',
    user2_id INT NOT NULL COMMENT 'The listing owner',
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user1_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (user2_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Ensure unique conversation per listing per user pair
    UNIQUE KEY unique_conversation (listing_type, listing_id, user1_id, user2_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    
    INDEX idx_conversation (conversation_id),
    INDEX idx_sender (sender_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add indexes for better performance
CREATE INDEX idx_conv_user1 ON conversations(user1_id);
CREATE INDEX idx_conv_user2 ON conversations(user2_id);
CREATE INDEX idx_conv_listing ON conversations(listing_type, listing_id);
CREATE INDEX idx_conv_last_message ON conversations(last_message_at DESC);
