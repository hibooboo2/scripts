var fs = require('fs');
var parseString = require('xml2js').parseString;
var xml2js = require('xml2js');

var xml1 = fs.readFileSync(process.argv[2]).toString()
var xml2 = fs.readFileSync(process.argv[3]).toString()

//var compareIdSetting = functio

parseString(xml1, function (err, json1) {
    //console.dir(json1.profiles.profile[0].setting[0].$.id);
    //console.dir(json1.profiles.profile[0].setting[0].$.value);
    parseString(xml2, function (err, json2) {
        //            console.dir(json1.profiles.profile[0].setting[i].$.id);
        //            console.dir(json2.profiles.profile[0].setting[i].$.id);
        var json2NewSetting = [];
        json1.profiles.profile[0].setting.map(function (currSetting) {
            //console.log(currSetting.$.id);
            json2.profiles.profile[0].setting.map(function (otherSetting) {
                if (currSetting.$.id === otherSetting.$.id) {
                    //                    console.log(currSetting.$.value === otherSetting.$.value);
                    json2NewSetting.push(otherSetting);
                }
            });
        });

        json2.profiles.profile[0].setting = json2NewSetting;

        //console.dir(json1.profiles.profile[0].setting[0].$.value);

        var builder = new xml2js.Builder();
        var xml = builder.buildObject(json1);
        console.log(xml);
        fs.writeFile('xml1.xml',xml);
        var builder2 = new xml2js.Builder();
        var xml2 = builder2.buildObject(json2);
        console.log(xml);
        fs.writeFile('xml2.xml',xml2);
        

    });

});