{-# LANGUAGE OverloadedStrings #-}
module Main where

import Crypto.BCrypt (validatePassword)
import Control.Monad (guard)
import Control.Monad.IO.Class (MonadIO)
import Data.Aeson (object, (.=))
import Data.ByteString (ByteString)
import Data.List (lookup)
import Data.Maybe (listToMaybe)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Encoding as Text
import qualified Database.MySQL.Simple as MySQL
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import Text.Mustache
import Web.Spock
import Web.Spock.Config

findCredential :: MonadIO m => ActionCtxT ctx m (Maybe (Text, Text))
findCredential = do
  username <- param "username"
  password <- param "password"
  pure $ (,) <$> username <*> password

validateCredential :: (Text, Text) -> ActionCtxT ctx (WebStateM MySQL.Connection sess st) (Maybe Int)
validateCredential (username, password) = do
  user <- runQuery $ \conn -> do
    results <- MySQL.query conn "SELECT id, password FROM user WHERE username = ?" (MySQL.Only (Text.encodeUtf8 username))
    pure $ (listToMaybe results :: Maybe (Int, ByteString))
  pure $ do
    (userId, passhash) <- user
    guard $ validatePassword passhash (Text.encodeUtf8 password)
    pure userId

main :: IO ()
main = do
  -- データベースの設定
  let mysqlConnect = MySQL.connect MySQL.defaultConnectInfo {MySQL.connectDatabase = "login_sample"}
      dbConn = ConnBuilder mysqlConnect MySQL.close (PoolCfg 1 1 60)

  -- stache の設定
  template <- compileMustacheDir "index" "views/"
  let render pname = TL.toStrict . renderMustache (template {templateActual = pname})

  -- Spock の設定と実行
  spockCfg <- defaultSpockCfg (Nothing :: Maybe Int) (PCConn dbConn) ()
  runSpock 8080 $ fmap (logStdoutDev.) $ spock spockCfg $ do

    -- GET /
    get root $ do
      maybeUserId <- readSession
      case maybeUserId of
        Nothing -> redirect "/login"
        Just userId -> html (render "index" (object ["text" .= (Text.pack (show userId))]))

    -- GET /logout
    get "logout" $ writeSession Nothing >> redirect "/login"

    -- GET /login
    get "login" $ html (render "login" (object []))

    -- POST /login
    post "login" $ do
      credential <- findCredential
      case credential of
        Nothing -> redirect "/login"
        Just (username, password) -> do
          maybeUserId <- validateCredential (username, password)
          case maybeUserId of
            Nothing -> redirect "/login"
            Just userId -> writeSession (Just userId) >> redirect "/"

