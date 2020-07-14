(*  Title:       Given Clause Prover Architectures
 *  Author:      Sophie Tourret <stourret at mpi-inf.mpg.de>, 2019-2020 *)

section \<open>Given Clause Prover Architectures\<close>

text \<open>This section covers all the results presented in the section 4 of the report.
  This is where abstract architectures of provers are defined and proven
  dynamically refutationally complete.\<close>

theory Given_Clause_Architectures
  imports
    Lambda_Free_RPOs.Lambda_Free_Util
    Labeled_Lifting_to_Non_Ground_Calculi
begin


subsection \<open>Basis of the Given Clause Prover Architectures\<close>

locale given_clause_basis = std?: labeled_lifting_intersection Bot_F Inf_F Bot_G Q
  entails_q Inf_G_q Red_I_q Red_F_q \<G>_F_q \<G>_Inf_q Inf_FL
  for
    Bot_F :: "'f set"
    and Inf_F :: "'f inference set"
    and Bot_G :: "'g set"
    and Q :: "'q set"
    and entails_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set \<Rightarrow> bool"
    and Inf_G_q :: \<open>'q \<Rightarrow> 'g inference set\<close>
    and Red_I_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g inference set"
    and Red_F_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set"
    and \<G>_F_q :: "'q \<Rightarrow> 'f \<Rightarrow> 'g set"
    and \<G>_Inf_q :: "'q \<Rightarrow> 'f inference \<Rightarrow> 'g inference set option"
    and Inf_FL :: \<open>('f \<times> 'l) inference set\<close>
  + fixes
    Equiv_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<doteq>" 50) and
    Prec_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<prec>\<cdot>" 50) and
    Prec_l :: "'l \<Rightarrow> 'l \<Rightarrow> bool" (infix "\<sqsubset>l" 50) and
    active :: "'l"
  assumes
    equiv_equiv_F: "equivp (\<doteq>)" and
    wf_prec_F: "minimal_element (\<prec>\<cdot>) UNIV" and
    wf_prec_l: "minimal_element (\<sqsubset>l) UNIV" and
    compat_equiv_prec: "C1 \<doteq> D1 \<Longrightarrow> C2 \<doteq> D2 \<Longrightarrow> C1 \<prec>\<cdot> C2 \<Longrightarrow> D1 \<prec>\<cdot> D2" and
    equiv_F_grounding: "q \<in> Q \<Longrightarrow> C1 \<doteq> C2 \<Longrightarrow> \<G>_F_q q C1 \<subseteq> \<G>_F_q q C2" and
    prec_F_grounding: "q \<in> Q \<Longrightarrow> C2 \<prec>\<cdot> C1 \<Longrightarrow> \<G>_F_q q C1 \<subseteq> \<G>_F_q q C2" and
    active_minimal: "l2 \<noteq> active \<Longrightarrow> active \<sqsubset>l l2" and
    at_least_two_labels: "\<exists>l2. active \<sqsubset>l l2" and
    inf_never_active: "\<iota> \<in> Inf_FL \<Longrightarrow> snd (concl_of \<iota>) \<noteq> active" and
    static_ref_comp: "statically_complete_calculus Bot_F Inf_F (\<Turnstile>\<inter>\<G>)
      no_labels.Red_I_\<G> no_labels.Red_F_\<G>_empty"
begin

abbreviation Prec_eq_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<preceq>\<cdot>" 50) where
  "C \<preceq>\<cdot> D \<equiv> C \<doteq> D \<or> C \<prec>\<cdot> D"

definition Prec_FL :: "('f \<times> 'l) \<Rightarrow> ('f \<times> 'l) \<Rightarrow> bool" (infix "\<sqsubset>" 50) where
  "Cl1 \<sqsubset> Cl2 \<longleftrightarrow> fst Cl1 \<prec>\<cdot> fst Cl2 \<or> (fst Cl1 \<doteq> fst Cl2 \<and> snd Cl1 \<sqsubset>l snd Cl2)"

lemma irrefl_prec_F: "\<not> C \<prec>\<cdot> C"
  by (simp add: minimal_element.po[OF wf_prec_F, unfolded po_on_def irreflp_on_def])

lemma trans_prec_F: "C1 \<prec>\<cdot> C2 \<Longrightarrow> C2 \<prec>\<cdot> C3 \<Longrightarrow> C1 \<prec>\<cdot> C3"
  by (auto intro: minimal_element.po[OF wf_prec_F, unfolded po_on_def transp_on_def, THEN conjunct2,
        simplified, rule_format])

lemma wf_prec_FL: "minimal_element (\<sqsubset>) UNIV"
proof
  show "po_on (\<sqsubset>) UNIV" unfolding po_on_def
  proof
    show "irreflp_on (\<sqsubset>) UNIV" unfolding irreflp_on_def Prec_FL_def
    proof
      fix Cl
      assume a_in: "Cl \<in> (UNIV::('f \<times> 'l) set)"
      have "\<not> (fst Cl \<prec>\<cdot> fst Cl)" using wf_prec_F minimal_element.min_elt_ex by force
      moreover have "\<not> (snd Cl \<sqsubset>l snd Cl)" using wf_prec_l minimal_element.min_elt_ex by force
      ultimately show "\<not> (fst Cl \<prec>\<cdot> fst Cl \<or> fst Cl \<doteq> fst Cl \<and> snd Cl \<sqsubset>l snd Cl)" by blast
    qed
  next
    show "transp_on (\<sqsubset>) UNIV" unfolding transp_on_def Prec_FL_def
    proof (simp, intro allI impI)
      fix C1 l1 C2 l2 C3 l3
      assume trans_hyp: "(C1 \<prec>\<cdot> C2 \<or> C1 \<doteq> C2 \<and> l1 \<sqsubset>l l2) \<and> (C2 \<prec>\<cdot> C3 \<or> C2 \<doteq> C3 \<and> l2 \<sqsubset>l l3)"
      have "C1 \<prec>\<cdot> C2 \<Longrightarrow> C2 \<doteq> C3 \<Longrightarrow> C1 \<prec>\<cdot> C3"
        using compat_equiv_prec by (metis equiv_equiv_F equivp_def)
      moreover have "C1 \<doteq> C2 \<Longrightarrow> C2 \<prec>\<cdot> C3 \<Longrightarrow> C1 \<prec>\<cdot> C3"
        using compat_equiv_prec by (metis equiv_equiv_F equivp_def)
      moreover have "l1 \<sqsubset>l l2 \<Longrightarrow> l2 \<sqsubset>l l3 \<Longrightarrow> l1 \<sqsubset>l l3"
        using wf_prec_l unfolding minimal_element_def po_on_def transp_on_def by (meson UNIV_I)
      moreover have "C1 \<doteq> C2 \<Longrightarrow> C2 \<doteq> C3 \<Longrightarrow> C1 \<doteq> C3"
        using equiv_equiv_F by (meson equivp_transp)
      ultimately show "C1 \<prec>\<cdot> C3 \<or> C1 \<doteq> C3 \<and> l1 \<sqsubset>l l3" using trans_hyp
        using trans_prec_F by blast
    qed
  qed
next
  show "wfp_on (\<sqsubset>) UNIV" unfolding wfp_on_def
  proof
    assume contra: "\<exists>f. \<forall>i. f i \<in> UNIV \<and> f (Suc i) \<sqsubset> f i"
    then obtain f where
      f_suc: "\<forall>i. f (Suc i) \<sqsubset> f i"
      by blast

    define R :: "(('f \<times> 'l) \<times> ('f \<times> 'l)) set" where
      "R = {(Cl1, Cl2). fst Cl1 \<prec>\<cdot> fst Cl2}"
    define S :: "(('f \<times> 'l) \<times> ('f \<times> 'l)) set" where
      "S = {(Cl1, Cl2). fst Cl1 \<doteq> fst Cl2 \<and> snd Cl1 \<sqsubset>l snd Cl2}"

    obtain k where
      f_chain: "\<forall>i. (f (Suc (i + k)), f (i + k)) \<in> S"
    proof (atomize_elim, rule wf_infinite_down_chain_compatible[of R f S])
      show "wf R"
        unfolding R_def using wf_app[OF wf_prec_F[unfolded minimal_element_def, THEN conjunct2,
              unfolded wfp_on_UNIV wfP_def]]
        by force
    next
      show "\<forall>i. (f (Suc i), f i) \<in> R \<union> S"
        using f_suc unfolding R_def S_def Prec_FL_def by blast
    next
      show "R O S \<subseteq> R"
        unfolding R_def S_def using compat_equiv_prec equiv_equiv_F equivp_reflp by fastforce
    qed

    define g where
      "\<And>i. g i = f (i + k)"

    have g_chain: "\<forall>i. (g (Suc i), g i) \<in> S"
      unfolding g_def using f_chain by simp
    have wf_s: "wf S"
      unfolding S_def
      by (rule wf_subset[OF wf_app[OF wf_prec_l[unfolded minimal_element_def, THEN conjunct2,
                unfolded wfp_on_UNIV wfP_def], of snd]])
        fast
    show False
      using g_chain[unfolded S_def]
        wf_s[unfolded S_def, folded wfP_def wfp_on_UNIV, unfolded wfp_on_def]
      by auto
  qed
qed

definition active_subset :: "('f \<times> 'l) set \<Rightarrow> ('f \<times> 'l) set" where
  "active_subset M = {CL \<in> M. snd CL = active}"

definition passive_subset :: "('f \<times> 'l) set \<Rightarrow> ('f \<times> 'l) set" where
  "passive_subset M = {CL \<in> M. snd CL \<noteq> active}"

lemma active_subset_insert[simp]:
  "active_subset (insert Cl N) = (if snd Cl = active then {Cl} else {}) \<union> active_subset N"
  unfolding active_subset_def by auto

lemma active_subset_union[simp]: "active_subset (M \<union> N) = active_subset M \<union> active_subset N"
  unfolding active_subset_def by auto

lemma passive_subset_insert[simp]:
  "passive_subset (insert Cl N) = (if snd Cl \<noteq> active then {Cl} else {}) \<union> passive_subset N"
  unfolding passive_subset_def by auto

lemma passive_subset_union[simp]: "passive_subset (M \<union> N) = passive_subset M \<union> passive_subset N"
  unfolding passive_subset_def by auto

sublocale std?: statically_complete_calculus Bot_FL Inf_FL "(\<Turnstile>\<inter>\<G>L)" Red_I Red_F
  using labeled_static_ref[OF static_ref_comp] .

lemma labeled_tiebreaker_lifting:
  assumes q_in: "q \<in> Q"
  shows "tiebreaker_lifting Bot_FL Inf_FL Bot_G (entails_q q) (Inf_G_q q)
    (Red_I_q q) (Red_F_q q) (\<G>_F_L_q q) (\<G>_Inf_L_q q) (\<lambda>g. Prec_FL)"
proof -
  have "tiebreaker_lifting Bot_FL Inf_FL Bot_G (entails_q q) (Inf_G_q q)
    (Red_I_q q) (Red_F_q q) (\<G>_F_L_q q) (\<G>_Inf_L_q q) (\<lambda>g Cl Cl'. False)"
    using ord_fam_lifted_q[OF q_in] .
  then have "standard_lifting Bot_FL Inf_FL Bot_G (Inf_G_q q) (entails_q q) (Red_I_q q)
    (Red_F_q q) (\<G>_F_L_q q) (\<G>_Inf_L_q q)"
    using lifted_q[OF q_in] by blast
  then show "tiebreaker_lifting Bot_FL Inf_FL Bot_G (entails_q q) (Inf_G_q q)
    (Red_I_q q) (Red_F_q q) (\<G>_F_L_q q) (\<G>_Inf_L_q q) (\<lambda>g. Prec_FL)"
    using wf_prec_FL by (simp add: tiebreaker_lifting.intro tiebreaker_lifting_axioms.intro)
qed

sublocale lifting_intersection Inf_FL Bot_G Q Inf_G_q entails_q Red_I_q Red_F_q
  Bot_FL \<G>_F_L_q \<G>_Inf_L_q "\<lambda>g. Prec_FL"
  using labeled_tiebreaker_lifting unfolding lifting_intersection_def
  by (simp add: lifting_intersection_axioms.intro
      no_labels.ground.consequence_relation_family_axioms
      no_labels.ground.inference_system_family_axioms)

notation derive (infix "\<rhd>RedL" 50)

lemma std_Red_I_eq: "std.Red_I = Red_I_\<G>"
  unfolding Red_I_\<G>_q_def Red_I_\<G>_L_q_def by simp

lemma std_Red_F_eq: "std.Red_F = Red_F_\<G>_empty"
  unfolding Red_F_\<G>_empty_q_def Red_F_\<G>_empty_L_q_def by simp

sublocale statically_complete_calculus Bot_FL Inf_FL "(\<Turnstile>\<inter>\<G>L)" Red_I Red_F
  by unfold_locales (use statically_complete std_Red_I_eq in auto)

(* lem:redundant-labeled-inferences *)
lemma labeled_red_inf_eq_red_inf:
  assumes i_in: "\<iota> \<in> Inf_FL"
  shows "\<iota> \<in> Red_I N \<longleftrightarrow> to_F \<iota> \<in> no_labels.Red_I_\<G> (fst ` N)"
proof
  assume i_in2: "\<iota> \<in> Red_I N"
  then have "X \<in> Red_I_\<G>_q ` Q \<Longrightarrow> \<iota> \<in> X N" for X
    unfolding Red_I_def by blast
  obtain X0 where "X0 \<in> Red_I_\<G>_q ` Q"
    using Q_nonempty by blast
  then obtain q0 where x0_is: "X0 N = Red_I_\<G>_q q0 N" by blast
  then obtain Y0 where y0_is: "Y0 (fst ` N) = to_F ` (X0 N)" by auto
  have "Y0 (fst ` N) = no_labels.Red_I_\<G>_q q0 (fst ` N)"
    unfolding  y0_is
  proof
    show "to_F ` X0 N \<subseteq> no_labels.Red_I_\<G>_q q0 (fst ` N)"
    proof
      fix \<iota>0
      assume i0_in: "\<iota>0 \<in> to_F ` X0 N"
      then have i0_in2: "\<iota>0 \<in> to_F ` Red_I_\<G>_q q0 N"
        using x0_is by argo
      then obtain \<iota>0_FL where i0_FL_in: "\<iota>0_FL \<in> Inf_FL" and i0_to_i0_FL: "\<iota>0 = to_F \<iota>0_FL" and
        subs1: "((\<G>_Inf_L_q q0 \<iota>0_FL) \<noteq> None \<and>
            the (\<G>_Inf_L_q q0 \<iota>0_FL) \<subseteq> Red_I_q q0 (\<G>_set_q q0 N))
            \<or> ((\<G>_Inf_L_q q0 \<iota>0_FL = None) \<and>
            \<G>_F_L_q q0 (concl_of \<iota>0_FL) \<subseteq> \<G>_set_q q0 N \<union> Red_F_q q0 (\<G>_set_q q0 N))"
        unfolding Red_I_\<G>_q_def by blast
      have concl_swap: "fst (concl_of \<iota>0_FL) = concl_of \<iota>0"
        unfolding concl_of_def i0_to_i0_FL to_F_def by simp
      have i0_in3: "\<iota>0 \<in> Inf_F"
        using i0_to_i0_FL Inf_FL_to_Inf_F[OF i0_FL_in] unfolding to_F_def by blast
      {
        assume
          not_none: "\<G>_Inf_q q0 \<iota>0 \<noteq> None" and
          "the (\<G>_Inf_q q0 \<iota>0) \<noteq> {}"
        then obtain \<iota>1 where i1_in: "\<iota>1 \<in> the (\<G>_Inf_q q0 \<iota>0)" by blast
        have "the (\<G>_Inf_q q0 \<iota>0) \<subseteq> Red_I_q q0 (no_labels.\<G>_set_q q0 (fst ` N))"
          using subs1 i0_to_i0_FL not_none by auto
      }
      moreover {
        assume
          is_none: "\<G>_Inf_q q0 \<iota>0 = None"
        then have "\<G>_F_q q0 (concl_of \<iota>0) \<subseteq> no_labels.\<G>_set_q q0 (fst ` N)
            \<union> Red_F_q q0 (no_labels.\<G>_set_q q0 (fst ` N))"
          using subs1 i0_to_i0_FL concl_swap by simp
      }
      ultimately show "\<iota>0 \<in> no_labels.Red_I_\<G>_q q0 (fst ` N)"
        unfolding no_labels.Red_I_\<G>_q_def using i0_in3 by auto
    qed
  next
    show "no_labels.Red_I_\<G>_q q0 (fst ` N) \<subseteq> to_F ` X0 N"
    proof
      fix \<iota>0
      assume i0_in: "\<iota>0 \<in> no_labels.Red_I_\<G>_q q0 (fst ` N)"
      then have i0_in2: "\<iota>0 \<in> Inf_F"
        unfolding no_labels.Red_I_\<G>_q_def by blast
      obtain \<iota>0_FL where i0_FL_in: "\<iota>0_FL \<in> Inf_FL" and i0_to_i0_FL: "\<iota>0 = to_F \<iota>0_FL"
        using Inf_F_to_Inf_FL[OF i0_in2] unfolding to_F_def
        by (metis Ex_list_of_length fst_conv inference.exhaust_sel inference.inject map_fst_zip)
      have concl_swap: "fst (concl_of \<iota>0_FL) = concl_of \<iota>0"
        unfolding concl_of_def i0_to_i0_FL to_F_def by simp
      have subs1: "((\<G>_Inf_L_q q0 \<iota>0_FL) \<noteq> None \<and>
           the (\<G>_Inf_L_q q0 \<iota>0_FL) \<subseteq> Red_I_q q0 (\<G>_set_q q0 N))
           \<or> ((\<G>_Inf_L_q q0 \<iota>0_FL = None) \<and>
           \<G>_F_L_q q0 (concl_of \<iota>0_FL) \<subseteq> (\<G>_set_q q0 N \<union> Red_F_q q0 (\<G>_set_q q0 N)))"
        using i0_in i0_to_i0_FL concl_swap unfolding no_labels.Red_I_\<G>_q_def by simp
      then have "\<iota>0_FL \<in> Red_I_\<G>_q q0 N"
        using i0_FL_in unfolding Red_I_\<G>_q_def by simp
      then show "\<iota>0 \<in> to_F ` X0 N"
        using x0_is i0_to_i0_FL i0_in2 by blast
    qed
  qed
  then have "Y \<in> no_labels.Red_I_\<G>_q ` Q \<Longrightarrow> to_F \<iota> \<in> Y (fst ` N)" for Y
    using i_in2 no_labels.Red_I_def std_Red_I_eq red_inf_impl by force
  then show "to_F \<iota> \<in> no_labels.Red_I_\<G> (fst ` N)"
    unfolding Red_I_def no_labels.Red_I_\<G>_def by blast
next
  assume to_F_in: "to_F \<iota> \<in> no_labels.Red_I_\<G> (fst ` N)"
  have imp_to_F: "X \<in> no_labels.Red_I_\<G>_q ` Q \<Longrightarrow> to_F \<iota> \<in> X (fst ` N)" for X
    using to_F_in unfolding no_labels.Red_I_\<G>_def by blast
  then have to_F_in2: "to_F \<iota> \<in> no_labels.Red_I_\<G>_q q (fst ` N)" if "q \<in> Q" for q
    using that by auto
  have "Red_I_\<G>_q q N = {\<iota>0_FL \<in> Inf_FL. to_F \<iota>0_FL \<in> no_labels.Red_I_\<G>_q q (fst ` N)}" for q
  proof
    show "Red_I_\<G>_q q N \<subseteq> {\<iota>0_FL \<in> Inf_FL. to_F \<iota>0_FL \<in> no_labels.Red_I_\<G>_q q (fst ` N)}"
    proof
      fix q0 \<iota>1
      assume
        i1_in: "\<iota>1 \<in> Red_I_\<G>_q q0 N"
      have i1_in2: "\<iota>1 \<in> Inf_FL"
        using i1_in unfolding Red_I_\<G>_q_def by blast
      then have to_F_i1_in: "to_F \<iota>1 \<in> Inf_F"
        using Inf_FL_to_Inf_F unfolding to_F_def by simp
      have concl_swap: "fst (concl_of \<iota>1) = concl_of (to_F \<iota>1)"
        unfolding concl_of_def to_F_def by simp
      then have i1_to_F_in: "to_F \<iota>1 \<in> no_labels.Red_I_\<G>_q q0 (fst ` N)"
        using i1_in to_F_i1_in unfolding Red_I_\<G>_q_def no_labels.Red_I_\<G>_q_def by force
      show "\<iota>1 \<in> {\<iota>0_FL \<in> Inf_FL. to_F \<iota>0_FL \<in> no_labels.Red_I_\<G>_q q0 (fst ` N)}"
        using i1_in2 i1_to_F_in by blast
    qed
  next
    show "{\<iota>0_FL \<in> Inf_FL. to_F \<iota>0_FL \<in> no_labels.Red_I_\<G>_q q (fst ` N)} \<subseteq> Red_I_\<G>_q q N"
    proof
      fix q0 \<iota>1
      assume
        i1_in: "\<iota>1 \<in> {\<iota>0_FL \<in> Inf_FL. to_F \<iota>0_FL \<in> no_labels.Red_I_\<G>_q q0 (fst ` N)}"
      then have i1_in2: "\<iota>1 \<in> Inf_FL" by blast
      then have to_F_i1_in: "to_F \<iota>1 \<in> Inf_F"
        using Inf_FL_to_Inf_F unfolding to_F_def by simp
      have concl_swap: "fst (concl_of \<iota>1) = concl_of (to_F \<iota>1)"
        unfolding concl_of_def to_F_def by simp
      then have "((\<G>_Inf_L_q q0 \<iota>1) \<noteq> None \<and> the (\<G>_Inf_L_q q0 \<iota>1) \<subseteq> Red_I_q q0 (\<G>_set_q q0 N))
        \<or> (\<G>_Inf_L_q q0 \<iota>1 = None \<and>
          \<G>_F_L_q q0 (concl_of \<iota>1) \<subseteq> \<G>_set_q q0 N \<union> Red_F_q q0 (\<G>_set_q q0 N))"
        using i1_in unfolding no_labels.Red_I_\<G>_q_def by auto
      then show "\<iota>1 \<in> Red_I_\<G>_q q0 N"
        using i1_in2 unfolding Red_I_\<G>_q_def by blast
    qed
  qed
  then have "\<iota> \<in> Red_I_\<G>_q q N" if "q \<in> Q" for q
    using that to_F_in2 i_in unfolding Red_I_\<G>_q_def no_labels.Red_I_\<G>_q_def by auto
  then show "\<iota> \<in> Red_I_\<G> N"
    unfolding Red_I_\<G>_def by blast
qed

(* lem:redundant-labeled-formulas *)
lemma red_labeled_clauses:
  assumes \<open>C \<in> no_labels.Red_F_\<G>_empty (fst ` N) \<or>
    (\<exists>C' \<in> fst ` N. C' \<prec>\<cdot> C) \<or> (\<exists>(C', L') \<in> N. L' \<sqsubset>l L \<and> C' \<preceq>\<cdot> C)\<close>
  shows \<open>(C, L) \<in> Red_F N\<close>
proof -
  note assms
  moreover have i: \<open>C \<in> no_labels.Red_F_\<G>_empty (fst ` N) \<Longrightarrow> (C, L) \<in> Red_F N\<close>
  proof -
    assume "C \<in> no_labels.Red_F_\<G>_empty (fst ` N)"
    then have "C \<in> no_labels.Red_F_\<G>_empty_q q (fst ` N)" if "q \<in> Q" for q
      unfolding no_labels.Red_F_\<G>_empty_def using that by fast
    then have g_in_red: "\<G>_F_q q C \<subseteq> Red_F_q q (no_labels.\<G>_set_q q (fst ` N))" if "q \<in> Q" for q
      unfolding no_labels.Red_F_\<G>_empty_q_def using that by blast
    have "\<G>_F_L_q q (C, L) \<subseteq> Red_F_q q (\<G>_set_q q N)" if "q \<in> Q" for q
      using that g_in_red by simp
    then show ?thesis
      unfolding Red_F_def Red_F_\<G>_q_def by blast
  qed
  moreover have ii: \<open>\<exists>C' \<in> fst ` N. C' \<prec>\<cdot> C \<Longrightarrow> (C, L) \<in> Red_F N\<close>
  proof -
    assume "\<exists>C' \<in> fst ` N. C' \<prec>\<cdot> C"
    then obtain C' where c'_in: "C' \<in> fst ` N" and c_prec_c': "C' \<prec>\<cdot> C" by blast
    obtain L' where c'_l'_in: "(C', L') \<in> N" using c'_in by auto
    have c'_l'_prec: "(C', L') \<sqsubset> (C, L)"
      using c_prec_c' unfolding Prec_FL_def by simp
    have c_in_c'_g: "\<G>_F_q q C \<subseteq> \<G>_F_q q C'" if "q \<in> Q" for q
      using prec_F_grounding[OF that c_prec_c'] by presburger
    then have "\<G>_F_L_q q (C, L) \<subseteq> \<G>_F_L_q q (C', L')" if "q \<in> Q" for q
      using that by auto
    then have "(C, L) \<in> Red_F_\<G>_q q N" if "q \<in> Q" for q
      unfolding Red_F_\<G>_q_def using that c'_l'_in c'_l'_prec by blast
    then show ?thesis
      unfolding Red_F_def by blast
  qed
  moreover have iii: \<open>\<exists>(C', L') \<in> N. L' \<sqsubset>l L \<and> C' \<preceq>\<cdot> C \<Longrightarrow> (C, L) \<in> Red_F N\<close>
  proof -
    assume "\<exists>(C', L') \<in> N. L' \<sqsubset>l L \<and> C' \<preceq>\<cdot> C"
    then obtain C' L' where c'_l'_in: "(C', L') \<in> N" and l'_sub_l: "L' \<sqsubset>l L" and c'_sub_c: "C' \<preceq>\<cdot> C"
      by fast
    have "(C, L) \<in> Red_F N" if "C' \<prec>\<cdot> C"
      using that c'_l'_in ii by fastforce
    moreover {
      assume equiv_c_c': "C \<doteq> C'"
      then have equiv_c'_c: "C' \<doteq> C"
        using equiv_equiv_F by (simp add: equivp_symp)
      then have c'_l'_prec: "(C', L') \<sqsubset> (C, L)"
        using l'_sub_l unfolding Prec_FL_def by simp
      have "\<G>_F_q q C = \<G>_F_q q C'" if "q \<in> Q" for q
        using that equiv_F_grounding equiv_c_c' equiv_c'_c by (simp add: set_eq_subset)
      then have "\<G>_F_L_q q (C, L) = \<G>_F_L_q q (C', L')" if "q \<in> Q" for q
        using that by auto
      then have "(C, L) \<in> Red_F_\<G>_q q N" if "q \<in> Q" for q
        unfolding Red_F_\<G>_q_def using that c'_l'_in c'_l'_prec by blast
      then have ?thesis
        unfolding Red_F_def by blast
    }
    ultimately show ?thesis
      using c'_sub_c equiv_equiv_F equivp_symp by fastforce
  qed
  ultimately show ?thesis
    by blast
qed

end


subsection \<open>Given Clause Procedure\<close>

locale given_clause = given_clause_basis Bot_F Inf_F Bot_G Q entails_q Inf_G_q Red_I_q
  Red_F_q \<G>_F_q \<G>_Inf_q Inf_FL Equiv_F Prec_F Prec_l active
  for
    Bot_F :: "'f set" and
    Inf_F :: "'f inference set" and
    Bot_G :: "'g set" and
    Q :: "'q set" and
    entails_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set \<Rightarrow> bool" and
    Inf_G_q :: \<open>'q \<Rightarrow> 'g inference set\<close> and
    Red_I_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g inference set" and
    Red_F_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set" and
    \<G>_F_q :: "'q \<Rightarrow> 'f \<Rightarrow> 'g set"  and
    \<G>_Inf_q :: "'q \<Rightarrow> 'f inference \<Rightarrow> 'g inference set option" and
    Inf_FL :: \<open>('f \<times> 'l) inference set\<close> and
    Equiv_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<doteq>" 50) and
    Prec_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<prec>\<cdot>" 50) and
    Prec_l :: "'l \<Rightarrow> 'l \<Rightarrow> bool" (infix "\<sqsubset>l" 50) and
    active :: 'l +
  assumes
    inf_have_prems: "\<iota>F \<in> Inf_F \<Longrightarrow> prems_of \<iota>F \<noteq> []"
begin

lemma labeled_inf_have_prems: "\<iota> \<in> Inf_FL \<Longrightarrow> prems_of \<iota> \<noteq> []"
  using inf_have_prems Inf_FL_to_Inf_F by fastforce

inductive step :: "('f \<times> 'l) set \<Rightarrow> ('f \<times> 'l) set \<Rightarrow> bool" (infix "\<Longrightarrow>GC" 50) where
  process: "N1 = N \<union> M \<Longrightarrow> N2 = N \<union> M' \<Longrightarrow> M \<subseteq> Red_F (N \<union> M') \<Longrightarrow>
    active_subset M' = {} \<Longrightarrow> N1 \<Longrightarrow>GC N2"
| infer: "N1 = N \<union> {(C, L)} \<Longrightarrow> N2 = N \<union> {(C, active)} \<union> M \<Longrightarrow> L \<noteq> active \<Longrightarrow>
    active_subset M = {} \<Longrightarrow>
    no_labels.Inf_from2 (fst ` (active_subset N)) {C}
    \<subseteq> no_labels.Red_I (fst ` (N \<union> {(C, active)} \<union> M)) \<Longrightarrow>
    N1 \<Longrightarrow>GC N2"

lemma one_step_equiv: "N1 \<Longrightarrow>GC N2 \<Longrightarrow> N1 \<rhd>RedL N2"
proof (cases N1 N2 rule: step.cases)
  show "N1 \<Longrightarrow>GC N2 \<Longrightarrow> N1 \<Longrightarrow>GC N2" by blast
next
  fix N M M'
  assume
    gc_step: "N1 \<Longrightarrow>GC N2" and
    n1_is: "N1 = N \<union> M" and
    n2_is: "N2 = N \<union> M'" and
    m_red: "M \<subseteq> Red_F (N \<union> M')" and
    active_empty: "active_subset M' = {}"
  have "N1 - N2 \<subseteq> Red_F N2"
    using n1_is n2_is m_red by auto
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
next
  fix N C L M
  assume
    gc_step: "N1 \<Longrightarrow>GC N2" and
    n1_is: "N1 = N \<union> {(C, L)}" and
    not_active: "L \<noteq> active" and
    n2_is: "N2 = N \<union> {(C, active)} \<union> M" and
    active_empty: "active_subset M = {}"
  have "(C, active) \<in> N2" using n2_is by auto
  moreover have "C \<preceq>\<cdot> C" using equiv_equiv_F by (metis equivp_def)
  moreover have "active \<sqsubset>l L" using active_minimal[OF not_active] .
  ultimately have "{(C, L)} \<subseteq> Red_F N2"
    using red_labeled_clauses by blast
  moreover have "N1 - N2 = {} \<or> N1 - N2 = {(C, L)}" using n1_is n2_is by blast
  ultimately have "N1 - N2 \<subseteq> Red_F N2"
    using std_Red_F_eq by blast
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
qed

(* lem:gc-derivations-are-red-derivations *)
lemma gc_to_red: "chain (\<Longrightarrow>GC) D \<Longrightarrow> chain (\<rhd>RedL) D"
  using one_step_equiv Lazy_List_Chain.chain_mono by blast

lemma (in-) all_ex_finite_set: "(\<forall>(j::nat)\<in>{0..<m}. \<exists>(n::nat). P j n) \<Longrightarrow>
  (\<forall>n1 n2. \<forall>j\<in>{0..<m}. P j n1 \<longrightarrow> P j n2 \<longrightarrow> n1 = n2) \<Longrightarrow> finite {n. \<exists>j \<in> {0..<m}. P j n}" for m P
proof -
  fix m::nat and P:: "nat \<Rightarrow> nat \<Rightarrow> bool"
  assume
    allj_exn: "\<forall>j\<in>{0..<m}. \<exists>n. P j n" and
    uniq_n: "\<forall>n1 n2. \<forall>j\<in>{0..<m}. P j n1 \<longrightarrow> P j n2 \<longrightarrow> n1 = n2"
  have "{n. \<exists>j \<in> {0..<m}. P j n} = (\<Union>((\<lambda>j. {n. P j n}) ` {0..<m}))" by blast
  then have imp_finite: "(\<forall>j\<in>{0..<m}. finite {n. P j n}) \<Longrightarrow> finite {n. \<exists>j \<in> {0..<m}. P j n}"
    using finite_UN[of "{0..<m}" "\<lambda>j. {n. P j n}"] by simp
  have "\<forall>j\<in>{0..<m}. \<exists>!n. P j n" using allj_exn uniq_n by blast
  then have "\<forall>j\<in>{0..<m}. finite {n. P j n}" by (metis bounded_nat_set_is_finite lessI mem_Collect_eq)
  then show "finite {n. \<exists>j \<in> {0..<m}. P j n}" using imp_finite by simp
qed

(* lem:fair-gc-derivations *)
lemma gc_fair:
  assumes
    deriv: "chain (\<Longrightarrow>GC) D" and
    init_state: "active_subset (lhd D) = {}" and
    final_state: "passive_subset (Liminf_llist D) = {}"
  shows "fair D"
  unfolding fair_def
proof
  fix \<iota>
  assume i_in: "\<iota> \<in> Inf_from (Liminf_llist D)"
  note lhd_is = lhd_conv_lnth[OF chain_not_lnull[OF deriv]]
  have i_in_inf_fl: "\<iota> \<in> Inf_FL" using i_in unfolding Inf_from_def by blast
  have "Liminf_llist D = active_subset (Liminf_llist D)"
    using final_state unfolding passive_subset_def active_subset_def by blast
  then have i_in2: "\<iota> \<in> Inf_from (active_subset (Liminf_llist D))" using i_in by simp
  define m where "m = length (prems_of \<iota>)"
  then have m_def_F: "m = length (prems_of (to_F \<iota>))" unfolding to_F_def by simp
  have i_in_F: "to_F \<iota> \<in> Inf_F"
    using i_in Inf_FL_to_Inf_F unfolding Inf_from_def to_F_def by blast
  then have m_pos: "m > 0" using m_def_F using inf_have_prems by blast
  have exist_nj: "\<forall>j \<in> {0..<m}. (\<exists>nj. enat (Suc nj) < llength D \<and>
      prems_of \<iota> ! j \<notin> active_subset (lnth D nj) \<and>
      (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (lnth D k)))"
  proof clarify
    fix j
    assume j_in: "j \<in> {0..<m}"
    then obtain C where c_is: "(C, active) = prems_of \<iota> ! j"
      using i_in2 unfolding m_def Inf_from_def active_subset_def
      by (smt Collect_mem_eq Collect_mono_iff atLeastLessThan_iff nth_mem old.prod.exhaust snd_conv)
    then have "(C, active) \<in> Liminf_llist D"
      using j_in i_in unfolding m_def Inf_from_def by force
    then obtain nj where nj_is: "enat nj < llength D" and
      c_in2: "(C, active) \<in> \<Inter> (lnth D ` {k. nj \<le> k \<and> enat k < llength D})"
      unfolding Liminf_llist_def using init_state by blast
    then have c_in3: "\<forall>k. k \<ge> nj \<longrightarrow> enat k < llength D \<longrightarrow> (C, active) \<in> lnth D k" by blast
    have nj_pos: "nj > 0" using init_state c_in2 nj_is
      unfolding active_subset_def lhd_is by force
    obtain nj_min where nj_min_is: "nj_min = (LEAST nj. enat nj < llength D \<and>
        (C, active) \<in> \<Inter> (lnth D ` {k. nj \<le> k \<and> enat k < llength D}))" by blast
    then have in_allk: "\<forall>k. k \<ge> nj_min \<longrightarrow> enat k < llength D \<longrightarrow> (C, active) \<in> (lnth D k)"
      using c_in3 nj_is c_in2
      by (metis (mono_tags, lifting) INT_E LeastI_ex mem_Collect_eq)
    have njm_smaller_D: "enat nj_min < llength D"
      using nj_min_is
      by (smt LeastI_ex \<open>\<And>thesis. (\<And>nj. \<lbrakk>enat nj < llength D;
          (C, active) \<in> \<Inter> (lnth D ` {k. nj \<le> k \<and> enat k < llength D})\<rbrakk> \<Longrightarrow> thesis) \<Longrightarrow> thesis\<close>)
    have "nj_min > 0"
      using nj_is c_in2 nj_pos nj_min_is lhd_is
      by (metis (mono_tags, lifting) Collect_empty_eq \<open>(C, active) \<in> Liminf_llist D\<close>
          \<open>Liminf_llist D = active_subset (Liminf_llist D)\<close>
          \<open>\<forall>k\<ge>nj_min. enat k < llength D \<longrightarrow> (C, active) \<in> lnth D k\<close> active_subset_def init_state
          linorder_not_less mem_Collect_eq zero_enat_def chain_length_pos[OF deriv])
    then obtain njm_prec where nj_prec_is: "Suc njm_prec = nj_min" using gr0_conv_Suc by auto
    then have njm_prec_njm: "njm_prec < nj_min" by blast
    then have njm_prec_njm_enat: "enat njm_prec < enat nj_min" by simp
    have njm_prec_smaller_d: "njm_prec < llength D"
      using HOL.no_atp(15)[OF njm_smaller_D njm_prec_njm_enat] .
    have njm_prec_all_suc: "\<forall>k>njm_prec. enat k < llength D \<longrightarrow> (C, active) \<in> lnth D k"
      using nj_prec_is in_allk by simp
    have notin_njm_prec: "(C, active) \<notin> lnth D njm_prec"
    proof (rule ccontr)
      assume "\<not> (C, active) \<notin> lnth D njm_prec"
      then have absurd_hyp: "(C, active) \<in> lnth D njm_prec" by simp
      have prec_smaller: "enat njm_prec < llength D" using nj_min_is nj_prec_is
        by (smt LeastI_ex Suc_leD \<open>\<And>thesis. (\<And>nj. \<lbrakk>enat nj < llength D;
            (C, active) \<in> \<Inter> (lnth D ` {k. nj \<le> k \<and> enat k < llength D})\<rbrakk> \<Longrightarrow> thesis) \<Longrightarrow> thesis\<close>
            enat_ord_simps(1) le_eq_less_or_eq le_less_trans)
      have "(C, active) \<in> \<Inter> (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D})"
      proof -
        {
          fix k
          assume k_in: "njm_prec \<le> k \<and> enat k < llength D"
          have "k = njm_prec \<Longrightarrow> (C, active) \<in> lnth D k" using absurd_hyp by simp
          moreover have "njm_prec < k \<Longrightarrow> (C, active) \<in> lnth D k"
            using nj_prec_is in_allk k_in by simp
          ultimately have "(C, active) \<in> lnth D k" using k_in by fastforce
        }
        then show "(C, active) \<in> \<Inter> (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D})" by blast
      qed
      then have "enat njm_prec < llength D \<and>
          (C, active) \<in> \<Inter> (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D})"
        using prec_smaller by blast
      then show False
        using nj_min_is nj_prec_is Orderings.wellorder_class.not_less_Least njm_prec_njm by blast
    qed
    then have notin_active_subs_njm_prec: "(C, active) \<notin> active_subset (lnth D njm_prec)"
      unfolding active_subset_def by blast
    then show "\<exists>nj. enat (Suc nj) < llength D \<and> prems_of \<iota> ! j \<notin> active_subset (lnth D nj) \<and>
        (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (lnth D k))"
      using c_is njm_prec_all_suc njm_prec_smaller_d by (metis (mono_tags, lifting)
          active_subset_def mem_Collect_eq nj_prec_is njm_smaller_D snd_conv)
  qed
  define nj_set where "nj_set = {nj. (\<exists>j\<in>{0..<m}. enat (Suc nj) < llength D \<and>
      prems_of \<iota> ! j \<notin> active_subset (lnth D nj) \<and>
      (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (lnth D k)))}"
  then have nj_not_empty: "nj_set \<noteq> {}"
  proof -
    have zero_in: "0 \<in> {0..<m}" using m_pos by simp
    then obtain n0 where "enat (Suc n0) < llength D" and
      "prems_of \<iota> ! 0 \<notin> active_subset (lnth D n0)" and
      "\<forall>k>n0. enat k < llength D \<longrightarrow> prems_of \<iota> ! 0 \<in> active_subset (lnth D k)"
      using exist_nj by fast
    then have "n0 \<in> nj_set" unfolding nj_set_def using zero_in by blast
    then show "nj_set \<noteq> {}" by auto
  qed
  have nj_finite: "finite nj_set"
    using all_ex_finite_set[OF exist_nj]
    by (metis (no_types, lifting) Suc_ile_eq dual_order.strict_implies_order
        linorder_neqE_nat nj_set_def)
      (* the n below in the n-1 from the pen-and-paper proof *)
  have "\<exists>n \<in> nj_set. \<forall>nj \<in> nj_set. nj \<le> n"
    using nj_not_empty nj_finite using Max_ge Max_in by blast
  then obtain n where n_in: "n \<in> nj_set" and n_bigger: "\<forall>nj \<in> nj_set. nj \<le> n" by blast
  then obtain j0 where j0_in: "j0 \<in> {0..<m}" and suc_n_length: "enat (Suc n) < llength D" and
    j0_notin: "prems_of \<iota> ! j0 \<notin> active_subset (lnth D n)" and
    j0_allin: "(\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j0 \<in> active_subset (lnth D k))"
    unfolding nj_set_def by blast
  obtain C0 where C0_is: "prems_of \<iota> ! j0 = (C0, active)" using j0_in
    using i_in2 unfolding m_def Inf_from_def active_subset_def
    by (smt Collect_mem_eq Collect_mono_iff atLeastLessThan_iff nth_mem old.prod.exhaust snd_conv)
  then have C0_prems_i: "(C0, active) \<in> set (prems_of \<iota>)" using in_set_conv_nth j0_in m_def by force
  have C0_in: "(C0, active) \<in> (lnth D (Suc n))"
    using C0_is j0_allin suc_n_length by (simp add: active_subset_def)
  have C0_notin: "(C0, active) \<notin> (lnth D n)" using C0_is j0_notin unfolding active_subset_def by simp
  have step_n: "lnth D n \<Longrightarrow>GC lnth D (Suc n)"
    using deriv chain_lnth_rel n_in unfolding nj_set_def by blast
  have "\<exists>N C L M. (lnth D n = N \<union> {(C, L)} \<and>
      lnth D (Suc n) = N \<union> {(C, active)} \<union> M \<and> L \<noteq> active \<and> active_subset M = {} \<and>
      no_labels.Inf_from2 (fst ` (active_subset N)) {C}
      \<subseteq> no_labels.Red_I (fst ` (N \<union> {(C, active)} \<union> M)))"
  proof -
    have proc_or_infer: "(\<exists>N1 N M N2 M'. lnth D n = N1 \<and> lnth D (Suc n) = N2 \<and> N1 = N \<union> M \<and>
         N2 = N \<union> M' \<and> M \<subseteq> Red_F (N \<union> M') \<and> active_subset M' = {}) \<or>
       (\<exists>N1 N C L N2 M. lnth D n = N1 \<and> lnth D (Suc n) = N2 \<and> N1 = N \<union> {(C, L)} \<and>
         N2 = N \<union> {(C, active)} \<union> M \<and> L \<noteq> active \<and> active_subset M = {} \<and>
         no_labels.Inf_from2 (fst ` (active_subset N)) {C} \<subseteq>
           no_labels.Red_I (fst ` (N \<union> {(C, active)} \<union> M)))"
      using step.simps[of "lnth D n" "lnth D (Suc n)"] step_n by blast
    show ?thesis
      using C0_in C0_notin proc_or_infer j0_in C0_is
      by (smt Un_iff active_subset_def mem_Collect_eq snd_conv sup_bot.right_neutral)
  qed
  then obtain N M L where inf_from_subs:
    "no_labels.Inf_from2 (fst ` (active_subset N)) {C0}
     \<subseteq> no_labels.Red_I (fst ` (N \<union> {(C0, active)} \<union> M))" and
    nth_d_is: "lnth D n = N \<union> {(C0, L)}" and
    suc_nth_d_is: "lnth D (Suc n) = N \<union> {(C0, active)} \<union> M" and
    l_not_active: "L \<noteq> active"
    using C0_in C0_notin j0_in C0_is using active_subset_def by fastforce
  have "j \<in> {0..<m} \<Longrightarrow> prems_of \<iota> ! j \<noteq> prems_of \<iota> ! j0 \<Longrightarrow> prems_of \<iota> ! j \<in> (active_subset N)" for j
  proof -
    fix j
    assume j_in: "j \<in> {0..<m}" and
      j_not_j0: "prems_of \<iota> ! j \<noteq> prems_of \<iota> ! j0"
    obtain nj where nj_len: "enat (Suc nj) < llength D" and
      nj_prems: "prems_of \<iota> ! j \<notin> active_subset (lnth D nj)" and
      nj_greater: "(\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (lnth D k))"
      using exist_nj j_in by blast
    then have "nj \<in> nj_set" unfolding nj_set_def using j_in by blast
    moreover have "nj \<noteq> n"
    proof (rule ccontr)
      assume "\<not> nj \<noteq> n"
      then have "prems_of \<iota> ! j = (C0, active)"
        using C0_in C0_notin step.simps[of "lnth D n" "lnth D (Suc n)"] step_n
        by (smt Un_iff nth_d_is suc_nth_d_is l_not_active active_subset_def insertCI insertE lessI
            mem_Collect_eq nj_greater nj_prems snd_conv suc_n_length)
      then show False using j_not_j0 C0_is by simp
    qed
    ultimately have "nj < n" using n_bigger by force
    then have "prems_of \<iota> ! j \<in> (active_subset (lnth D n))"
      using nj_greater n_in Suc_ile_eq dual_order.strict_implies_order unfolding nj_set_def by blast
    then show "prems_of \<iota> ! j \<in> (active_subset N)"
      using nth_d_is l_not_active unfolding active_subset_def by force
  qed
  then have "set (prems_of \<iota>) \<subseteq> active_subset N \<union> {(C0, active)}"
    using C0_prems_i C0_is m_def
    by (metis Un_iff atLeast0LessThan in_set_conv_nth insertCI lessThan_iff subrelI)
  moreover have "\<not> (set (prems_of \<iota>) \<subseteq> active_subset N - {(C0, active)})" using C0_prems_i by blast
  ultimately have "\<iota> \<in> Inf_from2 (active_subset N) {(C0, active)}"
    using i_in_inf_fl unfolding Inf_from2_def Inf_from_def by blast
  then have "to_F \<iota> \<in> no_labels.Inf_from2 (fst ` (active_subset N)) {C0}"
    unfolding to_F_def Inf_from2_def Inf_from_def
      no_labels.Inf_from2_def no_labels.Inf_from_def using Inf_FL_to_Inf_F
    by force
  then have "to_F \<iota> \<in> no_labels.Red_I (fst ` (lnth D (Suc n)))"
    using suc_nth_d_is inf_from_subs by fastforce
  then have "\<forall>q \<in> Q. (\<G>_Inf_q q (to_F \<iota>) \<noteq> None \<and>
      the (\<G>_Inf_q q (to_F \<iota>)) \<subseteq> Red_I_q q (\<Union> (\<G>_F_q q ` fst ` lnth D (Suc n))))
      \<or> (\<G>_Inf_q q (to_F \<iota>) = None \<and>
      \<G>_F_q q (concl_of (to_F \<iota>)) \<subseteq> \<Union> (\<G>_F_q q ` fst ` lnth D (Suc n)) \<union>
        Red_F_q q (\<Union> (\<G>_F_q q ` fst ` lnth D (Suc n))))"
    unfolding to_F_def no_labels.Red_I_def no_labels.Red_I_\<G>_q_def by blast
  then have "\<iota> \<in> Red_I_\<G> (lnth D (Suc n))"
    using i_in_inf_fl unfolding Red_I_\<G>_def Red_I_\<G>_q_def by (simp add: to_F_def)
  then show "\<iota> \<in> Sup_llist (lmap Red_I_\<G> D)"
    unfolding Sup_llist_def using suc_n_length by auto
qed

theorem gc_complete_Liminf:
  assumes
    deriv: "chain (\<Longrightarrow>GC) D" and
    init_state: "active_subset (lhd D) = {}" and
    final_state: "passive_subset (Liminf_llist D) = {}" and
    b_in: "B \<in> Bot_F" and
    bot_entailed: "no_labels.entails_\<G> (fst ` lhd D) {B}"
  shows "\<exists>BL \<in> Bot_FL. BL \<in> Liminf_llist D"
proof -
  note lhd_is = lhd_conv_lnth[OF chain_not_lnull[OF deriv]]
  have labeled_b_in: "(B, active) \<in> Bot_FL" using b_in by simp
  have labeled_bot_entailed: "entails_\<G>_L (lhd D) {(B, active)}"
    using labeled_entailment_lifting bot_entailed lhd_is by fastforce
  have fair: "fair D" using gc_fair[OF deriv init_state final_state] .
  then show ?thesis
    using dynamically__complete_Liminf[OF labeled_b_in gc_to_red[OF deriv] fair
        labeled_bot_entailed]
    by blast
qed

(* thm:gc-completeness *)
theorem gc_complete:
  assumes
    deriv: "chain (\<Longrightarrow>GC) D" and
    init_state: "active_subset (lhd D) = {}" and
    final_state: "passive_subset (Liminf_llist D) = {}" and
    b_in: "B \<in> Bot_F" and
    bot_entailed: "no_labels.entails_\<G> (fst ` lhd D) {B}"
  shows "\<exists>i. enat i < llength D \<and> (\<exists>BL \<in> Bot_FL. BL \<in> lnth D i)"
proof -
  note lhd_is = lhd_conv_lnth[OF chain_not_lnull[OF deriv]]
  have "\<exists>BL\<in>Bot_FL. BL \<in> Liminf_llist D"
    using assms by (rule gc_complete_Liminf)
  then show ?thesis
    unfolding Liminf_llist_def by auto
qed

end


subsection \<open>Lazy Given Clause Procedure\<close>

locale lazy_given_clause = given_clause_basis Bot_F Inf_F Bot_G Q entails_q Inf_G_q Red_I_q
  Red_F_q \<G>_F_q \<G>_Inf_q Inf_FL Equiv_F Prec_F Prec_l active
  for
    Bot_F :: "'f set" and
    Inf_F :: "'f inference set" and
    Bot_G :: "'g set" and
    Q :: "'q set" and
    entails_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set \<Rightarrow> bool" and
    Inf_G_q :: \<open>'q \<Rightarrow> 'g inference set\<close> and
    Red_I_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g inference set" and
    Red_F_q :: "'q \<Rightarrow> 'g set \<Rightarrow> 'g set" and
    \<G>_F_q :: "'q \<Rightarrow> 'f \<Rightarrow> 'g set"  and
    \<G>_Inf_q :: "'q \<Rightarrow> 'f inference \<Rightarrow> 'g inference set option" and
    Inf_FL :: \<open>('f \<times> 'l) inference set\<close> and
    Equiv_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<doteq>" 50) and
    Prec_F :: "'f \<Rightarrow> 'f \<Rightarrow> bool" (infix "\<prec>\<cdot>" 50) and
    Prec_l :: "'l \<Rightarrow> 'l \<Rightarrow> bool" (infix "\<sqsubset>l" 50) and
    active :: 'l
begin

inductive step :: "'f inference set \<times> ('f \<times> 'l) set \<Rightarrow>
  'f inference set \<times> ('f \<times> 'l) set \<Rightarrow> bool" (infix "\<Longrightarrow>LGC" 50) where
  process: "N1 = N \<union> M \<Longrightarrow> N2 = N \<union> M' \<Longrightarrow> M \<subseteq> Red_F (N \<union> M') \<Longrightarrow>
    active_subset M' = {} \<Longrightarrow> (T, N1) \<Longrightarrow>LGC (T, N2)" |
  schedule_infer: "T2 = T1 \<union> T' \<Longrightarrow> N1 = N \<union> {(C, L)} \<Longrightarrow> N2 = N \<union> {(C, active)} \<Longrightarrow>
    L \<noteq> active \<Longrightarrow> T' = no_labels.Inf_from2 (fst ` (active_subset N)) {C} \<Longrightarrow>
    (T1, N1) \<Longrightarrow>LGC (T2, N2)" |
  compute_infer: "T1 = T2 \<union> {\<iota>} \<Longrightarrow> N2 = N1 \<union> M \<Longrightarrow> active_subset M = {} \<Longrightarrow>
    \<iota> \<in> no_labels.Red_I (fst ` (N1 \<union> M)) \<Longrightarrow> (T1, N1) \<Longrightarrow>LGC (T2, N2)" |
  delete_orphans: "T1 = T2 \<union> T' \<Longrightarrow>
    T' \<inter> no_labels.Inf_from (fst ` (active_subset N)) = {} \<Longrightarrow> (T1, N) \<Longrightarrow>LGC (T2, N)"

lemma premise_free_inf_always_from:
  "\<iota> \<in> Inf_F \<Longrightarrow> length (prems_of \<iota>) = 0 \<Longrightarrow> \<iota> \<in> no_labels.Inf_from N"
  unfolding no_labels.Inf_from_def by simp

lemma one_step_equiv: "(T1, N1) \<Longrightarrow>LGC (T2, N2) \<Longrightarrow> N1 \<rhd>RedL N2"
proof (cases "(T1, N1)" "(T2, N2)" rule: step.cases)
  show "(T1, N1) \<Longrightarrow>LGC (T2, N2) \<Longrightarrow> (T1, N1) \<Longrightarrow>LGC (T2, N2)" by blast
next
  fix N M M'
  assume
    n1_is: "N1 = N \<union> M" and
    n2_is: "N2 = N \<union> M'" and
    m_red: "M \<subseteq> Red_F (N \<union> M')"
  have "N1 - N2 \<subseteq> Red_F N2"
    using n1_is n2_is m_red by auto
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
next
  fix N C L M
  assume
    n1_is: "N1 = N \<union> {(C, L)}" and
    not_active: "L \<noteq> active" and
    n2_is: "N2 = N \<union> {(C, active)}"
  have "(C, active) \<in> N2" using n2_is by auto
  moreover have "C \<preceq>\<cdot> C" by (metis equivp_def equiv_equiv_F)
  moreover have "active \<sqsubset>l L" using active_minimal[OF not_active] .
  ultimately have "{(C, L)} \<subseteq> Red_F N2"
    using red_labeled_clauses by blast
  then have "N1 - N2 \<subseteq> Red_F N2"
    using std_Red_F_eq using n1_is n2_is by blast
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
next
  fix M
  assume
    n2_is: "N2 = N1 \<union> M"
  have "N1 - N2 \<subseteq> Red_F N2"
    using n2_is by blast
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
next
  assume n2_is: "N2 = N1"
  have "N1 - N2 \<subseteq> Red_F N2"
    using n2_is by blast
  then show "N1 \<rhd>RedL N2"
    unfolding derive.simps by blast
qed

(* lem:lgc-derivations-are-red-derivations *)
lemma lgc_to_red: "chain (\<Longrightarrow>LGC) D \<Longrightarrow> chain (\<rhd>RedL) (lmap snd D)"
  using one_step_equiv Lazy_List_Chain.chain_mono by (smt chain_lmap prod.collapse)

(* lem:fair-lgc-derivations *)
lemma lgc_fair:
  assumes
    deriv: "chain (\<Longrightarrow>LGC) D" and
    init_state: "active_subset (snd (lhd D)) = {}" and
    final_state: "passive_subset (Liminf_llist (lmap snd D)) = {}" and
    no_prems_init_active: "\<forall>\<iota> \<in> Inf_F. length (prems_of \<iota>) = 0 \<longrightarrow> \<iota> \<in> fst (lhd D)" and
    final_schedule: "Liminf_llist (lmap fst D) = {}"
  shows "fair (lmap snd D)"
  unfolding fair_def
proof
  fix \<iota>
  assume i_in: "\<iota> \<in> Inf_from (Liminf_llist (lmap snd D))"
  note lhd_is = lhd_conv_lnth[OF chain_not_lnull[OF deriv]]
  have i_in_inf_fl: "\<iota> \<in> Inf_FL" using i_in unfolding Inf_from_def by blast
  have "Liminf_llist (lmap snd D) = active_subset (Liminf_llist (lmap snd D))"
    using final_state unfolding passive_subset_def active_subset_def by blast
  then have i_in2: "\<iota> \<in> Inf_from (active_subset (Liminf_llist (lmap snd D)))"
    using i_in by simp
  define m where "m = length (prems_of \<iota>)"
  then have m_def_F: "m = length (prems_of (to_F \<iota>))" unfolding to_F_def by simp
  have i_in_F: "to_F \<iota> \<in> Inf_F"
    using i_in Inf_FL_to_Inf_F unfolding Inf_from_def to_F_def by blast
  have exist_nj: "\<forall>j \<in> {0..<m}. (\<exists>nj. enat (Suc nj) < llength D \<and>
      prems_of \<iota> ! j \<notin> active_subset (snd (lnth D nj)) \<and>
      (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (snd (lnth D k))))"
  proof clarify
    fix j
    assume j_in: "j \<in> {0..<m}"
    then obtain C where c_is: "(C, active) = prems_of \<iota> ! j"
      using i_in2 unfolding m_def Inf_from_def active_subset_def
      by (smt Collect_mem_eq Collect_mono_iff atLeastLessThan_iff nth_mem old.prod.exhaust snd_conv)
    then have "(C, active) \<in> Liminf_llist (lmap snd D)"
      using j_in i_in unfolding m_def Inf_from_def by force
    then obtain nj where nj_is: "enat nj < llength D" and
      c_in2: "(C, active) \<in> \<Inter> (snd ` (lnth D ` {k. nj \<le> k \<and> enat k < llength D}))"
      unfolding Liminf_llist_def using init_state by fastforce
    then have c_in3: "\<forall>k. k \<ge> nj \<longrightarrow> enat k < llength D \<longrightarrow> (C, active) \<in> snd (lnth D k)" by blast
    have nj_pos: "nj > 0" using init_state c_in2 nj_is unfolding active_subset_def lhd_is by fastforce
    obtain nj_min where nj_min_is: "nj_min = (LEAST nj. enat nj < llength D \<and>
        (C, active) \<in> \<Inter> (snd ` (lnth D ` {k. nj \<le> k \<and> enat k < llength D})))" by blast
    then have in_allk: "\<forall>k. k \<ge> nj_min \<longrightarrow> enat k < llength D \<longrightarrow> (C, active) \<in> snd (lnth D k)"
      using c_in3 nj_is c_in2 INT_E LeastI_ex
      by (smt INT_iff INT_simps(10) c_is image_eqI mem_Collect_eq)
    have njm_smaller_D: "enat nj_min < llength D"
      using nj_min_is
      by (smt LeastI_ex \<open>\<And>thesis. (\<And>nj. \<lbrakk>enat nj < llength D;
          (C, active) \<in> \<Inter> (snd ` (lnth D ` {k. nj \<le> k \<and> enat k < llength D}))\<rbrakk> \<Longrightarrow> thesis) \<Longrightarrow> thesis\<close>)
    have "nj_min > 0"
      using nj_is c_in2 nj_pos nj_min_is lhd_is
      by (metis (mono_tags, lifting) active_subset_def emptyE in_allk init_state mem_Collect_eq
          not_less snd_conv zero_enat_def chain_length_pos[OF deriv])
    then obtain njm_prec where nj_prec_is: "Suc njm_prec = nj_min" using gr0_conv_Suc by auto
    then have njm_prec_njm: "njm_prec < nj_min" by blast
    then have njm_prec_njm_enat: "enat njm_prec < enat nj_min" by simp
    have njm_prec_smaller_d: "njm_prec < llength D"
      using  HOL.no_atp(15)[OF njm_smaller_D njm_prec_njm_enat] .
    have njm_prec_all_suc: "\<forall>k>njm_prec. enat k < llength D \<longrightarrow> (C, active) \<in> snd (lnth D k)"
      using nj_prec_is in_allk by simp
    have notin_njm_prec: "(C, active) \<notin> snd (lnth D njm_prec)"
    proof (rule ccontr)
      assume "\<not> (C, active) \<notin> snd (lnth D njm_prec)"
      then have absurd_hyp: "(C, active) \<in> snd (lnth D njm_prec)" by simp
      have prec_smaller: "enat njm_prec < llength D" using nj_min_is nj_prec_is
        by (smt LeastI_ex Suc_leD \<open>\<And>thesis. (\<And>nj. \<lbrakk>enat nj < llength D;
            (C, active) \<in> \<Inter> (snd ` (lnth D ` {k. nj \<le> k \<and> enat k < llength D}))\<rbrakk> \<Longrightarrow> thesis) \<Longrightarrow> thesis\<close>
            enat_ord_simps(1) le_eq_less_or_eq le_less_trans)
      have "(C, active) \<in> \<Inter> (snd ` (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D}))"
      proof -
        {
          fix k
          assume k_in: "njm_prec \<le> k \<and> enat k < llength D"
          have "k = njm_prec \<Longrightarrow> (C, active) \<in> snd (lnth D k)" using absurd_hyp by simp
          moreover have "njm_prec < k \<Longrightarrow> (C, active) \<in> snd (lnth D k)"
            using nj_prec_is in_allk k_in by simp
          ultimately have "(C, active) \<in> snd (lnth D k)" using k_in by fastforce
        }
        then show "(C, active) \<in> \<Inter> (snd ` (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D}))"
          by blast
      qed
      then have "enat njm_prec < llength D \<and>
          (C, active) \<in> \<Inter> (snd ` (lnth D ` {k. njm_prec \<le> k \<and> enat k < llength D}))"
        using prec_smaller by blast
      then show False
        using nj_min_is nj_prec_is Orderings.wellorder_class.not_less_Least njm_prec_njm by blast
    qed
    then have notin_active_subs_njm_prec: "(C, active) \<notin> active_subset (snd (lnth D njm_prec))"
      unfolding active_subset_def by blast
    then show "\<exists>nj. enat (Suc nj) < llength D \<and> prems_of \<iota> ! j \<notin> active_subset (snd (lnth D nj)) \<and>
        (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))"
      using c_is njm_prec_all_suc njm_prec_smaller_d by (metis (mono_tags, lifting)
          active_subset_def mem_Collect_eq nj_prec_is njm_smaller_D snd_conv)
  qed
  define nj_set where "nj_set = {nj. (\<exists>j\<in>{0..<m}. enat (Suc nj) < llength D \<and>
      prems_of \<iota> ! j \<notin> active_subset (snd (lnth D nj)) \<and>
      (\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow> prems_of \<iota> ! j \<in> active_subset (snd (lnth D k))))}"
  {
    assume m_null: "m = 0"
    then have "enat 0 < llength D \<and> to_F \<iota> \<in> fst (lhd D)"
      using no_prems_init_active i_in_F m_def_F zero_enat_def chain_length_pos[OF deriv] by auto
    then have "\<exists>n. enat n < llength D \<and> to_F \<iota> \<in> fst (lnth D n)"
      unfolding lhd_is by blast
  }
  moreover {
    assume m_pos: "m > 0"
    have nj_not_empty: "nj_set \<noteq> {}"
    proof -
      have zero_in: "0 \<in> {0..<m}" using m_pos by simp
      then obtain n0 where "enat (Suc n0) < llength D" and
        "prems_of \<iota> ! 0 \<notin> active_subset (snd (lnth D n0))" and
        "\<forall>k>n0. enat k < llength D \<longrightarrow> prems_of \<iota> ! 0 \<in> active_subset (snd (lnth D k))"
        using exist_nj by fast
      then have "n0 \<in> nj_set" unfolding nj_set_def using zero_in by blast
      then show "nj_set \<noteq> {}" by auto
    qed
    have nj_finite: "finite nj_set"
      using all_ex_finite_set[OF exist_nj] by (metis (no_types, lifting) Suc_ile_eq
          dual_order.strict_implies_order linorder_neqE_nat nj_set_def)
    have "\<exists>n \<in> nj_set. \<forall>nj \<in> nj_set. nj \<le> n"
      using nj_not_empty nj_finite using Max_ge Max_in by blast
    then obtain n where n_in: "n \<in> nj_set" and n_bigger: "\<forall>nj \<in> nj_set. nj \<le> n" by blast
    then obtain j0 where j0_in: "j0 \<in> {0..<m}" and suc_n_length: "enat (Suc n) < llength D" and
      j0_notin: "prems_of \<iota> ! j0 \<notin> active_subset (snd (lnth D n))" and
      j0_allin: "(\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
          prems_of \<iota> ! j0 \<in> active_subset (snd (lnth D k)))"
      unfolding nj_set_def by blast
    obtain C0 where C0_is: "prems_of \<iota> ! j0 = (C0, active)"
      using j0_in i_in2 unfolding m_def Inf_from_def active_subset_def
      by (smt Collect_mem_eq Collect_mono_iff atLeastLessThan_iff nth_mem old.prod.exhaust snd_conv)
    then have C0_prems_i: "(C0, active) \<in> set (prems_of \<iota>)" using in_set_conv_nth j0_in m_def by force
    have C0_in: "(C0, active) \<in> (snd (lnth D (Suc n)))"
      using C0_is j0_allin suc_n_length by (simp add: active_subset_def)
    have C0_notin: "(C0, active) \<notin> (snd (lnth D n))"
      using C0_is j0_notin unfolding active_subset_def by simp
    have step_n: "lnth D n \<Longrightarrow>LGC lnth D (Suc n)"
      using deriv chain_lnth_rel n_in unfolding nj_set_def by blast
    have is_scheduled: "\<exists>T2 T1 T' N1 N C L N2. lnth D n = (T1, N1) \<and> lnth D (Suc n) = (T2, N2) \<and>
        T2 = T1 \<union> T' \<and> N1 = N \<union> {(C, L)} \<and> N2 = N \<union> {(C, active)} \<and> L \<noteq> active \<and>
        T' = no_labels.Inf_from2 (fst ` active_subset N) {C}"
      using step.simps[of "lnth D n" "lnth D (Suc n)"] step_n C0_in C0_notin
      unfolding active_subset_def by fastforce
    then obtain T2 T1 T' N1 N L N2 where nth_d_is: "lnth D n = (T1, N1)" and
      suc_nth_d_is: "lnth D (Suc n) = (T2, N2)" and t2_is: "T2 = T1 \<union> T'" and
      n1_is: "N1 = N \<union> {(C0, L)}" "N2 = N \<union> {(C0, active)}" and
      l_not_active: "L \<noteq> active" and
      tp_is: "T' = no_labels.Inf_from2 (fst ` active_subset N) {C0}"
      using C0_in C0_notin j0_in C0_is using active_subset_def by fastforce
    have "j \<in> {0..<m} \<Longrightarrow> prems_of \<iota> ! j \<noteq> prems_of \<iota> ! j0 \<Longrightarrow> prems_of \<iota> ! j \<in> (active_subset N)"
      for j
    proof -
      fix j
      assume j_in: "j \<in> {0..<m}" and
        j_not_j0: "prems_of \<iota> ! j \<noteq> prems_of \<iota> ! j0"
      obtain nj where nj_len: "enat (Suc nj) < llength D" and
        nj_prems: "prems_of \<iota> ! j \<notin> active_subset (snd (lnth D nj))" and
        nj_greater: "(\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow>
            prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))"
        using exist_nj j_in by blast
      then have "nj \<in> nj_set" unfolding nj_set_def using j_in by blast
      moreover have "nj \<noteq> n"
      proof (rule ccontr)
        assume "\<not> nj \<noteq> n"
        then have "prems_of \<iota> ! j = (C0, active)"
          using C0_in C0_notin step.simps[of "lnth D n" "lnth D (Suc n)"] step_n
            active_subset_def is_scheduled nj_greater nj_prems suc_n_length by auto
        then show False using j_not_j0 C0_is by simp
      qed
      ultimately have "nj < n" using n_bigger by force
      then have "prems_of \<iota> ! j \<in> (active_subset (snd (lnth D n)))"
        using nj_greater n_in Suc_ile_eq dual_order.strict_implies_order
        unfolding nj_set_def by blast
      then show "prems_of \<iota> ! j \<in> (active_subset N)"
        using nth_d_is l_not_active n1_is unfolding active_subset_def by force
    qed
    then have prems_i_active: "set (prems_of \<iota>) \<subseteq> active_subset N \<union> {(C0, active)}"
      using C0_prems_i C0_is m_def
      by (metis Un_iff atLeast0LessThan in_set_conv_nth insertCI lessThan_iff subrelI)
    moreover have "\<not> (set (prems_of \<iota>) \<subseteq> active_subset N - {(C0, active)})" using C0_prems_i by blast
    ultimately have "\<iota> \<in> Inf_from2 (active_subset N) {(C0, active)}"
      using i_in_inf_fl prems_i_active unfolding Inf_from2_def Inf_from_def by blast
    then have "to_F \<iota> \<in> no_labels.Inf_from2 (fst ` (active_subset N)) {C0}"
      unfolding to_F_def Inf_from2_def Inf_from_def
        no_labels.Inf_from2_def no_labels.Inf_from_def
      using Inf_FL_to_Inf_F by force
    then have i_in_t2: "to_F \<iota> \<in> T2" using tp_is t2_is by simp
    have "j \<in> {0..<m} \<Longrightarrow> (\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
        prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))" for j
    proof (cases "j = j0")
      case True
      assume "j = j0"
      then show "(\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
          prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))" using j0_allin by simp
    next
      case False
      assume j_in: "j \<in> {0..<m}" and
        "j \<noteq> j0"
      obtain nj where nj_len: "enat (Suc nj) < llength D" and
        nj_prems: "prems_of \<iota> ! j \<notin> active_subset (snd (lnth D nj))" and
        nj_greater: "(\<forall>k. k > nj \<longrightarrow> enat k < llength D \<longrightarrow>
            prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))"
        using exist_nj j_in by blast
      then have "nj \<in> nj_set" unfolding nj_set_def using j_in by blast
      then show "(\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
          prems_of \<iota> ! j \<in> active_subset (snd (lnth D k)))"
        using nj_greater n_bigger by auto
    qed
    then have allj_allk: "(\<forall>c\<in> set (prems_of \<iota>). (\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
        c \<in> active_subset (snd (lnth D k))))"
      using m_def by (metis atLeast0LessThan in_set_conv_nth lessThan_iff)
    have "\<forall>c\<in> set (prems_of \<iota>). snd c = active"
      using prems_i_active unfolding active_subset_def by auto
    then have ex_n_i_in: "\<exists>n. enat (Suc n) < llength D \<and> to_F \<iota> \<in> fst (lnth D (Suc n)) \<and>
        (\<forall>c\<in> set (prems_of \<iota>). snd c = active) \<and>
        (\<forall>c\<in> set (prems_of \<iota>). (\<forall>k. k > n \<longrightarrow> enat k < llength D \<longrightarrow>
          c \<in> active_subset (snd (lnth D k))))"
      using allj_allk i_in_t2 suc_nth_d_is fstI n_in nj_set_def
      by auto
    then have "\<exists>n. enat n < llength D \<and> to_F \<iota> \<in> fst (lnth D n) \<and>
        (\<forall>c\<in> set (prems_of \<iota>). snd c = active) \<and> (\<forall>c\<in> set (prems_of \<iota>). (\<forall>k. k \<ge> n \<longrightarrow>
          enat k < llength D \<longrightarrow> c \<in> active_subset (snd (lnth D k))))"
      by auto
  }
  ultimately obtain n T2 N2 where i_in_suc_n: "to_F \<iota> \<in> fst (lnth D n)" and
    all_prems_active_after: "m > 0 \<Longrightarrow> (\<forall>c\<in> set (prems_of \<iota>). (\<forall>k. k \<ge> n \<longrightarrow> enat k < llength D \<longrightarrow>
                  c \<in> active_subset (snd (lnth D k))))" and
    suc_n_length: "enat n < llength D" and suc_nth_d_is: "lnth D n = (T2, N2)"
    by (metis less_antisym old.prod.exhaust zero_less_Suc)
  then have i_in_t2: "to_F \<iota> \<in> T2" by simp
  have "\<exists>p\<ge>n. enat (Suc p) < llength D \<and> to_F \<iota> \<in> (fst (lnth D p)) \<and> to_F \<iota> \<notin> (fst (lnth D (Suc p)))"
  proof (rule ccontr)
    assume
      contra: "\<not> (\<exists>p\<ge>n. enat (Suc p) < llength D \<and> to_F \<iota> \<in> (fst (lnth D p)) \<and>
                     to_F \<iota> \<notin> (fst (lnth D (Suc p))))"
    then have i_in_suc: "p0 \<ge> n \<Longrightarrow> enat (Suc p0) < llength D \<Longrightarrow> to_F \<iota> \<in> (fst (lnth D p0)) \<Longrightarrow>
        to_F \<iota> \<in> (fst (lnth D (Suc p0)))" for p0
      by blast
    have "p0 \<ge> n \<Longrightarrow> enat p0 < llength D \<Longrightarrow> to_F \<iota> \<in> (fst (lnth D p0))" for p0
    proof (induction rule: nat_induct_at_least)
      case base
      then show ?case using i_in_t2 suc_nth_d_is
        by simp
    next
      case (Suc p0)
      assume p_bigger_n: "n \<le> p0" and
        induct_hyp: "enat p0 < llength D \<Longrightarrow> to_F \<iota> \<in> fst (lnth D p0)" and
        sucsuc_smaller_d: "enat (Suc p0) < llength D"
      have suc_p_bigger_n: "n \<le> p0" using p_bigger_n by simp
      have suc_smaller_d: "enat p0 < llength D"
        using sucsuc_smaller_d Suc_ile_eq dual_order.strict_implies_order by blast
      then have "to_F \<iota> \<in> fst (lnth D p0)" using induct_hyp by blast
      then show ?case using i_in_suc[OF suc_p_bigger_n sucsuc_smaller_d] by blast
    qed
    then have i_in_all_bigger_n: "\<forall>j. j \<ge> n \<and> enat j < llength D \<longrightarrow> to_F \<iota> \<in> (fst (lnth D j))"
      by presburger
    have "llength (lmap fst D) = llength D" by force
    then have "to_F \<iota> \<in> \<Inter> (lnth (lmap fst D) ` {j. n \<le> j \<and> enat j < llength (lmap fst D)})"
      using i_in_all_bigger_n using Suc_le_D by auto
    then have "to_F \<iota> \<in> Liminf_llist (lmap fst D)"
      unfolding Liminf_llist_def using suc_n_length by auto
    then show False using final_schedule by fast
  qed
  then obtain p where p_greater_n: "p \<ge> n" and p_smaller_d: "enat (Suc p) < llength D" and
    i_in_p: "to_F \<iota> \<in> (fst (lnth D p))" and i_notin_suc_p: "to_F \<iota> \<notin> (fst (lnth D (Suc p)))"
    by blast
  have p_neq_n: "Suc p \<noteq> n" using i_notin_suc_p i_in_suc_n by blast
  have step_p: "lnth D p \<Longrightarrow>LGC lnth D (Suc p)" using deriv p_smaller_d chain_lnth_rel by blast
  then have "\<exists>T1 T2 \<iota> N2 N1 M. lnth D p = (T1, N1) \<and> lnth D (Suc p) = (T2, N2) \<and>
      T1 = T2 \<union> {\<iota>} \<and> N2 = N1 \<union> M \<and> active_subset M = {} \<and>
      \<iota> \<in> no_labels.Red_I_\<G> (fst ` (N1 \<union> M))"
  proof -
    have ci_or_do: "(\<exists>T1 T2 \<iota> N2 N1 M. lnth D p = (T1, N1) \<and> lnth D (Suc p) = (T2, N2) \<and>
        T1 = T2 \<union> {\<iota>} \<and> N2 = N1 \<union> M \<and> active_subset M = {} \<and>
        \<iota> \<in> no_labels.Red_I_\<G> (fst ` (N1 \<union> M))) \<or>
        (\<exists>T1 T2 T' N. lnth D p = (T1, N) \<and> lnth D (Suc p) = (T2, N) \<and>
        T1 = T2 \<union> T' \<and> T' \<inter> no_labels.Inf_from (fst ` active_subset N) = {})"
      using step.simps[of "lnth D p" "lnth D (Suc p)"] step_p i_in_p i_notin_suc_p by fastforce
    then have p_greater_n_strict: "n < Suc p"
      using suc_nth_d_is p_greater_n i_in_t2 i_notin_suc_p le_eq_less_or_eq by force
    have "m > 0 \<Longrightarrow> j \<in> {0..<m} \<Longrightarrow> prems_of (to_F \<iota>) ! j \<in> fst ` active_subset (snd (lnth D p))"
      for j
    proof -
      fix j
      assume
        m_pos: "m > 0" and
        j_in: "j \<in> {0..<m}"
      then have "prems_of \<iota> ! j \<in> (active_subset (snd (lnth D p)))"
        using all_prems_active_after[OF m_pos] p_smaller_d m_def p_greater_n p_neq_n
        by (meson Suc_ile_eq atLeastLessThan_iff dual_order.strict_implies_order nth_mem
            p_greater_n_strict)
      then have "fst (prems_of \<iota> ! j) \<in> fst ` active_subset (snd (lnth D p))"
        by blast
      then show "prems_of (to_F \<iota>) ! j \<in> fst ` active_subset (snd (lnth D p))"
        unfolding to_F_def using j_in m_def by simp
    qed
    then have prems_i_active_p: "m > 0 \<Longrightarrow>
        to_F \<iota> \<in> no_labels.Inf_from (fst ` active_subset (snd (lnth D p)))"
      using i_in_F unfolding no_labels.Inf_from_def
      by (smt atLeast0LessThan in_set_conv_nth lessThan_iff m_def_F mem_Collect_eq subsetI)
    have "m = 0 \<Longrightarrow> (\<exists>T1 T2 \<iota> N2 N1 M. lnth D p = (T1, N1) \<and> lnth D (Suc p) = (T2, N2) \<and>
        T1 = T2 \<union> {\<iota>} \<and> N2 = N1 \<union> M \<and> active_subset M = {} \<and>
        \<iota> \<in> no_labels.Red_I_\<G> (fst ` (N1 \<union> M)))"
      using ci_or_do premise_free_inf_always_from[of "to_F \<iota>" "fst ` active_subset _", OF i_in_F]
        m_def i_in_p i_notin_suc_p m_def_F by auto
    then show "(\<exists>T1 T2 \<iota> N2 N1 M. lnth D p = (T1, N1) \<and> lnth D (Suc p) = (T2, N2) \<and>
        T1 = T2 \<union> {\<iota>} \<and> N2 = N1 \<union> M \<and> active_subset M = {} \<and>
        \<iota> \<in> no_labels.Red_I_\<G> (fst ` (N1 \<union> M)))"
      using ci_or_do i_in_p i_notin_suc_p prems_i_active_p unfolding active_subset_def by force
  qed
  then obtain T1p T2p N1p N2p Mp where  "lnth D p = (T1p, N1p)" and
    suc_p_is: "lnth D (Suc p) = (T2p, N2p)" and "T1p = T2p \<union> {to_F \<iota>}" and "T2p \<inter> {to_F \<iota>} = {}" and
    n2p_is: "N2p = N1p \<union> Mp"and "active_subset Mp = {}" and
    i_in_red_inf: "to_F \<iota> \<in> no_labels.Red_I_\<G>
        (fst ` (N1p \<union> Mp))"
    using i_in_p i_notin_suc_p by fastforce
  have "to_F \<iota> \<in> no_labels.Red_I (fst ` (snd (lnth D (Suc p))))"
    using i_in_red_inf suc_p_is n2p_is by fastforce
  then have "\<forall>q \<in> Q. (\<G>_Inf_q q (to_F \<iota>) \<noteq> None \<and>
      the (\<G>_Inf_q q (to_F \<iota>)) \<subseteq> Red_I_q q (\<Union> (\<G>_F_q q ` fst ` snd (lnth D (Suc p)))))
      \<or> (\<G>_Inf_q q (to_F \<iota>) = None \<and>
      \<G>_F_q q (concl_of (to_F \<iota>)) \<subseteq> \<Union> (\<G>_F_q q ` fst ` snd (lnth D (Suc p))) \<union>
        Red_F_q q (\<Union> (\<G>_F_q q ` fst ` snd (lnth D (Suc p)))))"
    unfolding to_F_def no_labels.Red_I_def no_labels.Red_I_\<G>_q_def by blast
  then have "\<iota> \<in> Red_I_\<G> (snd (lnth D (Suc p)))"
    using i_in_inf_fl unfolding Red_I_\<G>_def Red_I_\<G>_q_def by (simp add: to_F_def)
  then show "\<iota> \<in> Sup_llist (lmap Red_I_\<G> (lmap snd D))"
    unfolding Sup_llist_def using suc_n_length p_smaller_d by auto
qed

theorem lgc_complete_Liminf:
  assumes
    deriv: "chain (\<Longrightarrow>LGC) D" and
    init_state: "active_subset (snd (lhd D)) = {}" and
    final_state: "passive_subset (Liminf_llist (lmap snd D)) = {}" and
    no_prems_init_active: "\<forall>\<iota> \<in> Inf_F. length (prems_of \<iota>) = 0 \<longrightarrow> \<iota> \<in> fst (lhd D)" and
    final_schedule: "Liminf_llist (lmap fst D) = {}" and
    b_in: "B \<in> Bot_F" and
    bot_entailed: "no_labels.entails_\<G> (fst ` snd (lhd D)) {B}"
  shows "\<exists>BL \<in> Bot_FL. BL \<in> Liminf_llist (lmap snd D)"
proof -
  have labeled_b_in: "(B, active) \<in> Bot_FL" using b_in by simp
  have simp_snd_lmap: "lhd (lmap snd D) = snd (lhd D)"
    by (rule llist.map_sel(1)[OF chain_not_lnull[OF deriv]])
  have labeled_bot_entailed: "entails_\<G>_L (snd (lhd D)) {(B, active)}"
    using labeled_entailment_lifting bot_entailed by fastforce
  have "fair (lmap snd D)"
    using lgc_fair[OF deriv init_state final_state no_prems_init_active final_schedule] .
  then show ?thesis
    using dynamically__complete_Liminf labeled_b_in lgc_to_red[OF deriv]
      labeled_bot_entailed simp_snd_lmap std_Red_I_eq
    by presburger
qed

(* thm:lgc-completeness *)
theorem lgc_complete:
  assumes
    deriv: "chain (\<Longrightarrow>LGC) D" and
    init_state: "active_subset (snd (lhd D)) = {}" and
    final_state: "passive_subset (Liminf_llist (lmap snd D)) = {}" and
    no_prems_init_active: "\<forall>\<iota> \<in> Inf_F. length (prems_of \<iota>) = 0 \<longrightarrow> \<iota> \<in> fst (lhd D)" and
    final_schedule: "Liminf_llist (lmap fst D) = {}" and
    b_in: "B \<in> Bot_F" and
    bot_entailed: "no_labels.entails_\<G> (fst ` snd (lhd D)) {B}"
  shows "\<exists>i. enat i < llength D \<and> (\<exists>BL \<in> Bot_FL. BL \<in> snd (lnth D i))"
proof -
  have "\<exists>BL\<in>Bot_FL. BL \<in> Liminf_llist (lmap snd D)"
    using assms by (rule lgc_complete_Liminf)
  then show ?thesis
    unfolding Liminf_llist_def by auto
qed

end

end