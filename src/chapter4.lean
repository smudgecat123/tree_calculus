import tactic chapter3

open chapter3

namespace chapter4

  -----------------------------------------------------------------------------------

  def is_elem : char â ð' â Prop
  | x (#y) := y = x
  | x â¢ := false
  | x (tâ¦u) := is_elem x t â¨ is_elem x u

  instance elem_decidable {x} {t} : decidable (is_elem x t) := begin
    induction t,
    case node {
      left,
      intro h,
      cases h,
    },
    case app : tâ tâ hâ hâ {
      cases hâ,
        cases hâ,
          left,
          intro h,
          cases h,
          apply hâ,
          assumption,
          apply hâ,
          assumption,
        right,
        right,
        assumption,
      cases hâ,
        right,
        left,
        assumption,
      right,
      right,
      assumption,
    },
    case ref {
      rw is_elem,
      exact eq.decidable t x,
    },
  end

  -----------------------------------------------------------------------------------

  def subst' : char â ð' â ð' â ð'
  | x u (#y) := if y = x then u else #y
  | x u â¢ := â¢
  | x u (sâ¦t) := (subst' x u s) â¦ (subst' x u t)

  lemma subst'_red_t {x} {u tâ tâ} (h : tâ â¦ tâ) : subst' x u tâ â subst' x u tâ := begin
    apply eqv_gen.rel,
    induction h,
    case kernel : y' z' {
      repeat {
        rw subst'
      },
      apply natree.pre.reduces.kernel,
    },
    case stem : x' y' z' {
      repeat {
        rw subst'
      },
      apply natree.pre.reduces.stem,
    },
    case fork : w' x' y' z' {
      repeat {
        rw subst'
      },
      apply natree.pre.reduces.fork,
    },
    case left {
        repeat {
        rw subst'
      },
      apply natree.pre.reduces.left,
      assumption,
    },
    case right {
        repeat {
        rw subst'
      },
      apply natree.pre.reduces.right,
      assumption,
    },
  end

  lemma subst'_red_u {x} {uâ uâ t} (h : uâ â¦ uâ) : subst' x uâ t â subst' x uâ t := begin
    induction t,
    case node {
      reflexivity,
    },
    case app : tâ tâ hâ hâ {
      apply natree.pre.equiv.congr,
      assumption,
      assumption,
    },
    case ref {
      repeat {
        rw subst',
      },
      split_ifs,
      apply eqv_gen.rel,
      assumption,
      reflexivity,
    }
  end
  
  def subst'1 : char â ð' â ð â ð := Î» x u, quotient.lift (Î» t, â¦subst' x u tâ§) 
  ( begin
      intros a b h,
      simp,
      induction h,
      case refl {
        refl,
      },
      case symm {
        symmetry,
        assumption,
      },
      case trans {
        transitivity,
        assumption,
        assumption,
      },
      case rel {
        apply subst'_red_t,
        assumption,
      },
    end
  )

  lemma subst'_id {x} {u t} (h : Â¬ is_elem x t) : subst' x u t = t := begin
    induction t,
    refl,
    case app : v w hv hw {
      rw subst',
      apply congr_arg2,

      apply hv,
      intro p,
      apply h,
      rw is_elem,
      left,
      assumption,

      apply hw,
      intro p,
      apply h,
      rw is_elem,
      right,
      assumption,
    },
    rw subst',
    split_ifs,
    exfalso,
    apply h,
    rw h_1,
    rw is_elem,
    refl,
  end

  -----------------------------------------------------------------------------------

  def subst : char â ð â ð â ð := Î» x, quotient.lift (Î» u, subst'1 x u) 
  ( begin
      intros a b h,
      simp,
      apply funext,
      intro t,
      induction h,
      case refl {
        refl,
      },
      case symm {
        symmetry,
        assumption,
      },
      case trans {
        transitivity,
        assumption,
        assumption,
      },
      case rel : uâ uâ h {
        rw subst'1,
        simp,
        have hâ := quotient.exists_rep t, cases hâ with t' hâ, rw âhâ,
        simp,
        apply subst'_red_u,
        assumption,
      }
    end
  )

  lemma subst_ref {x y} {u} : subst x u &y = if x = y then u else &y := begin
    have hâ := quotient.exists_rep (u), cases hâ with u' hâ, rw âhâ,
    rw natree.ref,

    split_ifs,

    rw [subst, h],
    simp,
    rw subst'1,
    simp,
    rw subst',
    split_ifs,
    refl,
    refl,

    rw [subst],
    simp,
    rw subst'1,
    simp,
    rw subst',
    split_ifs,
    
    exfalso,
    apply h,
    symmetry,
    assumption,
    refl,
  end

  lemma subst_node {x} {u} : subst x u â³ = â³ := begin
    have hâ := quotient.exists_rep (u), cases hâ with u' hâ, rw âhâ,
    rw natree.node,
    rw subst,
    simp,
    rw subst'1,
    simp,
    refl,
  end

  lemma subst_app {x} {u s t} : subst x u (sâ¬t) = (subst x u s)â¬(subst x u t) := begin
    have hâ := quotient.exists_rep (u), cases hâ with u' hâ, rw âhâ,
    have hâ := quotient.exists_rep (s), cases hâ with s' hâ, rw âhâ,
    have hâ := quotient.exists_rep (t), cases hâ with t' hâ, rw âhâ,
    rw subst,
    simp,
    rw subst'1,
    simp,
    refl,
  end

  lemma subst_id {x} {u} {t} (h : Â¬ is_elem x t) : subst x u â¦tâ§ = â¦tâ§ := begin
    have hâ := quotient.exists_rep u, cases hâ with u' hâ, rw âhâ,
    rw subst,
    dsimp,
    rw subst'1,
    dsimp,
    apply quotient.sound,
    rw subst'_id,
    assumption,
  end

  -----------------------------------------------------------------------------------

  @[simp] def kernel' {y z} : â¢â¦â¢â¦yâ¦z â y := natree.pre.equiv.kernel
  @[simp] def stem' {x y z} : â¢â¦(â¢â¦x)â¦yâ¦z â yâ¦zâ¦(xâ¦z) := natree.pre.equiv.stem
  @[simp] def fork' {w x y z} : â¢â¦(â¢â¦wâ¦x)â¦yâ¦z â zâ¦wâ¦x := natree.pre.equiv.fork
      
  def K' := â¢â¦â¢
  lemma K'_prop {a b} : K'â¦aâ¦b â a := by simp [K']

  def I' := â¢â¦K'â¦K'
  lemma I'_prop {a} : I'â¦a â a := begin
    rw I',
    transitivity,
    apply stem',
    apply K'_prop,
  end

  def d' (x) := â¢â¦(â¢â¦x)
  lemma d'_prop {x y z} : (d' x)â¦yâ¦z â yâ¦zâ¦(xâ¦z) := by simp [d']

  def D' := â¢â¦K'â¦(K'â¦â¢)
  lemma D'_prop {x y z} : D'â¦xâ¦yâ¦z â yâ¦zâ¦(xâ¦z) := begin
    rw D',
    transitivity,
    apply natree.pre.equiv.congr_left,
    apply natree.pre.equiv.congr_left,
    transitivity,
    apply stem',
    apply natree.pre.equiv.congr_left,
    apply K'_prop,
    apply stem',
  end

  def S' := (d' (K'â¦D'))â¦((d' K')â¦(K'â¦D'))
  lemma S'_prop {x y z} : S'â¦xâ¦yâ¦z â xâ¦zâ¦(yâ¦z) := begin
    rw S',
    transitivity,
    apply natree.pre.equiv.congr_left,
    apply natree.pre.equiv.congr_left,
    transitivity,
    apply d'_prop,
    apply natree.pre.equiv.congr_left,
    transitivity,
    apply d'_prop,
    apply natree.pre.equiv.congr_left,
    apply K'_prop,
    transitivity,
    apply natree.pre.equiv.congr_left,
    transitivity,
    apply D'_prop,
    apply natree.pre.equiv.congr_left,
    apply natree.pre.equiv.congr_left,
    apply K'_prop,
    transitivity,
    apply natree.pre.equiv.congr_left,
    apply natree.pre.equiv.congr_right,
    apply K'_prop,
    apply D'_prop,
  end

  -----------------------------------------------------------------------------------

  --bracket is not liftable because it "does not preserve the equality induced by the evaluation rules" (as covered in the book)
  def bracket : char â ð' â ð'
  | x (#y) := if y =  x then I' else K'â¦(#y)
  | x â¢ := K'â¦â¢
  | x (uâ¦v) := (d' (bracket x v))â¦(bracket x u)
  lemma bracket_prop {x} {t} : (bracket x t)â¦(#x) â t := begin
    induction t,
    case node {
      rw bracket,
      apply K'_prop,
    },
    case app : tâ tâ hâ hâ {
      rw bracket,
      transitivity,
      apply d'_prop,
      apply natree.pre.equiv.congr,
      assumption,
      assumption,
    },
    case ref {
      rw bracket,
      split_ifs,
      transitivity,
      apply I'_prop,
      rw h,
      apply K'_prop,
    },
  end

  theorem bracket_beta {x} {t u} : (bracket x t)â¦u â subst' x u t := begin
    induction t,
    case node {
      rw [bracket, subst'],
      apply K'_prop,  
    },
    case app : tâ tâ hâ hâ {
      rw [bracket, subst', d'],
      transitivity,
      apply stem',
      apply natree.pre.equiv.congr,
      assumption,
      assumption,
    },
    case ref {
      rw [bracket, subst'],
      split_ifs,
      apply I'_prop,
      apply K'_prop,
    },
  end

  -----------------------------------------------------------------------------------

  --star abs similarly not liftable
  def star_abs : char â ð' â ð'
  | x â¢ := K'â¦â¢
  | x (#y) := if is_elem x (#y) then I' else K'â¦(#y)
  | x (tâ¦(#y)) := if is_elem x (#y) â§ Â¬ is_elem x t then t else (d' (star_abs x (#y)))â¦(star_abs x t) --special case for eta-reduction
  | x (tâ¦u) := (d' (star_abs x u))â¦(star_abs x t)

  notation `Î»* ` x `, ` t := star_abs x t

  lemma star_eta {x} {t} (h : Â¬ is_elem x t) : (Î»* x, tâ¦#x) â t := begin
    rw star_abs,
    split_ifs,
    refl,
    exfalso,
    cases not_and_distrib.mp h_1,

    apply h_2,
    rw is_elem,

    apply h_2,
    assumption,
  end

  lemma star_unchanged {x} {t u} (h : Â¬ is_elem x t) : (Î»* x, t)â¦u â t := begin
    induction t,
    case node {
      rw star_abs,
      apply K'_prop,
    },
    case app : tâ tâ hâ hâ {
      induction tâ,
      case node {
        rw star_abs,
        transitivity,
        apply d'_prop,
        apply natree.pre.equiv.congr,

        apply hâ,
        intro p,
        apply h,
        rw is_elem,
        left,
        assumption,

        rw star_abs,
        apply K'_prop,
      },
      case app : tâ tâ hâ hâ {
        rw star_abs,
        transitivity,
        apply d'_prop,
        apply natree.pre.equiv.congr,

        apply hâ,
        intro p,
        apply h,
        rw is_elem,
        left,
        assumption,

        apply hâ,
        intro p,
        apply h,
        rw is_elem,
        right,
        assumption,
      },
      case ref {
        symmetry,
        transitivity,
        apply natree.pre.equiv.congr,

        symmetry,
        apply hâ,
        intro p,
        apply h,
        rw is_elem,
        left,
        assumption,

        symmetry,
        apply hâ,
        intro p,
        apply h,
        rw is_elem,
        right,
        assumption,

        symmetry,

        repeat {rw star_abs},
        split_ifs,

        exfalso,
        apply h,
        rw is_elem,
        right,
        assumption,

        exfalso,
        apply h_2,
        apply and.left,
        assumption,

        transitivity,
        apply d'_prop,
        refl,

        transitivity,
        apply d'_prop,
        refl,
      },
    },
    case ref {
      rw star_abs,
      split_ifs,
      apply K'_prop,
    },
  end

  theorem star_beta {x} {t u} : (Î»* x, t)â¦u â subst' x u t := begin
    induction t,
    case node {
      rw [star_abs, subst'],
      apply K'_prop,
    },
    case ref {
      rw [star_abs, subst'],
      split_ifs,
      apply I'_prop,
      apply K'_prop,
    },
    case app : tâ tâ hâ hâ {
      rw subst',
      
      symmetry,
      transitivity,
      apply natree.pre.equiv.congr,
      symmetry,
      assumption,
      symmetry,
      assumption,
      symmetry,

      induction tâ,
      case node {
        rw star_abs,
        transitivity,
        apply d'_prop,
        refl,
      },
      case app {
        rw star_abs,
        transitivity,
        apply d'_prop,
        refl,
      },
      case ref {
        repeat {
          rw star_abs,
        },
        symmetry,
        split_ifs,

        apply natree.pre.equiv.congr,
        apply star_unchanged,
        exact h_1.2,
        apply I'_prop,

        symmetry,
        apply d'_prop,

        exfalso,
        apply h,
        apply and.left,
        assumption,

        symmetry,
        apply d'_prop,
      },
    },
  end

  theorem star_beta_q {x} {t} {u} : â¦Î»* x, tâ§â¬u = subst x u â¦tâ§ := begin
    have hâ := quotient.exists_rep u, cases hâ with u' hâ, rw âhâ,
    rw ânatree.quot_dist_app,
    rw subst,
    dsimp,
    rw subst'1,
    dsimp,
    apply quotient.sound,
    apply star_beta,
  end

  -----------------------------------------------------------------------------------

  def Ï : ð := â¦Î»* 'z', Î»* 'f', #'f'â¦(#'z'â¦#'z'â¦#'f')â§

  def Y (f) := Ïâ¬Ïâ¬f
  lemma Y_prop {f} : Y f = fâ¬(Y f) := begin
    rw Y,
    
    transitivity,
    apply congr, apply congr, refl,
    apply congr, apply congr, refl,
    rw Ï,
    refl, refl,

    transitivity,
    apply congr_arg2,
    rw star_beta_q,
    refl,

    --...

    -- have hâ := quotient.exists_rep Ï, cases hâ with Ï' hâ, rw âhâ,
    -- have hâ := quotient.exists_rep f, cases hâ with f' hâ, rw âhâ,
    -- repeat {rw ânatree.quot_dist_app},
    -- apply quotient.sound,

    -- transitivity,
    -- apply natree.pre.equiv.congr,
    -- apply star_beta,
    -- refl,

    -- transitivity,
    -- rw star_abs,
    -- rw subst',

    -- transitivity,
    -- apply natree.pre.equiv.congr_left,
    -- apply natree.pre.equiv.congr,

    -- show subst' 'z' Ï' (d' (Î»* 'f', #'z'â¦#'z'â¦#'f')) â d' (Ï'â¦Ï'),
    -- refl,
    -- show subst' 'z' Ï' (Î»* 'f', #'f') â I',
    -- refl,

    -- transitivity,
    -- apply d'_prop,

    -- apply natree.pre.equiv.congr_left,
    -- apply I'_prop,
  end

  def wait (x y) := (d I)â¬((d (Kâ¬y))â¬(Kâ¬x))
  lemma wait_prop {x y z} : (wait x y)â¬z = xâ¬yâ¬z := by simp [wait, d, I, K]

  def wait1 (x) := d (d (Kâ¬(Kâ¬x))â¬(d ((d K)â¬(Kâ¬â³))â¬(Kâ¬â³)))â¬(Kâ¬(d (â³â¬Kâ¬K)))
  lemma wait1_prop {x y z} : (wait1 x)â¬yâ¬z = xâ¬yâ¬z := by simp [wait1, d, I, K]

  def self_apply := (d I)â¬I
  lemma self_apply_prop {x} : self_applyâ¬x = xâ¬x := by simp [self_apply, d, I, K]

  def Z (f) := (wait1 self_apply)â¬((d (wait1 self_apply)) â¬ (Kâ¬f))
  lemma Z_prop {f x} : (Z f)â¬x = fâ¬(Z f)â¬x := by simp [Z, wait1, self_apply, d, I, K]

  def swap (f) := (d K)â¬(Kâ¬(((d (Kâ¬f))â¬D)))
  lemma swap_prop {f x y} : (swap f)â¬xâ¬y = fâ¬yâ¬x := by simp [swap, d, D, I, K]

  def Yâ (f) := Z (swap f)

  theorem fixpoint_function {f x} : (Yâ f)â¬x = fâ¬xâ¬(Yâ f) := by simp [Yâ, Z, swap, wait1, self_apply, d, D, I, K]
  lemma Yâ_prop {f x} : (Yâ f)â¬x = fâ¬xâ¬(Yâ f) := fixpoint_function

  def plus : ð := Yâ â¦Î»* 'm', Î»* 'p', â¢â¦#'m'â¦I'â¦(K'â¦(Î»* 'x', Î»* 'n', K'â¦(#'p'â¦#'x'â¦#'n')))â§

  def t_nil := â³
  def t_cons (h t) := â³â¬hâ¬t

  def t_head := â¦Î»* 'x', (((â¢â¦#'x')â¦(K'â¦I'))â¦K')â§
  lemma head_prop {h t} : t_headâ¬(t_cons h t) = h := begin
    rw [t_head, t_cons],
    have hâ := quotient.exists_rep h, cases hâ with h' hâ, rw âhâ,
    have hâ := quotient.exists_rep t, cases hâ with t' hâ, rw âhâ,
    rw natree.node,
    repeat {rw âquot_dist_app},
    apply quotient.sound,
    transitivity,
    apply star_beta,
    repeat {rw subst'},
    show (â¢â¦(â¢â¦h'â¦t')â¦(K'â¦I')â¦K') â h',
    transitivity,
    apply natree.pre.equiv.lift_reduces_to,
    apply natree.pre.reduces.fork,
    apply K'_prop,
  end

  def t_tail := â¦Î»* 'x', (((â¢â¦#'x')â¦(K'â¦I'))â¦(K'â¦I'))â§
  lemma tail_prop {h t} : t_tailâ¬(t_cons h t) = t := begin
    rw [t_tail, t_cons],
    have hâ := quotient.exists_rep h, cases hâ with h' hâ, rw âhâ,
    have hâ := quotient.exists_rep t, cases hâ with t' hâ, rw âhâ,
    rw natree.node,
    repeat {rw âquot_dist_app},
    apply quotient.sound,
    transitivity,
    apply star_beta,
    repeat {rw subst'},
    transitivity,
    apply natree.pre.equiv.congr,
    apply natree.pre.equiv.congr,
    apply natree.pre.equiv.congr,
    refl,
    show subst' 'x' (â¢â¦h'â¦t') (#'x') â (â¢â¦h'â¦t'),
    refl,
    show subst' 'x' (â¢â¦h'â¦t') K'â¦subst' 'x' (â¢â¦h'â¦t') I' â K'â¦I',
    refl,
    show subst' 'x' (â¢â¦h'â¦t') K'â¦subst' 'x' (â¢â¦h'â¦t') I' â K'â¦I',
    refl,
    transitivity,
    apply natree.pre.equiv.lift_reduces_to,
    apply natree.pre.reduces.fork,
    transitivity,
    apply natree.pre.equiv.congr_left,
    apply K'_prop,
    apply I'_prop,
  end

  def t_nil' := â¢
  def t_cons' (h t) := â¢â¦hâ¦t

  def list_map_swap := â¦(Î»* 'x', â¢â¦#'x'â¦(K'â¦(K'â¦t_nil')))â¦(Î»* 'h', Î»* 't', Î»* 'm', Î»* 'f', t_cons' (#'f'â¦#'h') (#'m'â¦#'f'â¦#'t'))â§
  def list_map := swap (Yâ list_map_swap)
  lemma list_map_prop_nil {f} : list_mapâ¬fâ¬t_nil = t_nil := begin
    --??? (we need to stop having to delve under the quotient whenever something is defined using star_abs)
    --if a ð' has no free variables, it is a combinator, and can be turned into an expression with no variables at all, which can then be simped
    rw [list_map, list_map_swap],

  end
  lemma list_map_prop_cons {f h t} : list_mapâ¬fâ¬(t_cons h t) = t_cons (fâ¬h) (list_mapâ¬fâ¬t) := begin
    --???
    sorry
  end

end chapter4