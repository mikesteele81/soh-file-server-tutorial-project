{-# LANGUAGE OverloadedStrings #-}

-- | This module initializes the application's state and starts the warp server.
module Main where

import Control.Concurrent.STM
import Data.IntMap
import Database.Persist.Sql
import Yesod

import Config
import Dispatch ()
import Foundation

main :: IO ()
main = do
    -- Initialize a connection to the database. We don't need to know what
    -- `persistConfig` actually is. Only the associated `PersistConfig`
    -- instance is needed.
    pool <- createPoolConfig persistConfig
    -- Initialize the filestore to an empty map.
    tstore <- atomically $ newTVar empty
    -- The first uploaded file should have an ID of 0.
    tident <- atomically $ newTVar 0
    -- warpEnv starts the Warp server over a port defined by an environment
    -- variable. To launch the app on a specific port use 'warp'.
    warpEnv $ App tident tstore pool
