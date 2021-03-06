module Decoders exposing (..)

import Types exposing (..)
import Json.Decode as Json exposing (field)


decodeAvailableLanguages : Json.Decoder (List Language)
decodeAvailableLanguages =
    Json.list decodeLanguage


decodeLanguage : Json.Decoder Language
decodeLanguage =
    Json.map2 Language
        (field "name" Json.string)
        (field "languageCode" Json.string)


decodeConcepts : Json.Decoder (List Concept)
decodeConcepts =
    Json.list decodeConcept


decodeConcept : Json.Decoder Concept
decodeConcept =
    Json.map6 Concept
        (field "name" Json.string)
        (field "description" Json.string)
        (field "index" Json.int)
        ((Json.maybe (field "notes" Json.string)) |> Json.andThen decodeSuccessNotes)
        (field "languages" decodeConceptLanguageImplementations)
        ((Json.maybe (field "links" decodeConceptLinks)) |> Json.andThen decodeSuccessLinks)


nullable : Json.Decoder a -> Json.Decoder (Maybe a)
nullable decoder =
    Json.oneOf
        [ Json.null Nothing
        , Json.map Just decoder
        ]


decodeSuccessNotes : Maybe String -> Json.Decoder (Maybe String)
decodeSuccessNotes notes =
    Json.succeed (Maybe.withDefault Nothing (Just notes))


decodeSuccessLinks : Maybe (List ConceptLink) -> Json.Decoder (List ConceptLink)
decodeSuccessLinks links =
    Json.succeed (Maybe.withDefault [] links)


decodeConceptLanguageImplementations : Json.Decoder (List LanguageImplementation)
decodeConceptLanguageImplementations =
    Json.list decodeLanguageImplementation


decodeLanguageImplementation : Json.Decoder LanguageImplementation
decodeLanguageImplementation =
    Json.map3 LanguageImplementation
        (field "name" Json.string)
        (field "code" Json.string)
        ((Json.maybe (field "example" (Json.list Json.string))) |> Json.andThen decodeSuccessExample)


decodeSuccessExample : Maybe (List String) -> Json.Decoder (Maybe (List String))
decodeSuccessExample example =
    Json.succeed (Maybe.withDefault Nothing (Just example))


decodeConceptLinks : Json.Decoder (List ConceptLink)
decodeConceptLinks =
    Json.list decodeConceptLink


decodeConceptLink : Json.Decoder ConceptLink
decodeConceptLink =
    Json.map2 ConceptLink
        (field "url" Json.string)
        (field "description" Json.string)
