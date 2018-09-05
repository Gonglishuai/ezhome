// phantomjs script for re-signing iOS apps
// args - ipa path, adsk userName, adsk pass
// example: ./phantomjs/bin/phantomjs phantomtest1.js ~/Documents/HSM\ Builds/Homestyler_149_dev.ipa yourname yourpass

function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 3000, //< Default Max Timout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
            console.log(new Date().getTime() - start);
            if ( (new Date().getTime() - start < maxtimeOutMillis) && !condition ) {
                // If not time-out yet and condition not yet fulfilled
                condition = (typeof(testFx) === "string" ? eval(testFx) : testFx()); //< defensive code
            } else {
                if(!condition) {
                    // If condition still not fulfilled (timeout but condition is 'false')
                    console.log("'waitFor()' timeout");
                    phantom.exit(1);
                } else {
                    // Condition fulfilled (timeout and/or condition is 'true')
                    console.log("'waitFor()' finished in " + (new Date().getTime() - start) + "ms. condition is " + condition);
                    typeof(onReady) === "string" ? eval(onReady) : onReady(); //< Do what it's supposed to do once the condition is fulfilled
                    clearInterval(interval); //< Stop this interval
                }
            }
        }, 3000);
};

function writeResponseToFile(response,destination){

    var fs = require('fs');
    try 
    {
        fs.write(destination, response, 'a');
    } 
    catch(e) 
    {
        console.log(e);
    }

};

var maxRunningTimoutInMS = 1000 * 60 * 10; // 10 minutes

var page = require('webpage').create(),
    system = require('system'),
    fname;
console.log(system.args[1]);

fname = system.args[1];
user = system.args[2];
pass = system.args[3];
results_path = system.args[4];

page.settings.userName = user;
page.settings.password = pass;

page.open("http://toracgosx.autodesk.com/ios/ET_Homestyler", function () {
     page.uploadFile('input[name=fileToUpload]', fname);

     page.evaluate(function () {
         document.querySelector('input[type=button]').click();
     });

//TODO verify click and uploaded file
    window.setTimeout(function () {
        //TODO debug only: page.render('step1.png');
        
        waitFor(function() {
            return page.evaluate(function() {
                return (document.querySelector('#uploadResponse').innerHTML != "");               
            });
        }, function() {
            var result = page.evaluate(function() {
                return (document.querySelector('#uploadResponse').innerHTML);               
            });
            console.log(result);
            var sep = "\n\n================================\n\n";
            writeResponseToFile(result+sep,results_path);
            //TODO debug only: page.render('step3.png');
            phantom.exit();
        },maxRunningTimoutInMS);

    }, 1000);
});

