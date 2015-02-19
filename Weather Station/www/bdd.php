<?php
// BDD
// ============================================================

// BDD Configuration :
define('DB_HOST', 'localhost');
define('DB_NAME', 'daweather');
define('DB_USER', 'root');
define('DB_PASSWORD', 'daweather');
$GLOBALS['DB'] = null;

// BBD Connexion :
function bdConnect(){
	try{ $GLOBALS['DB'] = new PDO("mysql:host=".DB_HOST.";dbname=".DB_NAME, DB_USER, DB_PASSWORD); } 
	catch ( Exception $e ) {
		echo "Connection à MySQL impossible : ", $e->getMessage();
		die();
	}
}

// BDD DisConnexion :
function bdDisconnect(){
	$GLOBALS['DB'] = null;
}
?>
