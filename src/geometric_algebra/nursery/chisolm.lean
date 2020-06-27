/-
Copyright (c) 2020 Utensil Song. All rights reserved.
Released under MIT license as described in the file LICENSE.
Authors: Utensil Song

This file is based on https://arxiv.org/abs/1205.5935
-/
import algebra.group.hom
import ring_theory.algebra
import data.real.basic
import data.complex.basic

import tactic.apply_fun
import tactic

universes u u₀ u₁

class geometric_algebra
-- Axiom 2: G contains a field G0 of characteristic zero which includes 0 and 1.
(G₀ : Type*) [field G₀]
-- Axiom 3: G contains a subset G1 closed under addition, 
-- and λ ∈ G0, v ∈ G1 implies λv = vλ ∈ G1.
(G₁ : Type*) [add_comm_group G₁] [vector_space G₀ G₁]
-- Axiom 1: G is a ring with unit. 
-- The additive identity is called 0 and the multiplicative identity is called 1.
(G : Type*) [ring G]
[algebra G₀ G]
:=
(f₁ : G₁ →+ G)
-- Axiom 4: The square of every vector is a scalar.
(vec_sq_scalar : ∀ v : G₁, ∃ k : G₀, f₁ v * f₁ v = algebra_map _ _ k )

namespace geometric_algebra

section

parameters
{G₀ : Type*} [field G₀]
{G₁ : Type*} [add_comm_group G₁] [vector_space G₀ G₁]
{G : Type*} [ring G] [algebra G₀ G] [geometric_algebra G₀ G₁ G]

def fᵥ : G₁ →+ G := f₁ G₀

def fₛ : G₀ →+* G := algebra_map G₀ G

lemma assoc : ∀ A B C : G, (A * B) * C = A * (B * C) := λ A B C, semigroup.mul_assoc A B C

lemma left_distrib : ∀ A B C : G, A * (B + C) = (A * B) + (A * C) := λ A B C, distrib.left_distrib A B C

lemma right_distrib : ∀ A B C : G, (A + B) * C = (A * C) + (B * C) := λ A B C, distrib.right_distrib A B C

def prod_vec (a b : G₁) := fᵥ a * fᵥ b

local infix `*ᵥ`:75 := prod_vec

def square (a : G) := a * a

def square_vec (a : G₁) := a *ᵥ a

local postfix `²`:80 := square

local postfix `²ᵥ`:80 := square_vec

def sym_prod (a b : G) := a * b + b * a

def sym_prod_vec (a b : G₁) := a *ᵥ b + b *ᵥ a

local infix `*₊`:75 := sym_prod

local infix `*₊ᵥ`:75 := sym_prod_vec


def is_orthogonal (a : G₁) (b : G₁) : Prop := sym_prod_vec a b = 0

theorem zero_is_orthogonal (a : G₁) : is_orthogonal 0 a := begin
  unfold is_orthogonal,
  unfold sym_prod_vec,
  unfold prod_vec,
  simp
end

class inductive blade (b : G): nat → Type u
| scalar :
  -- equals a scalar
  (∃ (k: G₀),
   b = fₛ k)
  → blade 0
| graded {n : ℕ} :
  -- or a product of orthogonal vectors
  (∃ (v : {l : vector G₁ (n + 1) // l.val.pairwise (λ a b, is_orthogonal a b ∧ a ≠ b)}),
   b = list.foldl (λ (b : G) (a : G₁), fᵥ a * b) (fᵥ v.val.head) v.val.tail.val)
  → blade(n + 1)

/-
  Symmetrised product of two vectors must be a scalar
-/
lemma vec_sym_prod_scalar:
∀ (a b : G₁), ∃ k : G₀, a *₊ᵥ b = fₛ k :=
assume a b,
have h1 : (a + b)²ᵥ = a²ᵥ + b²ᵥ + a *₊ᵥ b, from begin
  unfold square_vec sym_prod_vec prod_vec,
  rw add_monoid_hom.map_add fᵥ a b,
  rw left_distrib,
  repeat {rw right_distrib},
  abel,
end,
have vec_sq_scalar : ∀ v : G₁, ∃ k : G₀, v²ᵥ = fₛ k, from
  λ v, geometric_algebra.vec_sq_scalar(v),
exists.elim (vec_sq_scalar (a + b))
(
  assume kab,
  exists.elim (vec_sq_scalar a)
  (
    assume ka,
    exists.elim (vec_sq_scalar b)
    (
      assume kb,
      begin
        intros hb ha hab,
        rw [hb, ha, hab] at h1,
        use kab - ka - kb,
        repeat {rw ring_hom.map_sub},
        rw h1,
        abel,
      end
    )
  )
)

/- The scalars are 0-blades, as is the result of the vector/vector sym_prod -/
instance scalar_blade0 (a : G₀) : blade (fₛ a) 0 := blade.scalar (by use a)
instance vec_sym_prod_blade0 (a b : G₁) : blade (a *₊ᵥ b) 0 := blade.scalar (vec_sym_prod_scalar a b)

/- The vectors are 1-blades -/
instance vector_blade1 (a : G₁) : blade (fᵥ a) 1 := blade.graded (begin
  use ⟨(vector.cons a vector.nil), list.pairwise_singleton _ _⟩,
  unfold vector.nil,
  simp,
end)

end

end geometric_algebra
