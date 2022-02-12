-- player
CREATE TABLE `Player` (
  `id` int(11),
  `name` varchar(30),
  `src` varchar(300),
  `age` int(2),
  `battingstyle` varchar(50),
  `bowlingstyle` varchar(50),
  `playingrole` varchar(30),
  `teams` varchar(100),
   PRIMARY KEY (`id`)
);
INSERT INTO `Player` (`id`, `name`, `src`, `age`, `battingstyle`, `bowlingstyle`, `playingrole`, `teams`) VALUES
(1, 'Sandip lamichhane', 'sandip.png', 21, 'Right Handed Bat', 'Right-arm legbreak', 'Bowler', 'Nepal U19, Nepal, Kowloon Cantons, Delhi Capitals, World XI, Montreal Tigers,'),
(2, 'Paras khadka', 'paras.png', 34, 'Right Handed Bat', 'Right-arm fast-medium', 'Batting Allrounder', 'Nepal, Team Abu Dhabi'),
(3, 'Sompal kami', 'sompal.png', 25, 'Right hand bat', 'Right arm fast medium', 'Bowling allrounder', 'Nepal,WinnipegHawks,SaracensSports Club'),
(4, 'Gyanendra Malla', 'GyanendraMalla.png', 31, 'Right hand bat', '', 'Batsman', 'Nepal');

-- shot_profile 

CREATE TABLE `shotprofile` (
  `id` int(11),
  `shot_name` varchar(30),
   PRIMARY KEY (`id`)
);
INSERT INTO `shotprofile` (`id`, `shot_name`) VALUES
(1, 'CutShot'),
(2, 'CoverDrive'),
(3, 'StraightDrive'),
(4, 'PullShot'),
(5, 'LegGlance'),
(6, 'Scoop');

-- shot
CREATE TABLE `shot` (
  `id` int(11),
  `player_id` int(11),
  `shot_id` int(11),
  `shot_frequency` int(11),
  `efficency` double,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`player_id`) REFERENCES `Player` (`id`),
  FOREIGN KEY (`shot_id`) REFERENCES `shotprofile` (`id`)
);
INSERT INTO `shot` (`id`, `player_id`, `shot_id`, `shot_frequency`, `efficency`) VALUES
(1, 2, 1, 30, 90.5),
(2, 2, 2, 20, 88.2),
(3, 2, 5, 15, 92.2),
(4, 2, 4, 10, 90.3),
(5, 2, 6, 3, 89.6),
(6, 2, 3, 5, 88.9);

