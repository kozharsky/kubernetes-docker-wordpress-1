var http = require('http');

const PORT=8080; 

function handleRequest(request, response){
    var name   = process.env.NAME;
    response.write('server:  '+ name + ', path = ' + request.url + '\n');
    response.write('body' + JSON.stringify(request.headers));
    response.end();
}

var server = http.createServer(handleRequest);


server.listen(PORT, function(){
    console.log("started", PORT);
});
