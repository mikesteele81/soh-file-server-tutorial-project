{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

-- | This module generates boilerplate code to integrate Yesod's routing
-- facilities with user-defined handler actions.
module Dispatch where

import Yesod

import Foundation
import Handler.Download
import Handler.Home
import Handler.Preview

-- The resourcesApp binding is generated by 'mkYesodData' in the "Foundation"
-- module.
mkYesodDispatch "App" resourcesApp