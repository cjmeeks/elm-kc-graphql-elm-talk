module Main exposing (main)

import Browser
import Graphql.Document as Document
import Graphql.Field as Field
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)
import Html exposing (div, h1, p, pre, text)


-- import PrintAny

import RemoteData exposing (RemoteData)
import Api.Object.Character as Character
import Api.Query as Query
import Api.Object


type alias Response =
    { characters : Maybe (List (Maybe ElmCharacter))
    }


query : SelectionSet Response RootQuery
query =
    Query.selection Response
        |> with (Query.characters hero)


type alias ElmCharacter =
    { name : Maybe String
    }


hero : SelectionSet ElmCharacter Api.Object.Character
hero =
    Character.selection ElmCharacter
        |> with Character.name


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "https://localhost:4000/graphql"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)


type Msg
    = GotResponse Model


type alias Model =
    RemoteData (Graphql.Http.Error Response) Response


init : () -> ( Model, Cmd Msg )
init _ =
    ( RemoteData.Loading
    , makeRequest
    )


view : Model -> Browser.Document Msg
view model =
    { title = "Starwars Demo"
    , body =
        [ div []
            [ div []
                [ h1 [] [ text "Generated Query" ]
                , pre [] [ text (Document.serializeQuery query) ]
                ]
            , div []
                [ h1 [] [ text "Response" ]
                ]
            ]
        ]
    }



-- viewCharacter :


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotResponse response ->
            ( response, Cmd.none )


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
