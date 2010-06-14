-----------------------------------------------------------------------
--
-- Module      :  xmonad.hs
-- Copyright   :  (c) David Rosenberg
-- License     :  BSD3-style (see LICENSE)
--
-- Maintainer  :  rosenbergdm@uchicago.edu
-- Stability   :  unstable
-- Portability :  not portable,
--
-- customization for the xmonad window manager
-----------------------------------------------------------------------



import XMonad                          -- (0) core xmonad libraries
 
import qualified XMonad.StackSet as W  -- (0a) window stack manipulation
import qualified Data.Map as M         -- (0b) map creation
import Data.List (isPrefixOf, (\\))
import Data.Maybe (isNothing, isJust, catMaybes)
 
import System.Posix.Unistd

-- Hooks -----------------------------------------------------
 
import XMonad.Hooks.DynamicLog     -- (1)  for dzen status bar
  hiding (pprWindowSet)
import XMonad.Hooks.UrgencyHook    -- (2)  alert me when people use my nick
                                   --      on IRC
import XMonad.Hooks.ManageDocks    -- (3)  automatically avoid covering my
                                   --      status bar with windows
import XMonad.Hooks.ManageHelpers  -- (4)  for doCenterFloat, put floating
                                   --      windows in the middle of the
                                   --      screen
import XMonad.Hooks.RestoreMinimized
                                   -- (*)  Restore minimized windows
import XMonad.Util.Loggers

-- Layout ----------------------------------------------------
 
import XMonad.Layout.ResizableTile -- (5)  resize non-master windows too
import XMonad.Layout.Grid          -- (6)  grid layout
import XMonad.Layout.TwoPane
import XMonad.Layout.NoBorders     -- (7)  get rid of borders sometimes
                                   -- (8)  navigate between windows
import XMonad.Layout.WindowNavigation  --  directionally
import XMonad.Layout.Named         -- (9)  rename some layouts
import XMonad.Layout.PerWorkspace  -- (10) use different layouts on different WSs
import XMonad.Layout.WorkspaceDir  -- (11) set working directory
                                   --      per-workspace
import XMonad.Layout.Reflect       -- (13) ability to reflect layouts
import XMonad.Layout.MultiToggle   -- (14) apply layout modifiers dynamically
import XMonad.Layout.MultiToggle.Instances
                                   -- (15) ability to magnify the focused
                                   --      window
import qualified XMonad.Layout.Magnifier as Mag
import XMonad.Layout.Minimize      -- (*)  minimize windows
import XMonad.Layout.Gaps
 
-- Actions ---------------------------------------------------
 
import XMonad.Actions.CycleWS      -- (16) general workspace-switching
                                   --      goodness
import XMonad.Actions.CycleRecentWS
                                   -- (17) more flexible window resizing
import qualified XMonad.Actions.FlexibleManipulate as Flex
import XMonad.Actions.Warp         -- (18) warp the mouse pointer
import XMonad.Actions.Submap       -- (19) create keybinding submaps
import XMonad.Actions.Search       -- (20) some predefined web searches
import XMonad.Actions.WindowGo     -- (21) runOrRaise
import XMonad.Actions.UpdatePointer -- (22) auto-warp the pointer to the LR
                                    --      corner of the focused window
import XMonad.Actions.GridSelect
import XMonad.Actions.WithAll
import XMonad.Actions.SpawnOn
 
import XMonad.Actions.TopicSpace
import XMonad.Actions.DynamicWorkspaces
 
-- Prompts ---------------------------------------------------
 
import XMonad.Prompt                -- (23) general prompt stuff.
import XMonad.Prompt.XMonad
import XMonad.Prompt.Man            -- (24) man page prompt
import XMonad.Prompt.AppendFile     -- (25) append stuff to my NOTES file
import XMonad.Prompt.Ssh            -- (26) ssh prompt
import XMonad.Prompt.Input          -- (26) generic input prompt, used for
                                    --      making more generic search
                                    --      prompts than those in
                                    --      XMonad.Prompt.Search
import XMonad.Prompt.Workspace
 
-- Utilities -------------------------------------------------
 
import XMonad.Util.Loggers          -- (28) some extra loggers for my
                                    --      status bar
import XMonad.Util.EZConfig         -- (29) "M-C-x" style keybindings
import XMonad.Util.NamedScratchpad  -- (30) 'scratchpad' terminal
import XMonad.Util.Scratchpad
import XMonad.Util.Run              -- (31) for 'spawnPipe', 'hPutStrLn'
 
import Control.Monad (when)         -- (*)
import IO                           -- (*)
import System.Exit                  -- (*)
import XMonad.Hooks.EwmhDesktops    -- (*)
import XMonad.Hooks.ServerMode
import XMonad.Actions.Commands
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Themes
import XMonad.Layout.Tabbed

import Data.Traversable (traverse)
import XMonad.Actions.GridSelect

import XMonad.Layout.LayoutHints


                                                                -- (31)
main = do 
    dzen2 <- spawnPipe "tee /usr/local/share/dzen/dmpipe"
    secondaryLog <- spawnPipe "tee /usr/local/share/dzen/dmpipe2"
    gadgetBar <- spawnPipe "tee /usr/local/share/dzen/gpipe"
    host <- getHost
    xmonad $ ewmh $ rosenbergConfig host dzen2 secondaryLog gadgetBar




rosenbergConfig host dzen2 secondaryLog gadgetBar = myUrgencyHook $ defaultConfig {
      -- simple stuff
        terminal           = myTerminal host,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask host,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
      -- keys               = myNormalKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayoutHook,
        manageHook         = myManageHook
                              <+> manageHook defaultConfig,
        handleEventHook    = serverModeEventHook,
        logHook            = myLogHook host dzen2 gadgetBar
                              >>  updatePointer (Relative 0.95 0.95),
        startupHook        = myStartupHook >>
                             checkKeymap (rosenbergConfig host dzen2 secondaryLog gadgetBar)
                                         (myKeys host dzen2 secondaryLog gadgetBar)
        } 
        `additionalKeysP` (myKeys host dzen2 secondaryLog gadgetBar)

myUrgencyHook = withUrgencyHook dzenUrgencyHook
    { args      =   ["-bg", "yellow", "-fg", "black"  ] 
    , duration  =   2000000                       }

myEmailPrompt :: XPConfig -> [String] -> X()
myEmailPrompt c addrs = 
    inputPromptWithCompl c "To" (mkComplFunFromList addrs) ?+ \to ->
    inputPrompt c "Subject" ?+ \subj ->
    inputPrompt c "Body" ?+ \body ->
    io $ runProcessWithInput "mutt" ["-s", subj, "--", to] (body ++ "\n")
        >> return ()

myEventPrompt :: XPConfig -> X ()
myEventPrompt c = 
    inputPrompt c "Event string" ?+ \event ->
    inputPrompt c "Edit by hand" ?+ \edit ->
    runProcessWithInput "wyrd" ["-a", event] "\n"
        >> return()

data Host = Desktop | Laptop Bool -- ^ Does the laptop have a Windows key?
  deriving (Eq, Read, Show)
 
getHost :: IO Host
getHost = do
  hostName <- nodeName `fmap` getSystemID
  return $ case hostName of
    "lappy.local"                -> Laptop True
    "rosenbergdm.uchicago.edu"   -> Desktop
    _                            -> Desktop

-- withOtherOf2 :: (WorkspaceId -> WindowSet -> WindowSet) -> X ()
-- withOtherOf2 fn = do
--    tag <- gets $ screenWorkspace . (1 -) . W.screen . W.current . windowset
--    flip whenJust (windows . fn) tag
 
onOtherOf2 :: (WindowSet -> WindowSet) -> X ()
onOtherOf2 fn' = do
   wset <- gets windowset
   other <- screenWorkspace . (1 -) . W.screen . W.current $ wset
   windows $ W.view (W.currentTag wset) . fn' . maybe id W.view other

 
checkWS :: (String -> Bool) -> String -> X ()
checkWS p w = do cw <- gets (W.currentTag . windowset)
                 when (not $ p cw) $ (windows $ W.greedyView w)


myShell         = "/bin/zsh-dev"
myTerminal host = case host of Laptop _ -> "/usr/local/bin/urxvt -pe tabbed,macosx-clipboard -mod Mod1 -e " ++ myShell
                               Desktop  -> "/usr/local/bin/urxvt -pe tabbed,macosx-clipboard -mod Mod1 -e " ++ myShell

isVisible :: X (WindowSpace -> Bool)
isVisible = do
  vs <- gets (map (W.tag . W.workspace) . W.visible . windowset)
  return (\w -> (W.tag w) `elem` vs)


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"
myFont= "xft:Consolas-12"
myIconDir = "/usr/local/share/dzen/icons"
myDzenFGColor = "#555555"
myDzenBGColor = "#222222"
myNormalFGColor = "#ffffff"
myNormalBGColor = "#0f0f0f"
myFocusedFGColor = "#f0f0f0"
myFocusedBGColor = "#333333"
myUrgentFGColor = "#0099ff"
myUrgentBGColor = "#0077ff"
myIconFGColor = "#777777"
myIconBGColor = "#0f0f0f"
mySeperatorColor = "#555555"
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False
 
-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
-- myModMask       = mod4Mask
myNumLockMask   = 0

myModMask host  = case host of Laptop _ -> mod1Mask
                               Desktop  -> mod1Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["term-1","term-2","www-3","email-4","remote-5","irc-6","R-7","REdit-8","unk-9"]

myDefaultGaps   = [(30,0,0,0)]


-- Config for Prompt
rXPConfig :: XPConfig
rXPConfig = defaultXPConfig   { font              = "xft:Consolas-12"
                              , bgColor           = "Aquamarine3"
                              , fgColor           = "black"
                              , fgHLight          = "black"
                              , bgHLight          = "darkslategray4"
                              , borderColor       = "black"
                              , promptBorderWidth = 1
                              , position          = Top
                              , height            = 24
                              , defaultText       = []
                              }

rTheme :: Theme
rTheme = defaultTheme { inactiveBorderColor = "#000"
                        , activeBorderColor = myFocusedBorderColor
                        , activeColor = "aquamarine3"
                        , inactiveColor = "DarkSlateGray4"
                        , inactiveTextColor = "#222"
                        , activeTextColor = "#222"
                        , fontName = "xft:Consolas-10:bold"
                        , decoHeight = 18
                        , urgentColor = "#000"
                        , urgentTextColor = "#63b8ff"
                        }

 
-- GSConfig options:
myGSConfig = defaultGSConfig
    { gs_cellheight = 50
    , gs_cellwidth = 250
    , gs_cellpadding = 10
    --, gs_colorizer = ""
    --, gs_font = "" ++ myFont ++ ""
    --, gs_navigate = ""
    --, gs_originFractX = ""
    --, gs_originFractY = ""
    }
 
-- XPConfig options:
myXPConfig = defaultXPConfig
    { font = "" ++ myFont ++ ""
    , bgColor = "" ++ myNormalBGColor ++ ""
    , fgColor = "" ++ myNormalFGColor ++ ""
    , fgHLight = "" ++ myNormalFGColor ++ ""
    , bgHLight = "" ++ myUrgentBGColor ++ ""
    , borderColor = "" ++ myFocusedBorderColor ++ ""
    , promptBorderWidth = 1
    , position = Bottom
    , height = 16
    , historySize = 100
    --, historyFilter = ""
    --, promptKeymap = ""
    --, completionKey = ""
    --, defaultText = ""
    --, autoComplete = "KeySym"
    --, showCompletionOnTab = ""
    }

commands :: X [(String, X ())]
commands = defaultCommands


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.

-- myKeys h host dzen2 = myKeymap host (rosenbergConfig h host dzen2)
 
-- myKeymap host conf =
 
    -- mod-[1..],       Switch to workspace N
    -- mod-shift-[1..], Move client to workspace N
    -- mod-ctrl-[1..],  Switch to workspace N on other screen

myKeys host dzen2 secondaryLog gadgetBar = myKeymap host (rosenbergConfig host dzen2 secondaryLog gadgetBar)

myKeymap host c = 

    [ (m ++ "M-" ++ [k], f i)                                   -- (0)
        | (i, k) <- zip (XMonad.workspaces c) "1234567890\\" -- (0)
        , (f, m) <- [ (windows . W.view, "")                    -- (0a)
                    , (windows . W.shift, "S-")
                    , (\ws -> nextScreen >> (windows . W.view $ ws), "C-")
                    ]
    ]
    ++
    [ ("M-S-<Return>"                , spawn $ XMonad.terminal c)
    , ("M-x <Return>"                , spawn $ XMonad.terminal c)
    , ("M-p"                         , spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    , ("M-x v"                       , spawn "/usr/local/bin/urxvt -e /opt/local/bin/vim")
    , ("M-x S-v"                     , spawn "/usr/local/bin/urxvt -e /Applications/MacVim.app/Contents/MacOS/Vim")
    , ("M-x w"                       , spawn "/usr/local/bin/urxvt -e /usr/local/bin/elinks")
    , ("M-x e"                       , spawn "/usr/local/bin/urxvt -e '/opt/local/bin/alpine'")
    , ("M-S-g"                       , goToSelected myGSConfig)
    -- , ("M-g"                         , gridselectViewWorkspace myGSConfig W.view) 
    , ("M-`"                         , scratchpadSpawnActionCustom "/usr/local/bin/urxvt -e /usr/bin/zsh-4.3.10" )
    , ("M-S-e"                       , myEmailPrompt defaultXPConfig ["aap@uchicago.edu", "sarah.dymphna@gmail.com"])
    , ("M-x S-c"                       , spawn "/usr/local/bin/urxvt -e /opt/local/bin/wyrd")
    , ("M-x S-a"                       , myEventPrompt defaultXPConfig)
    , ("M-S-p"                       , spawn "gmrun")

    , ("M-S-c"                       , kill)

    , ("M-<Space>"                   , sendMessage NextLayout)

    , ("M-S-<Space>"                 , spawn "/usr/local/share/dzen/scripts/logwin.zsh && xdotool key --clearmodifiers 'Meta_L+F1'"  )
    , ("M-<F1>"                      , nextScreen )

    , ("M-n"                         , refresh)

    , ("M-<Tab>"                     , windows W.focusDown)

    , ("M-j"                         , windows W.focusDown)

    , ("M-k"                         , windows W.focusUp  )


    , ("M-<Return>"                   , windows W.swapMaster)

    , ("M-S-j"                       , windows W.swapDown  )

    , ("M-S-k"                       , windows W.swapUp    )

    , ("M-h"                         , sendMessage Shrink)

    , ("M-l"                         , sendMessage Expand)

    , ("M-t"                         , withFocused $ windows . W.sink)

    , ("M-."                         , sendMessage (IncMasterN 1))

    , ("M-,"                         , sendMessage (IncMasterN (-1)))

    , ("M-S-o"                       , sshPrompt defaultXPConfig )
    , ("M-o"                         , spawn "exe=`dmenu_ssh | dmenu \"$@\"` && eval /usr/local/bin/urxvt -e $exe")

    , ("M-S-q"                       , io (exitWith ExitSuccess))

    , ("M-m"                         , withFocused (\f -> sendMessage (MinimizeWin f)))
    , ("M-S-m"                       , sendMessage RestoreNextMinimizedWin)
    , ("M-q"                         , spawn "xmonad --recompile && xmonad --restart" )
    , ("M-x x"                       , commands >>= runCommand)
    , ("M-x S-x"                     , xmonadPrompt defaultXPConfig)
    

    
    , ("M-C-<Right>",   nextWS )                                    -- (16)
    , ("M-C-<Left>",   prevWS )                                    --  "
    , ("M-S-<Right>",   shiftToNext )                               --  "
    , ("M-S-<Left>",   shiftToPrev )                               --  "
    , ("M-S-C-<Right>", shiftToNext >> nextWS )                     --  "
    , ("M-S-C-<Left>", shiftToPrev >> prevWS )                     --  " 
    ]





------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging111
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- specify a custom layout hook.
myLayoutHook =
 
    -- automatically avoid overlapping my dzen status bar.
    avoidStrutsOn [U,D] $                                        -- (3)

    layoutHints $

    -- make manual gap adjustment possible.
    gaps (zip [U,D,L,R] [18, 0, 0, 0]) $
    -- gaps (zip [U,D,L,R] (30, 0, 0, 0)) $
    -- start all workspaces in my home directory, with the ability
    -- to switch to a new working dir.                          -- (10,11)
    workspaceDir "~" $
 
    -- navigate directionally rather than with mod-j/k
    configurableNavigation (navigateColor "#00aa00") $          -- (8)
 
    -- ability to toggle between fullscreen, reflect x/y, no borders,
    -- and mirrored.
    mkToggle1 NBFULL $                                  -- (14)
    mkToggle1 REFLECTX $                                -- (14,13)
    mkToggle1 REFLECTY $                                -- (14,13)
    mkToggle1 NOBORDERS $                               --  "
    mkToggle1 MIRROR $                                  --  "
 
    -- borders automatically disappear for fullscreen windows.
    smartBorders $                                              -- (7)
 
    -- "web" and "irc" start in Full mode and can switch to tiled...
    onWorkspaces ["web","irc"] (Full ||| myTiled) $               -- (10,0)
 
    -- ...whereas all other workspaces start tall and can switch
    -- to a grid layout with the focused window magnified.
    minimize (Full) |||
    minimize (myTiled) |||           -- resizable tall layout
    minimize (Mag.magnifier Grid) |||                                      -- (15,6)
    minimize (TwoPane (3/100) (1/2)) |||
    minimize (Tall 1 (3/100) (1/2)) 
 
-- use ResizableTall instead of Tall, but still call it "Tall".
myTiled = named "Tall" $ ResizableTall 1 0.03 0.5 []            -- (9,5) 
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--


-- Window rules aka Manage Hook {{{
myManageHook :: ManageHook
myManageHook = scratchpadManageHook (W.RationalRect 0.25 0.375 0.5 0.35) <+>
               (composeAll . concat $
    [ [ className =? c --> doCenterFloat        | c <- floats ],
      [ className =? w --> doShift "web-3"  | w <- webs]   ,
      [ className =? m --> doShift "mail-4" | m <- mails]  ,
      [ resource  =? "desktop_window"  --> doIgnore
      , title     =? "mutt"            --> doShift "mail-4"
      , title     =? "alpine"            --> doShift "mail-4"
      , title     =? "Save a Bookmark" --> doCenterFloat
      , isFullscreen                   --> doFullFloat
      , isDialog                       --> doCenterFloat
      ] ])
        <+> manageDocks -- make some space
            where floats = ["Xv", "xev", "Event Tester",  "xv", "Mplayer","Tsclient","VirtualBox","Gtklp","smc", "Xmessage", "xmessage", "Gxmessage", "gxmessage"]
                  webs   = ["Navigator","Gran Paradiso","Firefox", "Midori", "Minefield"]
                  games  = ["roguestar-gl","neverputt","neverball","wesnoth"]
                  mails  = ["Evolution", "Thunderbird-bin", "Shredder"]
-- }}}


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The fu:nction should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- myEventHook =  
myHandleEventHook = serverModeEventHook
-- restoreMinimizedEventHook <+> 

-- Status bars and logging {{{

gadgetPP :: Handle -> PP
gadgetPP p = defaultPP
    { ppOutput      = hPutStrLn p
    , ppTitle       = const ""
    , ppCurrent     = const ""
    , ppLayout      = const ""
    , ppVisible     = const ""
    , ppHidden      = const ""
    , ppHiddenNoWindows = const ""
    , ppExtras      = [ date "%a %b %d %I:%M %p"
                      , loadAvg
                      ]
    , ppSep         = ""
    , ppWsSep       = ""
    }

workspacePP :: Handle -> PP
workspacePP p = defaultPP
    { ppOutput      = hPutStrLn p
    , ppCurrent     = dzenColor "red" "black" . wrap "[" "]" 
    , ppVisible     = dzenColor "yellow" "black" . wrap "<" ">"
    , ppHiddenNoWindows = dzenColor "grey30" "black"
    , ppHidden      = dzenColor "grey70" "black"
    , ppUrgent      = dzenColor "orange" "black" . dzenStrip
    -- , ppVisible     = wrap "<" ">"
    -- , ppExtras      = [logTitle2]
    , ppSep         = " :: "
    , ppWsSep       = " "
    }
    --    , ppVisible     = dzenColor "blue" "#a8a3f7"
    --    , ppExtras      = [ date "%a %b %d %I:%M %p" ]
    --    , ppTitle       = shorten (case host of Laptop _ -> 45
    --                                            Desktop  -> 60)
    --    }

myLogHook host dzen2 gadgetBar = do
    ewmhDesktopsLogHook
    dynamicLogWithPP $ gadgetPP gadgetBar
    dynamicLogWithPP $ workspacePP dzen2

-- }}}



-- Startup hook {{{

myStartupHook = 
    return () -- >> checkKeymap rosenbergConfig myKeymap   
    -- do
    -- spawn "/usr/local/share/dzen/scripts/dzen_status.sh"
    -- spawn "/usr/local/share/dzen/scripts/dzen_wifi2.zsh"
    -- spawn "/usr/local/share/dzen/scripts/dzen_xmonad.zsh"
    -- spawn "/usr/local/share/dzen/scripts/dzendate.zsh"

-- }}}


-- goto :: Topic -> X ()
-- goto = switchTopic myTopicConfig
--  
-- promptedGoto :: X ()
-- promptedGoto = workspacePrompt myXPConfig goto
--  
-- promptedGotoOtherScreen :: X ()
-- promptedGotoOtherScreen =
--   workspacePrompt myXPConfig $ \ws -> do
--     nextScreen
--     goto ws
--  
-- promptedShift :: X ()
-- promptedShift = workspacePrompt myXPConfig $ windows . W.shift

