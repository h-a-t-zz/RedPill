<center><img src="logo.png"></center>
<h1> Env: <? echo $_ENV["BUILD_STAGE"] ?></h1>
<?
$db=mysql_connect("db",$_ENV["DB_ENV_MYSQL_USER"],$_ENV["DB_ENV_MYSQL_PASSWORD"]);
mysql_select_db("sqli",$db);
$user_id = $_GET['id'];
$sql = mysql_query("SELECT username, nom, prenom, email FROM users WHERE user_id = $user_id") or die(mysql_error());
if(mysql_num_rows($sql) > 0)
{
while($row = mysql_fetch_assoc($sql)) { ?>
  <fieldset>
  <legend>Profil of <? echo $row["username"] ?></legend>
  <p>Name : <? echo $row["nom"] ?> <? echo $row["prenom"] ?></p>
  <p>Email : <? echo $row["email"] ?></p>
  </fieldset>
<?php }} ?>
