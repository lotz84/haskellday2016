CREATE TABLE IF NOT EXISTS `user` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE (`username`));

INSERT INTO user VALUES (1, 'lotz',  '$2y$04$UMnRYB26AvreBv0v4efdauIIr3qTM0opEKln26tSy6XXmKV4hS56S', NULL, NULL);
INSERT INTO user VALUES (2, 'alice', '$2y$04$kRpVhhxbgerHneJJ4HqmNe8MIB7WbPJPXXI3Zy0hFhWpiaJIz6t3m', NULL, NULL);
INSERT INTO user VALUES (3, 'bob',   '$2y$04$qbhEesNseMuIpJfFzN7F7uCN6Y5CB0vmMs7eq708CAAx8wnzxvGAm', NULL, NULL);
