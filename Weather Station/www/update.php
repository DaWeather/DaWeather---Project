<?php 
/* Ce fichier PHP permet de mettre à jour les configurations de la Raspberry Pi au WebService 
 * et de répondre au requête dz l'application.
 */
 
// CONSTATNTES :
define("WEBSERVICE", "http://daweather.ovh/webservice");
 
// DEPANDANCES :
require("bdd.php");

// TRAITEMENTS :
	// connexion à la base de données :
	bdConnect();
	$req = $GLOBALS['DB']->prepare("SELECT email, private_key, nom, lieu, altitude, date_installation FROM station WHERE idStation='1'");
	$req->execute();
	$params = $req->fetch(); 
	//print_r($params);

	// on ce connecte au web service pour s'enregistrer :
	// CURL - si passer ok, sinon mail et die
	$requestStationPush = curl_init();
    curl_setopt($requestStationPush, CURLOPT_URL, WEBSERVICE."/station/push");
	curl_setopt($requestStationPush, CURLOPT_POST, true);
	curl_setopt($requestStationPush, CURLOPT_RETURNTRANSFER, true);  
	curl_setopt($requestStationPush, CURLOPT_POSTFIELDS, array("email"=>$params["email"],
															   "privatekey"=>$params["private_key"],
															   "nom"=>$params["nom"],
															   "lieu"=>$params["lieu"],
															   "altitude"=>$params["altitude"]));
	$resultStationPush = json_decode(curl_exec($requestStationPush), true);
	curl_close($requestStationPush);
	//print_r($resultStationPush);
	if($resultStationPush["response"]["code"] != 1){ 
		echo "Station update error, please check configuration.";
		die();
	}

	// on ce connecte au web service pour récuperer les taches à faires :
    	$requestRaspberryPull = curl_init();
        curl_setopt($requestRaspberryPull, CURLOPT_URL, WEBSERVICE."/request/raspberry/pull");
        curl_setopt($requestRaspberryPull, CURLOPT_POST, true);
        curl_setopt($requestRaspberryPull, CURLOPT_RETURNTRANSFER, true);  
        curl_setopt($requestRaspberryPull, CURLOPT_POSTFIELDS, array("email"=>$params["email"],
                                                                     "privatekey"=>$params["private_key"]));
        $resultRaspberryPull = json_decode(curl_exec($requestRaspberryPull), true);
        curl_close($requestRaspberryPull);
        //print_r($resultRaspberryPull);
        if($resultRaspberryPull["response"]["code"] != 1){ 
            echo "Station pull request on Raspberry Pi error, please check configuration.";
            die();
        }
        
		// si on a des taches on fais le requete en bdd
		if(isset($resultRaspberryPull['response']['data']) && count($resultRaspberryPull['response']['data'])>0){
		    foreach ($resultRaspberryPull['response']['data'] as $requestKey => $requestValue) {
				try{
                    $responde = $GLOBALS['DB']->prepare($requestValue["request"]);
                    //echo $requestValue["request"];
                    $responde->execute();
                    $responde = $responde->fetchAll();
                    
                    if(is_array($responde)){
                        $requestRaspberryPush = curl_init();
                        curl_setopt($requestRaspberryPush, CURLOPT_URL, WEBSERVICE."/request/raspberry/push");
                        curl_setopt($requestRaspberryPush, CURLOPT_POST, true);
                        curl_setopt($requestRaspberryPush, CURLOPT_RETURNTRANSFER, true);  
                        curl_setopt($requestRaspberryPush, CURLOPT_POSTFIELDS, array("email"=>$params["email"],
                                                                                     "privatekey"=>$params["private_key"],
                                                                                     "id"=>$requestValue["request_id"],
                                                                                     "response"=>json_encode($responde)));
                        $resultRaspberryPush = json_decode(curl_exec($requestRaspberryPush), true);
                        curl_close($requestRaspberryPush);
                        //print_r($resultRaspberryPush);
                        if($resultRaspberryPush["response"]["code"] != 1){ 
                            echo "Station push respond to '".$requestValue["request"]."' with id=".$requestValue["request_id"]." error on return result.";
                            die();
                        }
                    }
                    else{ echo "Station respond to '".$requestValue["request"]."' with id=".$requestValue["request_id"]." error on result format."; } 
                }
                catch(Exception $e){ echo "Station respond to '".$requestValue["request"]."' with id=".$requestValue["request_id"]." error on execute."; die(); }
			}
		}

		// déconnexion de la base de données :
		bdConnect();
        
        // return good result if script was not interrupted :
        echo "Station full responde."; 