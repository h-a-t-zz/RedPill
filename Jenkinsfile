node{
  def appname = "hpoc"
stage 'Checkout'
  git url: 'https://www.github.com/h-a-t/RedPill'

stage 'Pull img'
  sh 'make pull'

stage 'Test build'
  sh 'make build'

stage('SonarQube analysis') {
    // requires SonarQube Scanner 2.8+
    def scannerHome = tool 'SonarQubeScanner';
    withSonarQubeEnv('SonarQube') {
      sh "${scannerHome}/bin/sonar-scanner -D sonar.projectKey=${appname} -D sonar.sources=."
    }
  }

stage 'Building env'
  def state = "staging"

  // Puts app stuff
  def busy = docker.image('busybox');
  busy.inside("-v ${appname}-app:/data"){
    sh "cp -r ./src/php/* /data/"
    sh "chown -R www-data:www-data /data"
  }
  // Puts db stuff
  busy.inside("-v ${appname}-${state}-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/staging.sql /data/"
  }
  // Prepares containers
  def php = docker.build("${appname}-app", './src/php/')
  def zap = docker.image('owasp/zap2docker-weekly')
  def db = docker.image('mysql/mysql-server:5.6')

  // Defines staging param
  def db_param = "-e 'MYSQL_RANDOM_ROOT_PASSWORD=yes' -e 'MYSQL_USER=user' -e 'MYSQL_PASSWORD=password' -e 'MYSQL_DATABASE=sqli' --label 'traefik.enable=false'"
  def app_param = "--label traefik.backend='app-${state}' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' -e BUILD_STAGE=${state}"


  // Starts Staging instances
  def staging_db = db.run("${db_param} -v ${appname}-${state}-db:/docker-entrypoint-initdb.d/")
  def staging_app = php.run ("-P ${app_param} -v ${appname}-app:/var/www/html  --link ${staging_db.id}:db")

  // Runs quick security check
stage 'Test with OWASP ZapProxy'
  zap.inside("--link ${staging_app.id}:app -v ${appname}-zap:/zap/wrk") {
          println('Waiting for server to be ready')
          sh "until \$(curl --output /dev/null --silent --head --fail http://app/index.php); do printf '.'; sleep 5; done"
          println('It Works!')
          sh "ls -la"
          // Active scan, a bit more permissive and customizable
          sh "zap-cli quick-scan --self-contained --start-options '-config api.disablekey=true' http://app/index.php"
          // Passive scan, build will fail if any WARN is returned -> #blame.
          // sh "zap-baseline.py -t http://app/index.php -r report.html"
}

  // "Oh hai o/ Can I haz a quality check?"
  stage 'QA'
  input "Is https://${state}.chocobo.yogosha.com going according to plan?"

  staging_app.stop()

  // "N33d Help for securitay?"
  stage 'Bug Bounty'
  // Defines bb param
  state = "bb"
  app_param = "--label traefik.backend='app-${state}' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' -e BUILD_STAGE=${state}"
  def bb_app = php.run ("-P ${app_param} -v ${appname}-app:/var/www/html  --link ${staging_db.id}:db")

  stage 'Production'
  // Loading a snapshot of Production data
  state = "prod"
  busy.inside("-v ${appname}-${state}-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/production.sql /data/"
  }

  // Push to the interwebz!
  app_param = "--label traefik.backend='app-${state}' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:${state}.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' -e BUILD_STAGE=${state}"
  db_param = "-e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_USER=user -e MYSQL_PASSWORD=p4s5w0rd -e 'MYSQL_DATABASE=sqli' --label traefik.enable=false"

  def prod_db = db.run("${db_param} -v ${appname}-${state}-db:/docker-entrypoint-initdb.d/")
  def prod_app = php.run ("-d -P ${app_param} -v ${appname}-app:/var/www/html  --link ${prod_db.id}:db")
}
