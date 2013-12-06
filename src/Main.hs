{-# LANGUAGE OverloadedStrings #-}

-- | This module initializes the application's state and starts the warp server.
module Main where

import Control.Monad.Logger
import Control.Monad.Trans.Resource
import Database.Persist.Sql
import Yesod

import Config
import Dispatch ()
import Foundation
import Model (migrateAll)

main :: IO ()
main = do
    -- Initialize a connection to the database. We don't need to know what
    -- `persistConfig` actually is. Only the associated `PersistConfig`
    -- instance is needed.
    pool <- createPoolConfig persistConfig
    runResourceT $ runStderrLoggingT $ flip runSqlPool pool
        $ runMigration migrateAll
    -- warpEnv starts the Warp server over a port defined by an environment
    -- variable. To launch the app on a specific port use 'warp'.
    warpEnv $ App pool
