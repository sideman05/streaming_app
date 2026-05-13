CREATE DATABASE IF NOT EXISTS iptv_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE iptv_app;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','admin') NOT NULL DEFAULT 'user',
  subscription_status ENUM('free','premium') NOT NULL DEFAULT 'free',
  plan_id INT UNSIGNED NULL,
  status TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_email (email),
  INDEX idx_users_plan (plan_id)
) ENGINE=InnoDB;

CREATE TABLE plans (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  duration_days INT UNSIGNED NOT NULL,
  status TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE subscriptions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  plan_id INT UNSIGNED NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  status ENUM('active','expired','cancelled') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_sub_user (user_id),
  INDEX idx_sub_plan (plan_id),
  INDEX idx_sub_status (status),
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  status TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE channels (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id INT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  logo_url VARCHAR(255) NOT NULL,
  stream_url VARCHAR(500) NOT NULL,
  description TEXT NULL,
  is_premium TINYINT(1) NOT NULL DEFAULT 0,
  status TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_channels_category (category_id),
  INDEX idx_channels_name (name),
  INDEX idx_channels_premium (is_premium),
  CONSTRAINT fk_channels_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE favorites (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  channel_id INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_channel (user_id, channel_id),
  INDEX idx_fav_user (user_id),
  INDEX idx_fav_channel (channel_id),
  CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_favorites_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE epg_programs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  channel_id INT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_epg_channel_time (channel_id, start_time, end_time),
  CONSTRAINT fk_epg_channel FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE auth_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  revoked TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_token_user (user_id),
  INDEX idx_token_exp (expires_at),
  CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

ALTER TABLE users
  ADD CONSTRAINT fk_users_plan FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE SET NULL;

INSERT INTO plans (name, description, price, duration_days) VALUES
('Free', 'Access to selected free channels', 0.00, 3650),
('Premium Monthly', 'All channels + premium sports and movies', 7.99, 30),
('Premium Quarterly', 'All channels + premium content for 90 days', 19.99, 90);

INSERT INTO categories (name) VALUES
('Sports'),
('News'),
('Movies'),
('Entertainment'),
('Kids'),
('Music');

INSERT INTO channels (category_id, name, logo_url, stream_url, description, is_premium) VALUES
(1, 'Sports Live 1', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Live sports highlights and commentary.', 0),
(2, 'Global News 24', 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Breaking world news, politics, and reports.', 0),
(3, 'Cinema Premium', 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Blockbuster movies and premieres.', 1),
(4, 'Family Entertainment', 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Shows and entertainment for all ages.', 0),
(5, 'Kids Planet', 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Animated kids and educational programs.', 0),
(6, 'Music Hits', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', 'Top charts and live music sessions.', 1);

-- EPG sample around current date/time.
INSERT INTO epg_programs (channel_id, title, description, start_time, end_time) VALUES
(1, 'Morning Sports Desk', 'Daily sports recap.', NOW() - INTERVAL 30 MINUTE, NOW() + INTERVAL 30 MINUTE),
(1, 'Top 10 Goals', 'Best football goals of the week.', NOW() + INTERVAL 30 MINUTE, NOW() + INTERVAL 90 MINUTE),
(2, 'Headlines Now', 'Current top stories.', NOW() - INTERVAL 20 MINUTE, NOW() + INTERVAL 40 MINUTE),
(2, 'Business Report', 'Market and economy updates.', NOW() + INTERVAL 40 MINUTE, NOW() + INTERVAL 100 MINUTE),
(3, 'Movie: Open Sky', 'Featured premium movie.', NOW() - INTERVAL 10 MINUTE, NOW() + INTERVAL 110 MINUTE),
(3, 'Behind The Scenes', 'Cast interviews.', NOW() + INTERVAL 110 MINUTE, NOW() + INTERVAL 170 MINUTE);

-- Optional admin bootstrap user (password: admin123)
INSERT INTO users (name, email, password_hash, role, subscription_status, plan_id)
VALUES ('Admin', 'admin@streamhub.local', '$2y$10$9QjQ8G8lqD0EJ4ThY4AF8e6weM7kDihf6X3hY6zH8McaYjkQx5qce', 'admin', 'premium', 2);
