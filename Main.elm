module Main where

import List
import String
import Signal exposing (Address)
import Html exposing (..)
import Html.Events exposing (onClick, targetChecked, on)
import Html.Attributes exposing (..)
import StartApp.Simple as StartApp

-- project imports
import FreeThrow exposing (..)
import Style exposing (font, background, layout)

main =
  StartApp.start { model = model, view = view, update = update }

model : FreeThrow.Session
model =
  {
    player = ""
  , shots = []
  , percentage = 0
  , score = 0
  , currentShotType = Layup
  }

view : Address Action -> Session -> Html
view address model =
  div [] [
    div [ style (font ++ background ++ layout) ] [
        text "Freethrows are fun"
        , div [style Style.currentSession] <|
          List.map buildStatView
            [ ("Shots Taken: ",  (List.length model.shots), "")
            , ("Shot percentage: ", model.percentage, "%")
            , ("Score: ", model.score, "") ]
        , h2 [] [text (toString model.currentShotType)]
    ]
    , div [] <|
      List.map (\shotType -> shotRadio address model shotType) [Layup, FreeThrow, ThreePointer]
    , div [] [
      button [onClick address (Shoot <| (setupShot model True))] [text "made it"]
      , button [onClick address (Shoot <| (setupShot model False))] [text "don't made it"]
    ]
  ]

buildStatView : (String, Int, String) -> Html
buildStatView (prefix, stat, suffix) =
  h4 [] [text <| prefix ++ (toString stat) ++ suffix]


shotRadio :  Address Action -> Session -> ShotType -> Html
shotRadio  address model shotType =
  label []
    [ input
      [ type' "radio"
      , checked (model.currentShotType == shotType)
      , on "change" targetChecked (\_ -> Signal.message address (ChangeShot shotType))
      ] []
    , text (toString shotType)
    , br [] [] ]


setupShot : Session -> Bool -> Shot
setupShot {currentShotType} made =
  {technique = currentShotType, made = made}

takeShot : Shot -> Session -> Session
takeShot shot session =
  let
    points = getShotScore shot
    newScore = session.score + points
    newShots = session.shots ++ [shot]
    shotsTaken = List.length newShots
    madeShots = getMadeShotCount newShots
  in
    {
      session |
        shots <- newShots
        , score <- newScore
        , percentage <- round ((toFloat madeShots / toFloat shotsTaken) * 100)
    }

getMadeShotCount : List Shot -> Int
getMadeShotCount shots =
  List.length (List.filter .made shots)

changeShotType : ShotType -> Session -> Session
changeShotType shotType model =
  {model | currentShotType <- shotType}


getShotScore : Shot -> Int
getShotScore {technique, made} =
  if made then
    case technique of
      Layup -> 2
      FreeThrow -> 2
      ThreePointer -> 3
    else 0

type Action =
  Shoot Shot
  | ChangeShot ShotType
  | ChangeName String

update :  Action -> FreeThrow.Session -> FreeThrow.Session
update action model =
  case action of
    Shoot shot ->
      takeShot shot model
    ChangeShot shotType ->
      changeShotType shotType model

