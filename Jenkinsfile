node{
stage 'Checkout'
  git url: 'https://www.github.com/h-a-t/programmez'

stage 'Pull img'
  sh 'make pull'

stage 'Test build'
  sh 'make build'

stage 'Building env'

  // Puts app stuff
  def busy = docker.image('busybox');
  busy.inside("-v programmez-app:/data"){
    sh "cp -r ./src/php/index.php /data/"
    sh "chown -R www-data:www-data /data"
  }
  // Puts db stuff
  busy.inside("-v programmez-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/staging.sql /data/"
  }
  // Prepares containers
  def php = docker.build('phpsqli-app', '.')
  def zap = docker.image('owasp/zap2docker-weekly')
  def db = docker.image('mysql/mysql-server:5.6')

  // Defines staging param
  def state = "staging"
  def db_param = "-e 'MYSQL_RANDOM_ROOT_PASSWORD=yes' -e 'MYSQL_USER=user' -e 'MYSQL_PASSWORD=password' -e 'MYSQL_DATABASE=sqli' --label 'traefik.enable=false'"
  def app_param = "--label traefik.backend='app' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' "


  // Starts Staging instances
  def staging_db = db.run("${db_param} -v programmez-db:/docker-entrypoint-initdb.d/")
  def staging_app = php.run ("-P ${app_param} -v programmez-app:/var/www/html  --link ${staging_db.id}:db")

  // Runs "security check" before sending to 'IRL QA'
stage 'Test with OWASP ZapProxy'
  zap.inside("--link ${staging_app.id}:app -v phpsqli-zap:/zap/wrk") {
          println('Waiting for server to be ready')
          sh "until \$(curl --output /dev/null --silent --head --fail http://app/index.php); do printf '.'; sleep 5; done"
          println('It Works!')
          sh "ls -la"
          // Active scan, a bit more permissive and customizable
          sh "zap-cli quick-scan --self-contained --start-options '-config api.disablekey=true' http://app/index.php"
          // Passive scan, build will fail if any WARN is returned #blame.
          // sh "zap-baseline.py -t http://app/index.php -r report.html"
}

  // "Oh hai o/ Can I haz a human check?"
  stage 'QA'
  input "Is https://${state}.chocobo.yogosha.com going according to plan?"

  staging_app.stop()

  // "N33d Help for securitay?"
  stage 'Bug Bounty'
  // Defines bb param
  state = "bb"
  // Staging data is enough! (eventually prevention of data leak depending on your data quality)
  app_param = "--label traefik.backend='app' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' "
  def bb_app = php.run ("-P ${app_param} -v phpsqli-app:/var/www/html  --link ${staging_db.id}:db")


  stage 'Production'
  staging_db.stop()
  // Loading a snapshot of Production fresh data
  busy.inside("-v phpsqli-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/production.sql /data/"
  }
  // Push to the interwebz!
  state = "prod"
  app_param = "--label traefik.backend='app' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' "
  db_param = "-e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_USER=user -e MYSQL_PASSWORD=p4s5w0rd -e 'MYSQL_DATABASE=sqli' --label traefik.enable=false"

  def prod_db = db.run("${db_param} -v phpsqli-db:/docker-entrypoint-initdb.d/")
  def prod_app = php.run ("-d -P ${app_param} -v phpsqli-app:/var/www/html  --link ${prod_db.id}:db")
}
