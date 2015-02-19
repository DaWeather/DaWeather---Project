<?php 
/* Ce fichier PHP permet de mettre à jour le configurations de la Raspberry Pi dans ça base de données MySQL.
 * Ainsi cela permet à la station par le script update.php de mettre à jour sur le WebService les données. 
 */
 

// DEPANDANCES :
require("bdd.php");

// TRAITEMENTS :
	// déclaration :
	$INPUTS = $_POST;
	$retour = '0';
	
	// connexion à la base de données :
	bdConnect();

	// mise à jour de la configuration :
		try{
			// date d'installation
			$req = $GLOBALS['DB']->prepare("UPDATE station SET date_installation = ? WHERE idStation='1' AND date_installation IS NULL");
			$req->execute(array(date("Y-m-d H:i:s")));
			// parametres :
			$req = $GLOBALS['DB']->prepare("UPDATE station SET nom=?, lieu=?, altitude=?, email=?, private_key=? WHERE idStation='1'");
			$params = array($INPUTS['name'], $INPUTS['place'], $INPUTS['altitude'], $INPUTS['email'], $INPUTS['privatekey']);
			if($req->execute($params)){ $retour = '1'; }
		} catch(Exception $e) { }

	// déconnexion de la base de données :
	bdDisconnect();

// RESULTAT :
echo $retour;