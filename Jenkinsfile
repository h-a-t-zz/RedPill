node{
  def busy = docker.image('busybox');
  def zap = docker.image('owasp/zap2docker-weekly')
  def db = docker.image('mysql/mysql-server:5.6')




  stage 'Checkout'
  git url: 'https://www.github.com/h-a-t/devopssec'

  stage 'Pull img'
  //sh 'make pull'
  zap.pull()
  db.pull()
  busy.pull()

  stage 'Build'
  //sh 'make build'
  def php = docker.build('phpsqli-app', '.')

  //stage 'Clean env'
  //sh 'make stop && make rm'

  stage 'Test with Zap'
  busy.inside("-v phpsqli-app:/data"){
    sh "cp -r ./src/php/* /data/"
    sh "chown -R www-data:www-data /data"
    sh "ls -la /data"
  }

  busy.inside("-v phpsqli-db:/data"){
    sh "cp -r ./src/sql/* /data/"
    sh "ls -la /data"
  }

  zap.pull()
  db.pull()

  def testdb = db.run('-e MYSQL_ROOT_PASSWORD=root -v phpsqli-db:/docker-entrypoint-initdb.d/ -d')
  def test = php.run ("-d -P -v phpsqli-app:/var/www/html  --link ${testdb.id}:db")

  zap.inside("--link ${test.id}:app") {
          println('Waiting for server to be ready')
          sh "until \$(curl --output /dev/null --silent --head --fail http://app/index.php); do printf '.'; sleep 5; done"
          println('It Works!')
          sh "zap-baseline.py -t http://app/index.php"

}
}
