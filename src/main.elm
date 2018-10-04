module Main exposing (main)

-- import PrintAny

import Api.Object
import Api.Object.Character as Character
import Api.Query as Query
import Browser
import Graphql.Document as Document
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)
import Html exposing (Html, button, div, h1, input, li, p, pre, table, td, text, tr, ul)
import Html.Attributes exposing (..)
import Html.Events
import RemoteData exposing (RemoteData(..))


type alias Response =
    { characters : Maybe (List ElmCharacter)
    }


queryWithName : String -> SelectionSet Response RootQuery
queryWithName queryStr =
    Query.selection Response
        |> with (Query.charactersName { name = queryStr } charactersQuery)


charactersQuery : SelectionSet ElmCharacter Api.Object.Character
charactersQuery =
    Character.selection ElmCharacter
        |> with Character.uid
        |> with Character.name
        |> with Character.gender


query : SelectionSet Response RootQuery
query =
    Query.selection Response
        |> with (Query.characters charactersQuery)


type alias ElmCharacter =
    { uid : String
    , name : String
    , gender : Maybe String

    -- , yearOfBirth : Maybe String
    -- , monthOfBirth : Maybe String
    -- , dayOfBirth : Maybe String
    -- , placeOfBirth : Maybe String
    -- , yearOfDeath : Maybe String
    -- , monthOfDeath : Maybe String
    -- , dayOfDeath : Maybe String
    -- , placeOfDeath : Maybe String
    -- , height : Maybe String
    -- , weight : Maybe String
    -- , deceased : Maybe String
    -- , bloodType : Maybe String
    -- , maritalStatus : Maybe String
    -- , serialNumber : Maybe String
    -- , hologramActivationDate : Maybe String
    -- , hologramStatus : Maybe String
    -- , hologramDateStatus : Maybe String
    }


initCharacter =
    { uid = ""
    , name = ""
    , gender = Nothing

    -- , yearOfBirth = Nothing
    -- , monthOfBirth = Nothing
    -- , dayOfBirth = Nothing
    -- , placeOfBirth = Nothing
    -- , yearOfDeath = Nothing
    -- , monthOfDeath = Nothing
    -- , dayOfDeath = Nothing
    -- , placeOfDeath = Nothing
    -- , height = Nothing
    -- , weight = Nothing
    -- , deceased = Nothing
    -- , bloodType = Nothing
    -- , maritalStatus = Nothing
    -- , serialNumber = Nothing
    -- , hologramActivationDate = Nothing
    -- , hologramStatus = Nothing
    -- , hologramDateStatus = Nothing
    }



-- |> with Character.yearOfBirth
-- |> with Character.monthOfBirth
-- |> with Character.dayOfBirth
-- |> with Character.placeOfBirth
-- |> with Character.yearOfDeath
-- |> with Character.monthOfDeath
-- |> with Character.dayOfDeath
-- |> with Character.placeOfDeath
-- |> with Character.height
-- |> with Character.weight
-- |> with Character.deceased
-- |> with Character.bloodType
-- |> with Character.maritalStatus
-- |> with Character.serialNumber
-- |> with Character.hologramActivationDate
-- |> with Character.hologramStatus
-- |> with Character.hologramDateStatus


makeNameRequest : String -> Cmd Msg
makeNameRequest queryStr =
    queryWithName queryStr
        |> Graphql.Http.queryRequest "http://localhost:4000/graphql"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "http://localhost:4000/graphql"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)



--npm run elm-graphql http://localhost:4000/graphql --base Stapi --output src


type Msg
    = GotResponse (RemoteData (Graphql.Http.Error Response) Response)
    | Search
    | SearchInput String


type alias Model =
    { data : RemoteData (Graphql.Http.Error Response) Response
    , chars : List ElmCharacter
    , query : String
    , currentGraphqlQuery : Maybe (SelectionSet Response RootQuery)
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { data = RemoteData.Loading
      , chars = []
      , query = ""
      , currentGraphqlQuery = Nothing
      }
    , makeRequest
    )


view : Model -> Browser.Document Msg
view model =
    let
        curQuery =
            Maybe.withDefault query model.currentGraphqlQuery
    in
        { title = "Star Trek API Demo"
        , body =
            [ div []
                [ div []
                    [ h1 [] [ text "Generated Query" ]
                    , pre [] [ text (Document.serializeQuery curQuery) ]
                    ]
                , div [] [ h1 [] [ text "Search By Name" ], input [ value model.query, Html.Events.onInput SearchInput ] [], button [ Html.Events.onClick Search ] [ text "Search" ] ]
                , div []
                    [ table [ style "border" "1px solid" ] <| List.map viewCharacter model.chars
                    ]
                ]
            ]
        }


viewCharacter : ElmCharacter -> Html Msg
viewCharacter character =
    tr []
        [ td [ style "border" "1px solid" ] [ text character.uid ]
        , td [ style "border" "1px solid" ] [ text character.name ]
        , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.gender ]

        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.yearOfBirth ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.yearOfDeath ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.height ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.weight ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.maritalStatus ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.serialNumber ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.hologramActivationDate ]
        -- , td [ style "border" "1px solid" ] [ text <| Maybe.withDefault "nothing" character.hologramStatus ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse response ->
            ( { model | data = response, chars = getChars response }, Cmd.none )

        Search ->
            let
                ( currentQuery, cmd ) =
                    if String.isEmpty model.query then
                        ( query, makeRequest )
                    else
                        ( queryWithName model.query, makeNameRequest model.query )
            in
                ( { model | currentGraphqlQuery = Just currentQuery }, cmd )

        SearchInput str ->
            ( { model | query = str }, Cmd.none )


getChars : RemoteData (Graphql.Http.Error Response) Response -> List ElmCharacter
getChars data =
    case data of
        Success response ->
            Maybe.withDefault [] response.characters

        _ ->
            []


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
