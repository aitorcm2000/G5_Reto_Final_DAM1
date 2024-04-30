-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         5.1.72-community - MySQL Community Server (GPL)
-- SO del servidor:              Win32
-- HeidiSQL Versión:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Volcando estructura de base de datos para reto
CREATE DATABASE IF NOT EXISTS `reto` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `reto`;

-- Volcando estructura para tabla reto.aulas
CREATE TABLE IF NOT EXISTS `aulas` (
  `ID_Aula` int(11) NOT NULL,
  `Nombre_Aula` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`ID_Aula`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para función reto.CuentaGente
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `CuentaGente`() RETURNS int(11)
BEGIN
    DECLARE numUsuarios INT;
    SELECT COUNT(*) INTO numUsuarios FROM usuarios;
    RETURN numUsuarios;
END//
DELIMITER ;

-- Volcando estructura para tabla reto.cursos
CREATE TABLE IF NOT EXISTS `cursos` (
  `ID_Curso` int(11) NOT NULL,
  `Curso_nombre` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID_Curso`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para procedimiento reto.Gran_Jugador
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `Gran_Jugador`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE dni_usuario VARCHAR(9);
    DECLARE totalPuntos INT;

    DECLARE cur CURSOR FOR
        SELECT DNI_usuario, SUM(Puntos) AS TotalPuntos
        FROM scores
        GROUP BY DNI_usuario;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO dni_usuario, totalPuntos;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF totalPuntos > 100 THEN
            UPDATE usuarios SET gran_jugador = TRUE WHERE DNI_usuario = dni_usuario;
        END IF;
    END LOOP;

    CLOSE cur;
END//
DELIMITER ;

-- Volcando estructura para vista reto.partidas_jugadas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `partidas_jugadas` (
	`Alias_jugador` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Partidas_jugadas` BIGINT(21) NOT NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista reto.puntuaciones_cursos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `puntuaciones_cursos` (
	`ID_Reto` INT(11) NULL,
	`Reto_Nombre` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Puntuacion_Maxima` INT(11) NULL,
	`Alias` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Curso_nombre` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista reto.puntuaciones_minimas
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `puntuaciones_minimas` (
	`ID_Reto` INT(11) NULL,
	`Reto_Nombre` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Puntuacion_minima` INT(11) NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista reto.puntuacion_max
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `puntuacion_max` (
	`ID_Reto` INT(11) NULL,
	`Reto_Nombre` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Usuario_con_mejor_puntuacion` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Puntuacion_Maxima` INT(11) NULL
) ENGINE=MyISAM;

-- Volcando estructura para tabla reto.retos
CREATE TABLE IF NOT EXISTS `retos` (
  `ID_Reto` int(11) NOT NULL,
  `Reto_Nombre` varchar(20) DEFAULT NULL,
  `Nivel` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID_Reto`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista reto.retos_mas_jugados
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `retos_mas_jugados` (
	`ID_Reto` INT(11) NOT NULL,
	`Reto_Nombre` VARCHAR(20) NULL COLLATE 'latin1_swedish_ci',
	`Numero_Jugado` BIGINT(21) NOT NULL
) ENGINE=MyISAM;

-- Volcando estructura para tabla reto.scores
CREATE TABLE IF NOT EXISTS `scores` (
  `ID_Score` int(11) NOT NULL,
  `DNI_usuario` varchar(9) DEFAULT NULL,
  `ID_Reto` int(11) DEFAULT NULL,
  `Puntos` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID_Score`),
  KEY `DNI_usuario` (`DNI_usuario`),
  KEY `ID_Reto` (`ID_Reto`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla reto.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `DNI_usuario` varchar(9) NOT NULL,
  `ID_Aula` int(11) DEFAULT NULL,
  `ID_Curso` int(11) DEFAULT NULL,
  `Alias` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`DNI_usuario`),
  KEY `ID_Aula` (`ID_Aula`),
  KEY `ID_Curso` (`ID_Curso`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista reto.partidas_jugadas
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `partidas_jugadas`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `partidas_jugadas` AS SELECT u.Alias AS Alias_jugador, COUNT(s.ID_Score) AS Partidas_jugadas
FROM usuarios u
LEFT JOIN scores s ON u.DNI_usuario = s.DNI_usuario
GROUP BY u.Alias ;

-- Volcando estructura para vista reto.puntuaciones_cursos
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `puntuaciones_cursos`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `puntuaciones_cursos` AS select s.ID_Reto, r.Reto_Nombre, MAX(s.Puntos) as Puntuacion_Maxima, u.Alias, c.Curso_nombre 
from scores s
inner join retos r on s.ID_Reto = r.ID_Reto
inner join usuarios u on s.DNI_usuario = u.DNI_usuario
inner join cursos c on c.ID_Curso = u.ID_Curso
order by Puntuacion_Maxima ;

-- Volcando estructura para vista reto.puntuaciones_minimas
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `puntuaciones_minimas`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `puntuaciones_minimas` AS select s.ID_Reto, r.Reto_Nombre, MIN(s.Puntos) as Puntuacion_minima
from scores s
inner join retos r on s.ID_Reto = r.ID_Reto
group by s.ID_Reto, r.Reto_Nombre
Order by Puntuacion_minima ;

-- Volcando estructura para vista reto.puntuacion_max
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `puntuacion_max`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `puntuacion_max` AS select s.ID_Reto, r.Reto_Nombre, u.Alias AS Usuario_con_mejor_puntuacion, MAX(s.puntos) AS Puntuacion_Maxima
from scores s
Inner join usuarios u ON s.DNI_Usuario = u.DNI_Usuario
Inner Join retos r on s.ID_Reto = r.ID_Reto
group by s.id_Reto
order by s.ID_Reto ;

-- Volcando estructura para vista reto.retos_mas_jugados
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `retos_mas_jugados`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `retos_mas_jugados` AS select r.ID_Reto, r.Reto_Nombre, count(s.ID_Score) AS Numero_Jugado
from retos r
left join scores s on r.ID_Reto = s.ID_Reto
group by r.ID_Reto, r.Reto_Nombre
order by Numero_Jugado desc ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
