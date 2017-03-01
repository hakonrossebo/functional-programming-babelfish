
module Pages.About.About exposing (..)

import Html exposing (Html, text, div, span, p, a)
import Html.Attributes exposing (href)
import Material
import Material.Grid as Grid exposing (grid, size, cell, Device(..))
import Material.Elevation as Elevation
import Material.Color as Color
import Material.Button as Button
import Material.Options as Options exposing (when, css, cs, Style, onClick)
import Material.Typography as Typo
import Material.Table as Table
import Material.Dialog as Dialog
import Material.Menu as Menu
import Markdown
import Types exposing (..)


view : Taco -> Html msg
view taco =
      grid [ Options.id "top", Options.css "max-width" "1280px" ]
          [ cell
              [ size All 12
              , Elevation.e2
              , Options.css "padding" "6px 4px"
              , Options.css "display" "flex"
              , Options.css "flex-direction" "column"
              , Options.css "align-items" "left"
              ]
              [ Markdown.toHtml [] introText
              ]
          ]

introText = """
### About
This is an attempt to provide a link and comparision between similar concepts and operations and their usage between different functional programming languages . When learning and working with different languages and concepts, it's nice to have an easy way of looking up the implementations. Please contribute! I am not an expert in these languages. Please contribute to improvements with PR's and issues to help improve this reference.

#### Roadmap
* More languages
* More concepts
* Searching
* Improve layout/colors
* Improve deployment/webpack setup
* Other suggestions / improvements

#### Contributing
* [Check out contribution guidelines here for:](https://github.com/hakonrossebo/functional-programming-babelfish/blob/master/CONTRIBUTE.md)
 * Ways to contribute
 * Structure of json files
 * Running without Elm installed
 * Running with Elm installed

#### Other sites with related content
[https://github.com/hemanth/functional-programming-jargon](https://github.com/hemanth/functional-programming-jargon)
"""


showText : (List (Html.Attribute m) -> List (Html msg) -> a) -> Options.Property c m -> String -> a
showText elementType displayStyle text_ =
    Options.styled elementType [ displayStyle, Typo.left ] [ text text_ ]
