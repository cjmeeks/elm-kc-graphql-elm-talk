var express = require('express');
var express_graphql = require('express-graphql');
var { buildSchema } = require('graphql');
var http = require("http");
var fetch = require("node-fetch")
// GraphQL schema
var schema = buildSchema(`
    type Query {
        characters: [Character]
        charactersMarried(id: String!): Character
    },
    type Character {  
        uid : String,
        name : String,
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

function fetchCharactersMarried() {
    return fetch(`${baseURL}/character/search`).then(res => res.json());
}

function fetchCharactersMarried() {
    return fetchCharacters().then(json => json.characters);
}
var root = {
    characters: getCharacters,
    charactersMarried: fetchCharactersMarried
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