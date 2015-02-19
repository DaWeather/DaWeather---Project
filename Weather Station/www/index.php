<?php
// DEPANDANCES :
require("bdd.php");

// TRAITEMENTS :
	// connexion à la base de données :
	bdConnect();
	
	// récupération de la configuration :
	$req = $GLOBALS['DB']->prepare("SELECT email, private_key, nom, lieu, altitude, date_installation FROM station WHERE idStation='1'");
	$req->execute();
	$params = $req->fetch(); 

	// déconnexion de la base de données :
	bdDisconnect();
?>
<!doctype html>
<html lang="fr">
	<head>
		<meta charset="utf-8">
		<title>DaWeather</title>
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />

		<link href='http://fonts.googleapis.com/css?family=Raleway:500,600,700,400,200,300' rel='stylesheet' type='text/css'>
		<link href='http://fonts.googleapis.com/css?family=Lato&subset=latin,latin-ext' rel='stylesheet' type='text/css'>
		<link rel="stylesheet" href="assets/styles/font-awesome.min.css">
		<link rel="stylesheet" href="assets/styles/animate.css">
		<link rel="stylesheet" href="assets/styles/style.css">
		<link rel="shortcut icon" href="assets/images/icon.ico">
	</head>

	<body>
		<noscript><div id="noJS" class="fullscreen green">
			<table valign="middle" align="center" border="0" height="100%" width="100%"><tbody><tr height="100%"><td align="center" height="100%" valign="middle" width="100%" class="click">
				<div class="container">
					<h1 class="animated fadeInDown">DaWeather</h1>
					<h3 class="animated fadeInDown"> Your browser does not support javascript, thank you kindly update your browser to <br/> access to the site's features. </h3>
				</div>
				</td></tr></tbody></table>
			</div></noscript>

		<div id="configuration" class="fullscreen green">
			<table valign="middle" align="center" border="0" height="100%" width="100%"><tbody><tr height="100%"><td align="center" height="100%" valign="middle" width="100%" class="click">
				<div class="container">
					<h1 class="animated fadeInDown">DaWeather</h1>
					<h3 class="animated fadeInDown">Through this menu you can configure the settings of the<br/> DaWeather station so that it can send up the informations on your mobile.</h3>
					
					<form class="animated fadeInUp" method="POST" action="#" onsubmit="return false;">
						<input type="email" name="email" class="required" placeholder="E-mail *" 
							<?php if(isset($params['email'])){ echo 'value="'.$params['email'].'"'; } ?> >
						<input type="text" name="privatekey" class="required" placeholder="Private key *"
						   <?php if(isset($params['private_key'])){ echo 'value="'.$params['private_key'].'"'; } ?> >

						<input type="text" name="name" class="required" placeholder="Name *"
							   <?php if(isset($params['nom'])){ echo 'value="'.$params['nom'].'"'; } ?> >
						<input type="text" name="place" class="required" placeholder="Place *"
						   <?php if(isset($params['lieu'])){ echo 'value="'.$params['lieu'].'"'; } ?> >
						<input type="number" name="altitude" class="required" placeholder="Altitude *"
						   <?php if(isset($params['altitude'])){ echo 'value="'.$params['altitude'].'"'; } ?> >
						
						<button type="submit" class="submit" value="Save">Save</button>
					</form>
				</div>
			</td></tr></tbody></table>
		</div>

		<script src='assets/js/jquery.min.js'></script>
		<script src="assets/js/app.js"></script>
	</body>
</html>