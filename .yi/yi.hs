{-# LANGUAGE TypeFamilies #-}

import Yi
-- Preamble
import Yi.Prelude

-- Import the desired keymap "template":
import Yi.Keymap.Emacs (keymap)
import Yi.Keymap.Cua (keymap)

-- Import the desired UI as needed. 
-- Some are not complied in, so we import none here.

-- import Yi.UI.Vty (start)
-- import Yi.UI.Cocoa (start)
-- import Yi.UI.Pango (start)

import Data.List (isPrefixOf, reverse, drop, length)
import Data.Monoid
import Yi.Hoogle
import Yi.Keymap.Keys
import Yi.String
import Maybe
import qualified Yi.Interact as I

import Yi.Modes (removeAnnots)
import qualified Yi.Mode.Haskell as Haskell
import qualified Yi.Syntax.Haskell as Haskell
import qualified Yi.Lexer.Haskell as Haskell
import qualified Yi.Syntax.Strokes.Haskell as Haskell
import Prelude (map)
import System.Environment
import Yi.Char.Unicode (greek, symbols)
import Control.Monad (replicateM_)
import Yi.Lexer.Alex (Tok)
import qualified Yi.Syntax.Tree as Tree
import Yi.Hoogle
import Yi.Buffer
import Yi.Keymap.Vim (viWrite, v_ex_cmds, v_top_level, v_ins_char, v_opts, tildeop, savingInsertStringB, savingDeleteCharB, exCmds, exHistInfixComplete')
import Yi.MiniBuffer (matchingBufferNames)
import qualified Yi.Keymap.Vim as Vim

myModetable :: [AnyMode]
myModetable = [
               AnyMode $ haskellModeHooks Haskell.cleverMode
              ,
               AnyMode $ haskellModeHooks Haskell.preciseMode
              ,
               AnyMode $ haskellModeHooks Haskell.fastMode
              ,
               AnyMode . haskellModeHooks . removeAnnots $ Haskell.cleverMode
              ,
               AnyMode $ haskellModeHooks Haskell.fastMode
              ,
               AnyMode . haskellModeHooks . removeAnnots $ Haskell.fastMode
              ]


haskellModeHooks :: (Foldable f) => Endom (Mode (f Haskell.TT))
haskellModeHooks mode =
  -- uncomment for shim:
  -- Shim.minorMode $ 
     mode {
        modeGetAnnotations = Tree.tokenBasedAnnots Haskell.tokenToAnnot,

        -- modeAdjustBlock = \_ _ -> return (),
        -- modeGetStrokes = \_ _ _ _ -> [],
        modeName = "my " ++ modeName mode,
        -- example of Mode-local rebinding
        modeKeymap = topKeymapA ^:
            ((char '\\' ?>> choice [char 'l' ?>>! Haskell.ghciLoadBuffer,
                                    char 'z' ?>>! Haskell.ghciGet,
                                    char 'h' ?>>! hoogle,
                                    char 'r' ?>>! Haskell.ghciSend ":r0",
                                    char 't' ?>>! Haskell.ghciInferType
                                   ])
                      <||)
     }

myConfig :: Config -> Config
myConfig cfg = cfg 
  { modeTable = fmap (onMode prefIndent) (myModetable ++ modeTable cfg)
  , defaultKm = Vim.mkKeymap extendedVimKeymap
  , startActions = startActions cfg ++ [makeAction (maxStatusHeightA %= 10 :: EditorM())]
  }

defaultUIConfig = configUI myOldConfig

-- Change the below to your needs, following the explanation in comments. See
-- module Yi.Config for more information on configuration. Other configuration
-- examples can be found in the examples directory. You can also use or copy
-- another user configuration, which can be found in modules Yi.Users.*

main :: IO ()
main = yi $ myConfig defaultVimConfig
 
myOldConfig = defaultVimConfig
  {
   
   -- Keymap Configuration
   defaultKm = defaultKm myOldConfig,

   -- UI Configuration
   -- Override the default UI as such: 
   startFrontEnd = startFrontEnd myOldConfig,
                    -- Yi.UI.Vty.start -- for Vty
   -- (can be overridden at the command line)
   -- Options:
   configUI = defaultUIConfig
     { 
       configFontSize = Nothing,
                        -- 'Just 10' for specifying the size.
       configTheme = configTheme defaultUIConfig,-- darkBlueTheme ,

                        -- configTheme defaultUIConfig,
                     --darkBlueTheme  -- Change the color scheme here.
       
       configWindowFill = '~' -- ' ' 
                          -- '~'    -- Typical for Vim
     }
  }


--------------------------------------------------------------------------
-- Custom Events 
--------------------------------------------------------------------------

increaseIndent :: BufferM()
increaseIndent =  modifyExtendedSelectionB Yi.Line $ mapLines ("  "++)

decreaseIndent :: BufferM()
decreaseIndent =  modifyExtendedSelectionB Yi.Line $ mapLines (drop 2)

prefIndent    :: Mode s -> Mode s
prefIndent m  =  m 
  { modeIndentSettings = IndentSettings 
      { expandTabs = True
      , shiftWidth  = 2
      , tabSize     = 2
      }
  }

mkInputMethod :: [(String,String)] -> Keymap
mkInputMethod xs = choice [pString i >> adjustPriority (negate (length i)) >>! savingInsertStringB o | (i,o) <- xs]

extraInput :: Keymap
extraInput = ctrl (char ']') ?>> mkInputMethod (greek ++ symbols)

-- need something better
unicodifySymbols :: BufferM ()
unicodifySymbols = modifyRegionB f =<< regionOfB unitViWORD
  where f x = fromMaybe x $ lookup x (greek ++ symbols)

extendedVimKeymap :: Proto Vim.ModeMap
extendedVimKeymap = Vim.defKeymap `override` \super self -> super
    { v_top_level = (deprioritize >> v_top_level super)
                    <|> (char ',' ?>>! viWrite)
                    <|> ((events $ map char "\\u") >>! unicodifySymbols)
                    <|> ((events $ map char "\\c") >>! withModeB modeToggleCommentSelection)
    , v_ins_char =
            (deprioritize >> v_ins_char super)
            -- On enter I always want to use the indent of previous line
            -- TODO: If the line where the newline is to be inserted is inside a
            -- block comment then the block comment should be "continued"
            -- TODO: Ends up I'm trying to replicate vim's "autoindent" feature. This 
            -- should be made a function in Yi.
            <|> ( spec KEnter ?>>! do
                    insertB '\n'
                    indentAsPreviousB
                )
            -- I want softtabs to be deleted as if they are tabs. So if the 
            -- current col is a multiple of 4 and the previous 4 characters
            -- are spaces then delete all 4 characters.
            -- TODO: Incorporate into Yi itself.
            <|> ( spec KBS ?>>! do
                    c <- curCol
                    line <- readRegionB =<< regionOfPartB Line Backward
                    sw <- indentSettingsB >>= return . shiftWidth
                    let indentStr = replicate sw ' '
                        toDel = if (c `mod` sw) /= 0
                                    then 1
                                    else if indentStr `isPrefixOf` reverse line 
                                        then sw
                                        else 1
                    adjBlock (-toDel)
                    replicateM_ toDel $ deleteB Character Backward
                )
            -- On starting to write a block comment I want the close comment 
            -- text inserted automatically.
            <|> choice 
                [ pString open_tag >>! do
                    insertN $ open_tag ++ " \n" 
                    indentAsPreviousB
                    insertN $ " " ++ close_tag
                    lineUp
                 | (open_tag, close_tag) <- 
                    [ ("{-", "-}") -- Haskell block comments
                    , ("/*", "*/") -- C++ block comments
                    ]
                ]
            <|> (adjustPriority (-1) >> extraInput)
    , v_opts = (v_opts super) { tildeop = True }
    , v_ex_cmds = exCmds [("b",
                       withEditor . switchToBufferWithNameE,
                       Just $ exHistInfixComplete' True matchingBufferNames)]
    }

