{-# LANGUAGE RankNTypes #-}
-- cover all cases!
{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}
-- warn about incomplete patterns v2
{-# OPTIONS_GHC -fwarn-incomplete-uni-patterns #-}
-- write all your toplevel signatures!
{-# OPTIONS_GHC -fwarn-missing-signatures #-}
-- use different names!
{-# OPTIONS_GHC -fwarn-name-shadowing #-}
-- use all your pattern matches!
{-# OPTIONS_GHC -fwarn-unused-matches #-}

module HOF where

import Prelude hiding (const, curry, id, log, map, on, swap, uncurry, until, ($), (.))
import Language.Haskell.TH (inferR)

-- WARNING:
-- remind about github classrooms -> in-class && HW00
-- say soon HW01?
--
-- NOTE: talk about
-- @-bindings
-- guards
-- let
-- where
-- ?
-- lambdas, desugar function def, HOF(arguments), tuple-map hof example, currying, polymorphism
-- sections (why (+) makes sense)
-- logging as example for DI via higher order functions
-- ($), (.)
-- what does "combinator" mean?
--
-- TODO: implement
-- applyTwice :: (a -> a) -> a -> a
-- id
-- ($) - maybe go back to solutions and start rewriting stuff using ($)?
-- `infixr 0 $` (draw AST of an operator-heavy expr?)
-- (.)


--($)
--($) ::  
($) :: (t1 -> t2) -> t1 -> t2
f $ x = f x 
infixr 0 $

-- TODO: live
data Tuple a b = MkTuple a b
  deriving (Show)

sumTuple :: Tuple Int Int -> Int
sumTuple (MkTuple x y)= x + y

-- TODO: implement, used in examples
fstTuple :: Tuple a b -> a
fstTuple (MkTuple x _) = x

sndTuple :: Tuple a b -> b
sndTuple (MkTuple _ y) = y

-- EXERCISE
-- Take two arguments and return the first.
-- This is called const because if we think of it as a function
-- on one argument x, it returns a function that when called, always returns x
-- It is also practically always used partially applied.
-- EXAMPLES
-- >>> const 5 6
-- 5
-- >>> applyTwice (const 42) 1337
-- 42
const :: a -> b -> a
const x _ = x

-- EXERCISE
-- Compose two functions, very useful very often
-- there's a builtin (.) for this - the dot mimics mathematical notation f o g
-- EXAMPLES
-- >>> let f = compose (+3) (*5) in f 4
-- 23
-- >>> let f = compose (*5) (+5) in f 1
-- 30
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)

-- Play around with the syntax
(.) :: (b -> c) -> (a -> b) -> a -> c
(.) = compose

-- EXERCISE
-- Iterate a function f n times over a base value x.
-- EXAMPLES
-- >>> iterateN (+1) 2 10
-- 12
-- >>> iterateN (*2) 2 10
-- 2048
iterateN :: (a -> a) -> a -> Integer -> a
iterateN f x y = if y == 0 
  then x
  else iterateN f (f x) (y - 1)

-- EXERCISE
-- Swap the two elements of a tuple
-- EXAMPLES
-- >>> swap $ MkTuple 42 69
-- MkTuple 69 42
swap :: Tuple a b -> Tuple b a
swap (MkTuple x y) = MkTuple y x

-- EXERCISE
-- Apply a function to only the first component of a tuple
-- EXAMPLES
-- >>> first (*2) $ MkTuple 1 1337
-- MkTuple 2 1337
first :: (a -> b) -> Tuple a c -> Tuple b c
first f (MkTuple x y)= MkTuple (f x) y

-- EXERCISE
-- Convert a function operating on a tuple, to one that takes two arguments.
-- Called Curry after Haskell Curry - inventor of lambda calculus.
-- (Guess where the language gets its name from, ексди)
-- EXAMPLES
-- >>> curry (\(MkTuple x y) -> x * y) 23 4
-- 92
curry :: (Tuple a b -> c) -> a -> b -> c
curry f x y = f (MkTuple x y)

-- EXERCISE
-- Convert a two argument function, to one that takes a Tuple.
-- EXAMPLES
-- >>> uncurry (\x y -> x + y) $ MkTuple 23 1
-- 24
uncurry :: (a -> b -> c) -> Tuple a b -> c
uncurry f (MkTuple x y) = f x y

-- EXERCISE
-- > p `on` f
-- Implement a combinator that allows you to "preapply" a function f on the arguments of a function p
-- EXAMPLES
-- >>> let maxOnFirst = max `on` fstTuple in maxOnFirst (MkTuple 1 20) (MkTuple 2 100000)
-- 2

-- >>> let maxOnSum = max `on` sumTuple in maxOnSum (MkTuple 20 39) (MkTuple 12 34)
-- 59
on :: (b -> b -> c) -> (a -> b) -> a -> a -> c
on f g x y =  f (g x) (g y)

-- EXERCISE
-- Execute a function, until the result starts sastifying a given predicate
-- EXAMPLES
-- >>> until (>1000) (*7) 4
-- 1372
until :: (a -> Bool) -> (a -> a) -> a -> a
until p g x = if p x 
  then x
  else until p g (g x) 

-- EXERCISE
-- Apply two different functions to the two different arguments of a tuple
-- Think about what the type should be.
-- >>> mapTuple (+1) (+2) (MkTuple 1 2)
-- MkTuple 2 4
mapTuple :: (a -> c) -> (b -> d) -> Tuple a b -> Tuple c d
mapTuple f g (MkTuple x y) = MkTuple (f x) (g y)


data Nat
  = Zero
  | Succ Nat
  deriving (Show)

-- EXERCISE
-- Look at addNat and multNat from last time.
--
addNat :: Nat -> Nat -> Nat
addNat Zero m = m
addNat (Succ n) m = Succ (addNat n m)

multNat :: Nat -> Nat -> Nat
multNat Zero _ = Zero
multNat (Succ n) m = addNat m (multNat n m)

-- They look very similar.
-- Can you implement a general enough higher-order function (called foldNat here), such that you can then use to
-- implement both of addNat and multNat by passing suitable arguments? What are those arguments?
--

foldNat :: a -> (a -> a) -> Nat -> a
foldNat x _ Zero     = x
foldNat x f (Succ n) = f (foldNat x f n)

-- >>> addNat' (Succ Zero) (Succ Zero)
-- Succ (Succ Zero)
addNat' :: Nat -> Nat -> Nat
addNat' x y = foldNat y Succ x

-- >>> multNat' (Succ Zero) (Succ (Succ Zero))
-- Succ (Succ Zero)
multNat' :: Nat -> Nat -> Nat
multNat' x y = foldNat Zero (addNat' y) x

--
-- If your function is "good enough" you should also be able to implement exponentiation using it.
-- expNat :: Nat -> Nat -> Nat
-- expNat = undifined
  
--
-- Can you also implement
-- natToInteger :: Nat -> Integer
-- natToInteger = undefined
-- using your function? If not, modify your function so you can.
--
-- Can you also implement the following "predecessor" function using it? Yes/no, and why?
--
-- predNat :: Nat -> Nat
-- predNat Zero = Zero
-- predNat (Succ n) = n
--
-- If not, can you think of a foldNat' :: ??? with a different type signature, which would allow you to implement predNat?
