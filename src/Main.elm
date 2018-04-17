module Main exposing (main)

import Navigation exposing (Location)
import UrlParser exposing (Parser, parseHash, map, top, s)
import Html exposing (Html, text, div, h1, a, table, th, td, tr, ul, li)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Date exposing (Date)
import Time exposing (Time)
import Task
import Date.Extra.Duration exposing (diff)


type Route
    = Top
    | About
    | Dreams
    | Works
    | Contact
    | NotFound


type alias Age =
    String


type alias Model =
    { route : Route
    , birthday : Maybe Date
    , age : Age
    }


init : Location -> ( Model, Cmd Msg )
init location =
    Model (parseLocation location) (Result.toMaybe (Date.fromString "1998/3/21")) "UNKNOWN" ! [ Task.perform UpdateAge Date.now ]


type Msg
    = NoOp
    | ChangeLocation Location
    | ClickLink Route
    | Tick Time
    | UpdateAge Date


durationToString : Date -> Date -> String
durationToString today birthday =
    let
        dr =
            diff today birthday
    in
        toString dr.year ++ "年 " ++ toString dr.month ++ "月 " ++ toString dr.day ++ "日 " ++ toString dr.hour ++ "時間 " ++ toString dr.minute ++ "分 " ++ toString dr.second ++ "秒"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ChangeLocation location ->
            { model | route = parseLocation location } ! []

        ClickLink route ->
            { model | route = route } ! [ Navigation.newUrl <| routeToPathStr route ]

        Tick _ ->
            model ! [ Task.perform UpdateAge Date.now ]

        UpdateAge today ->
            let
                age =
                    model.birthday
                        |> Maybe.map (durationToString today)
                        |> Maybe.withDefault "UNKNOWN"
            in
                { model | age = age } ! []


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ a [ class "sidebar-item top", onClick (ClickLink Top) ]
            [ text "TOP" ]
        , a [ class "sidebar-item about", onClick (ClickLink About) ]
            [ text "ABOUT" ]
        , a [ class "sidebar-item dreams", onClick (ClickLink Dreams) ]
            [ text "DREAMS" ]
        , a [ class "sidebar-item works", onClick (ClickLink Works) ]
            [ text "WORKS" ]
        , a [ class "sidebar-item contact", onClick (ClickLink Contact) ]
            [ text "CONTACT" ]
        , content model.route model.age
        ]


content : Route -> Age -> Html Msg
content route age =
    case route of
        Top ->
            div [ class "content top" ]
                [ h1 [] [ text "magurotabetai.github.io" ] ]

        About ->
            div [ class "content about" ]
                [ div [ class "about-section" ]
                    [ h1 [] [ text "About" ]
                    , table []
                        [ tr []
                            [ th []
                                [ text "名前" ]
                            , td []
                                [ text "ゆうた" ]
                            ]
                        , tr []
                            [ th []
                                [ text "年齢" ]
                            , td []
                                [ text age ]
                            ]
                        , tr []
                            [ th []
                                [ text "GitHub" ]
                            , td []
                                [ text "magurotabetai" ]
                            ]
                        , tr []
                            [ th []
                                [ text "GitLab" ]
                            , td []
                                [ text "magurotabetai" ]
                            ]
                        ]
                    ]
                ]

        Dreams ->
            div [ class "content dreams" ]
                [ div [ class "dreams-section" ]
                    [ h1 [] [ text "DREAMS" ]
                    , ul []
                        [ li [ class "done" ] [ text "無職脱出" ]
                        , li [] [ text "海外逃亡" ]
                        , li [] [ text "一人生活" ]
                        ]
                    ]
                ]

        Works ->
            div [ class "content works" ]
                [ div [ class "works-section" ]
                    [ h1 [] [ text "WORKS" ]
                    , div [] [ text "ないよ" ]
                    ]
                ]

        Contact ->
            div [ class "content contact" ]
                [ div [ class "contact-section" ]
                    [ h1 [] [ text "CONTACT" ]
                    , div [] [ text "ZTdAb3V0bG9vay5qcA==" ]
                    ]
                ]

        NotFound ->
            div [ class "content notfound" ]
                [ div [ class "notfound-section" ]
                    [ h1 [] [ text "NOT FOUND" ]
                    ]
                ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every Time.second Tick


main : Program Never Model Msg
main =
    Navigation.program ChangeLocation
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


matchers : Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ map Top top
        , map About <| s "about"
        , map Dreams <| s "dreams"
        , map Works <| s "works"
        , map Contact <| s "contact"
        ]


routeToPathStr : Route -> String
routeToPathStr route =
    case route of
        Top ->
            "/"

        About ->
            "#about"

        Dreams ->
            "#dreams"

        Works ->
            "#works"

        Contact ->
            "#contact"

        NotFound ->
            "#other"


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            NotFound
