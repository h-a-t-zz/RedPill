node{
  stage 'Checkout'
  git url: 'https://www.github.com/h-a-t/devopssec'

  stage 'Pull img'
  sh 'make pull'

  stage 'Test build'
  sh 'make build'

  stage 'Test with Zap'
  def busy = docker.image('busybox');
  busy.inside("-v phpsqli-app:/data"){
    sh "cp -r ./src/php/index.php /data/"
    sh "chown -R www-data:www-data /data"
  }

  busy.inside("-v phpsqli-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/staging.sql /data/"
  }

  def php = docker.build('phpsqli-app', '.')
  def zap = docker.image('owasp/zap2docker-weekly')
  def db = docker.image('mysql/mysql-server:5.6')

  def staging_param = "-e 'MYSQL_RANDOM_ROOT_PASSWORD=yes' -e 'MYSQL_USER=user' -e 'MYSQL_PASSWORD=password' -e 'MYSQL_DATABASE=sqli' --label 'traefik.enable=false'"
  def traefik_param = "--label traefik.backend='app' --label traefik.port='80' --label traefik.protocol='http' --label traefik.weight='10' --label traefik.frontend.rule='Host:cd.chocobo.yogosha.com' --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' "
  def staging_db = db.run("${staging_param} -v phpsqli-db:/docker-entrypoint-initdb.d/")
  def staging_app = php.run ("-P ${traefik_param} -v phpsqli-app:/var/www/html  --link ${staging_db.id}:db")

  zap.inside("--link ${staging_app.id}:app -v phpsqli-zap:/zap/wrk") {
          println('Waiting for server to be ready')
          sh "until \$(curl --output /dev/null --silent --head --fail http://app/index.php); do printf '.'; sleep 5; done"
          println('It Works!')
          sh "ls -la"
          // Active scan
          sh "zap-cli quick-scan --self-contained --start-options '-config api.disablekey=true' http://app/index.php"
          // Passive scan
          // sh "zap-baseline.py -t http://app/index.php -r report.html"
}


  stage 'QA Staging'
  input "Is https://cd.chocobo.yogosha.com good?"

  stage 'Production'
  staging_db.stop()
  staging_app.stop()
  busy.inside("-v phpsqli-db:/data"){
    sh "rm -rf /data/*"
    sh "cp -r ./src/sql/production.sql /data/"
  }
  def prod_param = "-e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_USER=user -e MYSQL_PASSWORD=p4s5w0rd -e 'MYSQL_DATABASE=sqli' --label traefik.enable=false"
  def prod_db = db.run("${prod_param} -v phpsqli-db:/docker-entrypoint-initdb.d/")
  def prod_app = php.run ("-d -P ${traefik_param} -v phpsqli-app:/var/www/html  --link ${prod_db.id}:db")
}
