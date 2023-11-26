{- HLINT ignore "Use lambda-case" -}

module Main (main) where

import Language.Haskell.Parser
import Language.Haskell.Syntax
import Language.Haskell.Pretty
import System.Directory
import Control.Monad (forM)
import Control.Arrow ((>>>))
import System.Environment (getArgs)

-- getName :: Name l -> String
-- getName (Ident _ str) = str
-- getName (Symbol _ str) = str

-- main :: IO ()
-- main = do
--     mdle <- fromParseResult . parseModule <$> readFile "hello.hs"
--     let Module _srcSpanInfo _maybeModuleHead _pragmas _imports decls = mdle
--     forM_ decls $ \decl -> case decl of
--         TypeSig _l _names typel -> putStrLn "Type Signature\n" >> print typel >> putStrLn "\n---\n"
--         FunBind _l matches -> do
--             putStrLn "Function Binding\n" 
--             forM_ matches (\match -> case match of
--                 Match _l name pats rhs _binds -> putStrLn "Match" >> print (getName name) >> print pats >> print rhs >> putStrLn "\n---\n"
--                 InfixMatch _l _pat name _pats _rhs _binds -> putStrLn "InfixMatch\n" >> print name)
--         coisa -> print coisa

-- https://hackage.haskell.org/package/haskell-src-exts-1.23.1/docs/Language-Haskell-Exts-Syntax.html#t:Pat


undefineds :: HsExp -> [HsExp]
undefineds (HsLit _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsVar _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsCon _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsList _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsTuple exprs) = HsVar (UnQual (HsIdent "undefined")) : [ HsTuple $ take i exprs ++ [x] ++ drop (i + 1) exprs | i <- [0..length exprs - 1], x <- undefineds (exprs !! i) ]
undefineds (HsInfixApp exp1 (HsQConOp conop) exp2) =
    map (\x -> HsInfixApp x (HsQConOp conop) exp2) (undefineds exp1)
    ++
    [HsInfixApp exp1 (HsQVarOp (UnQual (HsIdent "undefined"))) exp2]
    ++
    map (HsInfixApp exp1 (HsQConOp conop)) (undefineds exp2)
undefineds (HsInfixApp exp1 (HsQVarOp (UnQual hn)) exp2) =
    map (\x -> HsInfixApp x (HsQVarOp (UnQual hn)) exp2) (undefineds exp1)
    ++
    [HsInfixApp exp1 (HsQVarOp (UnQual (HsIdent "undefined"))) exp2]
    ++
    map (HsInfixApp exp1 (HsQVarOp (UnQual hn))) (undefineds exp2)
undefineds (HsApp exp1 exp2) =
    map (`HsApp` exp2) (undefineds exp1)
    ++
    map (HsApp exp1) (undefineds exp2)
undefineds (HsLeftSection exp1 op) =
    map (`HsLeftSection` op) (undefineds exp1)
    ++
    [HsLeftSection exp1 (HsQVarOp (UnQual (HsIdent "undefined")))]
undefineds (HsRightSection op exp2) =
    map (HsRightSection op) (undefineds exp2)
    ++
    [HsRightSection (HsQVarOp (UnQual (HsIdent "undefined"))) exp2]
undefineds (HsCase expr alts) =
    map (`HsCase` alts) (undefineds expr)
    ++ map (HsCase expr) (undefinedsCase alts)
undefineds (HsIf exp1 exp2 exp3) =
    map (\x -> HsIf x exp2 exp3) (undefineds exp1)
    ++
    map (\x -> HsIf exp1 x exp3) (undefineds exp2)
    ++
    map (HsIf exp1 exp2) (undefineds exp3)
undefineds (HsLet binds expr) =
    map ((`HsLet` expr) . undefinedsDecl) binds
    ++
    map (HsLet binds) (undefineds expr)
undefineds (HsDo stmts) = map (HsDo . undefinedStmt) stmts
undefineds (HsEnumFrom _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsEnumFromTo _ _) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsEnumFromThenTo {}) = [HsVar (UnQual (HsIdent "undefined"))]
undefineds (HsParen exps) = map HsParen (undefineds exps)
undefineds (HsListComp expr stmts) =
    map (`HsListComp` stmts) (undefineds expr)
    ++
    [HsListComp expr (take i stmts ++ [x] ++ drop (i + 1) stmts) | i <- [0 .. length stmts - 1], x <- undefinedStmt (stmts !! i)]
undefineds x = error $ show [x]

undefinedsCase :: [HsAlt] -> [[HsAlt]]
undefinedsCase [] = []
undefinedsCase (HsAlt srcLoc pat (HsUnGuardedAlt expr) binds : xs) =
    map (\x -> HsAlt srcLoc x (HsUnGuardedAlt expr) binds : xs) (undefinedsPatterns pat)
    ++ map (\x -> HsAlt srcLoc pat (HsUnGuardedAlt x) binds : xs) (undefineds expr)
    ++ map (\x -> HsAlt srcLoc pat (HsUnGuardedAlt expr) binds : x) (undefinedsCase xs)

undefinedsPatterns :: HsPat -> [HsPat]
undefinedsPatterns (HsPVar _) = [HsPVar (HsIdent "undefined")]
undefinedsPatterns (HsPLit _) = [HsPVar (HsIdent "undefined")]
undefinedsPatterns (HsPApp n []) = [HsPVar (HsIdent "undefined")]
undefinedsPatterns (HsPApp n pats) = HsPVar (HsIdent "undefined") : HsPApp (UnQual (HsIdent "undefined")) pats : map (HsPApp n) (undefinedsPatternsT pats)
undefinedsPatterns (HsPTuple t) = HsPVar (HsIdent "undefined") : map HsPTuple (tail $ undefinedsPatternsT t)
undefinedsPatterns HsPWildCard = []
undefinedsPatterns x = error $ show x

undefinedsPatternsT :: [HsPat] -> [[HsPat]]
undefinedsPatternsT [] = []
undefinedsPatternsT [p] = [[p], [HsPVar (HsIdent "undefined")]]
undefinedsPatternsT (p:pats) = (p:pats) : (HsPVar (HsIdent "undefined") : pats) : map (p :) (tail $ undefinedsPatternsT pats)

undefinedsGuards :: [HsGuardedRhs] -> [[HsGuardedRhs]]
undefinedsGuards [] = []
undefinedsGuards (HsGuardedRhs srcLoc exp1@(HsVar (UnQual (HsIdent "otherwise"))) exp2 : xs) =
    map (\x -> HsGuardedRhs srcLoc exp1 x : xs) (undefineds exp2)
    ++ map (\x -> HsGuardedRhs srcLoc exp1 exp2 : x) (undefinedsGuards xs)
undefinedsGuards (HsGuardedRhs srcLoc exp1 exp2 : xs) =
    map (\x -> HsGuardedRhs srcLoc x exp2 : xs) (undefineds exp1)
    ++ map (\x -> HsGuardedRhs srcLoc exp1 x : xs) (undefineds exp2)
    ++ map (\x -> HsGuardedRhs srcLoc exp1 exp2 : x) (undefinedsGuards xs)

undefinedStmt :: HsStmt -> [HsStmt]
undefinedStmt (HsGenerator srcLoc pat expr) = HsGenerator srcLoc (HsPVar (HsIdent "undefined")) expr : map (HsGenerator srcLoc pat) (undefineds expr)
undefinedStmt (HsQualifier expr) = map HsQualifier (undefineds expr)
undefinedStmt (HsLetStmt binds) = error $ show binds

-- TODO
undefinedsDecl :: HsDecl -> [HsDecl]
undefinedsDecl x = [x]

combinations :: [(HsMatch, [HsMatch])] -> [[HsMatch]]
combinations [] = [[]]
combinations ((e, unds) : xs) =
    let
        others = map fst xs
        r = combinations xs
    in
        map (e :) r ++ [ und : others | und <- unds]

mergeDecls :: [Either [HsDecl] HsDecl] -> [[HsDecl]]
mergeDecls [] = [[]]
mergeDecls (Left xs : t) = let rs = mergeDecls t in [ x : head rs | x <- xs ] ++ [ head xs : r | r <- tail rs ]
mergeDecls (Right x : t) = [ x : r | r <- mergeDecls t]

main :: IO ()
main =
    getArgs >>= \args ->
    if length args /= 1 then
        error "Missing required argument <filename.hs>."
    else do
        ast <- parseModule <$> readFile (head args)
        print ast
        case ast of
            ParseOk (HsModule _srcLoc _modName _maybeExportSpec imports declars) -> do
                createDirectoryIfMissing False "variants"
                forM declars $ \decl ->
                    case decl of
                        HsFunBind matches ->
                            return $ Left $ map HsFunBind $ combinations $ map (\match ->
                                case match of
                                    HsMatch srcLoc funcName pats (HsUnGuardedRhs uexp) binds ->
                                        (HsMatch srcLoc funcName pats (HsUnGuardedRhs uexp) binds, map (\x -> HsMatch srcLoc funcName pats (HsUnGuardedRhs x) binds) (undefineds uexp))
                                    HsMatch srcLoc funcName pats (HsGuardedRhss guards) binds ->
                                        (HsMatch srcLoc funcName pats (HsGuardedRhss guards) binds, map (\x -> HsMatch srcLoc funcName pats (HsGuardedRhss x) binds) (undefinedsGuards guards))) matches
                        outracoisa -> return $ Right outracoisa
                >>= (mergeDecls
                    >>> zip [(0::Int)..]
                    >>> mapM_ (\(i, decls) -> do
                        putStrLn "------------------"
                        putStrLn $ "Decl " ++ show i
                        putStrLn $ unlines $ map prettyPrint decls
                        if i == 0 then
                            -- writeFile "variants/original.hs" (unlines $ map prettyPrint imports)
                            -- >> appendFile "variants/original.hs" (unlines $ map prettyPrint decls)
                            return ()
                        else
                            writeFile ("variants/v" ++ show i ++ ".hs") (unlines $ map prettyPrint imports)
                            >> appendFile ("variants/v" ++ show i ++ ".hs") (unlines $ map prettyPrint decls)))
                        {-
                        if i == 0 then
                            writeFile "variants/original.hs" $ prettyPrint $ HsModule srcLoc modName maybeExportSpec imports decls
                        else
                            writeFile ("variants/v" ++ show i ++ ".hs") $ prettyPrint $ HsModule srcLoc modName maybeExportSpec imports decls))
                        -}
            ParseFailed srcLoc msg -> do
                putStrLn "Parse failed - check if the file doesn't contain any non-type errors."
                putStrLn $ "Error at " ++ show srcLoc
                putStrLn msg

