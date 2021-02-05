-- Base
import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

-- Data
import Data.Char (isSpace, toUpper)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory

-- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Prompt
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Prompt.Man
import XMonad.Prompt.Pass
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import Control.Arrow (first)

-- Text
import Text.Printf

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask       -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty"   -- Sets default terminal

myBrowser :: String
myBrowser = "brave "       -- Sets Brave as browser for tree select

myEditor :: String
myEditor = "emacsclient -c -a emacs "  -- Sets emacs as editor for tree select
-- myEditor = myTerminal ++ " -e vim "    -- Sets vim as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 2          -- Sets border width for windows

myNormColor :: String
myNormColor   = "#282c34"  -- Border color of normal windows

myFocusColor :: String
myFocusColor  = "#46d9ff"  -- Border color of focused windows

altMask :: KeyMask
altMask = mod1Mask         -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
          spawnOnce "lxsession &"
          spawnOnce "nitrogen --restore &"
          spawnOnce "picom --experimental-backends &"
          spawnOnce "nm-applet &"
          spawnOnce "volumeicon &"
          spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 0 --transparent true --alpha 0 --tint 0x282c34  --height 21 &"
          spawnOnce "/usr/bin/emacs --daemon &" -- emacs daemon for the emacsclient
          setWMName "LG3D"

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
magnify  = renamed [Replace "magnify"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 8
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 0
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
spirals  = renamed [Replace "spirals"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 8
           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| magnify
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                                 ||| spirals
                                 ||| threeCol
                                 ||| threeRow

myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myClickableWorkspaces :: [String]
myClickableWorkspaces = clickable . (map xmobarEscape)
               $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               -- $ [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..9] l,
                      let n = i ]

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces, and the names would very long if using clickable workspaces.
     [ className =? "firefox"                                           --> doShift ( myClickableWorkspaces !! 2 )
     , className =? "brave-browser"                                     --> doShift ( myWorkspaces !! 2 )
     , className =? "google-chrome"                                     --> doShift ( myWorkspaces !! 2 )
     , className =? "Gimp"                                              --> doShift ( myWorkspaces !! 8 )
     , className =? "Gimp"                                              --> doFloat
     , title =? "Oracle VM VirtualBox Manager"                          --> doFloat
     , className =? "VirtualBox Manager"                                --> doShift  ( myWorkspaces !! 4 )
     -- , (className =? "brave-browser" <&&> resource =? "Dialog")         --> doFloat  -- Float Brave Dialog
     -- , (className =? "firefox" <&&> resource =? "Dialog")               --> doFloat  -- Float Firefox Dialog
     -- , (className =? "google-chrome" <&&> resource =? "Dialog")         --> doFloat  -- Float Chrome Dialog
     ]

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.95

myKeys :: String -> [([Char], X ())]
myKeys home =
  [
    -- Xmonad
    ("M-C-r", spawn "xmonad --recompile") -- Recompiles xmonad
  , ("M-S-r", spawn "xmonad --restart")   -- Restarts xmonad
  , ("M-S-q", io exitSuccess)             -- Quits xmonad

   -- Run Prompt
  , ("M-d", spawn "rofi -show drun -config ~/.config/rofi/themes/dt-dmenu.rasi -display-drun \"Run: \" -drun-display-format \"{name}\"") -- Rofi

  -- Useful programs to have a keybinding for launch
  , ("M-<Return>", spawn (myTerminal ++ " -e bash"))
  , ("M-b", spawn (myBrowser))
  , ("M-M1-h", spawn (myTerminal ++ " -e htop"))

  -- Kill windows
  , ("M-S-c", kill1)     -- Kill the currently focused client
  , ("M-S-a", killAll)   -- Kill all windows on current workspace

  -- Workspaces
  , ("M-.", nextScreen)  -- Switch focus to next monitor
  , ("M-,", prevScreen)  -- Switch focus to prev monitor

  -- Floating windows

  -- Increase/decrease spacing (gaps)

  -- Grid Select (CTR-g followed by a key)

  -- Tree Select

  -- Windows navigation
  , ("M-m", windows W.focusMaster)  -- Move focus to the master window
  , ("M-j", windows W.focusDown)    -- Move focus to the next window
  , ("M-k", windows W.focusUp)      -- Move focus to the prev window
  , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
  , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
  , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
  , ("M-<Backspace>", promote)      -- Moves focused window to master, others maintain order
  , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
  , ("M-C-<Tab>", rotAllDown)       -- Rotate all the windows in the current stack

  -- Layouts
  , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout
  , ("M-C-M1-<Up>", sendMessage Arrange)
  , ("M-C-M1-<Down>", sendMessage DeArrange)
  , ("M-f", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
  , ("M-S-<Space>", sendMessage ToggleStruts)     -- Toggles struts
  , ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder

  -- Increase/decrease windows in the master pane or the stack
  , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
  , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
  , ("M-C-<Up>", increaseLimit)                   -- Increase number of windows
  , ("M-C-<Down>", decreaseLimit)                 -- Decrease number of windows

  -- Window resizing
  , ("M-h", sendMessage Shrink)                   -- Shrink horiz window width
  , ("M-l", sendMessage Expand)                   -- Expand horiz window width
  , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
  , ("M-M1-k", sendMessage MirrorExpand)          -- Exoand vert window width

  -- Sublayouts
  -- This is used to push windows to tabbed sublayouts, or pull them out of it.
  , ("M-C-h", sendMessage $ pullGroup L)
  , ("M-C-l", sendMessage $ pullGroup R)
  , ("M-C-k", sendMessage $ pullGroup U)
  , ("M-C-j", sendMessage $ pullGroup D)
  , ("M-C-m", withFocused (sendMessage . MergeAll))
  , ("M-C-u", withFocused (sendMessage . UnMerge))
  , ("M-C-/", withFocused (sendMessage . UnMergeAll))
  , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab
  , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab

  -- Multimedia Keys
  , ("<XF86AudioPlay>", spawn (myTerminal ++ "mocp --play"))
  , ("<XF86AudioPrev>", spawn (myTerminal ++ "mocp --previous"))
  , ("<XF86AudioNext>", spawn (myTerminal ++ "mocp --next"))
  , ("<XF86AudioMute>",   spawn "amixer set Master toggle")
  , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
  , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
  , ("<XF86HomePage>", spawn myBrowser)
  , ("<XF86Search>", safeSpawn myBrowser ["https://www.duckduckgo.com/"])
  , ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
  , ("<XF86Eject>", spawn "toggleeject")
  , ("<Print>", spawn "scrotd 0")
  ]

main :: IO ()
main = do
    home <- getHomeDirectory
    xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/.xmobarrc"
    xmonad $ ewmh def
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks
        -- Run xmonad commands from command line with "xmonadctl command". Commands include:
        -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
        -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
        -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
        -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
        , handleEventHook    = serverModeEventHookCmd
                               <+> serverModeEventHook
                               <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                               <+> docksEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook
        , workspaces         = myClickableWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                    { ppOutput          = hPutStrLn xmproc
                    , ppCurrent         = xmobarColor "#98be65" "" . wrap "[" "]" -- Current workspace in xmobar
                    , ppVisible         = xmobarColor "#98be65" ""                -- Visible but not current workspace
                    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""  -- Hidden workspaces in xmobar
                    , ppHiddenNoWindows = xmobarColor "#c792ea" ""                -- Hidden workspaces (no windows)
                    , ppTitle           = xmobarColor "#b3afc2" "" . shorten 60   -- Title of active window in xmobar
                    , ppSep             = "<fc=#666666> <fn=1>|</fn> </fc>"       -- Separators in xmobar
                    , ppUrgent          = xmobarColor "#C45500" "" . wrap "!" "!" -- Urgent workspace
                    , ppExtras          = [windowCount]                           -- # of windows current workspace
                    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                    }
        } `additionalKeysP` myKeys home
