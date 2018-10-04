var express = require('express');
var express_graphql = require('express-graphql');
var { buildSchema } = require('graphql');
var http = require("http");
var fetch = require("node-fetch")
// GraphQL schema
var schema = buildSchema(`
    type Query {
        characters: [Character!]
        charactersName(name: String!): [Character!]
    },
    type Character {  
        uid : String!,
        name : String!,
        gender : String,
        yearOfBirth : String,
        monthOfBirth : String,
        dayOfBirth : String,
        placeOfBirth : String,
        yearOfDeath : String,
        monthOfDeath : String, 
        dayOfDeath : String,
        placeOfDeath : String,
        height : String,
        weight : String,
        deceased : String,
        bloodType : String,
        maritalStatus : String,
        serialNumber : String,
        hologramActivationDate : String,
        hologramStatus : String,
        hologramDateStatus : String,
        hologram : Boolean,
        fictionalCharacter : Boolean,
        mirror : Boolean,
        alternateReality : Boolean
     }
`);
const baseURL = `http://stapi.co/api/v1/rest`

function fetchCharacters() {
    return fetch(`${baseURL}/character/search`).then(res => res.json());
}

function getCharacters() {
    return fetchCharacters().then(json => json.characters);
}

function fetchCharactersByName(name) {
    var headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    var body = 'name=' + name + '&title=' + name;
    return fetch(`${baseURL}/character/search`, { method: 'POST', body: body, headers: headers }).then(res => res.json());
}

function getCharactersByName(args) {
    if (args.name) {
        return fetchCharactersByName(args.name).then(json => json.characters);
    } else {
        return [];
    }
}
var root = {
    characters: getCharacters,
    charactersName: getCharactersByName
};
// Create an express server and a GraphQL endpoint
var app = express();
app.use('/app', express.static('index.html'))
app.use('/graphql', express_graphql({
    schema: schema,
    rootValue: root,
    graphiql: true
}));
app.listen(4000, () => console.log('Express GraphQL Server Now Running On localhost:4000/graphql'));