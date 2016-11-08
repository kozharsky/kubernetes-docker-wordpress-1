eval $(aws ecr get-login --region us-west-1)
docker build -t haproxy .
docker tag haproxy:latest 424632819416.dkr.ecr.us-west-1.amazonaws.com/haproxy:latest
docker push 424632819416.dkr.ecr.us-west-1.amazonaws.com/haproxy:latest