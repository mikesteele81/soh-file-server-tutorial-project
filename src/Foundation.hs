{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

-- | This module is home to the foundation type, where all application state
-- is stored.
module Foundation where

import Data.Default
import Database.Persist.Sql
import Text.Hamlet
import Yesod
import Yesod.Default.Util

-- The Config module is needed so that we can integrate 'persistent' with
-- 'yesod-core'.
import Config
import Model

-- | This is the application\'s "foundation" type. The first argument to 'App'
-- is the next identifier to be used when a new file is uploaded. The second
-- is a mapping from identifiers to files.
data App = App
    { connPool :: ConnectionPool
    -- ^Handle to an open database connection. This is initialized in `main`.
    -- It is accessed by the `YesodPersist` instance so that we can call
    -- `runDB` to execute database queries.
    }

instance Yesod App where
  -- This method is customized so that global CSS styling can be defined in
  -- "templates/default-layout.cassius". This code is very similar to Yesod's
  -- scaffolding website.
  defaultLayout widget = do
    pc <- widgetToPageContent $ $(widgetFileNoReload def "default-layout")
    withUrlRenderer $(hamletFile "templates/default-layout-wrapper.hamlet")

-- Making 'App' an instance of RenderMessage is required for Yesod's form
-- controls.
instance RenderMessage App FormMessage where
  renderMessage _ _ = defaultFormMessage

-- YesodPersist is used so that we can call `runDB` from within handler
-- actions. It is almost possible to be defined automatically, so there
-- is a `defaultRunDB` utility function to help us. We only need to tell
-- it where to look for our persintent configuration and connection pool.
instance YesodPersist App where
  type YesodPersistBackend App = SqlBackend
  runDB action = defaultRunDB (const persistConfig) connPool action

-- We won't make use of `YesodPersistRunner` in this application. Like
-- `YesodPersist`, it is almost possible to be defined automatically.
instance YesodPersistRunner App where
  getDBRunner = defaultGetDBRunner connPool

-- Calling 'mkYesodData' generates boilerplate code and type aliases for
-- interfacing our foundation type with Yesod. The "Dispatch" module contains
-- a call to 'mkYesodDispatch', which performs the other half of boilerplate
-- generation.
mkYesodData "App" $(parseRoutesFile "config/routes")

-- | Generate a list of file's and identifiers. This is used on the main page
-- to generate links to preview pages.
getList :: Handler [Entity StoredFile]
getList = runDB $ selectList [] []

-- | Add a new file to the 'Store'.
addFile :: StoredFile -> Handler ()
addFile file = runDB $ insert_ file

-- | Retrieve a file from the application\'s 'Store'. In the case where the
-- file does not exist a 404 error will be returned.
getById :: Key StoredFile -> Handler StoredFile
getById ident = do
    mfile <- runDB $ get ident
    case mfile of
      Nothing -> notFound
      Just file -> return file
