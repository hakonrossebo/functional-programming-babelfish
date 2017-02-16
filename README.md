# Functional programming babelfish

This is an attempt to provide a link and comparision between similar concepts and operations and their usage between different functional programming languages
. When learning and working with different languages and concepts, it's nice to have an easy way of looking up the implementations.

I am not an expert in all of these languages. Please contribute to improvements with PR's and issues to help improve this reference.

# Cheat sheet - condensed overview
| Concept | Name | Purescript | Haskell | Elm | F# |
----------|---------------------|------------|---------|-----|----|-------|
Forward function application|Apply/Pipe|```#```|```see below```|```|>```|```|>```|
Function application|Apply/Pipe|```$```|```$```|```<|```|```<|```|
Composition|Forward/right|```>>>```|```>>>```|```>>```|```>>```|
Composition|Backward/left|```<<<```|```.```|```<<```|```<<```|
Unit type|Empty|```Unit```|```()```|```()```|```()```|
Anonymous function|Lambda|```(\x -> x + 1)```|```(\x -> x + 1)```|```(\x -> x + 1)```|```(fun x -> x + 1)```|
Identity function||```id```|```id```|```identity```|```id```|
Tuple|Definition|```Tuple a b```|```(Integer, String)```|```(Int, String)```|```int * string```|
Tuple|Usage|```Tuple 2 "Test"```|```(2, "Test")```|```(2, "Test")```|```(2, "Test")```|
Functor map|Map|```<$>```|```<$>```|```.map```|```.map```|
Functor apply|Apply|```<*>```|```<*>```|```.mapN?```|```mapN?```|
Bind||```>>=```|```>>=```|```andThen```|```bind?```|
Union types||``` ```|```data Shape = ```|```type Shape = ```|``` ```|
Union types cont||``` ```|```Circle Point```|```Circle \| Line ```|``` ```|
Union types cont||``` ```|```&#124; Line ```|```&#124; Line Rect```|``` ```|
Record types||```data Point = Point```|``` ```|``` ```|``` ```|
Record types||```{x::number, y::number} ```|``` ```|``` ```|``` ```|

* Todo:
* Maybe
* Either/result
* Pattern matching
* Let In / Where
* Concat
* Lists



||``` ```|``` ```|``` ```|``` ```|

# Concepts
## Function application
### Forwards function application / Piping

| Language | Syntax |
|----------|--------|
Purescript | ```# ```
Haskell | ```Reverse $ instead ```
Elm | ```|> ```
F# | ```|> ```


#### Notes/links
* [http://stackoverflow.com/questions/1457140/haskell-composition-vs-fs-pipe-forward-operator](http://stackoverflow.com/questions/1457140/haskell-composition-vs-fs-pipe-forward-operator)
```
F#
( |> ) : 'T1 -> ('T1 -> 'U) -> 'U
let result = 100 |> function1 |> function2
202

Elm
(|>) : a -> (a -> b) -> b
result = 100 |> function1 |> function2
202

```
### Backwards function application / Backward Piping

| Language | Syntax |
|----------|--------|
Purescript | ```# ```
Haskell | ```Reverse $ instead ```
Elm | ```|> ```
F# | ```|> ```


#### Notes/links
* [https://docs.microsoft.com/en-us/dotnet/articles/fsharp/language-reference/functions/index](https://docs.microsoft.com/en-us/dotnet/articles/fsharp/language-reference/functions/index)
* [https://docs.microsoft.com/en-us/dotnet/articles/fsharp/language-reference/symbol-and-operator-reference/](https://docs.microsoft.com/en-us/dotnet/articles/fsharp/language-reference/symbol-and-operator-reference/)

```
Purescript:
apply :: forall a b. (a -> b) -> a -> b
apply f x = f x
street (address (boss employee))
street $ address $ boss employee

Haskell:
($) :: (a -> b) -> a -> b
F x = f x

F#: Passes the result of the expression on the right side to the function on left side
( <| ) : ('T -> 'U) -> 'T -> 'U
(backward pipe operator)
street (address (boss employee))
street <| address <| boss employee
```



### Other sites with related content
[https://github.com/hemanth/functional-programming-jargon](https://github.com/hemanth/functional-programming-jargon)