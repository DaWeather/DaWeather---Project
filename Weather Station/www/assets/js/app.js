$(document).ready(function () { });

$(window).load(function () {
	// FUNCTIONS : 
	function isValidEmailAddress(emailAddress) {
		var pattern = new RegExp(/^(("[\w-+\s]+")|([\w-+]+(?:\.[\w-+]+)*)|("[\w-+\s]+")([\w-+]+(?:\.[\w-+]+)*))(@((?:[\w-+]+\.)*\w[\w-+]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?((25[0-5]\.|2[0-4][\d]\.|1[\d]{2}\.|[\d]{1,2}\.))((25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\.){2}(25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\]?$)/i);
		return pattern.test(emailAddress);
	};
	
	
	// LORS DE LA SOUMISSION DU FORLULAIRE :
	$("button.submit").click(function(){
		// Déclaration :
		var ajaxResult = 0;
		var result = 0;
		
		// Récupération de la configuration :
        var data = [];
		data['email'] = $('input[name="email"]').val();
		data['privatekey'] = $('input[name="privatekey"]').val();
		data['name'] = $('input[name="name"]').val();
		data['place'] = $('input[name="place"]').val();
		data['altitude'] = $('input[name="altitude"]').val();
		
		// Vérification de la saisie :
		if(data['email'].trim() == "" ||
		   data['privatekey'].trim() == "" ||
		   data['name'].trim() == "" ||
		   data['place'].trim() == "" ||
		   data['altitude'].trim() == "" ||
		   !isValidEmailAddress(data['email'])){
			alert("Thank you kindly to fill in all fields of the configuration form, please.");
			return false;
		}
        
		// Modification en ajax des configuration dans la base de données :
        $.ajax({
            url : 'configuration.php',
            type : 'POST',
			data : 'email='+data['email']+ '&privatekey='+data['privatekey']+ '&name='+data['name']+ '&place='+data['place']+ '&altitude='+data['altitude'],
            dataType : 'html',
			success : function(code_html, statut){ result = 1; },
			error : function(resultat, statut, erreur){ result = 0; }
        });
		
		// Resultat :
		if(result = 1){ alert ("Settings saved."); }
		else{ alert("An error occurred while saving settings."); }

	});
});