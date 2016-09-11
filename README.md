##Content
.  
├── Dockerfile -> Dev World  
├── Jenkinsfile -> QA/Security World  
├── LICENSE  
├── Makefile -> Ops World  
├── README.md  
└── src  
    ├── php  
    │   └── index.php  
    └── sql  
        ├── production.sql  
        └── staging.sql  

3 directories, 8 files  

traefik :  
docker run -d -p 8666:8080 -p 80:80 -p 443:443 -v /var/run/docker.sock:/var/run/docker.sock \  
        -v traefik:/data -v $PWD/conf/traefik.toml:/traefik.toml -v $PWD/conf/acme.json:/acme.json traefik  

Jenkins:  
docker run -p 8080 -d -v /data/jenkins/var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/$  
         -v $(which make):/usr/bin/make --label traefik.backend='jenkins' --label traefik.port='8080' --label traefik.protocol='http' \  
        --label traefik.weight='10' --label traefik.frontend.rule='Host:chocobo.yogosha.com' \  
        --label traefik.frontend.passHostHeader='true' --label traefik.priority='10' jenkinsci/docker-workflow-demo  
