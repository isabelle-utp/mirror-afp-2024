(*<*)
\<comment>\<open> ******************************************************************** 
 * Project         : HOL-CSP_OpSem - Operational semantics for HOL-CSP
 *
 * Author          : Benoît Ballenghien, Burkhart Wolff
 *
 * This file       : Operational semantics with FD refinement
 *
 * Copyright (c) 2023 Université Paris-Saclay, France
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of the copyright holders nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************\<close>
(*>*)

chapter \<open> Failure Divergence Operational Semantics \<close>

theory  OpSemFD
  imports OpSemGeneric "HOL-Library.LaTeXsugar"
begin


text \<open>As announced in the motivations, the first definition we want to try is with \<^term>\<open>(\<sqsubseteq>\<^sub>F\<^sub>D)\<close>.\<close>

abbreviation \<tau>_trans :: \<open>'\<alpha> process \<Rightarrow> '\<alpha> process \<Rightarrow> bool\<close> (infixl \<open>\<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau>\<close> 50)
  where \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q \<equiv> P \<sqsubseteq>\<^sub>F\<^sub>D Q\<close>
 
text \<open>We now instantiate the locale of \<^theory>\<open>HOL-CSP_OpSem.OpSemGeneric\<close>.\<close>

interpretation OpSemGeneric \<open>(\<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau>)\<close>
  using trans_FD by unfold_locales 
                    (auto simp add: anti_mono_ready_set_FD mono_AfterExt_FD)

notation event_trans (\<open>_/ \<^sub>F\<^sub>D\<leadsto>_/ _\<close>  [50, 3, 51] 50)
notation trace_trans (\<open>_/ \<^sub>F\<^sub>D\<leadsto>\<^sup>*_/ _\<close> [50, 3, 51] 50)


lemma \<open>P \<^sub>F\<^sub>D\<leadsto> e P' \<Longrightarrow> P' \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P'' \<Longrightarrow> P \<^sub>F\<^sub>D\<leadsto> e P''\<close>
      \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P' \<^sub>F\<^sub>D\<leadsto> e P'' \<Longrightarrow> P \<^sub>F\<^sub>D\<leadsto> e P''\<close>
  by (fact event_trans_\<tau>_trans \<tau>_trans_event_trans)+


section \<open>Operational Semantics Laws\<close>

text \<open>\<^const>\<open>SKIP\<close> law\<close>

lemma \<open>SKIP \<^sub>F\<^sub>D\<leadsto>\<checkmark> STOP\<close>
  by (fact SKIP_trans_tick)



text \<open>\<^term>\<open>e \<rightarrow> P\<close> laws\<close>

lemma \<open>e \<in> A \<Longrightarrow> \<box>a \<in> A \<rightarrow> P a \<^sub>F\<^sub>D\<leadsto>(ev e) (P e)\<close>
  by (fact ev_trans_Mprefix)

lemma \<open>e \<in> A \<Longrightarrow> \<sqinter>a \<in> A \<rightarrow> P a \<^sub>F\<^sub>D\<leadsto>(ev e) (P e)\<close>
  by (fact ev_trans_Mndetprefix)

lemma \<open>e \<rightarrow> P \<^sub>F\<^sub>D\<leadsto> (ev e) P\<close> 
  by (fact ev_trans_prefix)



text \<open>\<^term>\<open>P \<sqinter> Q\<close> laws\<close>

lemma \<open>P \<sqinter> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P\<close>
  and \<open>P \<sqinter> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q\<close>
  by (fact \<tau>_trans_NdetL \<tau>_trans_NdetR)+

lemma \<open>a \<in> A \<Longrightarrow> (\<sqinter>a \<in> A. P a) \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P a\<close>
  by (fact \<tau>_trans_GlobalNdet)

lemma \<open>finite A \<Longrightarrow> a \<in> A \<Longrightarrow> (\<Sqinter>a \<in> A. P a) \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P a\<close>
  by (fact \<tau>_trans_MultiNdet)



text \<open>\<^term>\<open>\<mu> X. f X\<close> law\<close>

lemma \<open>cont f \<Longrightarrow> P = (\<mu> X. f X) \<Longrightarrow> P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> f P\<close>
  by (fact fix_point_\<tau>_trans)



text \<open>\<^term>\<open>P \<box> Q\<close> laws\<close>

lemma \<tau>_trans_DetL: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<box> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<box> Q \<close>
  and \<tau>_trans_DetR: \<open>Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q' \<Longrightarrow> P \<box> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P  \<box> Q'\<close>
  by simp_all

lemma \<tau>_trans_MultiDet:
  \<open>finite A \<Longrightarrow> \<forall>a \<in> A. P a \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' a \<Longrightarrow> 
   (\<^bold>\<box>a \<in> A. P a) \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> (\<^bold>\<box>a \<in> A. P' a)\<close>
  by (fact mono_MultiDet_FD)


lemma \<open>P \<^sub>F\<^sub>D\<leadsto>e P' \<Longrightarrow> P \<box> Q \<^sub>F\<^sub>D\<leadsto>e P'\<close>
  and \<open>Q \<^sub>F\<^sub>D\<leadsto>e Q' \<Longrightarrow> P \<box> Q \<^sub>F\<^sub>D\<leadsto>e Q'\<close>
  by (fact event_trans_DetL event_trans_DetR)+

lemma \<open>finite A \<Longrightarrow> a \<in> A \<Longrightarrow> P a \<^sub>F\<^sub>D\<leadsto>e Q \<Longrightarrow> (\<^bold>\<box>a \<in> A. P a) \<^sub>F\<^sub>D\<leadsto>e Q\<close>
  by (fact event_trans_MultiDet)



text \<open>\<^term>\<open>P \<^bold>; Q\<close> laws\<close>

lemma \<tau>_trans_SeqL: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<^bold>; Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<^bold>; Q\<close>
  by simp

lemma ev_trans_SeqL: \<open>P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> P \<^bold>; Q \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<^bold>; Q\<close>
  (* by (metis (no_types, lifting) AfterExt_Seq mono_Ndet_FD_left Diff_iff UNIV_I Un_iff 
               \<tau>_trans_SeqL empty_iff event.distinct(1) insert_iff ready_set_Seq) *)
  by (auto simp add: ready_set_Seq AfterExt_Seq)

lemma \<tau>_trans_SeqR: \<open>\<exists>P'. P \<^sub>F\<^sub>D\<leadsto>\<checkmark> P' \<Longrightarrow> P \<^bold>; Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q\<close>
  by (metis mono_Seq_FD SKIP_Seq \<tau>_trans_eq ready_tick_imp_\<tau>_trans_SKIP)


(* not in the Roscoe's because direct consequence of \<tau>_trans_SeqR *)
lemma \<open>\<checkmark> \<in> ready_set P \<Longrightarrow> Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q' \<Longrightarrow> P \<^bold>; Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q'\<close>
  (* using \<tau>_trans_SeqR \<tau>_trans_eq \<tau>_trans_event_trans by blast *)
  by (fact ev_trans_SeqR)



text \<open>\<^term>\<open>P \ B\<close> laws\<close>

lemma \<tau>_trans_Hiding: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \ B \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \ B\<close>
  by (fact mono_Hiding_FD)

lemma ev_trans_Hiding_notin:
  \<open>P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> e \<notin> B \<Longrightarrow> P \ B \<^sub>F\<^sub>D\<leadsto>(ev e) P' \ B\<close> 
  by (metis AfterExt_def After_Hiding_FD_Hiding_After_if_ready_notin mono_Hiding_FD 
            event_trans_\<tau>_trans event.simps(4) ready_notin_imp_ready_Hiding)

lemma \<open>P \<^sub>F\<^sub>D\<leadsto>\<checkmark> P' \<Longrightarrow> P \ B \<^sub>F\<^sub>D\<leadsto>\<checkmark> STOP\<close>
  by (fact tick_trans_Hiding)

lemma ev_trans_Hiding_inside:
  \<open>P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> e \<in> B \<Longrightarrow> P \ B \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \ B\<close>
  by (metis AfterExt_def Hiding_FD_Hiding_After_if_ready_inside
            mono_Hiding_FD event.simps(4) trans_FD)

  

text \<open>\<^term>\<open>Renaming P f\<close> laws\<close>

lemma \<tau>_trans_Renaming:
  \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> Renaming P f \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Renaming P' f\<close>
  by (fact mono_Renaming_FD)

lemma tick_trans_Renaming: \<open>P \<^sub>F\<^sub>D\<leadsto>\<checkmark> P' \<Longrightarrow> Renaming P f \<^sub>F\<^sub>D\<leadsto>\<checkmark> STOP\<close>
  by (simp add: AfterExt_def ready_set_Renaming tick_eq_EvExt)

lemma ev_trans_Renaming:
  \<open>f a = b \<Longrightarrow> P \<^sub>F\<^sub>D\<leadsto>(ev a) P' \<Longrightarrow> Renaming P f \<^sub>F\<^sub>D\<leadsto>(ev b) (Renaming P' f)\<close>
  apply (simp add: AfterExt_Renaming Renaming_BOT ready_set_BOT ready_set_Renaming)
  apply (intro conjI impI)
   apply (meson ev_elem_anteced1 imageI vimageI2)
  apply (rule \<tau>_trans_transitivity[of _ \<open>Renaming (P afterExt ev a) f\<close>])
   apply (solves \<open>rule \<tau>_trans_GlobalNdet, simp\<close>)
  by (simp add: \<tau>_trans_Renaming)
 

(* variations with the RenamingF syntax *)
lemma \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<lbrakk>a := b\<rbrakk> \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<lbrakk>a := b\<rbrakk>\<close>
  by (fact \<tau>_trans_Renaming)

lemma \<open>P \<^sub>F\<^sub>D\<leadsto>\<checkmark> P' \<Longrightarrow> P \<lbrakk>a := b\<rbrakk> \<^sub>F\<^sub>D\<leadsto>\<checkmark> STOP\<close>
  by (fact tick_trans_Renaming)

lemma ev_trans_RenamingF:
  \<open>P \<^sub>F\<^sub>D\<leadsto>(ev a) P' \<Longrightarrow> P \<lbrakk>a := b\<rbrakk> \<^sub>F\<^sub>D\<leadsto>(ev b) P' \<lbrakk>a := b\<rbrakk>\<close>
  by (metis ev_trans_Renaming fun_upd_same)
  


text \<open>\<^term>\<open>P \<lbrakk>S\<rbrakk> Q\<close> laws\<close>

lemma \<tau>_trans_SyncL: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<lbrakk>S\<rbrakk> Q\<close>
  and \<tau>_trans_SyncR: \<open>Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P \<lbrakk>S\<rbrakk> Q'\<close>
  by simp_all

lemma ev_trans_SyncL:
      \<open>e \<notin> S \<Longrightarrow> P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<lbrakk>S\<rbrakk> Q \<close>
  and ev_trans_SyncR:
      \<open>e \<notin> S \<Longrightarrow> Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>(ev e) P  \<lbrakk>S\<rbrakk> Q'\<close>
  by (simp_all add: AfterExt_Sync ready_set_Sync image_iff)
  
lemma ev_trans_SyncLR:
  \<open>\<lbrakk>e \<in> S; P \<^sub>F\<^sub>D\<leadsto>(ev e) P'; Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q'\<rbrakk> \<Longrightarrow>
   P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<lbrakk>S\<rbrakk> Q'\<close>
  by (simp add: AfterExt_Sync ready_set_Sync)


text \<open>From here we slightly defer from Roscoe's laws for \<^const>\<open>Sync\<close>: 
      we obtain the following rules for \<^const>\<open>SKIP\<close> instead of \<^const>\<open>STOP\<close>.\<close>

lemma tick_trans_SyncL: \<open>P \<^sub>F\<^sub>D\<leadsto>\<checkmark> P' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> SKIP \<lbrakk>S\<rbrakk> Q\<close>
  and tick_trans_SyncR: \<open>Q \<^sub>F\<^sub>D\<leadsto>\<checkmark> Q' \<Longrightarrow> P \<lbrakk>S\<rbrakk> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P \<lbrakk>S\<rbrakk> SKIP\<close>
  by (simp_all add: ready_tick_imp_\<tau>_trans_SKIP)

lemma tick_trans_SKIP_Sync_SKIP: \<open>SKIP \<lbrakk>S\<rbrakk> SKIP \<^sub>F\<^sub>D\<leadsto>\<checkmark> STOP\<close>
  by (simp add: SKIP_trans_tick Sync_SKIP_SKIP)

lemma \<tau>_trans_SKIP_Sync_SKIP: \<open>SKIP \<lbrakk>S\<rbrakk> SKIP \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> SKIP\<close>
  by (simp add: Sync_SKIP_SKIP)



text \<open>\<^term>\<open>P \<rhd> Q\<close> laws\<close>

lemma Sliding_\<tau>_trans_left: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<rhd> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<rhd> Q\<close>
  by (simp add: Sliding_def)
 
lemma \<open>P \<^sub>F\<^sub>D\<leadsto>e P' \<Longrightarrow> P \<rhd> Q \<^sub>F\<^sub>D\<leadsto>e P'\<close>
  by (fact Sliding_event_transL)

lemma \<open>P \<rhd> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q\<close>
  by (fact Sliding_\<tau>_transR)



text \<open>\<^term>\<open>P \<triangle> Q\<close> laws\<close>

lemma Interrupt_\<tau>_trans_left: \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<triangle> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<triangle> Q\<close>
  by (simp add: mono_Interrupt_FD)

lemma Interrupt_\<tau>_trans_right: \<open>Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q' \<Longrightarrow> P \<triangle> Q \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P \<triangle> Q'\<close>
  by (simp add: mono_Interrupt_FD)

lemma Interrupt_ev_trans_left:
  \<open>P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> P \<triangle> Q \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<triangle> Q\<close>
  by (simp add: AfterExt_def After_Interrupt Interrupt_\<tau>_trans_left ready_set_Interrupt)

lemma Interrupt_ev_trans_right: \<open>Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q' \<Longrightarrow> P \<triangle> Q \<^sub>F\<^sub>D\<leadsto>(ev e) Q'\<close>
  by (simp add: AfterExt_def After_Interrupt ready_set_Interrupt)



text \<open>\<^term>\<open>P \<Theta> a \<in> A. Q a\<close> laws\<close>

lemma Throw_\<tau>_trans_left:
  \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Longrightarrow> P \<Theta> a \<in> A. Q a \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P' \<Theta> a \<in> A. Q a\<close>
  by (simp add: mono_Throw_FD)

lemma Throw_\<tau>_trans_right: 
  \<open>\<forall>a \<in> A. Q a \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q' a \<Longrightarrow> P \<Theta> a \<in> A. Q a \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P \<Theta> a \<in> A. Q' a\<close>
  by (simp add: mono_Throw_FD)

lemma Throw_event_trans_left: 
  \<open>P \<^sub>F\<^sub>D\<leadsto>e P' \<Longrightarrow> e \<notin> ev ` A \<Longrightarrow> P \<Theta> a \<in> A. Q a \<^sub>F\<^sub>D\<leadsto>e (P' \<Theta> a \<in> A. Q a)\<close>
  apply (simp add: AfterExt_Throw ready_set_Throw image_iff split: event.split)
  apply (intro conjI impI)
  by (metis AfterExt_def Throw_\<tau>_trans_left event.simps(4))
     (solves \<open>simp add: Throw_STOP tick_trans_iff\<close>)

lemma Throw_ev_trans_right: 
  \<open>P \<^sub>F\<^sub>D\<leadsto>(ev e) P' \<Longrightarrow> e \<in> A \<Longrightarrow> P \<Theta> a \<in> A. Q a \<^sub>F\<^sub>D\<leadsto>(ev e) (Q e)\<close>
  by (simp add: AfterExt_Throw ready_set_Throw split: event.split)





lemma \<open>front_tickFree s \<Longrightarrow> \<bottom> \<^sub>F\<^sub>D\<leadsto>\<^sup>*s P\<close>
  by (fact BOT_trace_trans_anything)



section \<open>Reality Checks\<close>

lemma  \<open>STOP \<^sub>F\<^sub>D\<leadsto>\<^sup>*s P \<longleftrightarrow> s = [] \<and> P = STOP\<close>
  by (fact STOP_trace_trans_iff)

lemma SKIP_trace_trans_iff :
  \<open>SKIP \<^sub>F\<^sub>D\<leadsto>\<^sup>*s P \<longleftrightarrow> s = [] \<and> P = SKIP \<or> s = [\<checkmark>] \<and> P = STOP\<close>
  by (simp add: \<tau>_trans_imp_leF_imp_SKIP_trace_trans_iff leFD_imp_leF)



lemma F_iff_exists_trans :
  \<open>(s, X) \<in> \<F> P \<longleftrightarrow> (\<exists>P'. (P \<^sub>F\<^sub>D\<leadsto>\<^sup>*s P') \<and> X \<in> \<R> P')\<close>
  using F_imp_exists_trace_trans leFD_imp_leF trace_trans_imp_F_if_\<tau>_trans_imp_leF by blast

lemma T_iff_exists_trans : \<open>s \<in> \<T> P \<longleftrightarrow> (\<exists>P'. P \<^sub>F\<^sub>D\<leadsto>\<^sup>*s P')\<close>
  by (meson T_imp_exists_trace_trans leFD_imp_leF leF_imp_leT trace_trans_imp_T_if_\<tau>_trans_imp_leT)

lemma D_iff_trace_trans_BOT: \<open>s \<in> \<D> P \<longleftrightarrow> P \<^sub>F\<^sub>D\<leadsto>\<^sup>*s \<bottom>\<close>
  using D_imp_trace_trans_BOT leFD_imp_leD trace_trans_BOT_imp_D_if_\<tau>_trans_imp_leD by blast
 


section \<open>Other Results\<close>

lemma trace_trans_ready_set_subset_ready_set_AfterTrace: 
  \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sup>*s Q \<Longrightarrow> ready_set Q \<subseteq> ready_set (P afterTrace s)\<close>
  by (metis T_iff_exists_trans T_imp_trace_trans_iff_AfterTrace_\<tau>_trans \<tau>_trans_anti_mono_ready_set)
       
lemma trace_trans_imp_ready_set:
  \<open>P \<^sub>F\<^sub>D\<leadsto>\<^sup>*(s @ e # t) Q \<Longrightarrow> e \<in> ready_set (P afterTrace s)\<close>
  using T_iff_exists_trans ready_set_AfterTrace by blast

lemma AfterTrace_\<tau>_trans_if_\<tau>_trans_imp_leT : 
  \<open>(P \<^sub>F\<^sub>D\<leadsto>\<^sup>*s Q) \<longleftrightarrow> s \<in> \<T> P \<and> P afterTrace s \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> Q\<close>
  using T_iff_exists_trans T_imp_trace_trans_iff_AfterTrace_\<tau>_trans by blast


lemma \<open>deadlock_free P \<longleftrightarrow> DF UNIV \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P\<close>
  by (simp add: deadlock_free_def)

lemma \<open>deadlock_free\<^sub>S\<^sub>K\<^sub>I\<^sub>P P \<longleftrightarrow> DF\<^sub>S\<^sub>K\<^sub>I\<^sub>P UNIV \<^sub>F\<^sub>D\<leadsto>\<^sub>\<tau> P\<close>
  by (fact deadlock_free\<^sub>S\<^sub>K\<^sub>I\<^sub>P_FD)


section \<open>Summary: Operational Rules\<close>

text \<open>In this section, we will just write down the operational 
      laws that we have proven in a fancy way.\<close>

paragraph \<open>Absorbance rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] event_trans_\<tau>_trans} \qquad
      @{thm[mode=Rule] \<tau>_trans_event_trans}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>SKIP\<close> rule\<close>
text \<open>\begin{center}
      @{thm[mode=Axiom] SKIP_trans_tick}
      \end{center}\<close>

paragraph \<open>\<^term>\<open>e \<rightarrow> P\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule, eta_contract=false] ev_trans_Mprefix} \qquad
      @{thm[mode=Rule, eta_contract=false] ev_trans_Mndetprefix}

      @{thm[mode=Axiom] ev_trans_prefix}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Ndet\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Axiom] \<tau>_trans_NdetL} \qquad
      @{thm[mode=Axiom] \<tau>_trans_NdetR}
      
      @{thm[mode=Rule, eta_contract=false] \<tau>_trans_GlobalNdet}
      \end{center}\<close>

paragraph \<open>\<^term>\<open>\<mu> X. f X\<close> rule\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] fix_point_\<tau>_trans}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Det\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] \<tau>_trans_DetL} \qquad
      @{thm[mode=Rule] \<tau>_trans_DetR}
      
      @{thm[mode=Rule] event_trans_DetL} \qquad
      @{thm[mode=Rule] event_trans_DetR}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Seq\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] \<tau>_trans_SeqL} \qquad
      @{thm[mode=Rule] ev_trans_SeqL}

      @{thm[mode=Rule] \<tau>_trans_SeqR}
      \end{center}\<close> 

paragraph \<open>\<^const>\<open>Hiding\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] \<tau>_trans_Hiding} \qquad
      @{thm[mode=Rule] tick_trans_Hiding}
      
      @{thm[mode=Rule] ev_trans_Hiding_notin} \qquad
      @{thm[mode=Rule] ev_trans_Hiding_inside}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Renaming\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] \<tau>_trans_Renaming} \qquad
      @{thm[mode=Rule] tick_trans_Renaming}
      
      @{thm[mode=Rule] ev_trans_Renaming}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Sync\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] \<tau>_trans_SyncL} \qquad
      @{thm[mode=Rule] \<tau>_trans_SyncR}
      
      @{thm[mode=Rule] ev_trans_SyncL} \qquad
      @{thm[mode=Rule] ev_trans_SyncR}

      @{thm[mode=Rule] ev_trans_SyncLR}

      @{thm[mode=Rule] tick_trans_SyncL} \qquad
      @{thm[mode=Rule] tick_trans_SyncR}

      @{thm[mode=Axiom] \<tau>_trans_SKIP_Sync_SKIP}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Sliding\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] Sliding_\<tau>_trans_left} \qquad
      @{thm[mode=Rule] Sliding_event_transL}
      
      @{thm[mode=Axiom] Sliding_\<tau>_transR}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Interrupt\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule] Interrupt_\<tau>_trans_left} \qquad
      @{thm[mode=Rule] Interrupt_\<tau>_trans_right}
      
      @{thm[mode=Rule] Interrupt_ev_trans_left} \qquad
      @{thm[mode=Rule] Interrupt_ev_trans_right}
      \end{center}\<close>

paragraph \<open>\<^const>\<open>Throw\<close> rules\<close>
text \<open>\begin{center}
      @{thm[mode=Rule, eta_contract=false] Throw_\<tau>_trans_left} \qquad
      @{thm[mode=Rule, eta_contract=false] Throw_\<tau>_trans_right}
      
      @{thm[mode=Rule, eta_contract=false] Throw_event_trans_left} \qquad
      @{thm[mode=Rule, eta_contract=false] Throw_ev_trans_right}
      \end{center}\<close>



end

