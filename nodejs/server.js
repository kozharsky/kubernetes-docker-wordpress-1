var http = require('http');

const PORT=8080; 

function handleRequest(request, response){

  response.writeHead(200, {
    'Set-Cookie': 'JSESSIONID=6B55894175A4520A96FD7B992E66E319; Path=/; HttpOnly, SERVERID=j1; path=/',
    'Content-Type': 'text/plain'
  });

    var name   = process.env.NAME;
    response.write('server:  '+ name + ', path = ' + request.url + '\n');
    response.write('body' + JSON.stringify(request.headers));
    response.end();
}

var server = http.createServer(handleRequest);


server.listen(PORT, function(){
    console.log("started", PORT);
});
