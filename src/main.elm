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


type alias Response =
    { hero : Character
    , greeting : String
    }




type alias Character =
    { name : String
    }


hero : SelectionSet Character Api.Interface.Character
hero =
    Character.selection Character
        [
        ]
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
                , model |> PrintAny.view
                ]
            ]
        ]
    }


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