<!DOCTYPE html>
<html>
<body>
<center><img height="100px" src="star.png"></center>
<center><h4>PoC||GTFO</h4></center>

<br><br><br>

<table style="width:100%">
  <tr>
    <th><h1> Env: <? echo $_ENV["BUILD_STAGE"] ?></h1><th>
    <th></th>

  </tr>
  <tr>
    <?
    $db=mysql_connect("db",$_ENV["DB_ENV_MYSQL_USER"],$_ENV["DB_ENV_MYSQL_PASSWORD"]);
    mysql_select_db("sqli",$db);
    $user_id = $_GET['id'];
    $sql = mysql_query("SELECT username, nom, prenom, email FROM users WHERE user_id = $user_id") or die(mysql_error());
    if(mysql_num_rows($sql) > 0)
    {
    while($row = mysql_fetch_assoc($sql)) { ?>
      <th>
      <fieldset>
      <legend>Profil of <? echo $row["username"] ?></legend>
      <p>Name : <? echo $row["nom"] ?> <? echo $row["prenom"] ?></p>
      <p>Email : <? echo $row["email"] ?></p>
      </fieldset>
    </th>
    <?php }} ?>
  </tr>
</table>
<br><br><br>
  <table style="width:100%">
  <tr>
    <th>Powered by:</th>
    <th><img height="100px" src='scaleway.svg' ></th>
    <th><img height="100px" src='debian.png' ></th>
    <th><img height="100px" src='docker.png' ></th>
    <th><img height="100px" src='traefik.png' ></th>
    <th><img height="100px" src='owasp.png' ></th>
    <th><img height="100px" src='jenkins.png' ></th>
    <th><img height="100px" src='lamp.jpg' ></th>

  </tr>
</table>

</body>
</html>
