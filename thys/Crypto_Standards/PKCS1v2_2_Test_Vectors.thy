theory PKCS1v2_2_Test_Vectors
  imports PKCS1v2_2_Interpretations
          Efficient_Mod_Exp
          
begin

section \<open>FIPS 186 Test Vectors\<close>

text \<open>
http://csrc.nist.gov/groups/STM/cavp/documents/dss/186-3rsatestvectors.zip
https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.186-5-draft.pdf

The RSA Cryptography Standard is not a NIST standard, per se.  It is published by RSA Laboratories.
So NIST does not publish test vectors for RSA as it does for its own standards.  However, RSA
does appear in FIPS 186, which currently is in version 5 in a draft form.  FIPS 186 is the Digital
Signature Standard and includes PKCS #1 in section 5.  There NIST provides guidelines for how
RSA should be used in a secure manner.  For example, it insists that only approved hash functions,
meaning hash functions approved by NIST, should be used.  It also insists that the encryption
exponent e should be larger than 2^16.  See FIPS 186 for more details.

Because RSA appears in FIPS 186, NIST provides test vectors for the signature scheme RSASSA-PSS.
The test vectors used in this theory are found in the first link above.
\<close>

subsection \<open>RSASSA-PSS: Mod Size 2048\<close>

text \<open>The first set of test vectors use a modulus n of 2048 bits.  We are also provided the 
encryption exponent e and the decryption exponent d.  These test vectors are from the file
SigGenPSS_186-3.txt, which is contained in the zip file linked at the top of this theory.  All
test vectors in that file are tested in this theory.\<close>

definition n2048 :: nat where
  "n2048 = 0xc5062b58d8539c765e1e5dbaf14cf75dd56c2e13105fecfd1a930bbb5948ff328f126abe779359ca59bca752c308d281573bc6178b6c0fef7dc445e4f826430437b9f9d790581de5749c2cb9cb26d42b2fee15b6b26f09c99670336423b86bc5bec71113157be2d944d7ff3eebffb28413143ea36755db0ae62ff5b724eecb3d316b6bac67e89cacd8171937e2ab19bd353a89acea8c36f81c89a620d5fd2effea896601c7f9daca7f033f635a3a943331d1b1b4f5288790b53af352f1121ca1bef205f40dc012c412b40bdd27585b946466d75f7ee0a7f9d549b4bece6f43ac3ee65fe7fd37123359d9f1a850ad450aaf5c94eb11dea3fc0fc6e9856b1805ef"

lemma n2048_gr_1: "1 < n2048" 
  using n2048_def by presburger

definition e2048 :: nat where
  "e2048 = 0x86c94f" 

definition d2048 :: nat where
  "d2048 = 0x49e5786bb4d332f94586327bde088875379b75d128488f08e574ab4715302a87eea52d4c4a23d8b97af7944804337c5f55e16ba9ffafc0c9fd9b88eca443f39b7967170ddb8ce7ddb93c6087c8066c4a95538a441b9dc80dc9f7810054fd1e5c9d0250c978bb2d748abe1e9465d71a8165d3126dce5db2adacc003e9062ba37a54b63e5f49a4eafebd7e4bf5b0a796c2b3a950fa09c798d3fa3e86c4b62c33ba9365eda054e5fe74a41f21b595026acf1093c90a8c71722f91af1ed29a41a2449a320fc7ba3120e3e8c3e4240c04925cc698ecd66c7c906bdf240adad972b4dff4869d400b5d13e33eeba38e075e872b0ed3e91cc9c283867a4ffc3901d2069f"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.  Note that we can't do a global interpretation inside a locale.  So we just have to
assume p and q exists.  Yes, this is a hacky workaround.\<close>
axiomatization where MissingPandQ: "\<exists>p q. PKCS1_validRSAprivateKey n2048 d2048 p q e2048"

lemma FunctionalInverses1: "\<forall>m<n2048. PKCS1_RSADP n2048 d2048 (PKCS1_RSAEP n2048 e2048 m) = m"
  by (meson MissingPandQ PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2: "\<forall>c<n2048. PKCS1_RSAEP n2048 e2048 (PKCS1_RSADP n2048 d2048 c) = c"
  by (meson MissingPandQ PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

subsubsection \<open>with SHA-224 (Salt len: 15)\<close>

text \<open>Now with our encryption/decryption primitives set up, and the appropriate EMSA_PSS locale,
we can interpret the RSASSA-PSS (probabilistic signature scheme) with those functions.\<close>
global_interpretation RSASSA_PSS_ModSize2048SHA224: 
  RSASSA_PSS MGF1wSHA224 SHA224octets 28 "PKCS1_RSAEP n2048 e2048" "PKCS1_RSADP n2048 d2048" n2048
  defines ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA224.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA224.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA224_k                                = "RSASSA_PSS_ModSize2048SHA224.k"
  and     ModSize2048SHA224_modBits                          = "RSASSA_PSS_ModSize2048SHA224.modBits"
  and     ModSize2048SHA224_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize2048SHA224.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA224 SHA224octets 28" by (simp add: EMSA_PSS_SHA224.EMSA_PSS_axioms) 
  have 5: "0 < n2048"                            using zero_less_numeral n2048_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048 e2048 m < n2048"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048 d2048 c < n2048" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048. PKCS1_RSADP n2048 d2048 (PKCS1_RSAEP n2048 e2048 m) = m" 
    using FunctionalInverses1 by blast
  have 9: "\<forall>c<n2048. PKCS1_RSAEP n2048 e2048 (PKCS1_RSADP n2048 d2048 c) = c" 
    using FunctionalInverses2 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA224 SHA224octets 28 (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-224. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA224_Msg0 :: octets where
  "ModSize2048SHA224_Msg0 = nat_to_octets 0x37ddd9901478ae5c16878702cea4a19e786d35582de44ae65a16cd5370fbe3ffdd9e7ee83c7d2f27c8333bbe1754f090059939b1ee3d71e020a675528f48fdb2cbc72c65305b65125c796162e7b07e044ed15af52f52a1febcf4237e6aa42a69e99f0a9159daf924bba12176a57ef4013a5cc0ab5aec83471648005d67d7122e"

definition ModSize2048SHA224_S0 :: octets where
  "ModSize2048SHA224_S0 = nat_to_octets 0x7e628bcbe6ff83a937b8961197d8bdbb322818aa8bdf30cdfb67ca6bf025ef6f09a99dba4c3ee2807d0b7c77776cfeff33b68d7e3fa859c4688626b2441897d26e5d6b559dd72a596e7dad7def9278419db375f7c67cee0740394502212ebdd4a6c8d3af6ee2fd696d8523de6908492b7cbf2254f15a348956c19840dc15a3d732ef862b62ede022290de3af11ca5e79a3392fff06f75aca8c88a2de1858b35a216d8f73fd70e9d67958ed39a6f8976fb94ec6e61f238a52f9d42241e8354f89e3ece94d6fa5bfbba1eeb70e1698bff31a685fbe799fb44efe21338ed6eea2129155aabc0943bc9f69a8e58897db6a8abcc2879d5d0c5d3e6dc5eb48cf16dac8"

definition ModSize2048SHA224_SaltVal :: octets where
  "ModSize2048SHA224_SaltVal = nat_to_octets 0x463729b3eaf43502d9cff129925681"

lemma ModSize2048SHA224_SaltInputValid:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA224_SaltVal"
  by eval

lemma ModSize2048SHA224_TestVector0:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg0 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S0" 
  by eval

text \<open>Because SaltVal is a valid input for the EMSA encoding scheme, and because we have shown
that signing Msg0 with SaltVal produces the signature S0, we know that the RSASSA_PSS_Verify
function applied to Msg0 and S0 will return true.  We don't bother to prove this lemma for the
remaining test vectors, but it is true for all of them.\<close>
lemma ModSize2048SHA224_TestVector0_SigVerifies:
  assumes "sLen = length ModSize2048SHA224_SaltVal"
  shows "ModSize2048SHA224_PKCS1_RSASSA_PSS_Verify ModSize2048SHA224_Msg0 ModSize2048SHA224_S0 sLen"
  by (metis RSASSA_PSS_ModSize2048SHA224.RSASSA_PSS_SigVerifies ModSize2048SHA224_SaltInputValid 
        ModSize2048SHA224_TestVector0 assms)

definition ModSize2048SHA224_Msg1 :: octets where
  "ModSize2048SHA224_Msg1 = nat_to_octets 0x5c61546b848a36e8e51f8beb1140823dbd95b06660924d16fdf9a1c33ca0b994c0745e7eb5be48ada8a58e259cf461a95a1efadb0880d1a6fde510d9d44f4714bff561e81e88d73a51ba23e8ca0178b06698b04dfdc886e23865059ca29b409302eb44f2e9704b588767327ec2ee2d198a0cba0266f2d39453806855cf0b0cd9"

definition ModSize2048SHA224_S1 :: octets where
  "ModSize2048SHA224_S1 = nat_to_octets 0x134e6acd94b76a86e7ff730f064a3d480d1cff1687b993163ce09f21d494a4a15e6d92758a93f7c83ead21c4ca290f9478241c9811c231f32d9d17e0b479a9b34cad02e5bbdde6c8e4ec4f35f93524f8afde49e6a4740bab2f2fdeff3fc5d92a1b50adc7af964eec82fb80be24092ab28791807c664a9106b5df3296747c014b75d69d181f2e58dafbbf9127164f88c862a48d5e9edcd6d2b2cbc20abceb0e98c7e731d27c8d04fad95ff50dd64af20e6388ed74b9b3cf33b4a316b0c752f33697e5a7445ae2f726f30333f107928872776225a3e0b1b14a7e84f9a695c7b3910330d225b4834110b54d6b05e69df6b7a2c9dc352942e3bce970cec677253230"

lemma ModSize2048SHA224_TestVector1:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg1 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S1"
  by eval

definition ModSize2048SHA224_Msg2 :: octets where
  "ModSize2048SHA224_Msg2 = nat_to_octets 0x7540edea54a4fa579684a5b59c51eb20e61106f82157917c6173ee9babe6e506b6198d8af24e709dcad6ea372684d2e335635c1569a43ebec3da121e506afcd9f43c8c4e66b7e6247ced2025a912eb50c43376290a248f5467bb0c62f13b69ebb513b2ddb7c9a31334310f2a2ae27e901bea1add0dc1cc67d57ca21095437463"

definition ModSize2048SHA224_S2 :: octets where
  "ModSize2048SHA224_S2 = nat_to_octets 0x45541aa65fbb0773b1434c4fdaafe23fe800f78eba900c6104a6f0e76dc08daedc28a3380c8078f82055cd4a20cf30541c32d9ac625378355c156880b35a29645325d488f7a0d2de7df92cf9bccdf851445c2b834ad0e6849a6549db72affa7ce66fbbfc5bc0194504a5fb031267b6ca9b57f583e7e11c927e3dc203f7d6d4b9df675d2a302231400008fbbd4a05e17f88bea074de9ab8211a18dcceae6c9fd8fad96ce0626eb25c9ab81df55ba4d0a6ae01eb25a2529e16c98ded286cb345d4fd59124297ba9b3efcb67884ed853ea96d74e00951987bcda54d404d08f2baf7f0d7ff13d81d1fa20cde1d21663684c13ffc7164448f4e85a6c811a850a3faed"

lemma  ModSize2048SHA224_TestVector2:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg2 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S2"
  by eval

definition ModSize2048SHA224_Msg3 :: octets where
  "ModSize2048SHA224_Msg3 = nat_to_octets 0x840ff32993223efe341eeb55558e6ab1fbae15d17bcf0731edfd32d4dee0ac4145e04accb88c7016e03d27d72bf670dbc08fd94bb8134d2e8b66302fc82baca10ae445c0275bb43aaa42f2ee841693f3fe4955dcf29ff93a3bd951636a919b72ba650d8f4757b1717a747320c8b479009c22b20b913cb25ee59dbdf72bd921bd"

definition ModSize2048SHA224_S3 :: octets where
  "ModSize2048SHA224_S3 = nat_to_octets 0x07f07ef5e793d59b0c3f899dc846bb831d88dd4d2d8345ad2d726c5c532d13e05b26f0fd03b2b9bde7b6d5b6febc8fe5d3228887eac443c99ec39fffeb939785f87be8a93e497cfdea3d8d06356518a5254c5946236458b29f1cd47e97718c805b167791d10f9304328635330116a2aeae1e0ecc16bfd5a31356d06892b8ca04aec27a417320be7bf6fc1083d70fa522c23850f5d6beda1a251d1a5e71762bc8fd5f16ef0c7a961f4858a5b760a8032f3fd6bdce2ed26351f2beab8b89d9312d88736ee5253a9da6753283e5b3d0d9cdd3e19ca0b60b9fae3e3dfd67831df72ed9611d5f2b3ac256052a207a5245d2cdeaad0d1266c7177b1a0844d5974a8a41"

lemma ModSize2048SHA224_TestVector3:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg3 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S3"
  by eval

definition ModSize2048SHA224_Msg4 :: octets where
  "ModSize2048SHA224_Msg4 = nat_to_octets 0xa5fb396eee4045f886191f7ff9ea68aaa1bcd8e781903b6071f3ba2b7cd35cc08691cdb131575d9502ac4b45c046444c1d1f279899cb0b76a20883bd00972148704a38aa8f5fe61efa0c52bdb45b33f4c83892342fc8d0ebf3fdeab49568fccaad4e04c3d0fde97bb660bc4e9cd23d8ae830a1230c3292a9acfb787803eef72f"

definition ModSize2048SHA224_S4 :: octets where
  "ModSize2048SHA224_S4 = nat_to_octets 0x4428c389d0c80a9320e4859e41cbd4a47f78e4da5d1c0644ff50bad172de9ffe74d84a76d6de4f72bbe34d7dccaa03e1324041cb98308d73dcff0bcf7ffc35936473cf3ec53c66ea8a6135742e0ea9056a4897a7cbd2b0654b344786bf3047d122dcbbc4bea1840e84bce066c3385dccb021a79e8de18dc114a40d824141d8331a4df6901b3409c30552519b097a96ded6793cbb9ae18bb9a4185b6f4e83aad6dce878c689bf595d272719b9f50b3ede1803dfae6dd3f54e4ca9c458c14463f4f19af6cc8127bec80a6a9e5a5fe0d3e14dfcc6ba052750ebbf84a652adde9d6be68d5b134cd09bb94d0875e5527fe3f3fa2a516dc05c14fd5516dff2d434f0c4"

lemma ModSize2048SHA224_TestVector4:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg4 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S4"
  by eval

definition ModSize2048SHA224_Msg5 :: octets where
  "ModSize2048SHA224_Msg5 = nat_to_octets 0x6e891589d71d2eff6cb986b071a31e2696d8ce671fa18c244267eb33d0c8e24018ebcfbf0910bb24966be0575f3268628df5786dfd2e6deda219661824c5029ccd6b6b90a60093abdd06bdb46aa74039f2048784eccb5dcb020767a7ba3df2c755b4f0e6f8143cfa093326afdc2b2b138fb0049332a0e3262bdcf9c8d9573b2a"

definition ModSize2048SHA224_S5 :: octets where
  "ModSize2048SHA224_S5 = nat_to_octets 0x01909328c24dd0ef912040f61492e3711243f8ca1262067cca6bdab165efe4157982323f13152999e9f21e6852d8c2efc4130e2c46a38446aacfc59fbca5d1a38946923b7e08be397fb787bc79a71ba08fc2b693d1bcbe897d1dface2858ba80a086a0e0a45efe66fd5350add819fd0dc1931d3eba2765f84f147422f5330d0efa0cd827197a5d89e2dd62db9051d5df8b9680169f349086dd038a9ac62f9941565b3f747d528ec4c36e9c948ad3a73240d07ef14b354ffef1b1965a9aafb13d0fc88a09707c6a0ad3028d5a5c6efaab50aad05304b1d5b2930abb8f58c0188b6a94231f8698c96ddd614343a0218494dfff9a293dfc7d5c3b5afbed8f079458"

lemma ModSize2048SHA224_TestVector5:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg5 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S5"
  by eval

definition ModSize2048SHA224_Msg6 :: octets where
  "ModSize2048SHA224_Msg6 = nat_to_octets  0xd66747638d8276920352b215158cefe0727a5e2b079d892cbb969f265d470ca2da354dfcb4300322af374699ce963bc17d51e95910c548456c8d9b8f04a300ad08c74602d825fea7bf32d56aded7211766d1b9f70b580a97b5fe67ca78dba1f1c6e7d87ae3a790a79a0c07912f98c76c94c2770cdf9cf6a8fcb3abdf9f3616f8"

definition ModSize2048SHA224_S6 :: octets where
  "ModSize2048SHA224_S6 = nat_to_octets  0x85f296084bda823556aa369e5cb19e10ce6e982a6d10a85ba6af6d3fed8f2c05599faed069215cc9eed9e72a4fe510a6c09ff721cf1a860e48cf645438c92c5c86d0885e7d246ccf9d0cfd8c56ca8d673b7094a3daa77db272d716f31b1380f72b50378f595471e4e481851c57a6b574bfb3fc7aa03636632045fcc8e9cc54594759f6014b527877e605ef60cf109b4ca71e772a99acfc7243318655ec50f74e48485668ed42859ff2c5934581ba184d926c8467d7c35257dce9964049568a990f65d591c2db86b48a7256da947fd7d978dd6734bd8685025d1a87e32f52a0299394c93e6d518b18e0b8db1d763f46905f405df0cbc8455e039f173e2b68c9de"

lemma ModSize2048SHA224_TestVector6:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg6 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S6"
  by eval

definition ModSize2048SHA224_Msg7 :: octets where
  "ModSize2048SHA224_Msg7 = nat_to_octets  0x23d92665e88a4f6f732de384034d493d5df37b767a8260557de05688e8d60dcd0eba9cb8cc4bceb174dcbd3c0ab5a37db3b6ecfb6a3d90a4f54a9f1117e11e0c08b0114f22f2d98fdd93c0b9fd95d37c0ab2f00701431f1449602525e849570df704adb353481713969a148546b680424c30ad24a75bb6ad616a104bc2d562da"

definition ModSize2048SHA224_S7 :: octets where
  "ModSize2048SHA224_S7 = nat_to_octets  0x8beeb201aedb9fe7d535fc7989713062497a03e18ef9977b98a93f18f37545c38f5e5206e2b5df7f4a41ab9e0675f7d46d172dc3af90fb7b1a6fa6c986b803a7f2ea4ed217872cc686165b1278450c23c329ee2855f65e651c3db085e407bf3e3a96eaa833ba2056a084031546cea2f454f7acf84c3b90fd7b6210ef6d1ad71ed1b0049262f5b4e3ca99d10a3307752b2ad8e8fbba3a3e8432bc966553901e87150738aac9170fab1d27219274ec528299f8afbbd861ee837f2c86ecce7e73c9b7bd6f6661d1efe3fd2ff7b3efa0d1fc7b84fefffa14b55a2c5fe3252cae0cf0da6e50e3d615f86ae6721aa5e29ed3a1c71c243c2529eef483c56b902e93718c"

lemma ModSize2048SHA224_TestVector7:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg7 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S7"
  by eval

definition ModSize2048SHA224_Msg8 :: octets where
  "ModSize2048SHA224_Msg8 = nat_to_octets  0x40abb42db34067fadb5aacbb2fdedd2d0324030bb75ca58f2e2ade378194b2c5f51ea2892b337ee297c77b03333b86f37581d7d77e80c87494bae8f0d22c4bd81e7525685c3b9706e1cbc90f2bff39d6cf6553eab29d41987c0304b14a8fc48ea4f96450ae205a6ca2acbe687df2a0dff9199fcbbc7bb704cf4e5b035184c4ec"

definition ModSize2048SHA224_S8 :: octets where
  "ModSize2048SHA224_S8 = nat_to_octets  0x54bec66241dc197ad92e695526b3b6a030216b48af90d93c36b2d70644e40cda2cb259f27ca9d141e5753f938497e84208b380ffe1788701c71d89bbea3edd352dabd32d9425edcf9a33e185cbc4031aa6069863fe47d499536a59da12a8bdbbf2a3a9f0039318d066f5117bbf6fce4f6752088ccc3a081d85da461a8bdcaf349fd4054f76384e668d00a6f747688c8420c7e452b0736ad62e1738a3f10cb62bc7ddc12fa670f858b2d5def9a42ac8f2fc91d488738a7c23168f51ddfbdae6a5d8ee1fc561cc3add4a7e14eb103bf9593cebf391c1f7a07d262faf03d47d07424ffb3a916a9564652a1be020a0e922e99a57da1abf931f74cfbdd484c0a9568f"

lemma ModSize2048SHA224_TestVector8:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg8 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S8"
  by eval

definition ModSize2048SHA224_Msg9 :: octets where
  "ModSize2048SHA224_Msg9 = nat_to_octets  0xef10b03c04578bd5f783358df367456a73de38c6fab2c35405bc685e3d4c4850f2cb387ac59e1612a44e5e78fce6f8be299d546832b5b970b3a3da8e1a70abb6165f72e14dd021104e64e38ec662f576f65ab776640803d2d17abdac6c75ab82451687f804b553d8db0eed57b9a3e39ac15c8878fa714882488938409b24f1be"

definition ModSize2048SHA224_S9 :: octets where
  "ModSize2048SHA224_S9 = nat_to_octets  0x4a183b82616f3bbc27a146710b28729161feb17900be62e69eed5d254d15f34bce52d6f3deba89a787ebeb0611e240cc23e16add3796d4a29783e2cbe8797e066cecbd66059c394f0e2f9e377f1ffa194fcb895e1c48874b9b6430a13c779f5ca29e3f42bca4b916710590ab6501809d645a4885b058dba0647971f04f6f2f4a296c45d89dd848b7c2f8777ec50846c97d35c12d54ebb6ff167327b1d4daedf4468031b59057d57ceddb79fdd013167ee6e46d9130693322c3ae6702901a1e90bd4b621d141977d0680acd524921bc540e34ac640ace02f89d5436808283e026e138ba3a5a4310fe1e048833f9b581baef5f891f9cdb2f0673bafa11ceabc7d7"

lemma ModSize2048SHA224_TestVector9:
  "ModSize2048SHA224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA224_Msg9 ModSize2048SHA224_SaltVal 
         = ModSize2048SHA224_S9"
  by eval


subsubsection \<open>with SHA-256 (Salt len: 20)\<close>

text \<open>Now we can interpret the RSASSA-PSS (probabilistic signature scheme) with the encoding 
scheme EMSA-PSS that uses SHA-256 and with the specific values for n, e, and d.\<close>

global_interpretation RSASSA_PSS_ModSize2048SHA256: 
  RSASSA_PSS MGF1wSHA256 SHA256octets 32 "PKCS1_RSAEP n2048 e2048" "PKCS1_RSADP n2048 d2048" n2048
  defines ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA256.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA256.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA256_k                                = "RSASSA_PSS_ModSize2048SHA256.k"
  and     ModSize2048SHA256_modBits                          = "RSASSA_PSS_ModSize2048SHA256.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA256 SHA256octets 32" by (simp add: EMSA_PSS_SHA256.EMSA_PSS_axioms)
  have 5: "0 < n2048"                            using zero_less_numeral n2048_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048 e2048 m < n2048"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048 d2048 c < n2048" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048. PKCS1_RSADP n2048 d2048 (PKCS1_RSAEP n2048 e2048 m) = m" 
    using FunctionalInverses1 by blast
  have 9: "\<forall>c<n2048. PKCS1_RSAEP n2048 e2048 (PKCS1_RSADP n2048 d2048 c) = c" 
    using FunctionalInverses2 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA256 SHA256octets 32 (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-256. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA256_Msg0 :: octets where
  "ModSize2048SHA256_Msg0 = nat_to_octets 0xdfc22604b95d15328059745c6c98eb9dfb347cf9f170aff19deeec555f22285a6706c4ecbf0fb1458c60d9bf913fbae6f4c554d245d946b4bc5f34aec2ac6be8b33dc8e0e3a9d601dfd53678f5674443f67df78a3a9e0933e5f158b169ac8d1c4cd0fb872c14ca8e001e542ea0f9cfda88c42dcad8a74097a00c22055b0bd41f"

definition ModSize2048SHA256_S0 :: octets where
  "ModSize2048SHA256_S0 = nat_to_octets 0x8b46f2c889d819f860af0a6c4c889e4d1436c6ca174464d22ae11b9ccc265d743c67e569accbc5a80d4dd5f1bf4039e23de52aece40291c75f8936c58c9a2f77a780bbe7ad31eb76742f7b2b8b14ca1a7196af7e673a3cfc237d50f615b75cf4a7ea78a948bedaf9242494b41e1db51f437f15fd2551bb5d24eefb1c3e60f03694d0033a1e0a9b9f5e4ab97d457dff9b9da516dc226d6d6529500308ed74a2e6d9f3c10595788a52a1bc0664aedf33efc8badd037eb7b880772bdb04a6046e9edeee4197c25507fb0f11ab1c9f63f53c8820ea8405cfd7721692475b4d72355fa9a3804f29e6b6a7b059c4441d54b28e4eed2529c6103b5432c71332ce742bcc"

definition ModSize2048SHA256_SaltVal :: octets where
  "ModSize2048SHA256_SaltVal = nat_to_octets 0xe1256fc1eeef81773fdd54657e4007fde6bcb9b1"

lemma ModSize2048SHA256_SaltInputValid:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA256_SaltVal"
  by eval

lemma ModSize2048SHA256_TestVector0:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg0 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S0"
  by eval

definition ModSize2048SHA256_Msg1 :: octets where
  "ModSize2048SHA256_Msg1 = nat_to_octets 0xfd6a063e61c2b354fe8cb37a5f3788b5c01ff15a725f6b8181e6f6b795ce1cf316e930cc939cd4e865f0bdb88fe6bb62e90bf3ff7e4d6f07320dda09a87584a0620cada22a87ff9ab1e35c7977b0da88eab00ca1d2a0849fec569513d50c5e392afc032aee2d3e522c8c1725dd3eef0e0b35c3a83701af31f9e9b13ce63bb0a5"

definition ModSize2048SHA256_S1 :: octets where
  "ModSize2048SHA256_S1 = nat_to_octets 0x492b6f6884df461fe10516b6b8cc205385c20108ec47d5db69283f4a7688e318cfdc3c491fb29225325aeb46efc75e855840910bbaf0d1c8d4784542b970754aaa84bfe47c77b3a1b5037d4d79759471e96cc7a527a0ed067e21709ef7f4c4111b60b8c08082c8180c7c96b61c0f7102ed9b90e24de11e6298bb244518f9b446ce641fe995e9cc299ed411b65eb25eaae9e553484a0a7e956eadf0840888c70e5ca6ebc3e479f8c69c53cf31370ab385e8b673dc45a0c1964ec49468d18246213a8f93a2a96aad5a2701c191a14a31519e4f36544d668708ff37be5481cb0ffa2b0e1f145e29f8575dfa9ec30c6cb41c393439292210ea806a505598ebdf0833"

lemma ModSize2048SHA256_TestVector1:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg1 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S1"
  by eval

definition ModSize2048SHA256_Msg2 :: octets where
  "ModSize2048SHA256_Msg2 = nat_to_octets 0x7e6690203cb068b8530cb1ff4eeaf0fc69a4e304f556072dfeef5c052c886c83e7f58a3dbe9a58dc0a808ccdcea9f33ae2a0b6395153dc43ff2510e78f40a4bf8328d7a4a596531ea683fa1e0683e2f033549e6bf5b7c06b097e9b810de74ee89c28febbb94b6266713c855bbc21c706a5e92502aa28bb8d662287396d2570e5"

definition ModSize2048SHA256_S2 :: octets where
  "ModSize2048SHA256_S2 = nat_to_octets 0x509a01bb0360d1160ed3ff33432291cfbb63daa2933819600db7dd825aef13dd1e9a888a9fb6fea93debd4cf4bc77129b06dd4727193d7e8a2e5aa5a6020b64524e93abb0406f5a18f74ff0aa804919df4072e319ce8234431c94e8eef8c5ce813a07b2f66dd6a032c3e69a3c58c6b54acf08bbbb019df15f3abd22c67f3e2cbffe99887adee58a39cc30ac45a6e6e59283ee0890aa87072a857845f5cf3ddacdc776e58e50b66e95eb13dec49ce45505c378734e964e8095d34a01317768b7b9fbef6eb24b08b1bf0312ab51e0acea4a3dfdfa6fa7bb115b8b685d354841d1901bc73cc655ae246a5453ea8d160610425c2c14969bf22a7e11e663cff1501f1"

lemma ModSize2048SHA256_TestVector2:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg2 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S2"
  by eval

definition ModSize2048SHA256_Msg3 :: octets where
  "ModSize2048SHA256_Msg3 = nat_to_octets 0x1dce34c62e4aef45e1e738497b602e82c1fe469f730cf164178b79fdf7272c926d69bd1b5e2de776055753b6f2c2bcbf52795110702a5bdf7cd71f6b8ccf068ee0ddfb916abf15458dd9764f262b73c4c981f5f64de91e8d8a6a30d961f3ab66fd92b6d159e6c0db02d767bc1f8499baae7df9f910338495c8ad74ee807c6443"

definition ModSize2048SHA256_S3 :: octets where
  "ModSize2048SHA256_S3 = nat_to_octets 0x1bd79d25ac6b0f242f39555c85d858c23680e1ebf9590d05463ebc58454a7822cf0e0c2ab9872b6eac5ae8ce3da773d6b2039e9b26ce751dadc48579320ea63b978b0df038191d9128102128a365c01d9e2b43fe2b5ef1ce9ee8f4a1e12caef1bbe7f3a8d1a93c9f399753bbfd60d22d8f39206a511ea448dc23cc0e4fcf0b77d3f3fbd9188b740de3f85009de94ee157dbf7edc3165e9f69b59db37f7fdc507496de8941a2a2628774b06c8cab034bbe3d2c04d253b5948d6e5712373ada99b7f860612440c5eed81efeea18d76329dc30bd9fcc500e92315677142d5e1b6b45ae0e6e725122f046c9a544ad1ef1ddc7c6b2a7809715ab75ef870ee6670627a"

lemma ModSize2048SHA256_TestVector3:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg3 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S3"
  by eval

definition ModSize2048SHA256_Msg4 :: octets where
  "ModSize2048SHA256_Msg4 = nat_to_octets 0xc32976432e240d23df6594f2885f00db7fa7e53b7aa84ef89798ec149fab74828b86423847f64285b7e210a5f87e5e93e8c2971ee81bc13fe060a8aa840739a3d6992c13ec63e6dbf46f9d6875b2bd87d8878a7b265c074e13ab17643c2de356ad4a7bfda6d3c0cc9ff381638963e46257de087bbdd5e8cc3763836b4e833a42"

definition ModSize2048SHA256_S4 :: octets where
  "ModSize2048SHA256_S4 = nat_to_octets 0xbe69c54dad9d8b6db7676fe74321a0aeb08d1cc17f6607e87982f99489344e99378c38341e0e605b8ff903c74a973872a9880e05a8ef0bd3e6049931acf152dd54fec9105a57b73f77631db736b427f1bd83275e0173d4e09cd4f8c382e8b502a3b0adbd0c68911d02de17fff3d927e250e1826762efc0b895dfa502f18dc334b4c573f99b51b74fdd23009861028f1eed6875bf31d557acd6de8f63fa1274f7bed7a1b4c079f5a9b85bfab29f552c7f647d6c9241563fac123a739674b0ad09c3f94208795d9a50529d799afc597e025f1254995f043234891620b10d5c5569be14b0f463a495f416024618486c7ff5ec775cfb46fbdff5379c5e09150b81a3"

lemma ModSize2048SHA256_TestVector4:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg4 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S4"
  by eval

definition ModSize2048SHA256_Msg5 :: octets where
  "ModSize2048SHA256_Msg5 = nat_to_octets 0x218551f425b3557d09ccfdecc9ab499085bd7fe7d60820be626c1a9aae293f5734a2f60fb661313dd15a9f22d5742268d4458306f91d65631b4777be928beecd4af733a416e0d8d94623d1e67bb0e1ceba4a5204c088e98895201953646477f58a0d6e7ded3834998faefcfe63686e0a5f5354a8d2509675f87f6821cbbdc217"

definition ModSize2048SHA256_S5 :: octets where
  "ModSize2048SHA256_S5 = nat_to_octets 0x96a269e0ca4af626aa8b7f45acdaa76d5dabfea5a7d762ab39b138dc7575fe196aeb182bee5b18503969b5ba111f057ccdbf292d7488173a4a4dd04e62c254d502673d5a076d326c66c9a71a3b83b1005c6366f8a0902987dbf08cee7562d0abffbdd661c3525be8e12dfd73ed31efaa817f61e7fef700a3215e77b6231d59c098fa455b69ec6e658a66cca2e8f2e090ef704270995170ba9a1f561b848676804413645a943d883191d95b024d6ffc9cb611c68f3319403bd7c07ac6694501368e8147a256e928604b63d50e2c65f3b2c30df1eb0363e29fe448f94b6907cdf42fbc9c27b31a43a8f5c15ce813f9b20d16da6c298843f052ed37678b4ef1d78e"

lemma ModSize2048SHA256_TestVector5:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg5 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S5"
  by eval

definition ModSize2048SHA256_Msg6 :: octets where
  "ModSize2048SHA256_Msg6 = nat_to_octets 0x06b76aaeb946fe6867e4716a8f1ee8d61c483ab345cbf8e5b2bfab5ce0bd5c8bc6ee5a1cb96837e28dbb140ffdc61ea74cd059342dd49dbce11bdef09f10b0a638510989fb02490fd66679acbfb0d04652167ce8bc289fbad760973196fa8283a405015e48bb3dd98c0e28ab9e83069a76432b37b97006c9deb55e878f21dc0a"

definition ModSize2048SHA256_S6 :: octets where
  "ModSize2048SHA256_S6 = nat_to_octets 0x65e2358bafc9fcb65536a19d27f710596cc31f9a8328cf9de21257506047ab1340a74505581a54f258bcbe0c1520f84ebd2e36913560dbd71574e3738428097d6b819e6900f27df159dcaf08c6e1591b073bfefe3da6bc827a649e0bae9c52fe9ae180d1efc01e5a38adef102c6d106af12163b1a0f6d1543ffce3980ca0f8b70d38007288d47bc565e995b8c21da2f959c928aa2f8574a660226048dc9dba59526a30e3274808683b41c0cf086ea5afc48eb294a88c4b8b7383dae6469e8483345b1daf1d2801bda93ff91ca75dfaa8dd5d47e73cecf0efb0629fda16c601070bee2e8cc0695150739202e3be270b9801d085e11e1df07f9a4cab54fda23da6"

lemma ModSize2048SHA256_TestVector6:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg6 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S6"
  by eval

definition ModSize2048SHA256_Msg7 :: octets where
  "ModSize2048SHA256_Msg7 = nat_to_octets 0xf91670bf6b8bf5c8c75056d844168fc6ec0c28d09400c1df11c7ef0da9e04664c854b7e8f4e01dd8035612328c4107759bc894aaa9d50ca5cb7655892983f68ab28172f70ec6d577d4de8c93fe2e79749ad747eec2ddfbbecd89cc10c70b35451f6448f2a083452ca2ae6b0382240e4c4f01eaa4c661b7b181c8feab6bc22a1b"

definition ModSize2048SHA256_S7 :: octets where
  "ModSize2048SHA256_S7 = nat_to_octets 0x2eac03233c4e24b3328447cc09661c259676b569e6a0848b5a193065296a59e3b6d35a2ecd91c6cefda4f2bf9f2252a27334fbbc2d79e450d44bc282f7d7321b46f82028c154f30f6d62edf3672a1019d914ec617aab2d007f844e63e295bbd8f66163deb278d99d66fddc58cca2b911ce0af95265134af55a4b786cc214fa11ffa29bcdfbed12c5ce6438e9b6beaeffa3587978a83409c29f115423174c05cb8c30198da8b193f9446b9b49f7e3e2862ec9a350e8441ba4e5550e87db54712865fc2690a5938aebb28409b88cf0d172111a74f678ee0819ff8bdc22b08fc6fed37b676d0705396f3247a267c60f7ccf1fb260c0c2e924c1ef5540eb6125f3b1"

lemma ModSize2048SHA256_TestVector7:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg7 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S7"
  by eval

definition ModSize2048SHA256_Msg8 :: octets where
  "ModSize2048SHA256_Msg8 = nat_to_octets 0x64e3f541453170db952c09b93f98bcf5cb77d8b4983861fa652cb2c31639664fb5d279bdb826abdb8298253d2c705f8c84d0412156e989d2eb6e6c0cd0498023d88ed9e564ad7275e2ebcf579413e1c793682a4f13df2298e88bd8814a59dc6ed5fd5de2d32c8f51be0c4f2f01e90a4dff29db655682f3f4656a3e470ccf44d9"

definition ModSize2048SHA256_S8 :: octets where
  "ModSize2048SHA256_S8 = nat_to_octets 0x76c297fbe302f686377cb155ae8a2b65a6c577af303035c4a755fe67014c560476e7a789b8f2195b0f80416f5f33b7fdccc380f988cebadb640e354bf5679ee973a1e1485b68be432b446ff5949504515a65cddb0faf6dcd1e1188656ce941af3ddc8600cf0e4087ac8382f0d5061d3d05f58c9362eb88f30a724d18a15ee68a60c5e4dedb4084c9d01522999092094c85622e67a66ed034564ac286b0ff8791e9933a23f83b4a88d2e79e3a29d6a3f87e63bb1a96a6bfd6898edaa938f74c72d6c10cb94d055ef3fda9e6dd097d52738754800ed403b1444195a311fd6962007999e31edcf2870d1c3ae3b3646bc7da55e5f1e6627e6248839e8f70b997fc1e"

lemma ModSize2048SHA256_TestVector8:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg8 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S8"
  by eval

definition ModSize2048SHA256_Msg9 :: octets where
  "ModSize2048SHA256_Msg9 = nat_to_octets 0x33ba932aaf388458639f06eb9d5201fca5d106aaa8dedf61f5de6b5d6c81a96932a512edaa782c27a1dd5cb9c912fb64698fad135231ee1b1597eec173cd9ffd15270c7d7e70eced3d44777667bb78844448a4cd49e02a8f465e8b18e126ac8c43082ae31168ed319e9c002a5f969fe59fc392e07332ba45f1f9ea6b9dd5f8a0"

definition ModSize2048SHA256_S9 :: octets where
  "ModSize2048SHA256_S9 = nat_to_octets 0x2891cbe23ccf10c396ef76a5840adaad6498b6fc8c6a2f6c26496cb428a9221ed59b3645f9a25f5747feda0f51b45319e0978f22ac4facbc15db9a4e5849ac2a1404aeb6c00e5eed3c07eeeee2435668fd17f16ab244c9d38f9ba0de9d3f3ef0d994094e92e327948f1409ef827752344a1375f608dc3cafe74970745a023b320b3bd3171b62a68a5ccaadbc64b82cee4b8a81840ed8b751ac66a29eb81fb819ec54c76b01c7b412a43ea057a80202f1c3c06a4ee60547c13c6c2fac34a5d5aae982b9dabd119b470829bd77a560e0973409115bd1ab5bdc6bb46fe4048022b0cf4fc6aad4184c28621ec6f82edb54733c902620bf45f2517f24902e56d58038"

lemma ModSize2048SHA256_TestVector9:
  "ModSize2048SHA256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA256_Msg9 ModSize2048SHA256_SaltVal 
         = ModSize2048SHA256_S9"
  by eval


subsubsection \<open>with SHA-384 (Salt len: 25)\<close>

text \<open>Now we can interpret the RSASSA-PSS (probabilistic signature scheme) with the encoding 
scheme EMSA-PSS that uses SHA-384 and with the specific values for n, e, and d.\<close>

global_interpretation RSASSA_PSS_ModSize2048SHA384: 
  RSASSA_PSS MGF1wSHA384 SHA384octets 48 "PKCS1_RSAEP n2048 e2048" "PKCS1_RSADP n2048 d2048" n2048
  defines ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA384.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA384.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA384_k                                = "RSASSA_PSS_ModSize2048SHA384.k"
  and     ModSize2048SHA384_modBits                          = "RSASSA_PSS_ModSize2048SHA384.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA384 SHA384octets 48" by (simp add: EMSA_PSS_SHA384.EMSA_PSS_axioms)
  have 5: "0 < n2048"                            using zero_less_numeral n2048_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048 e2048 m < n2048"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048 d2048 c < n2048" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048. PKCS1_RSADP n2048 d2048 (PKCS1_RSAEP n2048 e2048 m) = m" 
    using FunctionalInverses1 by blast
  have 9: "\<forall>c<n2048. PKCS1_RSAEP n2048 e2048 (PKCS1_RSADP n2048 d2048 c) = c" 
    using FunctionalInverses2 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA384 SHA384octets 48 (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-384. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA384_Msg0 :: octets where
  "ModSize2048SHA384_Msg0 = nat_to_octets 0x833aa2b1dcc77607a44e804ee77d45408586c536861f6648adcd2fb65063368767c55c6fe2f237f6404250d75dec8fa68bcaf3b6e561863ae01c91aa23d80c6999a558a4c4cb317d540cde69f829aad674a89812f4d353689f04648c7020a73941620018295a4ae4083590cc603e801867a51c105a7fb319130f1022de44f13e"

definition ModSize2048SHA384_S0 :: octets where
  "ModSize2048SHA384_S0 = nat_to_octets 0x2ca37a3d6abd28c1eaf9bde5e7ac17f1fa799ce1b4b899d19985c2ff7c8ba959fe54e5afb8bc4021a1f1c687eebb8cba800d1c51636b1f68dc3e48f63e2da6bc6d09c6668f68e508c5d8c19bef154759e2f89ade152717370a8944f537578296380d1fe6be809e8b113d2b9d89e6a46f5c333d4fd48770fc1ea1c548104575b84cf071042bfe5acf496392be8351a41c46a2cab0864c4c1c5b5e0c7b27e7b88c69f37ffa7e1a8cd98f343ac84a4ad67025a40ed8f664e9d630337de6e48bb2125e2552123609491f183afd92634487f0b2cf971f2626e88858879d45a29b0fefb66cd41b2e4e968385bd9fc8c7211976bc6bd3e1ad6df60856985a825f4726d2"

definition ModSize2048SHA384_SaltVal :: octets where
  "ModSize2048SHA384_SaltVal = nat_to_octets 0xb750587671afd76886e8ffb7865e78f706641b2e4251b48706"

lemma ModSize2048SHA384_SaltInputValid:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA384_SaltVal"
  by eval

lemma ModSize2048SHA384_TestVector0:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg0 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S0"
  by eval

definition ModSize2048SHA384_Msg1 :: octets where
  "ModSize2048SHA384_Msg1 = nat_to_octets 0x8925b87e9d1d739d8f975450b79d0919dde63e8a9eaa1cb511b40fe3abb9cd8960e894770bc2b253102c4b4640c357f5fd6feab39e3bb8f41564d805ceafc8fbdb00b2ea4f29ed57e700c7eff0b4827964619c0957e1547691e6690f7d45258a42959a3d2ff92c915c3a4fb38e19928c5ce3ddf49045f622d0624a677e23eb1d"

definition ModSize2048SHA384_S1 :: octets where
  "ModSize2048SHA384_S1 = nat_to_octets 0x43ef93d14e89b05d5e0db2dbd57a12403910646b4b0a24d9b80d947954591afa6e9809e96d7d3e711003ee0a9186ab3d8e0b4d3425c6da4b5f7899537e737b71df9ed6355529aace77a7cba96b5b0a86399252f1286a6fcab180b598455dfe1de4b80470d06318d5f7a52e45b6d0bcc00bd365819a4a142b83072775f485f63c8004f53378a9a0d2345d07b1b326238ed070d1e69fc0b5cf853a807cfb723562d1f5682482e8a4840588bcc7154ce0740c768616cf04d7aa103642917ec5b4b514a3734d9e0c58427cff42f27f43fdfc85991e045acd17af6fba7bdab818e90eb4117684e89f9163dff7b98b82a08baa2b49acde480c5702c335237d1be771b7"

lemma ModSize2048SHA384_TestVector1:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg1 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S1"
  by eval

definition ModSize2048SHA384_Msg2 :: octets where
  "ModSize2048SHA384_Msg2 = nat_to_octets 0xd0eb4623eedbd97ee03672f8e4174d2e30a68323ce9980e2aafbb864ea2c96b37d2ab550f70e53d29cda03d1ba71a1023de78ba37dfb0e1a5ae21fd98b474c84338ff256b561afc1ca661a54d14db2e2661315e13581731010f6415d4066320519a363fdd2dbd5919362214bceb26716d3b188a39f32950cf5bd87b7b193307e"

definition ModSize2048SHA384_S2 :: octets where
  "ModSize2048SHA384_S2 = nat_to_octets 0x213ea3fb11cdd71bd5b839de8a598b6a142023825e24db7cb1a4459e78092b32b07643c7270839f247870efbd320b419ff3b1914c41b6ca4bc3cf17017d9a94d86f0f022f4495666c4a89f08e216a161d4664f2d616fa4bb2a17ccb85004e63f488ba29564ca136aa3a6f9561f85cb550b8cf8b0a85afbc8aee2c76891a53e7cb66e36f8709e7990d8de8d0c73865c1cb44727f18c0faf25c53f15e070c430e73f77b1e9c8f8ec13114d7e7ac790ade4ec6f1de0cec13f25a48d534965a8ede12090a928a91d5a1f214aefe6cee576ad43eaeccf635409a8646853d9cef93c9c04a884253380a49e682bff0750577c5a80becdef21a4a9793fabb579eb50e3fa"

lemma ModSize2048SHA384_TestVector2:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg2 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S2"
  by eval

definition ModSize2048SHA384_Msg3 :: octets where
  "ModSize2048SHA384_Msg3 = nat_to_octets 0xd58e0997224d12e635586e9cedd82dddf6a268aa5570774c417163f635059ea643c1f24cabbab82eac004a8b9a68bb7e318fc526291b02040a445fa44294cf8075ea3c2114c5c38731bf20cb9258670304f5f666f129a7b135324ac92ec752a11211ce5e86f79bb96c9ed8a5fc309b3216dde2b2d620cd1a6a440aab202690d1"

definition ModSize2048SHA384_S3 :: octets where
  "ModSize2048SHA384_S3 = nat_to_octets 0x4385e67819283d81eab2b59357c51ce37b5ea32b76af345a457e5aa2dd61113865a587d2c8a8f1c8825281c052a88fc67797adb6251d28efb911564671affcbfc7e1a3c055dce8d93497fe80da459647ac71f17e9aa07d1aafd5260ac284d622a03b6670c55b0d40696d436c638f9b48bd08f37db4eaf1d9746d2c24de347dcca0a62df244bd2a554bd08d047efe52cb1266ee5988447e1b2740f960d22e9ed3f2573ea8753a60d306d654a26503a5416a4439ee44aefe08cfebbed56585eaa01a64bc812f589da9e9d51849b4d4feea04e2b03c4d4fe516decea1e3d9e7e35bfec17d7b2c218d8553bab921eab6410ad30cc131579497d186fa25cf62521fe9"

lemma ModSize2048SHA384_TestVector3:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg3 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S3"
  by eval

definition ModSize2048SHA384_Msg4 :: octets where
  "ModSize2048SHA384_Msg4 = nat_to_octets 0x3b9dc97a36492a68816aff839c135da2d7dec5505ddf496670dbf0e0f6b65ce9352baa38dbc09a9f41f8f0e1f0ca1ac56552126811c786d7a4ad37dd8b4b9f1ab760d655a112b6148b273e690877340ebea10eb46bfe139926d3be59e8cb63064aa4147a9028c6ece75fb0c2eb03f4a66c3481dc726d38d37eb74efa131cf1d4"

definition ModSize2048SHA384_S4 :: octets where
  "ModSize2048SHA384_S4 = nat_to_octets 0x3fc0e79913fc234e4f271cd6f5aa63bcd00e0c4fe2242815645d384781d5a00485076bc011f4412457bb7a2cb2695abfa18471ff6087038d585f802995159c8beee7607330759f310107c35b4a6a9a48fc910f45f70bffed1281f2215af34759ab08b68acd539ddd37f98a528434cf11ae0e85ef221f7117c757d970f3181e9ccda927469aa88de59ceae91c270818137761e56d75a3c01ac128b65818f28dbf7dd268337356e97bd104df6218db3b1292ec2652b62e5aeaafd905ec8fe67d6ed42e805048deb55cd9d75f818236687bc5b2cf33e17678c45a9b2144d58a4c77c163e57c1ee42cbd92bab46678092aef867968d8e6a387f7cef3920e4ee046eb"

lemma ModSize2048SHA384_TestVector4:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg4 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S4"
  by eval

definition ModSize2048SHA384_Msg5 :: octets where
  "ModSize2048SHA384_Msg5 = nat_to_octets 0x93ebc05837d0d50897a1d10bf1b08a6a767e52bfaa887da40d631d6cfb0b1011d1793d6e51731aae48a872056dfc659e8d21b0d4e5672ea4d0d59f62a278a9acd3fb1c9d60787a426e8eb75230b43d190ccc33b6f9fcff862cb909e0f324c203e19ae64c2b86fead527a285a027f1ac53ba965cdaeeef7326a37e44db7b866fe"

definition ModSize2048SHA384_S5 :: octets where
  "ModSize2048SHA384_S5 = nat_to_octets 0x19b1bbc3e4a23b44ec429dc4479f3fa45da87037136ada535bb325c0c03193a2ed8216a9621e9f48ad2c53af330570fdfc85fc1dbb077105af39e8e3a9faba4a79ffe987e1a37e5a49c60320d086e9292060e9fe671f1bfa18ad79f1ae559551a1d5520f8164a877b3fe1938fa51cbe8b5110a332c500585d288d8b30855afdddd233254f62e56eda75ea6854b84bb05e5b4497aca3d20baaf2d6d228a400135ecc45161c3f2e7258f8e4742aa687bd9f7a4468a61558fa0ddf79e5e0ca51ffaf0151bb255152219c76a08c3e46557ed6b1415622bdfd94f733ac10d8f388c0ef646d8f5d71a3205307db703d627287e2b7be15c33fff19147e5daa36d4252b1"

lemma ModSize2048SHA384_TestVector5:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg5 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S5"
  by eval

definition ModSize2048SHA384_Msg6 :: octets where
  "ModSize2048SHA384_Msg6 = nat_to_octets 0x8bb56404897a19140d112d939f73fd7d18a5d107aaa20332209664a0674cdba64eea4fa48adcc791fd0ed0da385e206d3e5178108a04cff85466ac9711a5d4b539e625c24c39c26b17cc706b345f40a4d0f76f6eb0d78a2f76acd52c2108ee9ed411ae09d87b50c9e3b3d5ed9b5da64956017cc724017dfe0fcfa806a15c728a"

definition ModSize2048SHA384_S6 :: octets where
  "ModSize2048SHA384_S6 = nat_to_octets 0x12f03c6f02b34f921831df384cc6e30d0b64f8ed133133ff190caca2503f1a4f4f721de6824ffde125bf41ae216e5feb8510e4d6337cec56f18550e78c69b1618457bc1b604d109e526c788628391ad8c29ad6c5da268922a55e4eb3053415a9de109112b5fac1f996236f46ed3a6c2f845c36bab09a4c21da20b17d2590c7b058fec130fbec4856ade373b6b0773994bed5ac7a420a09df8c1de246ad453dc8a62310accc9f0bdff16104dfd74c7752c33df20ef08c52d0bcdeacdf2a31298a3c72bb7397c3f9306fdbec45287688877fd6c965b8dcc513c9bdefc2f9ee7e92bac62438e4d80bd3ee2ca50a024d6fdedf39266480b2ec77eedea6b64a9c58ad"

lemma ModSize2048SHA384_TestVector6:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg6 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S6"
  by eval

definition ModSize2048SHA384_Msg7 :: octets where
  "ModSize2048SHA384_Msg7 = nat_to_octets 0x35ef7f038e9b98a421b9f6a129ebc641596380ea1648bf9fe35c50c71ddd8930e8a9dc5369a5acda365e5e5f0af1b477be2956ef74e8b25516c806baff01bbb7f78ef5ae658b6852c0e26d6a472655d2f2bffdc2a848a252b235f73e70b975e74ae7f39bea177616a88b4a494652525ade6d9ceb1831389fa0ec4bdad8cb5fc9"

definition ModSize2048SHA384_S7 :: octets where
  "ModSize2048SHA384_S7 = nat_to_octets 0xaf809f10fd160a88d42dc9d92285e2b2afd8162c38eb91a6b6273a66c30c79d7caec94a00fa732710d9f751219767185da5064ce26fec0647cb0670ecc68f2a601390dff07ff0237f284dd4fcb0b11148835c8114c5a15c513713dbc16286707eecaf2c450f588fc96217d34f59e0c716c7348270041b2c4386f5a5877f7fa48510cca8b07b70490f9eee957ec0a52ab955a3f1054695a7f5806f705fe3e9802770d591eddf2a83fe03d8adbf553ae59528051218db1f3fd070f8e1d3d4b4083588cf2710271ecca5d9369468d045b0f2e0ef285f9cfa65a04cd223fd84c01b8c740a4e95b9fb675c0d7c470b3598d06489bb7d6722eb72ab8120d7f0ae29a06"

lemma ModSize2048SHA384_TestVector7:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg7 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S7"
  by eval

definition ModSize2048SHA384_Msg8 :: octets where
  "ModSize2048SHA384_Msg8 = nat_to_octets 0xb4422216f1e75f1cea1e971e29d945b9a2c7aa3d3cca70bc8dab8e61e50d6b038f9f46fa5396d5323f5b2c7ea880e12e6bf96ee37889d6a2927a8c285091907d6841dbcc2c1ffd725596055500dca177f62486cb301612479b7c303a183e7de0c790a933856a1f05b338e84c3ad4ccbdcbb1bb9c6c596cd23019444045fa7953"

definition ModSize2048SHA384_S8 :: octets where
  "ModSize2048SHA384_S8 = nat_to_octets 0x0f31c8fb4cef7233cc20bca20eaa5b42a9aed4a4f40855e2c518501ae1cfd71f98bf9ffdec1a74bea75bdf90b9c67c5824a7054ae57ef49806359ed64b2c5efdaf52829395fe426c802665bd7530ca3cbb40d5f29367ea55eba29903e8eba5df7556b5527335ac06a211c597e916fd6978ea5bc6daadccd4fcbc61ee64aacc902f652e545ef48579cd523944461d9161a542e2e7bd2a1da72ec9a751651d184fb75b16951e1b5a98107ab3ba680df0dd06131a9318e47e15326f27fc34dddeeac89b11236fdc9b8f799828dfa9714e6ca3982d8f79efa2a455e6d73421a1c933c92902790eb79adf0e4fb6202b6a0868aecac2208ab673b249a826646518aabc"

lemma ModSize2048SHA384_TestVector8:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg8 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S8"
  by eval

definition ModSize2048SHA384_Msg9 :: octets where
  "ModSize2048SHA384_Msg9 = nat_to_octets 0x882c97fad763ca235b162fba88fd714d023bf7380133681cfa9e6a8d7cdab00b58853334044bbf3741fcb28cfce201e372517b5a987f52f2ba96d744620885707b234157b6e5e00a2d11ea8147829d91dbc0351898d16b7ba4523c5283c6eb613b2d49cbb5d93482677d5e023087503f83afaedbc8d0bc9dfff7211fa7baebc6"

definition ModSize2048SHA384_S9 :: octets where
  "ModSize2048SHA384_S9 = nat_to_octets 0x0c4850b815169cda5c11f77bee14ff2fa1399af8dba09fb9485211ddd458e4152f966b2162cced299e496ca0c6cc891fce52fde9be554aa213c9f9dcce053452fe0702bf2e953ac6490c97660d8dae7ae557d94e4de409100951bd3f8be77ad5e6a7f8551190a1f2ede40fa5a12e5d995c7739221fd9be3970c05dfc990a103db1e9dff25e37234be4f70b372a4071a9c921a34de8f6c56f1106a2431b2fc2d60026c7f2cfab11ee75afaab90d72dc8e15c6d6ddee0d4302341f107c541b23368995b6e95a0efb3624e70e7980533a4d6cd823e26072a4bc88f2c01349222472ee394b86ec83f4fb9df8fd105fedc77d28b7a7e9d71451219eb42c25764bfec6"

lemma ModSize2048SHA384_TestVector9:
  "ModSize2048SHA384_PKCS1_RSASSA_PSS_Sign ModSize2048SHA384_Msg9 ModSize2048SHA384_SaltVal 
         = ModSize2048SHA384_S9"
  by eval


subsubsection \<open>with SHA-512 (Salt len: 30)\<close>

text \<open>Now we can interpret the RSASSA-PSS (probabilistic signature scheme) with the encoding 
scheme EMSA-PSS that uses SHA-512 and with the specific values for n, e, and d.\<close>

global_interpretation RSASSA_PSS_ModSize2048SHA512: 
  RSASSA_PSS MGF1wSHA512 SHA512octets 64 "PKCS1_RSAEP n2048 e2048" "PKCS1_RSADP n2048 d2048" n2048
  defines ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA512.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA512.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA512_k                                = "RSASSA_PSS_ModSize2048SHA512.k"
  and     ModSize2048SHA512_modBits                          = "RSASSA_PSS_ModSize2048SHA512.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA512 SHA512octets 64" by (simp add: EMSA_PSS_SHA512.EMSA_PSS_axioms) 
  have 5: "0 < n2048"                            using zero_less_numeral n2048_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048 e2048 m < n2048"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048 d2048 c < n2048" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048. PKCS1_RSADP n2048 d2048 (PKCS1_RSAEP n2048 e2048 m) = m" 
    using FunctionalInverses1 by blast
  have 9: "\<forall>c<n2048. PKCS1_RSAEP n2048 e2048 (PKCS1_RSADP n2048 d2048 c) = c" 
    using FunctionalInverses2 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512 SHA512octets 64 (PKCS1_RSAEP n2048 e2048) (PKCS1_RSADP n2048 d2048) n2048" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-512. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA512_Msg0 :: octets where
  "ModSize2048SHA512_Msg0 = nat_to_octets 0x5f0fe2afa61b628c43ea3b6ba60567b1ae95f682076f01dfb64de011f25e9c4b3602a78b94cecbc14cd761339d2dc320dba504a3c2dcdedb0a78eb493bb11879c31158e5467795163562ec0ca26c19e0531530a815c28f9b52061076e61f831e2fc45b86631ea7d3271444be5dcb513a3d6de457a72afb67b77db65f9bb1c380"

definition ModSize2048SHA512_S0 :: octets where
  "ModSize2048SHA512_S0 = nat_to_octets 0x5e0712bb363e5034ef6b23c119e3b498644445faab5a4c0b4e217e4c832ab34c142d7f81dbf8affdb2dacefabb2f83524c5aa883fc5f06e528b232d90fbea9ca08ae5ac180d477eaed27d137e2b51bd613b69c543d555bfc7cd81a4f795753c8c64c6b5d2acd9e26d6225f5b26e4e66a945fd6477a277b580dbeaa46d0be498df9a093392926c905641945ec5b9597525e449af3743f80554788fc358bc0401a968ff98aaf34e50b352751f32274750ff5c1fba503050204cec9c77deede7f8fa20845d95f5177030bc91d51f26f29d2a65b870dc72b81e5ef9eeef990d7c7145bbf1a3bc7aedd19fa7cbb020756525f1802216c13296fd6aac11bf2d2d90494"

definition ModSize2048SHA512_SaltVal :: octets where
  "ModSize2048SHA512_SaltVal = nat_to_octets 0xaa10fec3f83b7a97e092877a5bf9081283f502a0a46b50e395ab983a49ac"

lemma ModSize2048SHA512_SaltInputValid:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA512_SaltVal"
  by eval

lemma ModSize2048SHA512_TestVector0:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg0 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S0"
  by eval

definition ModSize2048SHA512_Msg1 :: octets where
  "ModSize2048SHA512_Msg1 = nat_to_octets 0x9e880ce59f547d592c309c22a2974ba5a52cf1c164f2d8a81ebbd4ede6e326dea33d9f135a4e0947b0b9c267aafbaae9b8583f5ff215074ca1e82f3601ad71fc455a3b6adc350d0bf345223e3b06548cec613a390ada9319e70ce7a5e9526b4e8dc82612ac72524cfdba05d0dc201037492d277834a843b9f80d4564253bdc7c"

definition ModSize2048SHA512_S1 :: octets where
  "ModSize2048SHA512_S1 = nat_to_octets 0x8c4f819e682081bb16ddd459662a8078bca4793e18110033539460b408c0af747ea5d941f712691f5d9ddb643166fd965f5b51b819d55141d67c1553b27a4682e67d5555b64d7cd3db7fc5c2e701dd26e422af8a1fb52cd5f5a09e0d6db900a992f318deeb6f6e39dfd6af44cb217c6854089ceaa16e3f9b100ef8e78f6b453458b8ef6d71493e7c6e45282c617fa87ccdd4a0f2f9f7166281806fb41d0fe188e00c40afeaa07d2da09a2cd78052f8d56b7af40d4c7314ccf02e490d5e2123bf676f2bcbdabeffcf58792998dd0f67ed24e483d8976b00d6151a6e0ba740bdb57c9bc27fe5df9126a47020075eb222d5ca2470724460c5adf067b5750287cd00"

lemma ModSize2048SHA512_TestVector1:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg1 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S1"
  by eval

definition ModSize2048SHA512_Msg2 :: octets where
  "ModSize2048SHA512_Msg2 = nat_to_octets 0xa6133ca436d3f2e0a6562f138975bcf785cd0c3b58b7671d197b483bc0c003a6e947aa39d5d93229b27ed2dc1cf0acffe34fafd30f16bcc7214e074c9c02c1e5c4f2f47da68baefe5817611f82328a7e1d7d91ee7b96f0128847982b4ffd902ec07ce01ab0d2ad882189a583c4219e9bbcbe7935a51d4d25d5ccc27fe19bbaa9"

definition ModSize2048SHA512_S2 :: octets where
  "ModSize2048SHA512_S2 = nat_to_octets 0x20ceee0fd620160ef6a40966fa4ef3d8f68c002a66d0103eb62a868a7ad7dce9523a5b83607b8cd0ca54f833f3a68c9fafa1de7fd723e22a0f724dfca1fb6bd1a88a7dbd17255ba1e06102c2cddf584f511bdd09e132b016f867896a592a28c53c70752a0b10d86bdbae9503928d2e0203ab8f845c1f77adef2bd2f4e126066fe15af4a5282d5d9fa73bec18d2e6a5969d766eba55c0bb95e13671f82646c35b31d894e7f95f2fd35f60d88c3e70b20f6f387326400f0a825bb9517df88bbcc4798861144782dd92ccaed36aec47d5365d3b61a495339ed58e2553b74f06a295ae47a309d8477b9ca838e77094718565903432ce243c9dffe6dad464cd5ee279"

lemma ModSize2048SHA512_TestVector2:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg2 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S2"
  by eval

definition ModSize2048SHA512_Msg3 :: octets where
  "ModSize2048SHA512_Msg3 = nat_to_octets 0x6d60a4ee806bf0fdb5e3848f58342c0dbab5ee3929d2996e1f6aa029ba7629c96cec6293f4e314f98df77a1c65ef538f509d365ebe06264febc3666755a78eb073a2df3aa4e5d4606647f94cc8e800be22141208036a635e6b3d094c3a3a0e88e94bc4ea78bc58b9a79daa2869675c2096e22a40e0457923089f32e15277d0d8"

definition ModSize2048SHA512_S3 :: octets where
  "ModSize2048SHA512_S3 = nat_to_octets 0x912fdcc5719a8af7389db8756bb0f630a4c78a1bd1fec7c4a6f3e50924a9818c9eca4a4efbaf9e8bad55d6468d83c54d0450b53a267a50685e7fb93550c2ef3554f69b4e49d3be359bc0b88f3e753714684ac047b4dfb436140b13129fc4bbfeed86548500d487094d222ed4e249db0a46b34ba5247c1b86e8650a703c9d3e0374433d3af52578d35f0f9108439df0701188da206b579e1712811c1e33b3da32f33acc9cd0bed60cfe977a4a6c6aa6498ecebab9be86c216a7214eecb13c2b7d4d309f5488012056905060c3eabe90f36b01588acb328869034e00bd19bf5c1a44d8ea2a89b747b2875d97047c53f2903f67b5a60aa87aa70a9479735198a508"

lemma ModSize2048SHA512_TestVector3:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg3 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S3"
  by eval

definition ModSize2048SHA512_Msg4 :: octets where
  "ModSize2048SHA512_Msg4 = nat_to_octets 0x1aa215c9f16050f31f0ce5adc8cfa594e44ef29087dc23ac65ed2a2595ce73c0959410618f5314dada903c01c4f8d5058f52d902b9b25cd281ef2627a658a2d672a3f776f726742a994a31bbcc3cf3ea1fe551047a1d15b6a31be52307302334b8b6112fb243398c62220c046903c9ea9df1a0be50851800d659ae4241c0be81"

definition ModSize2048SHA512_S4 :: octets where
  "ModSize2048SHA512_S4 = nat_to_octets 0x6ba800b8692ae568344c448094e3e16f50dc2c53edcfbbc9c7be9c07461c0e0686fcfed607af2a66291fcf8e9653fb3e9857b208ba210100df9e6c0495ab4d13f1029089cfea49a6be8b62036f30e0d4e4c1d95a5eb9580397d3bcf65a9311c2d8de249c2d1d7472369537cccedf8a7feb0c170eef41341f05e7d17caac4261b62498776a5eb1d9ce7e4746b4849f9021f0aff917179750253c719017fb5dd6855672eeb0847ca075e589e320f356f49872455b30f8cc1a3a7e1a4276ed6a909be06bd9f89c3494ff7db432d0d4d3f3ccb0be71b0bda4f66ff79773004905c6102d964b3b5a5e28e4578840c0e488b7f2b4f31066b61e13821e88a0ddd2b1c2e"

lemma ModSize2048SHA512_TestVector4:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg4 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S4"
  by eval

definition ModSize2048SHA512_Msg5 :: octets where
  "ModSize2048SHA512_Msg5 = nat_to_octets 0xcce6ea5a46bdd6805160dce409d1023cd71d3893303ca0497f392d5c5f936fe50ee2ade61ebd35426edcf00d597a39062dfdef62dfd9c9ccfdb2eaa9e3c1b6a03278e35a7e69d386476421212bdf7af4599bae5e49850653abdbd9a59d8f5a8220f0b43fcd875953c43f96a7e6ca6c0d443f9b0dd608ffe871fb1fd7f3c70494"

definition ModSize2048SHA512_S5 :: octets where
  "ModSize2048SHA512_S5 = nat_to_octets 0x9a465479c1474c1a54f16f309bd87b0c641a458d86173a4f29c2829fea0410787a81b3c1360cfc525d133dfdecc13acdd5199954dd8440739608545724cf1270caa39a221e9c6bfba399b9b05e55708875bac1578642ba7211260662299bf5ef68a39594e38faee14989ac5b2daa13211ece394cde46afa1b110bb55f631bdae5b848dfdb8920d7c74eff82ecdf59f2c6ed9b818c2336364b2a56d34a22ac42089dc5730e8e57b356cc4822c1e646268dc6a423e034b8b1512d41b88c70b27e431d68151e61a4fa5c89f1e90d621e07228c0346ca46f767a989f1b0d007237645d448030a7fe45ee0f46521272a8cc453a835984f8268752bef801b6226140b5"

lemma ModSize2048SHA512_TestVector5:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg5 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S5"
  by eval

definition ModSize2048SHA512_Msg6 :: octets where
  "ModSize2048SHA512_Msg6 = nat_to_octets 0xcb79cee1e7c3546750dd49fb760546e651e2a42ba4bbe16083e744bd1385c473916d273e9566673e98995903b44590e7acb580a02c6fdf1552af51716c134376049817151ac5823bb02633ed8cfcb697393397a14f94ca44f43c4a9ca34d01fe2ce3e88bfc4a6f059f6e1fe283927e9fff45335793926a9472787a653d9ac5b1"

definition ModSize2048SHA512_S6 :: octets where
  "ModSize2048SHA512_S6 = nat_to_octets 0x7cfcc23518bc137b94dbc87e83e5c942a5297ab4f70a4ad797b1dfa931c9cfcb30449ba3b443fd3abf4d350b80feaa9687b39e7b5b524ffa35063ae6b4e12a41fd734a24f89c3652b449c2154099a1c7739d5db77ba9de0358a69ec99bcc626f657213a256732631461851c919a93b04ad39800f02d0e627cd01d4b80697a9a1fb0d71df4f32ecaad3f1d5c80cac67a58c71ce81e23fc8a05ec840019c834d78ee1955c5e41065b323d01fdbe81b768448b4a7388886c9740b1541ecd8454f73ab64f90dd46cce6a2329beae9f3ee0bf567b507440ab3ca9de2e855374ddf6e105b3d0b33a138d716d138ce9f9570797a82eae557cf321fa09b862e31ee8d85b"

lemma ModSize2048SHA512_TestVector6:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg6 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S6"
  by eval

definition ModSize2048SHA512_Msg7 :: octets where
  "ModSize2048SHA512_Msg7 = nat_to_octets 0x3ddc491798c6d8c2d6932502e14ca0d6cd90016c219438427268a38b377c84d4d862b2e708d58ff055fb39defde7050c0462292183ebb83543fcd4358a8f1f8835e172f20776d2b9415d9f0773b50f909170db7449573867944e090f8cda53ad7de0f1003eb08967c241be45eabea7a99d42802f1be1a0218ee7abe2e364098d"

definition ModSize2048SHA512_S7 :: octets where
  "ModSize2048SHA512_S7 = nat_to_octets 0x68a46140382dbf84b1794ce86937812d8220fc59e83dd1afa087efc41883616bfffb8283bd6dd5ee1930337951ded3be23fdc657e1bc07f41b539eb779ec98f436b367259b6841e495bf84555aff07674c9fb705c85a9cc1fde4bad40506e3373cc3a490daada1c10705177c165719104daa8ab675666625335e09a24f7a2363d7b3b878f34fe68fe01425275881c34b60ee78fcc0a54d56ac8304fc7a4bc0d5a447ab89b9206401e3c445bb1cc8e0c2541fe0f3634bb49d5af3a1b7c2e7651d208392718311247f0f15e4041a46301b93da2cda7af833d80191565833926a78468abac9eb4b02c5f047ed38851c3ed7add4edc05e8407481b8b942ab627e03d"

lemma ModSize2048SHA512_TestVector7:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg7 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S7"
  by eval

definition ModSize2048SHA512_Msg8 :: octets where
  "ModSize2048SHA512_Msg8 = nat_to_octets 0xd422e63e3c65eff3ee15c7eeb2ef0de7ab96a3c37e2af9c2b71d8ffa6842b504122796f5c9a5748f94b535b913851f2d64cce071465ad1087ff37be97c5d5b3038b8e2145f0ec019b22b6286adafb91a67613efbbbc633efa5f32bceee9fcc380c7cd48344c85af7111e573ec99364167efec5492297a7dfefc4a692062f9282"

definition ModSize2048SHA512_S8 :: octets where
  "ModSize2048SHA512_S8 = nat_to_octets 0x2bc6331715b62972a0a5dab2138c5663b0e33961063ce973e68e1ad172723bcea293f7ba35af24504cb2e373b11f80b49f79d3905e0aaef838fc7c7fb5df49a322d7c3daa294a1a0a8b71a52e2c5dd94575f319c64ef9f6fc6bbb70c0c97fa12ae78f73234aaeb93df299f81513458ecd243fca5284f44a1afcd0575dbf5f81d406236ce315e98ba4c9ef7c1d43896af3b5d172e7a786fc58c4220c27b56e5c7a9be49a40b49158305034a295a6c5743cda6c2c69f7ac02f87ed6cf7b4e989ce8218e5e7cbdac12fe7de3a5437170084ef8ce33e3530392c25a58ebeddc086685a4dfb9c0c5b91d946df65161ffbf82aa3d6a80c7c07995aa3ee06b1800a54ee"

lemma ModSize2048SHA512_TestVector8:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg8 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S8"
  by eval

definition ModSize2048SHA512_Msg9 :: octets where
  "ModSize2048SHA512_Msg9 = nat_to_octets 0x6e87214fc1a8b0116f04a45a67e101ac75e9933366c532f96cee4559c4c085b695d1046d1c806d0706d18db41d7812f5273393980b5dd1e936c13d273dacba35c446a3929e21108b361355af2d41cc84447dd5787dd21a1a7d5c188a355ddb2ec18e08a790b32104c6720535de65b6c2946e5fbd024b96f5096ade6cf2fe700b"

definition ModSize2048SHA512_S9 :: octets where
  "ModSize2048SHA512_S9 = nat_to_octets 0x802db067a8d90967c2860c9076c1a0227560b59b66350490af1153d20b31840918e7d7262f633d37880a153b1a23e40d3cf9fcbd9c1610878b6317d9d1187f80074512524561f1c0f99f1b2ba168a15eac098b2b20673ac63f9b002e60887ff296d1212dc696450e7bb14a3efbdcdbc7f4ae2210ed35a3bf028d3eb99ab696f63a2fc69d8cce4b45846ab88943f89d588a72f00f15e1ea16d99961084542467b8f998c118fe76a2a326cb1ca3f9959c06c810a004a67cb0655f8c6202ff5e4ced43c4d8e0c3683d55607d4ddbcc0d9dd4e1783b58f51f95e159fe593066cec53b544f2391cbf0e3dc4172afd5ff6de23088404f7a496bbc6a4ce22826204b6aa"

lemma ModSize2048SHA512_TestVector9:
  "ModSize2048SHA512_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_Msg9 ModSize2048SHA512_SaltVal 
         = ModSize2048SHA512_S9"
  by eval


subsection \<open>RSASSA-PSS: Mod Size 3072\<close>

text \<open>The second half of the test vectors found in SigGenPSS_186-3.txt use a larger modulus n, 
with 3072 bits.  Again, SigGenPSS_186-3.txt is contained in the zip file linked at the top of 
this theory.  This subsection together with the previous subsection contain all the test vectors
from that file.\<close>

definition n3072 :: nat where
  "n3072 = 0xa7a1882a7fb896786034d07fb1b9f6327c27bdd7ce6fe39c285ae3b6c34259adc0dc4f7b9c7dec3ca4a20d3407339eedd7a12a421da18f5954673cac2ff059156ecc73c6861ec761e6a0f2a5a033a6768c6a42d8b459e1b4932349e84efd92df59b45935f3d0e30817c66201aa99d07ae36c5d74f408d69cc08f044151ff4960e531360cb19077833adf7bce77ecfaa133c0ccc63c93b856814569e0b9884ee554061b9a20ab46c38263c094dae791aa61a17f8d16f0e85b7e5ce3b067ece89e20bc4e8f1ae814b276d234e04f4e766f501da74ea7e3817c24ea35d016676cece652b823b051625573ca92757fc720d254ecf1dcbbfd21d98307561ecaab545480c7c52ad7e9fa6b597f5fe550559c2fe923205ac1761a99737ca02d7b19822e008a8969349c87fb874c81620e38f613c8521f0381fe5ba55b74827dad3e1cf2aa29c6933629f2b286ad11be88fa6436e7e3f64a75e3595290dc0d1cd5eee7aaac54959cc53bd5a934a365e72dd81a2bd4fb9a67821bffedf2ef2bd94913de8b"

lemma n3072_gr_1: "1 < n3072" 
  using n3072_def by presburger

definition e3072 :: nat where
  "e3072 = 0x1415a7" 

definition d3072 :: nat where
  "d3072 = 0x073a5fc4cd642f6113dffc4f84035cee3a2b8acc549703751a1d6a5eaa13487229a58ef7d7a522bb9f4f25510f1aa0f74c6a8fc8a5c5be8b91a674ede50e92f7e34a90a3c9da999fffb1d695e4588f451256c163484c151350cb9c7825a7d910845ee5cf826fecf9a7c0fbbbba22bb4a531c131d2e7761ba898f002ebef8ab87218511f81d3266e1ec07a7ca8622514c6dfdc86c67679a2c8f5f031de9a0c22b5a88060b46ee0c64d3b9af3c0a379bcd9c6a1b51cf6480456d3fd6def94cd2a6c171dd3f010e3c9d662bc857208248c94ebcb9fd997b9ff4a7e5fd95558569906525e741d78344f6f6cfdbd59d4faa52ee3fa964fb7cccb2d6be1935d211fe1498217716273939a946081fd8509913fd47747c5c2f03efd4d6fc9c6fcfd8402e9f40a0a5b3de3ca2b3c0fac9456938faa6cf2c20e3912e5981c9876d8ca1ff29b87a15eeae0ccce3f8a8f1e405091c083b98bcc5fe0d0deaae33c67c0394437f0eccb385b7efb17aeebba8afaecca30a2f63eac8f0ac8f1eacad85bbcaf3960b"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.\<close>
axiomatization where MissingPandQ3072: "\<exists>p q. PKCS1_validRSAprivateKey n3072 d3072 p q e3072"

lemma FunctionalInverses1_3072: "\<forall>m<n3072. PKCS1_RSADP n3072 d3072 (PKCS1_RSAEP n3072 e3072 m) = m"
  by (meson MissingPandQ3072 PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2_3072: "\<forall>c<n3072. PKCS1_RSAEP n3072 e3072 (PKCS1_RSADP n3072 d3072 c) = c"
  by (meson MissingPandQ3072 PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

subsubsection \<open>with SHA-224 (Salt len: 28)\<close>

text \<open>Now with our encryption/decryption primitives set up for the new RSA key, and the appropriate
EMSA_PSS locale, we can interpret the RSASSA-PSS (probabilistic signature scheme) with those
functions.\<close>
global_interpretation RSASSA_PSS_ModSize3072SHA224: 
  RSASSA_PSS MGF1wSHA224 SHA224octets 28 "PKCS1_RSAEP n3072 e3072" "PKCS1_RSADP n3072 d3072" n3072
  defines ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA224.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA224.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA224_k                                = "RSASSA_PSS_ModSize3072SHA224.k"
  and     ModSize3072SHA224_modBits                          = "RSASSA_PSS_ModSize3072SHA224.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA224 SHA224octets 28" by (simp add: EMSA_PSS_SHA224.EMSA_PSS_axioms)
  have 5: "0 < n3072"                            using zero_less_numeral n3072_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072 e3072 m < n3072"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072 d3072 c < n3072" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072. PKCS1_RSADP n3072 d3072 (PKCS1_RSAEP n3072 e3072 m) = m" 
    using FunctionalInverses1_3072 by blast
  have 9: "\<forall>c<n3072. PKCS1_RSAEP n3072 e3072 (PKCS1_RSADP n3072 d3072 c) = c" 
    using FunctionalInverses2_3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA224 SHA224octets 28 (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-224. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA224_Msg0 :: octets where
  "ModSize3072SHA224_Msg0 = nat_to_octets 0xc8ed14895c80a91fda8367cf4aee386b8a378645f06afee72f7c94047fddc7aef84c26c83fef13bf65a3c7750c91967ecc02748fd574b933d5ec21c01c8f178afe6c3356789d0112178e04c3169cfabec6e2621b334f3c6705fc1099a4bd3147a0f7431a4fb1fb80b8ed26a0af38ed93428057d154260fe98854687661919e4e"

definition ModSize3072SHA224_S0 :: octets where
  "ModSize3072SHA224_S0 = nat_to_octets 0x27b4f0aa139565fbd7860760610f6866d5b5f0d777921f06f5053291123e3b259d67294ccb8c0d068b8dae360aad2cf7d07296b539e4d2e9b08c343286d522f7dd63c6620e8672be492f3b039f73d88ab9d22a5463cd1f07d688e8ba3fbad531b0c3870ccbfebb596ce4ec643d309744bdbd675d5841284cbac902cfb70ade6d33946d8dc6109bbbc42412db25b8c62222c5ff94f8eb868982265392a44e807474910b4b39558bbef33197907178ce146fdd7e94092ad58bf41a474e626136789fc2fe6374a1b5fefddd5fecb7f8ca5893220d1ab9e822c3ae8adda1ebaddb18a6a12bfc165d12071441a991377cee6dc8e50839497346fee13f12c5b7b6d024b8ecfdad80d5ef6e9e4996ac21c4eb6036bb51f5be5e38f265181154000824e3c1f231d18589ccdaee90fe307ba56324318b5358468e9f3913b83ab8b34d949629ed7839f8da85bdcda52f3da5a419f777b3860dbf2ffe28d96244312549528a20cc7399fc010844365806167fe43235521c909587c2c7b8db4e296dad2aefa2"

definition ModSize3072SHA224_SaltVal :: octets where
  "ModSize3072SHA224_SaltVal = nat_to_octets 0x3f805057471aab0a28cfc8430dabcf990612e8a908b158ae36b4ed53"

lemma ModSize3072SHA224_SaltInputValid:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA224_SaltVal"
  by eval

lemma ModSize3072SHA224_TestVector0:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg0 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S0"
  by eval

definition ModSize3072SHA224_Msg1 :: octets where
  "ModSize3072SHA224_Msg1 = nat_to_octets 0xd04be758e97644ee60a9212e5eb81a1088041aab31e428b0cd4a8437a9a3f3bedafe576e747182a1fcb84ca21f20e3b3a3a463559f55a7c3e7ff5ec0cb096192019d444fdf092a57cd65de22fb76203c4fd33d8da246e3de2b7532993bc216d02b6fd5819306e419bdf8ff365a8478b173dad0dca281840881f6294b6396bb80"

definition ModSize3072SHA224_S1 :: octets where
  "ModSize3072SHA224_S1 = nat_to_octets 0x4aba732c6255f0bc443939c131dd4ce64478d4f58dcbf1d73f5f0e660c492315e987cafbc83a1a0be3d359a960783d293d375ccc3ec0d82c72abcacc339f1b42207a03795be6808ba06a891e3b4251e1b3001dfb537252572a33b4c52846dafefb24aca53fc08e63c39da02c4138b3de9510fb790f87566cd14380b138c728c243543b89d1f916ce27cada85fa32d8185deefa25c323c65c7ed578ca57276b66744a7a1a78e66d4e570999d17015bdbdd8d3d6185a3eb1dec8bc3a1287a2e235e4f116a8b91d06128d36b58ed4c9a6ed84773dc49f755e2e27a6f1aea31417069bd066b848095c002f22dd6caa72957e21a1e640f9ab9b9180df8ef8963e3611df2693a7ed064f348221e7edb1a5a81acce24acc335c6ee7d4f1af6d68acaf15d77e128142ca9bfc55a121b1b13fe5bafe2e4d6a5546b8cc631bb9d304c0e9f3d6d5dfe833c346965f0103698d34a51bca5db266afded271d8490645b3f63efc991e01683211f9482d214cfa9220f7bc81e8cbb4d118a2c306709807c070c60d"

lemma ModSize3072SHA224_TestVector1:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg1 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S1"
  by eval

definition ModSize3072SHA224_Msg2 :: octets where
  "ModSize3072SHA224_Msg2 = nat_to_octets 0x39d8ec4816fa9365cdf299ce60053b9c1e99540ed29d2d163a249718ba5337ee527e222fce8eaab13ca6774ca306d9e1f22f5c9b37479d7511c05dfd6835d4575b9447847a82dde536fbaffa95391e702bd8695b45377fc067211156f9adec8d3d6286d0849fd607a23a69619f68b350afdda3d564347afd2390dcacd5842799"

definition ModSize3072SHA224_S2 :: octets where
  "ModSize3072SHA224_S2 = nat_to_octets 0x0df81ec6e9c2f0ebe824c445009902cd55e2718523546f08ed13faf811ec4e57e6f5772037e07025c3c0c99cd9d6c885682e0eb904a3314b825948819acecd195c845a81e22ae62c13251823d6ee386e0be17a604bafc6497b7a6cdaad1a33cd5ae33bdd50e62063bddf6d12b878b31d3b7d490ce86810f9d456739bcebde592b07808350aee542455d1761154188e6e02cbda795e48e4f28acb819440bcd8da53fdf19808456898a18fba517af06b51156129b0b8029547ca9bd9436a0673e5b5cb995340fc425fecc566acc99884e0b4fc87248f5b35bbf08b0dfd0b9ead06737b67c85f94e1eac8802fea1b1dcea446b7cab8a45b25429750946bc8b22e076828a0a9718277568b9b7202a8cc3688d44194e834e0a405fb9eea46bc7e94255d600ff6c95a46ebf46449510fdb39b6ce05a20ac1832938b659318764dc0b7e4a0215fd253f5219296fbc82f03a7b95a12628d219093e2cdac42e20eba3dd5aeeb9dd7bef5d647f151b04ab85c48970cfe73ef9fc3e7d1d8a138dec3f5d5fb5"

lemma  ModSize3072SHA224_TestVector2:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg2 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S2"
  by eval

definition ModSize3072SHA224_Msg3 :: octets where
  "ModSize3072SHA224_Msg3 = nat_to_octets 0xf7b22de3bee8295c4d8c8a94da8cd704c5541c97214390bc6f5c75baac3f40458f57fa4e0c54e61f1cdc64a6c07d151143e7409cc05874a7e5576f0cf6a53faf1571a757c0cbc4bc9b5bf0e17053e7a374a22992cc6b9f014fb580598e6476b31168fda5e4340c5b5371f8eaf1f495e2dfee9e224a6357f136de704a7a622d76"

definition ModSize3072SHA224_S3 :: octets where
  "ModSize3072SHA224_S3 = nat_to_octets 0x727669abeb6bcc9502d7e88162f4a6c1dfe1a0f5141d3763e0f7e16744f9063874f153cc2de48784de84426b548b03e05a9074cef6a951640eaf9b32014d97cd9f3a828b45def13527f72a3e5e5adccaece82212c016c28f9f3312853bf52062e719081bc028f70831f9fc9132e8b63824e37c7cdeba463f9034d815683e27750cb9b383c3420f122a3b7fc6e9440925a77d766f93d586161e9607beb8a6e4ac72c32ef7b69ed52f5077a881dd0e494591e2ba552b74731c18cece9905561459f4553d49acfd6cc6be027833a220429d46bcb88dfcff0d2c5cb567371563b4852b7e628c4a6432af967e8ed69c9b6428ac552cd370922a0a4b01ef1bdfdcbc9088cdfb6d9fe326bd6b2bb1fc2acfea3bcf60d1fac5880b0510736b7e201ee8f6bc6332c0756315789700350fa549009d16e0bac084bf6aa3492f63367819506bf0c4f9c232fbd7c4d4ad663a7566108238c31fed887f368666dc75a623f222d357f8e523ff084111be4db6baf444f191ad1468d077349fef8a22f3fa56085975"

lemma ModSize3072SHA224_TestVector3:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg3 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S3"
  by eval

definition ModSize3072SHA224_Msg4 :: octets where
  "ModSize3072SHA224_Msg4 = nat_to_octets 0x8d48fddf28b05b42c9b4df4742ed8e735a140a6972165ca6696bf06ebea4e106f44478243bd1efa44c2b7a7c951c88f2962f450d8bc664494b671d8e70577163b86ab560ab194ee17ed5ba02389bd0c713c9489a25307dfb3f6a7273166d13c9a061be79c1af0262275ba7bf7393ee58998819fa897c2e240f1cf903f71150a0"

definition ModSize3072SHA224_S4 :: octets where
  "ModSize3072SHA224_S4 = nat_to_octets 0xa1a4d16956d718830f625f06c42e99189e36a80523b25f0c9a7bb85568ce76d1e85e437db0a7728b8a9c90d25e6f38150208debe54e1e3f648ff01798a8ce132e4b33f3d26fa8963771440fdc4f5d852117b3ccea975da10e5d4f27af1bec1b853b7b5c9b420012317a6c33b2596dbdcebf97bef821b3076ce86345309b6bdf29a4acd391d3b2e5c4a6866136287d17cb0e2d4d6a6cf89d64272d5c01849ed57fa2842074d3b7734c4c92be50a922d0517ebb9891072b1b47a710887004b238f90079d10fb2cad7f5013e7243089f3c601865c6bce1cb8d0d669f2bb709253e3f1e421936f6a1643bbbb7d503b0631f7e1660382bacf4680de8d70e24abf4450510e6b40475bfc9fe547752d0d5f63f40f62f4dcc903fe6d260fa45a1b85a7501065aa1900a3f841e54c136d686fadbb33b225d15ae6fc348be57fc9ccbfdeb57d5cbf53e3479d9bae9f4ff859cbd3fb076073ca016ad94086700cc85aced83aebb4254b0cfc814585f930dc623c7f85e89de6a554b9898918d7cbb4cd2db075"

lemma ModSize3072SHA224_TestVector4:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg4 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S4"
  by eval

definition ModSize3072SHA224_Msg5 :: octets where
  "ModSize3072SHA224_Msg5 = nat_to_octets 0x4753183ce5607fa03636db2fdc84722aeb9d98a6ed70d0282aba3571267a189b6aa6eb65871c5dcc59dbc7db8973c7c355ba2a2e94c110d1f4064a4087eb07077e67b0f634fc10bc6ee9b8b8e1a0a20bf47a14f2c8aac75375704995978fa0b50a003096f1e8df99fdc8766eecf34a2a4f461d9991133fd5355ef8175f4c2bce"

definition ModSize3072SHA224_S5 :: octets where
  "ModSize3072SHA224_S5 = nat_to_octets 0x2e078b29b5288a77ed25ecececa645f6d9298e4294e3ef08173cc37ccbf727ac9b092cd27d6fbd378fff7b1061b56ed5cf077fd1a227771f58cbb2c1195a01f830f0366f989aa2d0c486d441e112daeaf83e85958f65a9e60a1937d2a7022781fcd1a83b3f7641a743001ebad53a4669405603ba0393bcd94f64324f1b777068a3ab101a086a6972b2c11376307e7d2485fbfad85be7171d20a5251cf9a5f004847d172c77bd80fbac0870a0b6bb9733537ca72bb6eac351c21588287c317625a25f416129e6f53c607ae08f43e5e0339740775a531c720f3f731840184ac7cd3b1f7bb820ff30ba7bb120b21b4bae7f9d7fc34d7418f700b142cf8fff43d81599236ebabe93d2e89f4702fada8742dc3bb4bc8fc5e55b4f874ae59f5dc9636868828efbe1025a8ca5c61ed8cc832686d5d00c08775590b316060285dc5bb9d32c90a474a727ddba9e7a8b7d69bae555604add9de0dab0eb0d551bac067c0088523d134b2e50dfe3ff73eefed934c0984aa4a5c563b862d46ed957ec3446fd24"

lemma ModSize3072SHA224_TestVector5:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg5 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S5"
  by eval

definition ModSize3072SHA224_Msg6 :: octets where
  "ModSize3072SHA224_Msg6 = nat_to_octets  0xaad03f3aa4cbd236d30fcf239c40da68de8ef54dcb36f5a6f64b32b6acb6834e887c6a35423f8bccc80863f2904336262c0b49eb1fa85271ef562d717b48d0598fed81a9b672479d4f889e0ce3676e90b6133ee79cdea5990e2e02db7d806db4e6adee5ea76cecef9119e8393eb56beea52d3c08ebdfd7677d5a1bbc5b6543a7"

definition ModSize3072SHA224_S6 :: octets where
  "ModSize3072SHA224_S6 = nat_to_octets  0x1bc325412cc952a8dd6918db8fb08192cdf81bf4111cb5f0a580a82d4dd2e14d7445eb7cb94cca6da06d2b5cc43e6ec22a5c9c845d99ac0353050c1374866befd9b6b849cf3b0efcc644ce17cca0dafcf7700c9c7d870c1e14511651b1d03a535110139c53b55938cc4a471d756a55b50d1bd280c324ac4dbaf526590c48c197573f3a91c70373ec62bd168288b0d163a09e623589d1ca5a70d17aa54c8627c7a64d921aad12626f7d32d61e8f14d0aa97c2d6502021e70855581f5e353e27f96efe1bc78c7fbaece66a560b93c0e7365d97dc4c729235484abe10bccae99fa8db9425614b673d5bbc188ea8f465424f768d8031f7eefbb698f058e1578ac41426739410aa7eacf796f43a4e4b2b4a463984d3d17d6d667cd15bf2e2b487aec3493440794c09908545f416b701a130f08027b8bcab4dc4a78cf4a55a688b2e1ca3a73a08ff0ed890bee4a0fa858cf69142f2f765400e7c29c4b540530a054641961499c709dbb4f36e7e75a5993cb3ab8cd4c886f6a3f5e3bdd3d68ef0a77750"

lemma ModSize3072SHA224_TestVector6:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg6 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S6"
  by eval

definition ModSize3072SHA224_Msg7 :: octets where
  "ModSize3072SHA224_Msg7 = nat_to_octets  0xc828eca460b39703696750999e23486a432d80000882d061316b2e3ef4512d6d22d2c49a0a1551399b5addbec8d5a21131bcca3cff9f7a670ff80f075403a85276cfe4f6bf95ed0a384ab5450f707f6e3c31a21364ae897efe95ffe5b4f1a9e10c47d42147de72608a5e5e943b9de869aeb58ded015a068d446a8540ddc63b02"

definition ModSize3072SHA224_S7 :: octets where
  "ModSize3072SHA224_S7 = nat_to_octets  0x799450a1256d245df0bb7d5290abcefe69d3b0e3b94924072f2d67d53a966513955fa7a01b830ba2cbbb056716fd605a0cfdc05f8ff58d88cb1bf32248f117de41ddfdc466215fa4e704096947a2dbe836a99071ea7344be0ffc782d14f995e4bfc74dc3ab1fa96d7223ec456497a2f51e1eb199f0464d415aef00f841e39f4578a0c26d726f3065ee687adbe40207801857160d440151fa374257eaa3f777337d129dc8b8c701eed56a276ec90c03df54305f300ef8c51155db30b68c0b06dae4c4aa07e75ef0fb09299b2b04d73d0b3e874ea1b6ac4e16f1bed0cd8dd3cf958a27e14e09705d4f0e10f8d46c75a195380126b437c68183e6bd39097e2f45b1184f519b2eb101110db74519016297683aca4b461cec1d92a7e68cbf30c2bb0d96c3b33dc62d278b9a640478258c3405a6ab5fcef5280408d4573b7ae42408b9c40483768f16a01c9ee4163b325bbb8e377034fd31c787cc0db8a53f6c0ce93e7d854411a136e1013d69fd03a0171176dc0712640ef2f792c340eedd0d07a8e6"

lemma ModSize3072SHA224_TestVector7:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg7 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S7"
  by eval

definition ModSize3072SHA224_Msg8 :: octets where
  "ModSize3072SHA224_Msg8 = nat_to_octets  0x87edd97182f322c24e937664c94443a25dd4ebe528fe0cdf5a3e050adfe4b6513f68870cc2fdab32d768a6cab6130ca3455d8c4538352e277de7d923d7351826c9aa1d2cb52b076c45cf60cf0af1eaa763839b9ea1a4e6ec68753cce5829d333ed5ca6b8a4a6bdd6606fae5a0b05641680eb1fd7a975bc97e49137f3ace86edf"

definition ModSize3072SHA224_S8 :: octets where
  "ModSize3072SHA224_S8 = nat_to_octets  0x9cba01f79f3551acfccf56e74428e270949f78a00b4ff3507ef180ce4c78ef4c53f3b7347ee37633c653aaeca834fc004385f87798922c53f8fd741cbce15de8dcae8bb04c7d481a823eadac7d4d4546fa4b0cc7e25e67b166edde4b6f66748017a4dcef85952cbf37e802fe534ecb984cb32f446c02ccb60e257a18ac368c2d2ed21975093499e35880930f8529790c1c7762ae11526e829dc0621ac904b822ba4815d8f83ac8f0fb0f8fc11bd33b02aff4e406f8fda5efabf39e6641a791cf8241b0946b675fa48d07e48639cc1ecf420380b8581a539a4de60adb0da22e10ad41f8ba6af40d11e2720086a63db72a5d7fbe97929ab23cae1d75c485d614ca38094baca699e47200f7a792292b5c7ab95b960d6921f8beab94d26f9629d8702c40df696787a6fb6ab9d6f3c1240c2fe58c565c9328dcab603897693d9dc7dcdaf500850711e6f30b5d8498a38e348469df79c3628fe1403a7649e82f06161e0ece42479a56eaa845f0582cbf817d4ba7dced36e93a6dc7dc7362f658f06461"

lemma ModSize3072SHA224_TestVector8:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg8 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S8"
  by eval

definition ModSize3072SHA224_Msg9 :: octets where
  "ModSize3072SHA224_Msg9 = nat_to_octets  0x02a1a65f8af90a298636fe8fd31164b6907d74c8d38a0ef59a8a4eb80572625cc28398bec829bb544823a06ee0e4fcbc13397811f62d08662b2a782213604899406ab9d2292f288d22079b848b209af2471f4052700a916948650e86739b870964a0312216d5f8dbfc2c16593a8ce55e1577f113a8ea5205d984396d8cebc8b4"

definition ModSize3072SHA224_S9 :: octets where
  "ModSize3072SHA224_S9 = nat_to_octets  0x740eeb1c71940ccbc041cf204469bd2d6a461558b1d15c9eb23361cd55e1ad418a7d2851ed3d44f9c02881a22f9e4be042d451998bc181887950da38246dc1656243db15fef359fe50d2af8711b3973a57763bfc3964cfe3c911b937572e639aee53a98752598c4b15dd53dd9355aee866d5f1e48137c12c342e8f274690b7b277acd087f293cb8b8c9a3e4b3f0277e831a6864e503f925557511e57b5285221421879696802066587ce6f993aacb70dafd39f63f09cb3dcc28e56782dbfb8b4ccb1b19876101573ee9678a5f6265f808f75e7711946c27c7a22dce9f592acddac81c67afa17bffb766058e2318a1211079842bd5fc58f9cef4b50ff0ee1a293f80ac1bf2eb64ce4e1051e1abe55ee067db6c24130f0bf4c134b0abf1e2f4465dc50fd3799f6dc206b9a7d2fe34b4f4257065d7494ae733c28d70aadb057ce1bcff36edf9f9ca6908cac2141845310660ab759d1f3e651dd9fa8056a624efc714f51f3a4f85adcba68f4a58e3a956af93a5a52f2b89f9c914b48e8dfb919cfc6"

lemma ModSize3072SHA224_TestVector9:
  "ModSize3072SHA224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA224_Msg9 ModSize3072SHA224_SaltVal 
         = ModSize3072SHA224_S9"
  by eval


subsubsection \<open>with SHA-256 (Salt len: 32)\<close>

text \<open>We interpret RSASSA-PSS with the new RSA key values and the appropriate EMSA-PSS encoding.\<close>

global_interpretation RSASSA_PSS_ModSize3072SHA256: 
  RSASSA_PSS MGF1wSHA256 SHA256octets 32 "PKCS1_RSAEP n3072 e3072" "PKCS1_RSADP n3072 d3072" n3072
  defines ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA256.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA256.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA256_k                                = "RSASSA_PSS_ModSize3072SHA256.k"
  and     ModSize3072SHA256_modBits                          = "RSASSA_PSS_ModSize3072SHA256.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA256 SHA256octets 32" by (simp add: EMSA_PSS_SHA256.EMSA_PSS_axioms)
  have 5: "0 < n3072"                            using zero_less_numeral n3072_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072 e3072 m < n3072"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072 d3072 c < n3072" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072. PKCS1_RSADP n3072 d3072 (PKCS1_RSAEP n3072 e3072 m) = m" 
    using FunctionalInverses1_3072 by blast
  have 9: "\<forall>c<n3072. PKCS1_RSAEP n3072 e3072 (PKCS1_RSADP n3072 d3072 c) = c" 
    using FunctionalInverses2_3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA256 SHA256octets 32 (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-256. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA256_Msg0 :: octets where
  "ModSize3072SHA256_Msg0 = nat_to_octets 0xc16499110ed577202aed2d3e4d51ded6c66373faef6533a860e1934c63484f87a8d9b92f3ac45197b2909710abba1daf759fe0510e9bd8dd4d73cec961f06ee07acd9d42c6d40dac9f430ef90374a7e944bde5220096737454f96b614d0f6cdd9f08ed529a4ad0e759cf3a023dc8a30b9a872974af9b2af6dc3d111d0feb7006"

definition ModSize3072SHA256_S0 :: octets where
  "ModSize3072SHA256_S0 = nat_to_octets 0x4335707da735cfd10411c9c048ca9b60bb46e2fe361e51fbe336f9508dc945afe075503d24f836610f2178996b52c411693052d5d7aed97654a40074ed20ed6689c0501b7fbac21dc46b665ac079760086414406cd66f8537d1ebf0dce4cf0c98d4c30c71da359e9cd401ff49718fdd4d0f99efe70ad8dd8ba1304cefb88f24b0eedf70116da15932c76f0069551a245b5fc3b91ec101f1d63b9853b598c6fa1c1acdbacf9626356c760119be0955644301896d9d0d3ea5e6443cb72ca29f4d45246d16d74d00568c219182feb191179e4593dc152c608fd80536329a533b3a631566814cd654f587c2d8ce696085e6ed1b0b0278e60a049ec7a399f94fccae6462371a69695ef525e00936fa7d9781f9ee289d4105ee827a27996583033cedb2f297e7b4926d906ce0d09d84128406ab33d7da0f8a1d4d2f666568686c394d139b0e5e99337758de85910a5fa25ca2aa6d8fb1c777244e7d98de4c79bbd426a5e6f657e37477e01247432f83797fbf31b50d02b83f69ded26d4945b2bc3f86e"

definition ModSize3072SHA256_SaltVal :: octets where
  "ModSize3072SHA256_SaltVal = nat_to_octets 0x3e07ade72a3f52530f53135a5d7d93217435ba001ea55a8f5d5d1304684874bc"

lemma ModSize3072SHA256_SaltInputValid:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA256_SaltVal"
  by eval

lemma ModSize3072SHA256_TestVector0:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg0 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S0"
  by eval

definition ModSize3072SHA256_Msg1 :: octets where
  "ModSize3072SHA256_Msg1 = nat_to_octets 0x60402ded89d0979afb49f8508eb978a841abc2aec59cacef40b31ad34bac1f2d3c166611abbed1e62f6b5fbb69cb53df44ae93ab7a724ea35bbee1beca74fc0188e00052b536ac8c933bf9cf8e42421a795aa81b1bc6b545eaad4024161390edc908c45aae1f71b4b0228e3104048d816917cba4ae7f2afe75e7fcad3873241a"

definition ModSize3072SHA256_S1 :: octets where
  "ModSize3072SHA256_S1 = nat_to_octets 0x5f183009708b379637dac2b14293709aa6d7e86c267a0b690a3c275031139891267c64e5edecdff14c2cc2f2d985b62f900aee6e04ca51a70a5f946463691cf16c2d45547c5374f15bdb8881641d3040ef57807532cf5b2ced07623d0f638b39ebc2f2ce283eea2247e1df3af5430554d1d4b88b7b21622993419971b7d0d5449122a10fc31b2ddcc53ff751ff4bf4d336fac667b646780272db89a3ea4226afa20877bfb86ba3ff4204e5cd56e13a1dc9d53f5c9465b97a182b2bf671512ef89e6c3969f97307a3e4beba39a78e0ad1bb9799cda92976ca39d99db4ac149c84bb9bc8997e8d5e056d67ca23fe4be28e66c4bc00a25d65bb9d7d623fea2d3b9cf859dfd9efa9e52268bfa297afb1cc2883db0c9c42fc04180e2ec6f49657c7008e4025061f896886613895a35bc2d3655a8f50a9fca2ac648f352eb06bfba2fc340aaeead4a8457c65e2e8fdba568c60a6d8d381f5d9caa30127771f4a94fdb8cde7be4fa7b4f89fe379dd3e1ca66ae1fdd63bebdc0015448e61ef1666594b8f"

lemma ModSize3072SHA256_TestVector1:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg1 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S1"
  by eval

definition ModSize3072SHA256_Msg2 :: octets where
  "ModSize3072SHA256_Msg2 = nat_to_octets 0x2f03701c2fe07d47f5fa2c83a8ea824f1d429ce4fa1df2671bfadd6234ca5775b8470249fa886dc693d2928603b2a3899b48062a9ae69e5196da4ceb1d87b5979dbb46a2813c76369da44bcecc6f20edd753a51099d027e1610712ad98cfb418a40643100b2522ffdc1760454b4c82e59b09827e4102177e462a3792edcada61"

definition ModSize3072SHA256_S2 :: octets where
  "ModSize3072SHA256_S2 = nat_to_octets 0x8291bc1be9c981663156ec80c1ed1675763de06199b9f2760caaed5207fb4b3d6037bd08462b100bb1767e3340105b1a68728bc45c7d6fd078dc1b5e7cbfa193006d52f67e77fcf809cf26172a46db384eaf552a5fb8e33840fa3ef3d6b20c7b46c32ef019e8d15dd38eab66f6e40399ad0bbb07f94b8c555196901c27e2d4573958f53060d800cfff40c602308044b75d6451801c688d276525c3fee17a6792882a074c8a41420109e2511418c9eeaf3ab47350dd8c2d3e066abeb7913e08f0a40abe71d397c3dddafc41fbd04cc8fa3b0641bf53a90031b61a2a9b63d8ed8aacc9b301593c9f425105498cc4f84627f4950758e01a291b9b1a33ba918aacc172b68c9fb2c767c65910816921281aa8e5482512cee686e51cabe88e18f923fde170a506ba3c340fd1d68261986347d30d124931db2ce17602150000b794c050e137f4ebd45cc41f70ef3df1656218ff76f2e75ad96e4167eed524fa2ed9fd1a0cf76926f382ffb16124dfc87bb1a4110928d5b1cd3b16204ceeeccb7db88fce"

lemma  ModSize3072SHA256_TestVector2:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg2 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S2"
  by eval

definition ModSize3072SHA256_Msg3 :: octets where
  "ModSize3072SHA256_Msg3 = nat_to_octets 0xaf90f131f9fc13db0bcebfae4a2e90ad39dc533f34165e3262bc23ffe5b20450538669bf6a5210e1ffe4a583381d9333fb971903a68aa08901f14c2a71e8d1996e59889a36d7c20cc3ca5c26fbcd930128541a56a7926a8ae49a5ae786c4ef2de6527549c653ce6440c80b1ffc06391da65b7dc39ff4643bf3fe74bf8c0c0714"

definition ModSize3072SHA256_S3 :: octets where
  "ModSize3072SHA256_S3 = nat_to_octets 0x8c45e38eafaaf10a710e131bec63e51e67741774a9ddbfccdd131a123ae2a03067e7a6a92e653a25178bf527b93d6aa83fa366a2bd44896baa8b7f3f54830e4d9f5632c2d1bcae2aaae8c55782132aa7279cf1cbb6b7a81e4965ff84635c296c5ac206a04680e91e7b1ee7e5793701b1feb832250010d4ad4017c1608de8f405014ca73c39adae7c4adcbaee35fbbc71151cf955acecd8083677fe49ececcb62353c0a89c9dcb9c507979b56bfe060fec45567517c05f29e262df50767df7547630d8a7b32483b923bb1e3d510422dd4cc2d61a647e4f9636aa7587d4f8ed84b6174c1fdca9a217d9b907972a66c1f5a2ec2dadb60b93b515bf74072d315d17d54d57d721c8f4ce1a43eedf2025e51a48e9ea28160cf300d7a26010383c3280a186c44a53b7188e6caa364bf4dbe0baf4dcbe37d70e3a475cfdae339386558ccbc119873b1863975e2300ede1e420031b4cdac567e7b9c5d575c8bae27eebb37097050acdc87008ca2380f5631d190029a1d712acda147c5c4378cb6eac81731"

lemma ModSize3072SHA256_TestVector3:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg3 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S3"
  by eval

definition ModSize3072SHA256_Msg4 :: octets where
  "ModSize3072SHA256_Msg4 = nat_to_octets 0xe57debad3563fa81f4b9819405e41f98a54096d44f6ed119dceb25f8efe7d7329054de70173deb344c59a710cce03b16af9d168f6745eaf0eb07f80916648e804941ce7e583ab0a8a43a4b51844850edeaa4d7c943135efa9e770e9411a2411c586c423fc00353c34483f5bff5c763079f7e60eba98132213d64efffa94af7ed"

definition ModSize3072SHA256_S4 :: octets where
  "ModSize3072SHA256_S4 = nat_to_octets 0x851dcd2d4e1d34dae0fd585af126be448d611acaeacfa34f1492aa7d1caff616707dc31b05186cdbef769479243afb341577803b579e105070ad5406a6744f56e55f569370b9fcf6ab10e1aa0383f9182d451afb41358a2f8c29d1a571e11c404e6870cbb04f6ef30414d9b6d7f1416bacab0184eebd8deae72f2a48bea3a7844a8bf472a5f8d349d5973ffde3b1c40623dbaabd6f681485a9691c9be12618bba393b396f41cfeb89e18e378c51f147c7b0ededbc403bb1306454848c9bdb89f947843d0aeaadcdf09bad99efb76e742322521929f034dadffa483958df58a71af7da45461fc408c7c45973fc60c37a6358743315169b3100d4cd54f810d6e0369b9847ee38795cfe58443019523c3c9003edec4cdaa70de31d00958653058d8509907a5149a9f81be0ed028724f7232b57f93dc62ccf093a2635ee1e5bfe6ca9ea017ffab79182eefff542d278c471e1a2b34231700423bd0e757f6a572a14a99c90329dd0701f347d8a679cff25fd6b0d380ee5dc330d6ff1b4b1a347fc98d"

lemma ModSize3072SHA256_TestVector4:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg4 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S4"
  by eval

definition ModSize3072SHA256_Msg5 :: octets where
  "ModSize3072SHA256_Msg5 = nat_to_octets 0x28db8ffa55e115df7f188d627cd291fdecfbeea1109e1155e0aabc2157f7fe2a1284611e190365d2fd972d2a23dc793a5f28d4aac4100f5fbb2eed57532220d5d8d774bfa7084b44400249c19dab50e6c3c3af15966a960af1e2cec1f697a694a35c31a5a6f8ae7b73e148f09347004a3f54e7a82db390a0aa4fc526e95d79af"

definition ModSize3072SHA256_S5 :: octets where
  "ModSize3072SHA256_S5 = nat_to_octets 0x72c5555111eaef954236163753674a6ff81f182cbb379bfc6b548a52f9a5f260a0ed58f562a6086cf5ed00ed30adb023e90076a8adfa17cfd7d74f1e7b1978b210da847eda6b49891e6bd3fc6cd4c87b9326e8481a16c66e40021e5f878c303d3d8532bd7d966513717d5499865b2d03e378e76f7940f0448ab4d112e3c52cb332d340af122de3ee849f2e2544a40691ddf701d902bfe629766b36d82449286fd03f75bb2632dd61d6b3c6ce1c9ea8e5aff92ad2ca95a950eecd998e495e90e1f0966f922b7fb3f03380385f3b143ac1960c3bb688adbfd91d8fe1a1c32160243d3bd231a31c95dd78b6648c1175fa9c3c1244b1fa34d7c6f3255853ebacf5b3ec19b864e0a4eaee63fd719c21a72fc25b30b03207cf2aa45fd15d7102e5bae90882d00a812959593031ea3a436898582cae5eded5c7ce43de3dcac30b8690631e8db9f7a0a7f3f67b7524db275aafe02448727ff629d13afa94801d37526fbd9176fc4c216211037f8ec26b4f2672975887d70bcdbeef1e6ae99edbfb6c9a9c"

lemma ModSize3072SHA256_TestVector5:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg5 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S5"
  by eval

definition ModSize3072SHA256_Msg6 :: octets where
  "ModSize3072SHA256_Msg6 = nat_to_octets  0x4839d71aabdad8b15d9f37c3d37a346758d8941b01c83909e460f589855ca0e691096865cf62698353787e7ff517561801a6ca98304f6d11d76065e75ff17a8ef5c86d9582798be4ded181424175721afac7477e6309476c14c5e750576ce3cbdc3d8db3ae68655b6674eb149fdeb1f3a903b4d5823feca1015722cd55140224"

definition ModSize3072SHA256_S6 :: octets where
  "ModSize3072SHA256_S6 = nat_to_octets  0x796ac3f6adf4eabcb7a528ca63a6168ca6d31d5e357ad7a3fd180334a90d22bab20b762d767a6e3077c2cc8732784e81330041dc79068d50753bd4109c9c6f9ba03b5ac44efbcc23ecda27948511645fa17897dad7c122957ae56bf4ffe3d7bef85010b33d3b91785b0427417d94b11f73fda90e6a8748e6acc1d2d582e8836bc7dbe196876a9545b2a3207c1d4ec28acf8fe6f24c240b56ab3b4e4313a3d951aa1a558230e5f1eaf38cd7fd9b393d58d359f58f4ae51dd3971b418c5b81d0707cd9e2c33a148e492e74bfdd565eba8b1f3935e37a9d1a8764cd30497066e3c4622611fc14c45bf46fc85b3ed3f6c9d4d65e9925fe4b85ed30ec35ffc69c5fdc2bfa35d1bbdcb20e399cf934fe938f4c5798cf091d51100b4db4be42e81901e5dc79a98074119b7980b02821f4c3ff8ea07a2fc09a701978364bbd00ce4c5e2e45629526e34a3652719d27a47371480daf52fa49844f6495f35e6f5e3116c00b27042b3cead283bfc577905f8be87f0d5daa13d1ca74203a9e0d9199e885f4fb"

lemma ModSize3072SHA256_TestVector6:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg6 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S6"
  by eval

definition ModSize3072SHA256_Msg7 :: octets where
  "ModSize3072SHA256_Msg7 = nat_to_octets  0xc0b8b24f4b8e0bf29168ba73aa912c97121f7140f3259c40a72a6d6f78da2dfcabfcda00bea48459edaaf7b5fb5a9aed2e6d97959c393cd1a524a269c15e8c207cd09142be4f7e7d5016f6f19c735b8ab4c0f28e96954172af3cbcf29d65a161391b213dd5f7c006c294fe5016423718abffc8546ba373cdcb5a053196573564"

definition ModSize3072SHA256_S7 :: octets where
  "ModSize3072SHA256_S7 = nat_to_octets  0x8503b85dbd9eba8d6fc57c6ae2103a78df1fff3600585e3e18f6ba6436a3acaf8e49fd12dcbb37c25b4b765037f545c3da8c39ef6842bc9ec264af6f519272f3d8698ef2ceac55393baa9846a7961b738e41f6360053d866763c824bc5873da14a28eb47d68d67f0cad7880853aeb561045f757a31d9f5c756f54d793637d721c88fb1f60126d3d16478f1fc15e0c4edbb531c2ca2e2fd9e8dabe1df2c09fd55bbc724ebeba290a7646249cd779fa1a923909b29345e54a2e25dd935bf0612a5580018b233d765a6fae3b46ef51bd8325912f439a7dc40148fdb754e2d866f357b8f0ebff6f18a6504ba31d10fe45226c88c9207b9be3c63261d75270466b43c271f75b1ab3c1d6b5a00dda8457b4d5c2195f320b0bd545fdd0679c84483c14a46b4d43c8452879725aa91d01fcc2c3867391c72200ca5d628ed9b566389f02fe74ba2a428a7ba31c00ef6b8d38c6b82b7379d2feb11031848fec0fac5b6091eb7607138bf0b96c3d2c174b5713d0dc8470b532eee6ea0ca1e8ffa3b15cbe0bb"

lemma ModSize3072SHA256_TestVector7:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg7 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S7"
  by eval

definition ModSize3072SHA256_Msg8 :: octets where
  "ModSize3072SHA256_Msg8 = nat_to_octets  0x4935eaccd2af7c5b99405471bed9b21da8965004f5e6f2a6b7ed3ee2dd26cebcef4d845fff7c1d5edc94093f88de7a3aecf2bc3ecbd8c435f56e0b89bd099de7ac5f6c4377a5eb1c2ff4d801b8f159547cad4b4e60cad743f8e04627f61e1652e9354d8024710d1cfb2969be365a77f2bf8fa63b9e045257270a96c572ad6285"

definition ModSize3072SHA256_S8 :: octets where
  "ModSize3072SHA256_S8 = nat_to_octets  0x66d1cea94b9603efad92b6ca8a1fbe0c6c4b9dc60ec0ab2c33bb62d27a100e839378a39208715de2102eae384ca407e92787ce1118f91a0ca2640a5c93fdb78635bc91082c99968ceab289890b3ec210d6cc6f1cf7e0fbe2dae88155e88f2fb7b325ab5e529e4b63493e551c53ae38c3fbfae49810050a81cdcea627da21b63224612d4361b9df19761d6ead44488dcabb50127149f077c2963afc049ac8837ff2c29e6a35593e22531ecc2e9ef8bcbaae4349bd7227ff3e13b31bb929bbd49e50059f28fd9ffe8c296a056c2760e5f6d8dab43e9bd557793f0759ad8e08b5c3773a305a0d316ff9bd07b43106335942055adc461a4346f05ab455780f32027de8b8bb6d4845bb24d0c5a21c293d2b0740e8d06ef5fb9dbdacb4fa1c6225fd4e19dae69a8e2cbfdff1ef8b7f21804ead0a45274c735fccbfa1d60bf497a3aa931bebac2e0c8beda9af596dff0cbe11e8d4602d36b2f6c6f5bb80f12f4b9daf2c0748f591098ea63d3193f50a1f4737efacb62ea85fb6fb212b3ec8effe788e55"

lemma ModSize3072SHA256_TestVector8:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg8 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S8"
  by eval

definition ModSize3072SHA256_Msg9 :: octets where
  "ModSize3072SHA256_Msg9 = nat_to_octets  0x3b8a68da11b61b5fee1c2ca00a6aa35bbfdbdd42855b284320ec8d0c1848edcf6ac850427d8479eb57bcbe9a11771637886974bd561a5387014592cb717e8364a8183fd4ad463c89c980215ff629d867956ee5e75f71f7a19ea7bd589d7efb915d44dd9789448bc1ac32fdf7a2c911734db2dbc589a83c1a61dab6bd83907ede"

definition ModSize3072SHA256_S9 :: octets where
  "ModSize3072SHA256_S9 = nat_to_octets  0x790058355d7ab9eccb46ea12368f3be9cf6b895e1734eb20a13c749557b9fecf92b316870f0f765864b607439ee5f7e510e2c83b2756a0d9877b48e0cf257b13c997b9dc70421d2d87c9b9e5625c36a17e21e20ed389657a3e544c677464eefff08a9ee4adb091a9fbce7626cdc127b5cf817c2a5f069e32c720bc2041cd21a6bae816dbbbe28552d022b7b608fa99da4d217dae8a69f54004fa3c004d50540957648296e14cca729f791b38e3645204c2c6d4cb678b0db63a181b40cd9851be84629a068415d54cab5cb5244c8dac8dc9799a0df1b58cebfbcd8377a391778869dd275e0dc8305eb0351d81e3afa46719355eee4f90894f7fed662dd3b03270660adff637b91e18330a4f3a62c914f0d32b4eb6a30b79371ab55190578a1e7d43294bb0a721def7dae3e021981707930bd9b5cb58675851c83acf330c6ba3aecb3a890ad3c151a1e2b583a7dccbf204850daa9f4679e759ec056abef7ba4d6e0bdfa57a5c5afb6368b048a2b74e3530bfa8991c55de7cc8bbfa990d118ada80"

lemma ModSize3072SHA256_TestVector9:
  "ModSize3072SHA256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA256_Msg9 ModSize3072SHA256_SaltVal 
         = ModSize3072SHA256_S9"
  by eval


subsubsection \<open>with SHA-384 (Salt len: 48)\<close>

text \<open>We interpret RSASSA-PSS with the new RSA key values and the appropriate EMSA-PSS encoding.\<close>

global_interpretation RSASSA_PSS_ModSize3072SHA384: 
  RSASSA_PSS MGF1wSHA384 SHA384octets 48 "PKCS1_RSAEP n3072 e3072" "PKCS1_RSADP n3072 d3072" n3072
  defines ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA384.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA384.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA384_k                                = "RSASSA_PSS_ModSize3072SHA384.k"
  and     ModSize3072SHA384_modBits                          = "RSASSA_PSS_ModSize3072SHA384.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA384 SHA384octets 48" by (simp add: EMSA_PSS_SHA384.EMSA_PSS_axioms)
  have 5: "0 < n3072"                            using zero_less_numeral n3072_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072 e3072 m < n3072"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072 d3072 c < n3072" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072. PKCS1_RSADP n3072 d3072 (PKCS1_RSAEP n3072 e3072 m) = m" 
    using FunctionalInverses1_3072 by blast
  have 9: "\<forall>c<n3072. PKCS1_RSAEP n3072 e3072 (PKCS1_RSADP n3072 d3072 c) = c" 
    using FunctionalInverses2_3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA384 SHA384octets 48 (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-384. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA384_Msg0 :: octets where
  "ModSize3072SHA384_Msg0 = nat_to_octets 0x9221f0fe9115843554d5685d9fe69dc49e95ceb5793986e428b8a10b894c01d6af8782fd7d952faf74c2b637ca3b19dabc19a7fe259b2b924eb363a908c5b368f8ab1b2333fc67c30b8ea56b2839dc5bdadefb14ada810bc3e92bac54e2ae1ca1594a4b9d8d19337be421f40e0674e0e9fedb43d3ae89e2ca05d90a68203f2c2"

definition ModSize3072SHA384_S0 :: octets where
  "ModSize3072SHA384_S0 = nat_to_octets 0x9687115be478e4b642cd369392b9dd0f3576e704af7218b1f94d7f8fe7f07073e3e8e1186fa768977d6b514e513459f2373df6ec52e3de9bd83fcc5cc3e6b97f8b3fb534163c64f5267620700e9d8c52b3df61a7c3748ef159d6b390895afa3af59109a5478d016d96c49f68dfc735ba2aafd5012c13515ed6644f0d4109c45556e14a3821e1aa24beb8a81a48da27f131de84f7ba51581d81b8ff31ba92b8a1fde867f07e32e6c2709253448174dd31324dbc32b05f07587f76a9997decb80f38d8c13d0f6eb3c10e3d96a2293f7464f1e04602ef6e84c2d0245d7db256a67d132a47cae9abe06b61a8968f50a1749995dc15ef0dcb1d5f5959e4d454c8547bbb4d195698f484617bfd122acaae2d0e8c76d28b24005ab03caa781ea97b1c4d9396a16f7998eee7ddd9de4cabe57032d9438a5d99c6b34a956122350263c7e998bc61dec91381012e686d079e39e96b1ea4bfdb7cdf630ddb422c6b580e5506c9cc3d6c100f2041d17ceaaaa54589249f04a1370ffa3bf3ff1adeb890688698"

definition ModSize3072SHA384_SaltVal :: octets where
  "ModSize3072SHA384_SaltVal = nat_to_octets 0x61a762f8968d5f367e2dbcacb4021653dc75437d9000e3169d943729703837a5cbf4de62bdedc95fd0d1004e84751452"

lemma ModSize3072SHA384_SaltInputValid:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA384_SaltVal"
  by eval

lemma ModSize3072SHA384_TestVector0:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg0 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S0"
  by eval

definition ModSize3072SHA384_Msg1 :: octets where
  "ModSize3072SHA384_Msg1 = nat_to_octets 0x752a9916f449aebf814ce59ca6e82fa8038e4685419241c1488c6659b2ff3f7b7f38f0900a79c77a3b57151aff613c16f5020ad96ba945db88268722ca584c09b4054a40c00901149bb392f0916cd4244699a5e6a8c37e9621f54b471166797a7b58502cff4083140827052646501f5b5f1bc0b4e129147d7cc157cf6e73ec58"

definition ModSize3072SHA384_S1 :: octets where
  "ModSize3072SHA384_S1 = nat_to_octets 0x6646a88ee4b845da4931274c23840dada6145fe0af954829d1d56661546a25e46316e216bb6b9446b368884ba14969a6f68ccbc1cf5b4e7a6d3aabec67f64963f63b088fa817c855d776ddcada57e5daa50fc1c877389c3cb9d99095a869a963bc91ec24b2422ef6b8dd18fd20d2b215fee6e98cda415ae44d2d2616fe1708292a3ef50a075170b3a7ebab02918ab0301794c17fb35e2038f369d94dd49569c066f7c392889dc4b878c50c7e52586b5081114d202338d23304f16f912d519a9ad21baff0e3d21761f373d08421e10108a983048fcb90eb2adc7c7f12ffa1571b091c781b255a77a880e97975f14f42baf5aa285ecc142157c3e1addd6aa0c09253a11c59144abd3b1e212d89e27ed96fb75756afc20ec67423b151194cb0b0648c659987a5583cb7757779d8a39e205e7101a5351ce1af2c9c6b0847cca57af52593323905e3d2297c0d54541a0125621640fe1deef13e759f8f6c56a2ec2a94831ac2c614b911e79edd542fef651f5a827f480575ae220c495f2a2842f99ec4"

lemma ModSize3072SHA384_TestVector1:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg1 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S1"
  by eval

definition ModSize3072SHA384_Msg2 :: octets where
  "ModSize3072SHA384_Msg2 = nat_to_octets 0x0403ef219938b8cdbf85d3b88cbb9c60d174134e43a7284cd87936d37456cdc3c541b4566b682e575dfc7d8f883fa581b9df7257bc82bc1bc6a2ea2a109bb5e6c5022fac1e390306cb40fe2196cece8143a10af3ba1273c368ec7a30e27e021dcbef6609f9d2be41d3fa5e54fd90a0c83862e40b837ed4ac8600edcb31283bcf"

definition ModSize3072SHA384_S2 :: octets where
  "ModSize3072SHA384_S2 = nat_to_octets 0x0a217503fc4870481264d8308292c663476b25f8dec08ea1d1276f0951ec6df27aae3beb93d630bf8fac08b6cce50bd92994851b4f310fdddce8e0d6a8b7a1e866a567b298c5577dc50d8a906ab1be880084e681b26456279149b4b85201621c445de13d127fb77e7f236c39df34052b4629572abe1c02c09eb198188003dd852f88f4f767f1000458680258fa4b63dafc761822ca8b98c1a121b72b1455393bee416d24051290f02a28a7b49b18b30ccb29c26fbac991401a3a6fe01fcd0608920facae9d5bc56540c80f4740af02c9b7a078958a8d8a7a93a5e5b6d2571f49d775ef7c35a6d674290b52cfbcd67277e2b2e829ec437fb70e90537eaa6fe4548551939bfa98fc98e235b264aa6064a505a8d67946e2c33e5c6f0f34fa86ba65715c258f238b69e4f6e36d86a89822b4802d21ba0ba760b2f3a5bd061f50aaadff12e0d86627294bd0c4cd1085b5dab6a6ab30146c9bbb37de3ac5c4f8ee29736d46047e450cfdcb1279e4ca83ab69e858741bfd01a779d475dfc0f71c621d78"

lemma  ModSize3072SHA384_TestVector2:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg2 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S2"
  by eval

definition ModSize3072SHA384_Msg3 :: octets where
  "ModSize3072SHA384_Msg3 = nat_to_octets 0x453e0835fee7cde81f18c2b309b804c67b9fd9e96ef0a96e3da94b640978830e5cd1c8940c3d4af763f5334a7caf2d20f0b82541b3434fa138016b92dcf14638817a833d79b79bc7a71223a7e0144ed4977bb217ba8d4f07d7adcd38832c05b0fc61c39a0dfcca3f32971931fd8e6dc9b81107d44c77af8a62d5f9c0c7d0c75e"

definition ModSize3072SHA384_S3 :: octets where
  "ModSize3072SHA384_S3 = nat_to_octets 0x6ec22bd58c32d41374c017a77027e770f678fd81017e20cdaaab48a8324b050749e5d864082f1f77fecf67a59c2885e931c3c2f58130fa6806fe1ca899045114b09d09cf9c513ce1109d2210511a3b2e93af511badad2716f48555310e6c5f547afbdb0b9a684491ff3588df933d6b04dae8883f5f8aad62a4570646f72f3656c4a7085623f5152164a81a06ccb59ca478c5c2315414550b0ad8eecd0328b2db01fff7db0f26596c41f970d032925887f1c8a446da889be64d48925b9c6b79a3d897700ab40af20b451aaa6b427ed162864db89f7824b6ae9b475b5433b865335d6f91491c1e32f635cb930dec1aa3ee7ddaa08e8ebd67b6b11a46ba049922446fa69f1a804acc29f6cee487723f2e61a40007865d80cde0119f3fe6e161a339487f5789e1fd23ac0a63b4673969fd8722e3edc9439778928f09610cbefbb42fe6242c73b68d466cef889da156d9d4ff888362db4cf9a941e80f577c944b79fb27dbe0a6967e88f1f67b91b0d38e083fc0c0228cd49d27352521312163f90fba"

lemma ModSize3072SHA384_TestVector3:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg3 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S3"
  by eval

definition ModSize3072SHA384_Msg4 :: octets where
  "ModSize3072SHA384_Msg4 = nat_to_octets 0x9aff46c14fd810a039c0a62eda403f5ca902ac41b8e225c6944748a36cb45f8a769ae2a18f713d362206d2af4a1742bf3b1de8e0de69a7fdbb72e66e1c6ed82a6f1f0138edf0f6677940643fcbfe5337cd76ac29456af902b5656dbe7f4c24944d36ab6db07dc39b081662c8a31dfb2c29b4ff04370ea43f4ac7e57adf77ca2e"

definition ModSize3072SHA384_S4 :: octets where
  "ModSize3072SHA384_S4 = nat_to_octets 0x62a505b3f3adda45c6badb61b464a28bc45d4c66159a34b63c1cce32604242eb8fcd9ac6929ec6ee4ac1144932d725cbf4638511464ec70dbb5543a4487a241396adb804c9794b271f9d35310ee560368d949a20a2b64cb4617fcf63cf7b60978cad734650dae86c7e51b766522ef0be48bceafe2030564d5b7b17ba125097bdafee48e4df60fbb7ac2d9f14af9a270c2b7ef18cadac45b9b54ef230794339d279d72ba48783bb09b1d1d5c1c65301276523fe90e63789ffbcd489e45f8aa9cf98f33de8f7d9c5cdd21a9ab2847896de6dce0b92f07b1ffb4230ee71ba1fe8048c22dd38af80f8762e747cdec6e99f1ce0d1c743ef98ddbaf7c764412446dca58e6ff5ac0dd13322649acbc96f1c5e0bc58d1a8211853a7d2f51538c5e5e803de0b13044608d6e650bace12945a7008194586e3b74809714b2a52e9f3824be41de9fec3f36175a289baf9fd68b7e92f3754e00b41782d055faa65433c25259aa653fda069386b083fb31aeec8e30c769553f8f0389b6e6d4b392cadd24ce3f74"

lemma ModSize3072SHA384_TestVector4:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg4 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S4"
  by eval

definition ModSize3072SHA384_Msg5 :: octets where
  "ModSize3072SHA384_Msg5 = nat_to_octets 0xb50bf2767250f14fa7b6f5ea21a54da8d01e91151eb491107fd88b2d4a5aa157c72d89ba896b87e0fe989819442bf0213e4aa7fde8d6b026e7a70ae965193a0e1bc7f8b8af96298c41f60d154164ba678333c903958d4ffb50b50f57ad8eedb6da61a6398ddbbf9c9955bba6bf5991c4c6615df1cde156d8e188003dcbc3a399"

definition ModSize3072SHA384_S5 :: octets where
  "ModSize3072SHA384_S5 = nat_to_octets 0x1f068bd083a26534040f41c1387e71a8c00370c5f1c958127e0bc721751b5940513023fad02a6101bbcefaaaaeea2875952bf859d494bfb23fd89149d91290359ecb44ecf2fcaa5775e2e61e5f8d5151343576fe9c7167e919a5d081dac6bb8117229c420fd2b0fcb521f4e72366bfb443e688a65fa392eaa5115c292ab05bb4db65468aab267178653dfa0a5efc960636fcce86433528dbce955a0b1aa188ac33ea128206ecc0feeab8f7df6f8c381b10489c8cfb2d02459e4cffc16f43a66aa4eaa19bc518ccfcf9fc1e4861cfa13e9b41fcefade2cd2ebc001ec8430a1cb949a0f2f876badc568c703e4209e7ca16f688ba9705c14fa1c882e6c4871b9deff31521d2d418e0342e189c40ed19c1b6f4320d89a36f78eca143d3c16dd3eb338c0743646fd314c725c2d36a13080bfcdeea0e431de71d61f652033a75424fe1e1586695c3dc463ad553c1cf3ab24a41ff4e031f9e0c2cb0024cef68273ea3b8c1be9d923d3e9c9686c41977ac7be94a6d23181936131c17a39a898c943dcc8b"

lemma ModSize3072SHA384_TestVector5:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg5 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S5"
  by eval

definition ModSize3072SHA384_Msg6 :: octets where
  "ModSize3072SHA384_Msg6 = nat_to_octets  0x5ff000f84a951dbfdd635a4d9f1891e94fc2a6b11c245f26195b76ebebc2edcac412a2f896ce239a80dec3878d79ee509d49b97ea3cabd1a11f426739119071bf610f1337293c3e809e6c33e45b9ee0d2c508d486fe10985e43e00ba36b39845dc32143047ada5b260c482f931a03a26e21f499ae831ea7079822d4a43594951"

definition ModSize3072SHA384_S6 :: octets where
  "ModSize3072SHA384_S6 = nat_to_octets  0x18cb47bbf80bad51006424830412d281c66ae45c0b756d03e5d8d49f73037968d13df46ebebd9b5b4c58b164d91d0608e8ebe31d8644cb0bebfaa8e2ccaa1f5746ac8f3bc02ff6930e219f53fe13fc070f910ba1cff0617aea6eb312c1ef285869746673ac1348e89c3646f583d7633f5a2341626bc2e7e2087ff9d8f13d573dc6455dc0068c7ac6eaf5b3093b081614f7b252170c4893891e469121fda655a2a55d67f5df0ff6e29ce5f9b0c3a1a88342140ead748edeea9706d6570e900f1cf3a9adcd7ae64f207585417946b104b3990d1a2d950e0e6a5533d3cfc8c470250e4c797273210f248b8922ab00422f2ecf85aef73587e8c5cd1c2ee6ed9509508409673fe07ee2c462c52d091e7a795d8d3c55fdd5a710d5450695a5a31ed76f115e71a73c6757d2def7ef472571b0bdc7558c71eaefeddec946860b0c77936db31f2001d0499a381e5018870b41ba04c8d42ec0dc55c9fa2af237dc1c405dd8f555b07a237cc50cbce46c3016118cf4ea06c047599283ad4719d647a225206e"

lemma ModSize3072SHA384_TestVector6:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg6 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S6"
  by eval

definition ModSize3072SHA384_Msg7 :: octets where
  "ModSize3072SHA384_Msg7 = nat_to_octets  0x531dc2b8566e01a8bfc580da607ec212fc1fbebd5a2590d897046f0ec069df20a1c2278ad70006642d9ba28625d7c1efd4473b68f38fb064346d762bd2fbd5376c2e77de13a31a32a29b88264d44c9f27d3a97b8dc4d1267ab85b5e05c6389575d6a98fc32dea5dbc6cc1a01034a42e1a000b8f63ae720a9a7511474872a6148"

definition ModSize3072SHA384_S7 :: octets where
  "ModSize3072SHA384_S7 = nat_to_octets  0x80baa663877615c2e7ca9dd89958a74e54012efad55ad05868dd74b0ce78a661e2b893c3ac1fd837f282327efe4b041220942649b5472c1ac702070787ae5549398a57653d5fca69cd5446d63f6e9d0684925a235acc96b8a10bdf14fbe209fcd4930b5945910d84b08867b2055fe8eb1d771b753759593b90d6aec5ef182cb33bf2fe29e8c67ea4e8433ecfa3f9ba4ce461f0ab19997f299e95409af97bf57e2de410ef7538f699f385c1abafdf9337f7f9d268da87b2b389131fe3dbefd8c67bd2a158cc4e04f9ab7fee2a58d74d063e6c16958a90574e3e4cb881d32c3116987e46bf5bd44f80abe6b9eb717a9fcd4c0cfe80dd2ca62c33b5dd3a59c64810073e0476085ec7b76638983291b69559c815cd3bb87d4b07e24c6b9ebb7028e800a04f09b110c167f6ee3a3bbb73695d89bee92407d4adcea3eaa47811e23f8c7f2fdfe891f8cfc071cb984a63846b95ec04d6261bb1c5980018feee15c4e7bf632dc8306128fa22c47decfd9e8b099554f17253635e6316712e0b95efa3fb00"

lemma ModSize3072SHA384_TestVector7:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg7 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S7"
  by eval

definition ModSize3072SHA384_Msg8 :: octets where
  "ModSize3072SHA384_Msg8 = nat_to_octets  0xa454391a7c3695486c337a41c2add417d8e9e9c6466d2ebb56ad5f97b9e7ce30784cfcd82d6066e372a3a1639a71a9369f2777435c87d100fc5e6638b3631a0bac639f36429b4594726613e5901816cf3a29f9228b96d66090844c7d0026d2e327e24ab924afda6554c2f74f0e69c2e8913798ec3a61e4e4fb6838ee08f89dc0"

definition ModSize3072SHA384_S8 :: octets where
  "ModSize3072SHA384_S8 = nat_to_octets  0x261180717edd905b647bc869f5259203811606221f545a3aee5fc123f297cf7d8a7ee6cee3dc8f97d24284ccdec2fd4680f1428ee75797e0379512aecb9fc1667523413e323c4bd7dded5caf9e5c606e5ee0c694d4d1b5a1f1cb613b980129f64146e42e8261c1f7ef5603954d34d56a50f7431beee5ab291a4759168655a5123640d596b744d97979d39f874ea7ff13a7466a7655d02edb492b58049f2208852297eb023e657f3240c5da9a99fd377728bff3cc073109c31712d94bc24e08c433533d4b86a73b58fbf2c598ccad78d46ca0a055601850960195aac1364dfaddbd06f14a78aac2ab4d374505cc61fc72c1050647d95a733517b709aed2d896721e7484208501480058fa4f6044302dd705c273fa7fb42eaeb02d025092b252e16d270d88dab6f68fd7ad571011f89627683e029d1bf1edc149d47452ebe87ec68679579940f5aec25999b0dedb820a5483ec6901abfee041c03b1a7f743548a2caabca613ff5d9f8fd7c694af12b29f2c2468eff55f9e008757443960fae459e"

lemma ModSize3072SHA384_TestVector8:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg8 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S8"
  by eval

definition ModSize3072SHA384_Msg9 :: octets where
  "ModSize3072SHA384_Msg9 = nat_to_octets  0xa05e5782a96ee6d6f10be8830d8c27c0acf272abbf77e684dd6a6c19e5398381e5d0400d3a21927cf904cb6e8e425c1ca3ece04544f25d6c40f0c640d24bc45c807db53044adf63fea835d8cb93a0a4e55f760ebe4594e247051d38d8c34c1413b0ec1d30d3a97888b2fa7c3d59db8c08ab9f985e8d4411635339be95d1b0299"

definition ModSize3072SHA384_S9 :: octets where
  "ModSize3072SHA384_S9 = nat_to_octets  0x87d80275df7b196b7e1d0a41147719d773edd80b5627301a500d91665ba86076e6a31c8f3ae86aedb643fe2af223976ea4eb3d4dca2cbcf81ffd14b7ef7de3ee355a8d0f4143e5b0f0a0950a42811102e602cd214e1c945c47e8b7b66d507103c3456f404f9c48aa7fe48dee0aad05e599f242adcf8ccb0cc9db3a6c244a913551ab595600ecfbb67c25a95b54f4054397abe47650e5c4991edaf1441ba9c8e3fbed904ffbc977142ebdc84769865a215158d5b052e75de318d75012172e28c31db2d8bd4edca787216dde2a7387c543f162fc91924918fd6c845bf1ebc0220a1027fb4227340ca4cb0f183e5b34b1e7f93e14fa57bb9d2d2ea53f86d838bcbe3f055b473b0b469afd2960c0d76ce2c30f3d49a3b29065bb9260248e728cbe328bdf502b109e1f20b9d037860cf9e261611b4cbf27ff9b5bf425b2612afc7cfa3138f78ad26077cbfb947fb2aae6f4be85ab2d1a15860839b822dd03a1a92a19a5c7244e98bdf561625ca2a8df410ff855752ebdf3d49f5eb98f228acdd52791"

lemma ModSize3072SHA384_TestVector9:
  "ModSize3072SHA384_PKCS1_RSASSA_PSS_Sign ModSize3072SHA384_Msg9 ModSize3072SHA384_SaltVal 
         = ModSize3072SHA384_S9"
  by eval


subsubsection \<open>with SHA-512 (Salt len: 62)\<close>

text \<open>We interpret RSASSA-PSS with the new RSA key values and the appropriate EMSA-PSS encoding.\<close>

global_interpretation RSASSA_PSS_ModSize3072SHA512: 
  RSASSA_PSS MGF1wSHA512 SHA512octets 64 "PKCS1_RSAEP n3072 e3072" "PKCS1_RSADP n3072 d3072" n3072
  defines ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA512.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA512.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA512_k                                = "RSASSA_PSS_ModSize3072SHA512.k"
  and     ModSize3072SHA512_modBits                          = "RSASSA_PSS_ModSize3072SHA512.modBits"
proof - 
  have A: "EMSA_PSS MGF1wSHA512 SHA512octets 64" by (simp add: EMSA_PSS_SHA512.EMSA_PSS_axioms)
  have 5: "0 < n3072"                            using zero_less_numeral n3072_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072 e3072 m < n3072"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072 d3072 c < n3072" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072. PKCS1_RSADP n3072 d3072 (PKCS1_RSAEP n3072 e3072 m) = m" 
    using FunctionalInverses1_3072 by blast
  have 9: "\<forall>c<n3072. PKCS1_RSAEP n3072 e3072 (PKCS1_RSADP n3072 d3072 c) = c" 
    using FunctionalInverses2_3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512 SHA512octets 64 (PKCS1_RSAEP n3072 e3072) (PKCS1_RSADP n3072 d3072) n3072" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-512. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA512_Msg0 :: octets where
  "ModSize3072SHA512_Msg0 = nat_to_octets 0x44240ce519f00239bd66ba03c84d3160b1ce39e3932866e531a62b1c37cf4170c3dc4809236fb1ade181db49fc9c7ccd794b433d1ad0bc056e14738e0ae45c0e155972a40a989fa4b9bcdc308f11990818835fa2c256b47ee4173fb4fed22ccf4385d2dd54d593c74f0004df08134eb8965dd53a122317f59b95d6b69d017958"

definition ModSize3072SHA512_S0 :: octets where
  "ModSize3072SHA512_S0 = nat_to_octets 0x8f47abc2326e22cf62404508b442e81ad45afff7274096b9a13e478cdd0a72f99a76bf517f1bb0f872a523d8c588d4402569e948fd6a108ae1a45c65830828a10e94d432765314ba82ead310fc87ac99a5b39f30ab8820bf69e6934a9c1c915c19f36ea7717eaff7af67b4991315b1873ba929bedf18a975be808e7aa14a6726126c79cc93f69541c5cefdeb5b67ec279d8f5a446583e4b4faed1685140ee4b3b757c8ff4a1ef9cd76a88e05319ee62003d2d77290c94c579b0ca2ab0deb3176ef10a3fdb85c80ffbc9e2a665a23744fc836f9a9a103cd9fb756952356a2f1acdd68a645e20179006558b5d4d0b9b0bd3adf5e290f49dae60b9d19920953ea8bb237d5b3dcfe149a60f12a4ee3a889b33bcd3a3b753d610757cbcd093dd5a734255333689695ab636963e3d215a8e77ff31973718a4944a1e9e44f45754d39f6fa431c53f9a2ef36e16a5f70636eb5fba54e15c20a714f2809a7cff4b8dc1165f836607eb5a5a3bb0c4567eee26941fef46fb41e73b565c0cf8c72e404221264"

definition ModSize3072SHA512_SaltVal :: octets where
  "ModSize3072SHA512_SaltVal = nat_to_octets 0x2d0c49b20789f39502eefd092a2b6a9b2757c1456147569a685fca4492a8d5b0e6234308385d3d629644ca37e3399616c266f199b6521a9987b2be9ee783"

lemma ModSize3072SHA512_SaltInputValid:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA512_SaltVal"
  by eval

lemma ModSize3072SHA512_TestVector0:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg0 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S0"
  by eval

definition ModSize3072SHA512_Msg1 :: octets where
  "ModSize3072SHA512_Msg1 = nat_to_octets 0x06d5534b7769256e8cf65c6ce52a3e86965a1fd12c7582d2eb36824a5a9d7053029fbeac721d1b528613e050e912abd7d9f049912abeda338efa2f5213067777edd91b7576f5e6fa7398696599379ed75028cb8db69fa96de7dbc6de7ca128dd51ea334e8cd9cd8fdaefbf53fc825eae836b6c6cd70039a77e420d999b57caae"

definition ModSize3072SHA512_S1 :: octets where
  "ModSize3072SHA512_S1 = nat_to_octets 0x913fc118d5ac1edffb4b8fcfa4e85986b46231cef3dad911d5e9534cc88261f6b6969b75a3f25d83ece7ec2034b01d3b2be6c5bd958cc4afcd44839e3953f01e4a15ea5ef6e1b4b0e8ae90bdfd404199e8f86547f67ff6b84f2162c4311cc9eee06bfb2fe46198afb9745d9c443833bf2387eb92406a6339521396f2cbda55d98fe64074d2f2e27b8bc6a79be3d1cc568869b0b50fcbf702b0831668fbfdedc2d1b5491e8ec623edeb60ac870e6e8d058593fbbc938fbf741700efc2b2467e7eb254ae008509e91607f8e50aa16a4e851abca7c8d20c6ff61cfee6c1fb676098e5cdf127c9b79538fd1e6c014161054caf43b734fa69fe06a00d76f710acc198f3da906a7d2e73a2ca882526cc354dd7630a303d8f32c655b5b33cf78859beeaba3f9ae052c8d7471cd2bd9edf42fd8f70c3b0aa79c076928068ca9770959afa632ca6aaba6679e45d6888c50125a73b9deb00d42a125f25df5434beff0d5b0ee13a16b17045cece0f2da7577d79d7cd75a4b6c5bc345f460a173487b51bc6a6"

lemma ModSize3072SHA512_TestVector1:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg1 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S1"
  by eval

definition ModSize3072SHA512_Msg2 :: octets where
  "ModSize3072SHA512_Msg2 = nat_to_octets 0x756c51bae61d75e8cf44930e1781dd6b8db6bf8b1f68b4ca4c685d14dcb2d4eece953eba92149f36788df34769987af5d53253b6ec1b4cef117cf9b88bcd03e07ef6c3301ab40ff4133f54b8512ae550e88a931b4a5a7e88bc1e2bd806c7d6266fd709a5e8c56d2a88a3e1ea38fec984b006a842a2eef29b34961bfdb468f4ca"

definition ModSize3072SHA512_S2 :: octets where
  "ModSize3072SHA512_S2 = nat_to_octets 0x735186ebf08d505161a8bab36786138414bb5ca2f4025289af237a40f8d0963df9117b619f83d9a98dfcf74b8f001a4a742c85ae018c3b51f16eb5015ba7027cb9a0d0b9e6b65c08ba58b671a9b3dd62107bbd5ae932784d328cdb2e1a551eb67e9d33ff1cf9bffdb223afd75d3650459fdb58143cd4490981efb0b3fe36f642e1837a5d95c3d444af73729dd1a5e9937b8114a28e065d1081f061049e650e45ff5ccf75c246e2e9433b27e79a1b06f7b6b57f9b009e97168a61297cfd0a8156d026a6bf8c3764d0b715c619d856b061df35725498d86cec25f7e1da65b99d9ecbb9a1a6364252e4790d97ea0ffd6234b515929b5ef22676c243d386ebb90a22e67a0e1d1094dddf7721099868c31326814887b646ca52a2c4bcd43f7c71399e7d13e19de688ae5c20463df5965d8255a3e6928d614b601274b757cfacdd4002d9ba8b248ae700d8776475d79d0a55ed4241c9919a3c44dfb9a1f5d0fec7ca341774c596144c38174af59af6deb8937a7d14c459b5d768a977445dafee1a4eeb"

lemma  ModSize3072SHA512_TestVector2:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg2 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S2"
  by eval

definition ModSize3072SHA512_Msg3 :: octets where
  "ModSize3072SHA512_Msg3 = nat_to_octets 0xa9579cce619ebade345e105a9214b938a21f2b7191c4211b2b75d9d2a853805dc8f1eb8f225b876ab857938bd0ea8cc2ff1ee90087030976e3f46afb9f1b1bae6d3874dd769d0426ee7dcbdceb67a9ad770e1781e34b15a45f656328c88ff485c1b2a083056d195afc5b20178c94f94131761cbd50a52defc8502e22cbb6f42a"

definition ModSize3072SHA512_S3 :: octets where
  "ModSize3072SHA512_S3 = nat_to_octets 0x603ff63ff638f1ad410e266d82a04c6d475416a0470d97f483c0c99e8fc7212d61e02cc8b4493c9a9dac711d2a8edf196a26563866d68fb04849e82db0f9741f721f2ba4e9db62f6ecfe3b87ebe7feed0c9e2dd46c3f9252d4c122c6bf1bf4ce215ba82fe7c5a91249da70dd30fc9c8ac8b3bb2810b4ff38bfacc13fd41f6fa26507a055e0f1242f18ea8ed8a702d265f893cb4eb61a3dc8e18777157552a1c58db14349a0d0a2a900a0a1f4de863fbadb063ad2a9e526a0a8c3bdcfca5524c181637b1c4a574809fb45b2e4f06f3f89f4ccfb30217b32fc484bb908276d659a0d9a3e7e3fbd46565a0924f918b16b2d6527ec4b5d1d6ef6d6720f3e00485e87de61ed49ed13e85ca6a10d46d4ca4839f486621cca48a7f955a878c4785d55de96facbb91b6ea12e9e4fe4beed00141b0372a3812465e65030f4fb8ddd58701aa3da27d26feb8644f7c80b8ee2a3c3b20a516c7f0b068b503fbb65d3f3b84b253466a887314aa8eb9d85cd035bf8dbb178ebd8d5496fd1b68432457c78c69cad"

lemma ModSize3072SHA512_TestVector3:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg3 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S3"
  by eval

definition ModSize3072SHA512_Msg4 :: octets where
  "ModSize3072SHA512_Msg4 = nat_to_octets 0xc3287c23b613aefc2425a8b8317d647a447816bac56d0c99259bd9711f5fb2b13eab18e8a0b3b81ff9e98f6cda2c51c4343c0c1118720884c0aef32dd3903ac9e5ebbadb3d7698fedcc56d79bb78a71453b32c2a62ce4000ed4da85581120f3abfd1aa2418c51840d4a18c0659ca2d11aac3bd2e2ee879b3b3604112b24df9ad"

definition ModSize3072SHA512_S4 :: octets where
  "ModSize3072SHA512_S4 = nat_to_octets 0x878b9a443921bc7d720e3e288e8f39e550113e01d04fb1635a26f796fb8b161d5b758cff914a2441d8350f8d3922aa5615edfd86501c9a05c210c93a1ae04ff761151dc8d652fb5509ed100999d2bf6e40b1bbb64cf6c5d8e067b445daf567137cb8f0863996de8de9a647f982c9e21a787ee8d72657a2dd42ec9fec49ea1c3345cf004e94594a064b6b6b222845d64c935b539d3fd2d535fe0e47ac6746028e748556c2d88e4d40707e74a1c0cad5cd95dad263efd3ca637ac6b8f78ddf7ba81e443b836d85a83dbe843bd6271e45d842e1bb241c9c18805f37bc19838ba2bc6cd38401dce0cc9780306ea8a87d43110b3e395bbfb81c3ba45ce1cd71596ed27c03e2090a7ee81f60119e187adff0d96acfbaac38f7cb503039ead9cf9550ded5693d3c257406dd0bc061d451bd81d64f969b7c2b84619f0dd82481781eaf5b8fc82a3ac5b9fc20b42f86d4225a435b903d2258f5cf693d1b5c6a5d144f7f4eab9e70de2f3879f68e4c1c7a38dda63e6186534fcd78d58db709bf57a78a848c"

lemma ModSize3072SHA512_TestVector4:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg4 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S4"
  by eval

definition ModSize3072SHA512_Msg5 :: octets where
  "ModSize3072SHA512_Msg5 = nat_to_octets 0xd54c51f90b278c1c602bb54a23419a62c2e8527229352ed74a17eda6fde02f4b0b012d708515a6215b221d2d291b41cf54a9ad8d562ad16156fb3017fcf2cdf6832fdfa21015cc41429355dd0aa80e09bd2612c867b6f4aa631cf93828bc8492665dd157522ee6c53d06c7226cf0ea5a24e7eae904de7ffb9804aed22a453d69"

definition ModSize3072SHA512_S5 :: octets where
  "ModSize3072SHA512_S5 = nat_to_octets 0x265749f7afb1e1d16492eebcee9f5004234e1dcb95b832d14165992f4d1c49d518ba15a6b3adedfd803287cf60ce8c915882e2c78d69ffc46fdecef008e5d7f146e38f268efe49065ddb6fd7969a842189b9d7b3ccb32d62aa05e87e932930f7a1775c338736d9bc8f36521609d8be0c29fdd1728430a537f0a2b9b9fef2cd9f0946c221c08aaa0270e3187ee5c518cfeb00169e7718b01ac0faef097e9cb6a4df3e87a5548a6c3d9f1ba230ee1caa01297e5f17d1be1d776552f36638cff13ab73a1058fe7c1eee28c76a145e9ff9b17074963c22c6435b6c5a619a6f39df94ce348b244320b207a9117e98b9aa5a8c58516d39c71878c4ecfd741ce6e51222fcd92ad32d70c3b92cbbe301dacddf2ec3aec21fdd38a7e110f4f5448577b9546f1a7cd71a35670c1ca47a9199437cbbc65926cd17dddd2c0c3b1ffebe682be616e638839744a147ea897885afefbe6f0e37d4e482dd005f4ff199d0d033bb753380780c90228a87d14d8dbfb829a195b5d8b2dbd67c9eedac48ae639c158eb3"

lemma ModSize3072SHA512_TestVector5:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg5 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S5"
  by eval

definition ModSize3072SHA512_Msg6 :: octets where
  "ModSize3072SHA512_Msg6 = nat_to_octets  0x57724b7062193d22f2b6bfd18461d87af122c27bf06093a5dd9c1d92b95f123971706cbf634b0b911ecfa0af6937cb4b884b8092bad7afca065d249d3707acb426df79883742c7752692c011042c9dbb7c9a0f775b09ddf950fdceffef43c9e4fc283b72e7e8b9f99369e79d5b2998f4577536d1dbdd655a41e4e361e9fcb2f1"

definition ModSize3072SHA512_S6 :: octets where
  "ModSize3072SHA512_S6 = nat_to_octets  0x84a21a5cc060d141ba9caeca77fd04be8ba8270235e9948d0706dca77413ce7f0811da8b2f5372f8ff5a2eb2bbeae43752c5d1c1e3877992a49574899a6ec9d2a9483156540322fdaa66eec4a2601c281ea5ae996190853644b48231bc22729f32c2188e5f5f7b5056fd3e99ccca3effcb9793343f52a9ee60217d1c492102534a334c1c60a9c4ed63ae861bec7de9898c2dde026d9a029e7d9fe44d552cd3763b8ec3f4371f4e682315657d72a888913d15e1a84a981b3d8d437589a6deb37d14e86aaa365124bf165045040b1f959accff35565205d0ee72bc56d273d1973410774cea7735ca79c6bcb256b54fef0172e058ba91619c66bc45e11b6bcc0f68b529ec3a4133598bcf09c9c4bb0f874c7095f3ebbf85a5f669bb3717eef929fb1c22943268c310282e8842840aecfdc942a468045b02595bb16336634da20ca0b8d758cd30a2b7a0bd0e3e2a6f30f36a1422adfed88e211485066d6c0fa5c986f1dc5b4c1d965021dcc24b3f729f07c02b47af75d01f49da3dea0f1bdd6b4c0f"

lemma ModSize3072SHA512_TestVector6:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg6 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S6"
  by eval

definition ModSize3072SHA512_Msg7 :: octets where
  "ModSize3072SHA512_Msg7 = nat_to_octets  0xbf5ff776122898e22333fb6da96d2a87a3e6c4e63f28fe7afbc8e8a40a3af2a3f9e9ae4f9287d70901a293f23579f55b890dc67da47b856a9d88ac44637e35ad5d375d7e4d77a8bc7a7f25c80edef3d5bd8b049fa731215b80ca2ee9ee6fb051326e8c6d0b9e11e3d7ef3957fc452cde868706b512f2da33eab4f7fc71b66a78"

definition ModSize3072SHA512_S7 :: octets where
  "ModSize3072SHA512_S7 = nat_to_octets  0x86ece9321faf1387de6afa7b1e16c2127e71e6472e093708f0ac4b40e6efb30eedc546907182798535ad6b88ae4a6f8c4fae429d225058294ef76d44ca81defdadd12cea16c58c660a4d158cb6728545307f5a6234c3aa16ae6d989b0b788cc4c18b08c89b57fe302ca6560affc57bd533bdec6ae90fc37167c4355b07c6c7c7aa2bdaf96002832d62c2dd090c61cb8658ecc0e224964b50b9abf1b4271869a8951d81cd5b46af4ead70b0454c01a7229ef2ff27599c7370e747988b45b9a8148575d73014166082947c97e8730d5458ff4a4606b1185f1bfd476e8fea2d1d7fb5d14a061f90e438ce5e36b489b5873b7400ed779ec82adfdc2d9314d6e6547dec3be9853359821e6f6d853c2292f1731789002033ecb46cfc3a7f197a18a677574fcf6870d7e47db874cff258f0f6589386fd9667af292c315ffd849bf71749ef1b4fc5a3fdf39e2782f986bc8f523162c0016c51702513ed17c8f68672cf425fd6ef8b6c8e983bd2128ce4614085e7fb216af7ff01501941f23ffbce556f14"

lemma ModSize3072SHA512_TestVector7:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg7 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S7"
  by eval

definition ModSize3072SHA512_Msg8 :: octets where
  "ModSize3072SHA512_Msg8 = nat_to_octets  0x61b6dd24903672621810cbe3342497a6b298b524f7cd50e342914f483596ecad9122a2b341094dd99ad98d4ee1546b040d233f06cfc8d10bd0d5be4b3a5b1d9179a663924327847dd5b25bd380ea4c7965f9280c7d845074dcdd1ebc367b8020a2a8e6689e7a5f755304fe1a1bcd832d418237dd08e71845ee13364231dd5d82"

definition ModSize3072SHA512_S8 :: octets where
  "ModSize3072SHA512_S8 = nat_to_octets  0x57d827593ad09f00005ff1ba4521a9ab2717fe34d7af12d7ef5dc07814cb93257a2903cedf0a80704b16fd8aa9dbd06fe3d96fcc7be3843ea161e80ca56f3ef6f760dfc7f1704ed4a50142267b87d244c71fc72102112fe4ea801c82c631edd9d917808c0a1f1c81a9de859dd87569898cba76b35702232aa492850739ec0371b0342318b92eefc45e6ae8547a604d9a15c2829ea85533d6d23fb61ef569be63779d3d2c7cd3bfbc26df02616b7bdbbc0b4e2b5ebba7ec93886a369d10b7bfc0e7f56e7b7ccc814880baa634f4afd874a841d40cdf9c8f117535650b55129b8913d53417bdaf163d68e7044ac011a55ac0e1afd9279d46d31ef83a0bb4a7dbe70bde4b33396750b676576497e202e40cd1401fd6cb08878a6c22db61404b4c2aa88072f7a4851d9faaf016a60a7a49147fc234ad67f8375a90069c274aaddaea43df6292ccdf7daab5f5113070f8ca5e7f43c791acc7e1737cbc311bd5714abb66561703b9ac3629bb10bd1b7709f081840eb3e939c69657ea8f7cfd596b0265"

lemma ModSize3072SHA512_TestVector8:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg8 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S8"
  by eval

definition ModSize3072SHA512_Msg9 :: octets where
  "ModSize3072SHA512_Msg9 = nat_to_octets  0xdcc271b1bb2e50ebc23330be36539d50338baf2e9d7a969358c677e8bcbc7787433615c485c2bc2e670098128f4caa411b9d171392adc6ac1a5b297eec4d5b0f06d96cfd1f26f93fe08effad5147f0c3924307a2cb54d95765942e607b040e6c8b731f6372a22ea697a50b98668c9a5d004327e230b7fa1da23a2b964f29b826"

definition ModSize3072SHA512_S9 :: octets where
  "ModSize3072SHA512_S9 = nat_to_octets  0x0ac938ab04bf4efa587e34143436ce608ad089420956a72b23103fea769c03f02c3a0db764cd5bf3cc8518565b7efff70c74cc653665dc06e7f1d584e967ba193a70f5e3f7416ed0d4d5dc0e761b24ac8a8be172eb95691f02244379c9aeda8a9f760e061fd476b063b5ededa56bed819fb7136a4604879a92b2cd35507fd49b7d478fbd24c764aa5bc535a6abd7bff5c7692035620597f6329a454ce9188731c4e74d56c5bdef11372540b958cf2f8c42cbdbf915e0c07c77f04b05d876afbc3f2c205a4048826319184d650a243d192fbe35a163ab8ea84a001dd7c1472988a78042cf9fffd96f6948f0e692fc3f3b1c9c13de4b7a021be25c80606e1105cd56815d27c45fef995b1fea36e2e12aafc4a69924785c4855c50c61b1f43be9a1adfd8d7ff2ef5240dcfe5ea4613db4ad085bb0a6fb8627b1ed94dd164a4d9c4c9f375983734f9d2c35ec69d6d7421157d8658dcec1bf6599ea94280a63422376bfabf1b9f730292c498c953654401743c9e6bc499446759484d93e28d5f9f486"

lemma ModSize3072SHA512_TestVector9:
  "ModSize3072SHA512_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_Msg9 ModSize3072SHA512_SaltVal 
         = ModSize3072SHA512_S9"
  by eval

subsection \<open>RSASSA-PSS: Truncated SHAs - Mod Size 2048\<close>
text\<open>NIST has test vectors for RSASSA_PSS using SHA-512/224 and SHA-512/256, but in a different
file and using different moduli from the test vectors above.  The test vectors in this and the
next subsection may be found in SigGenPSS_186-3_TruncatedSHAs.txt, which is included in the zip
file linked at the top of this theory.\<close>

definition n2048t :: nat where
  "n2048t = 0xabf44a770836fee434fc7bf17b06428a7cb50d27213facac88fb38d3a29ee81669d18e71daa3c78fd89774a223e7a15df4216290c4fda8e15a00088d4071b682f3121c45e25d93b03b2332a9f1a0772018548302f60b2d366528b2364a8962c8bf0ab64e87e1d6ae13432038e3f9e9fd8eb37aef736a19987c259106f4cbbcc4ed6a4d679fa9422489092cc4f12b17d974fe799477995b8cfa3494bc5b426ec3b2d8c02373969630c003e08a42e5e62072dfcb1183ea5364513e6e357bd6c47d69c41767a304b7e7ba115f348963b49b02f34c87e17f5fdd29674dc125d333a4c0c6ba96a5b8afb4e4f785d2e9eecb0165e7f2bbb464e2a65f03baec25d7f519"

lemma n2048t_gr_1: "1 < n2048t" 
  using n2048t_def by presburger

definition e2048t :: nat where
  "e2048t = 0x9b34af"

definition d2048t :: nat where
  "d2048t = 0x1fd04b94cdfa3cdb225082a261b12b739ae7c359148acd5ac0899b54347eea93e1375aac688e3a2e6a40a4f4010126edf569a039566b315784bb6a3b3e370e89694f4e6d94608df9e1fc086eb9b3c283fcb7aaff7011e2d5a6f0aa56f2fd64d7dd75abce5e37247c6cccec7cb04e0b5e597020c7f63cce7dd7f84564a6c0fa8d73813d187878271d74cf8b696ff676204847cffa599f61cc3ae39fc1805be01fa2308011b7b1f1c39be87869b7faea7bf22d7fb2adffee26b364014554f6cf31e98d3fb68175731af23355048a22e9a3de432fe434f88cf0689aaba5aefbff08b9d996d92152a5bab5a650c73a1db065b8fcd4a9e260c69b7c806cadda8b0c4b"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.  Note that we can't do a global interpretation inside a locale.  So we just have to
assume p and q exists\<close>
axiomatization where MissingPandQt: "\<exists>p q. PKCS1_validRSAprivateKey n2048t d2048t p q e2048t"

lemma FunctionalInverses1t: "\<forall>m<n2048t. PKCS1_RSADP n2048t d2048t (PKCS1_RSAEP n2048t e2048t m) = m"
  by (meson MissingPandQt PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2t: "\<forall>c<n2048t. PKCS1_RSAEP n2048t e2048t (PKCS1_RSADP n2048t d2048t c) = c"
  by (meson MissingPandQt PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

subsubsection \<open>with SHA-512/224 (Salt len: 0)\<close>

text \<open>Now with our encryption/decryption primitives set up, and the appropriate EMSA_PSS locale,
we can interpret the RSASSA-PSS (probabilistic signature scheme) with those functions.\<close>
global_interpretation RSASSA_PSS_ModSize2048SHA512_224: 
  RSASSA_PSS MGF1wSHA512_224 SHA512_224octets 28 "PKCS1_RSAEP n2048t e2048t" "PKCS1_RSADP n2048t d2048t" n2048t
  defines ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA512_224.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA512_224.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA512_224_k                                = "RSASSA_PSS_ModSize2048SHA512_224.k"
  and     ModSize2048SHA512_224_modBits                          = "RSASSA_PSS_ModSize2048SHA512_224.modBits"
  and     ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize2048SHA512_224.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA512_224 SHA512_224octets 28" by (simp add: EMSA_PSS_SHA512_224.EMSA_PSS_axioms) 
  have 5: "0 < n2048t"                                   using zero_less_numeral n2048t_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048t e2048t m < n2048t"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048t d2048t c < n2048t" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048t. PKCS1_RSADP n2048t d2048t (PKCS1_RSAEP n2048t e2048t m) = m" 
    using FunctionalInverses1t by blast
  have 9: "\<forall>c<n2048t. PKCS1_RSAEP n2048t e2048t (PKCS1_RSADP n2048t d2048t c) = c" 
    using FunctionalInverses2t by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048t e2048t) (PKCS1_RSADP n2048t d2048t) n2048t" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512_224 SHA512_224octets 28 (PKCS1_RSAEP n2048t e2048t) (PKCS1_RSADP n2048t d2048t) n2048t" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-512/224. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA512_224_Msg0 :: octets where
  "ModSize2048SHA512_224_Msg0 = nat_to_octets 0x877b48928e3fae877f436179c74fd2a7fbb3e4f7be96f2e5e68b14bfda659e143e4dea6ad311582f98bf92f2367315d39a6ded38e466bfc280240d80924db6629879bcf04b8a4a3bc540f614e908437d00156a5da0b25a78d2d7fd9d73fabd21db27478dbd538e944eee1348aab7658d73d4e3cdbb22c9ed24ca6b804515bb3b"

definition ModSize2048SHA512_224_S0 :: octets where
  "ModSize2048SHA512_224_S0 = nat_to_octets 0xa08596d43d483c01d959691c1b8d5bb22bb6e1bdb250a8a4d7d4c192e33389baf5328e84d8262115d5ed0eb1bfaa509285dcd17bb4da684e3fab339bf356d74a26e785e1c4e6b2b17518ed0fe796c86ed0b5be64b571f0abf19667e98656054edd3b1bd20c6aedb17b39aabfc5542673fb73bd9614ea37ac4dfd22dbdb1a55d3028984e65475d14caaf7088004555adc39b3cad91526b3812c943c2504bc9145b784f8ae534b6ac6d1395beaaa3d80467bf9b83ec0cd2edf31e50c582cd035b44215779393543e250dbf1c789e248bf980fe4ecfe23c84c78230db169a3b1f2959f63cc6a6950cbb30c91f7bd68fe8298c3c1619af9ee413169e5942626bfa92"

definition ModSize2048SHA512_224_SaltVal :: octets where
  "ModSize2048SHA512_224_SaltVal = []"

lemma ModSize2048SHA512_224_SaltInputValid:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA512_224_SaltVal"
  by eval

lemma ModSize2048SHA512_224_TestVector0:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg0 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S0" 
  by eval

text \<open>Because SaltVal is a valid input for the EMSA encoding scheme, and because we have shown
that signing Msg0 with SaltVal produces the signature S0, we know that the RSASSA_PSS_Verify
function applied to Msg0 and S0 will return true.  We don't bother to prove this lemma for the
remaining test vectors, but it is true for all of them.\<close>
lemma ModSize2048SHA512_224_TestVector0_SigVerifies:
  assumes "sLen = length ModSize2048SHA512_224_SaltVal"
  shows "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Verify ModSize2048SHA512_224_Msg0 ModSize2048SHA512_224_S0 sLen"
  by (metis RSASSA_PSS_ModSize2048SHA512_224.RSASSA_PSS_SigVerifies ModSize2048SHA512_224_SaltInputValid 
        ModSize2048SHA512_224_TestVector0 assms)

definition ModSize2048SHA512_224_Msg1 :: octets where
  "ModSize2048SHA512_224_Msg1 = nat_to_octets 0x6c2cdf5fcbb2a735f76045a50c35cc43db0cb86be0c48085759d6f8844e5afbd02d5a7c65bb687de28472062e863fa916edfa090d7b23fb0bf586ff4b57851ceebc4da2a32206ead2607b13fa62b9ac7885cc9358aab1ac68bcf7a83fbc8f90c90c221933a3b862b5a689f432fd5d46d904dd865e1f9394e40cb363eff1ed0fd"

definition ModSize2048SHA512_224_S1 :: octets where
  "ModSize2048SHA512_224_S1 = nat_to_octets 0x2c9796e896b6a034ad2bd39ff85fbd2764280f38e4a4e7ea7e369ef65b5cc43226ec9615be328330b2e598ab6e407808c44cce49c89d02adef349af24ac5c279e1ea6eb5d7930a612559ec8607e159be5df95f6df6227a4d55a6b4e75be5b7ca59f93c7c93d2c1fa1f25c4acf8e55fc920d4e21b84ad71d4601e3cf68cbca1b41ecdd2b770134d336e6a9c02e4531fc4bf8bbfd157e1d50a633e0b22c49eba6dbfad2743d0f586d49c9cd74bbe725f6633fddfc73b06fdf4c8673d4c723e0d81e5578e186af059e1e62197e270f7fccd97506b5d9bcf9e17463efe6ac15e3f1b7fe2addb1dd49732575676bbeef8339ce96a8800657d1d7bf8adb9ce5ff380af"

lemma ModSize2048SHA512_224_TestVector1:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg1 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S1"
  by eval

definition ModSize2048SHA512_224_Msg2 :: octets where
  "ModSize2048SHA512_224_Msg2 = nat_to_octets 0x64be9e2354f13bec61d7a59ac983318890be155dcf0764314fd840f1562b4b04c13d5e2e53927eb54d390bc33f513b0c1dccc7b09573e463a02a75cb58767f29093cdd3c8acc3563ce1d2a01b65ad325299e6c6b67fd4c1d9ac3179eaf00350963448315a1a7483c0b0c6a1cd7a7e21ddcbd6d54ecab84a7652a8f3203d156ea"

definition ModSize2048SHA512_224_S2 :: octets where
  "ModSize2048SHA512_224_S2 = nat_to_octets 0x57457c844156d5e608579f117e87f9721dfb86c72de9b464dff60201e81a5095b891e5c2d5cd1d902bb3b75881f930edbb3a955bc35a102202b6676637792d22135cc7bc67411258bc3a5a4d0bdd5bc2e2362e6bbef30cb40573e4cd404f374090a1b0417c9659244e33878f297006b3113635af5713f24d971f32fa2be633ee7bf12c4539ffede0026cbb9eeecc8312f375d1a4c8676cc51a9f26fbf64926adea4a1a3746a4276e5d4d2f282e81007ec0e498e54ffb2e7a318ab21f5a10d6c7f4d52c4723f22fc51ee4899221f7cab15477326bebfd031a771e937e3754be3695227ffed0f87677c0fce2fba40345b7f77c86ae04ec5cecb34bbc62112fd957"

lemma ModSize2048SHA512_224_TestVector2:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg2 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S2"
  by eval

definition ModSize2048SHA512_224_Msg3 :: octets where
  "ModSize2048SHA512_224_Msg3 = nat_to_octets 0x40c62273c4b139e7807d1f987b9dc8c0da351bb9628a971039b83cdaeca3a94bb62f828400b414ad24ac3c4476af84b485a2902a9e2bb9a49267f74bb9e0040237b9be3f7e2cce19153787a397911079fee3c6982135dc737ca644433061d39e4acca04b4803ad55da84c95ee52cb436cd6285acf49249a47edded6a580e5e46"

definition ModSize2048SHA512_224_S3 :: octets where
  "ModSize2048SHA512_224_S3 = nat_to_octets 0x3e6a0621cfaa5ff9c896ded65fa0480a86cfd22c7367bb11721b912441eefcc4f43fd6c60bc519c72d2ae3ec7c945b15d0a664b6183224cf08d9a14b3b30fafbf7fa90a582f68fa428fd1cd6c3c76400a4c0a1a256616bcc3494b2d96354ce0e31d6421299cfe56a8764f0ba6f97f77f063c3feb66e0d3bc89d174bd039b239edd553be0c677d7cdd1b1245563453e619c4673f7480bdce096c4a7344e7ed335d284cee291798fba609e16a06133b63891ca9c293dcee039af1fafda36fdce52f10d24bbca8756659bdb1b09297c95561b94362f85898fcb9bd90496ce1ea4b0db316d0057ea12f770d2d61fa5a1ed01f517cb439d7a3cc5a70ff961e9d51231"

lemma ModSize2048SHA512_224_TestVector3:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg3 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S3"
  by eval

definition ModSize2048SHA512_224_Msg4 :: octets where
  "ModSize2048SHA512_224_Msg4 = nat_to_octets 0xca89b42f3a534fb6dd079bd8a463b1581c512197f15f94abb26fb0b0d3af3c63f8cc85ed716300fc00b93018e3abca350ee81884b95d9b8f1af1f485747305d250d053f30a8aae89906515ac6764d481eff3ef0fe766c34e33a2eb81dd1a61c65bfee5ec10aea3841575103b3874156745dc6fdf8561561085eb5c4d188e9967"

definition ModSize2048SHA512_224_S4 :: octets where
  "ModSize2048SHA512_224_S4 = nat_to_octets 0x6c6b9d1a5aa486e6f9b9cc83edf8390bdb1e9086d3600698ad2c56980f249860e73975b51fadfe64f4383f99b545714da25b246b8feee234af16f43f7822fef569851817ad669ac75d311ed82aaf0d31987b885bacab8886e4f53da93fb208d94dd7767172e22ca9d1c9677f1484e21bb71bc6a01c1db8eb95f5b2ecf0624bbfa048141022a781e3959935290fd477d95c2999bd0dc08a92614f7eff0d11cf56afd3ff05646d47a00559238131099532b425fd44830ed2af8677e539a135dfaf8a0f86e9da0bd614a59a22a1c009d303d623fd178d935d9322f9840c9b58494c1e689237f81ceca727b09203b72f750da314c9bc583978c34010e9af7cd0aa5f"

lemma ModSize2048SHA512_224_TestVector4:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg4 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S4"
  by eval

definition ModSize2048SHA512_224_Msg5 :: octets where
  "ModSize2048SHA512_224_Msg5 = nat_to_octets 0x847c8d5f082149677d5c0816e9ec20bc6e39e5ad1fdb1ce71260b3f4b64aaf12675865924007ed7e3157d47e51d211fc75cb3a8701e4f875fed3b9cd6d65a464dbc2d24536f4bb56dfa3ee390022067120b0d9c6f5f7f2ea79d9425c406c128d08433c4292f09b39b0c6c00fa0e4e661986f2832a21ef28caafcb66ad569e0d6"

definition ModSize2048SHA512_224_S5 :: octets where
  "ModSize2048SHA512_224_S5 = nat_to_octets 0x6e332aada45368149e434a5fd56aabd1034c2387d662b323c6d00919f90808b75d011a9418f8e876e1142008b2c637c94887cdd6d9341375934efa022cbd372a8573afbc2f221c2b25814de43708b9e3068f685f7a08c422bd65911f4609ee059f9e1e4a6658838192ffeb221d16a5bcb099d37d0032b04fafe84fd4e535153fcc980b4c2e8ce8473ad184191cdece6d8b3d06c88af24e80eabcac5c38ed36bd790d5cac562bb62b92f270d9c269c7f4a38b4db96b661733e5bcc0928184b6bef1b9d96de1dafbde41d481cf683fdf43f41793a54a82cfbfc9e17cf60e7d46d8c7323a1308aa4c1efd53e7ca9b6adce17612ce87872b11165122df1a18a92c5e"

lemma ModSize2048SHA512_224_TestVector5:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg5 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S5"
  by eval

definition ModSize2048SHA512_224_Msg6 :: octets where
  "ModSize2048SHA512_224_Msg6 = nat_to_octets 0x32c9805889b6208134896c8e74cdd00d3511b4954046514db268c3adad615f894d2a464bde333a804c05b196da2628e3173cbaea0f76f1dabe28dc58cab5627e71b2d524bf48cb5e05da294588e880fb76349de91e235b4b5f65bcef61d8383984aa556b96bf78234952fb26e4de7f5b383f841bd61437a87f698afadc938ac2"

definition ModSize2048SHA512_224_S6 :: octets where
  "ModSize2048SHA512_224_S6 = nat_to_octets 0x28f10bb4f6f9bf3c5e33bdb9c0f48cf583bda58b2cecf1917ea450f59951da191e8f77a05929efa6c8eb324629a21e9e894ad9a45b48e967c7f2aed3a44bc68200535901ce342d36a2e1a8785c353119975ef38a0064877d3b67a220ac6ced595e1ff351902e065c65ec94238b4d5d18b9b4c146489b1ac2c2cc70c159dfff13d13b05254355af3381499c2b2072e20e6dfcaf3b89f46d0154cce353f4b5b1a51b0586417ef824d00090f9e71ea274a7e12073482f467c6e7d383d9ca027c0fbb51db4e0139227c2f6775132c4c75c9548f0f139c3473be03d35c8f3054b5920aedf7e9e0bd3b0d21d271ab77414b75f3ad11283a47a35a54392464e50053bc8"

lemma ModSize2048SHA512_224_TestVector6:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg6 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S6"
  by eval

definition ModSize2048SHA512_224_Msg7 :: octets where
  "ModSize2048SHA512_224_Msg7 = nat_to_octets 0xe631de1cbe356af118de8a7808be1c6c6f012bfccff362715dc2c7105884a6429a7bcaf26d98f3379f3f8533d94a7e3b2c50aa37ed271a4cc3a7d2b9feb1c2ff2a70f845e4df13faed8cfbbc7d9bcf79da0d1fd428435cca83bd8c954b2842d0bf98ceddce12b184294d54dc9db9f96fa0c1f1992a4d0f31c68c5e6be8f00ffd"

definition ModSize2048SHA512_224_S7 :: octets where
  "ModSize2048SHA512_224_S7 = nat_to_octets 0x1d2da7020c7f307dfc97d775ad8d1a218761fb9d55c632398a63ecb2eac7712899362dd8e373226ae0955c8d7a37ae75fe74bf42d8af0e6c4f61a532c1fbb9223b22cf2de1283a7b4f00cf2ee473f79de7b364327e3443dbbf2983312b5df9a2b64b9c8c1ba67b568ca24b37ebf695a1080b2f1c472bb965c3b49fae480486d5ad082b6c649241b9fbd031cc679ea683c446bd131c7060ee77140df1eb4fbc28948ac47f6f500f3d27c4aa76ae50c3ea8ae1f1dbfe8de2df42a93c112994264ba5e6a5c67aca13c485c326fadb4a44d35337916588bc57ec45908b5f27a0d05d8fe5b2fce109fc7e0e2b2eddd936bb4a116aa2ee6fb5ec2f39d476a0973e9add"

lemma ModSize2048SHA512_224_TestVector7:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg7 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S7"
  by eval

definition ModSize2048SHA512_224_Msg8 :: octets where
  "ModSize2048SHA512_224_Msg8 = nat_to_octets 0x607889b7ba0071c5840960147da438d3ad0e51c754d41190203abd2ea2de8ec30399089af3a68769e3061bd3742295312fb3e29276df9800baa4cf06ef7a326f3d34564ff9284a48d38f6f06512f890c7c3717b3d96ae06f9a7fcf5516c800da77131bdeb2cee1e9bd6e04b4fc113cebfc61973163bc116527936423ff10218e"

definition ModSize2048SHA512_224_S8 :: octets where
  "ModSize2048SHA512_224_S8 = nat_to_octets 0x5c318b9e83c78bb1a3a26a3e6bbf619ca566ca0fbcffd4b382163c7deada6c095fbe3be8f7501e5b09b8ea4cd70b50d519b7d8572ce60e354d193ed584e499e4fdab6bc66e7c10faa8eb097a11c7c02180afec545a69e78b128441ff1fb3ca59258bd702b34a30e39a31bde69b50eb312f9aac82c8b5013a57edead1c4a8250158639d637b3ecde9c1764bae8177e596e8da98ba9bada550c7a59ea662f12de60dc965c9c08f85bfd179560e65c56394c98a0eb476e405539717ec667a0f29f0a63b57df171a60e76ffce83338d37b1234af79623654f911bf38df146b8efd8ef3e4d9e0303674cdde2be7f7a05ab67c4ff01492ec61c9cabf608070fd4b5542"

lemma ModSize2048SHA512_224_TestVector8:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg8 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S8"
  by eval

definition ModSize2048SHA512_224_Msg9 :: octets where
  "ModSize2048SHA512_224_Msg9 = nat_to_octets 0x8dc8f2d43a54d5da6080bb26c0d59b2621cf91d4a3e2d4de50bbe804f4c815c22efa1730c8ca1726447adaa3b79d3970dbd9d1005fecfb9b81edffbcdfd484b78a3d4b9e5d691d668d8602468030b460e33753a3f7a35af02bf5d27bf0b0c675c918f6e8a13acfe2622c9bd5c396f63e62718185120fda24765ccb0ccf63c144"

definition ModSize2048SHA512_224_S9 :: octets where
  "ModSize2048SHA512_224_S9 = nat_to_octets 0x42b530b315fb5507cf9a361b45eb179442992c1e6b3df9c405c44fa8f07f6bdb12c7929f08308e65a1aa4a8ce69c72002144801c1cc50ff1b55418ad24a4c853fbc3faf025f6fb592c768eae48ddbfe1485904c87cdc5a0bc6e27cfd21a5bc482c2455fb32bac168de1104939ce006b3005dc4c99dc6e13a03b3eec838f3a7f4151b470212b45cf946338750554ac3ac553e3c0a746e3c435a05f44639f912177187fbbbab58ec8ae1f5d148d1a3b0f7946876f99b844e17377d62cd4c38e88ba387bcc92a72c855c5b827df8597c38e01d3ecf0ac4b51d5c1f54bc0a6e5a8f5765b6788bdf866e090512a16283dcb689169851d04fec33f890df7dae82ddaa2"

lemma ModSize2048SHA512_224_TestVector9:
  "ModSize2048SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_224_Msg9 ModSize2048SHA512_224_SaltVal 
         = ModSize2048SHA512_224_S9"
  by eval

subsubsection \<open>with SHA-512/256 (Salt len: 0)\<close>

text \<open>Now with our encryption/decryption primitives set up, and the appropriate EMSA_PSS locale,
we can interpret the RSASSA-PSS (probabilistic signature scheme) with those functions.\<close>
global_interpretation RSASSA_PSS_ModSize2048SHA512_256: 
  RSASSA_PSS MGF1wSHA512_256 SHA512_256octets 32 "PKCS1_RSAEP n2048t e2048t" "PKCS1_RSADP n2048t d2048t" n2048t
  defines ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize2048SHA512_256.PKCS1_RSASSA_PSS_Sign"
  and     ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize2048SHA512_256.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize2048SHA512_256_k                                = "RSASSA_PSS_ModSize2048SHA512_256.k"
  and     ModSize2048SHA512_256_modBits                          = "RSASSA_PSS_ModSize2048SHA512_256.modBits"
  and     ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize2048SHA512_256.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA512_256 SHA512_256octets 32" by (simp add: EMSA_PSS_SHA512_256.EMSA_PSS_axioms) 
  have 5: "0 < n2048t"                                   using zero_less_numeral n2048t_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048t e2048t m < n2048t"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n2048t d2048t c < n2048t" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n2048t. PKCS1_RSADP n2048t d2048t (PKCS1_RSAEP n2048t e2048t m) = m" 
    using FunctionalInverses1t by blast
  have 9: "\<forall>c<n2048t. PKCS1_RSAEP n2048t e2048t (PKCS1_RSADP n2048t d2048t c) = c" 
    using FunctionalInverses2t by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n2048t e2048t) (PKCS1_RSADP n2048t d2048t) n2048t" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512_256 SHA512_256octets 32 (PKCS1_RSAEP n2048t e2048t) (PKCS1_RSADP n2048t d2048t) n2048t" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 2048 with SHA-512/256. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize2048SHA512_256_Msg0 :: octets where
  "ModSize2048SHA512_256_Msg0 = nat_to_octets 0xb75c5176eb13776150b26d43a11b6120219154828312216f07e7bb98e779b6d3f16609cb75d412f66106dac8ab2d9b27ef807f1e5a8eabd5c6d37cc1268a101825c309880ab58d28df5591afd22858e4db5536559ffe9a4c95d04cff67d9f2079b9ad913725ef2de10ca1b5edeb4a03f2d39028f1c09f7bbbb06b1ba700e6388"

definition ModSize2048SHA512_256_S0 :: octets where
  "ModSize2048SHA512_256_S0 = nat_to_octets 0x83855773c5c8d64c4d84a92b82259da5bc6ad0a6a1cdc001bcda472b41a98841bc85ff46692c9556e51001a0d6566d7e48776166e2ed69ce386d96e544bd498d0f58ec68f1a5739db424b43e1aac84bff459528c0928a04eecd6e199bc568cf376d6abfac1eff0993404ba4a40c8a80cc55d068b6fe5a7709a9b39e60686098f3289623feff411fdf1b333ef66d1b40e44f1041a05a7c53ab88e4a95a78b24ed821f774f748b80cb9f782c8cfd33882347361843723acd1b2366480423dcb953d22ad1a30329e042ae0e9264464a281a51fad7b5466e94c3438cb675bbc5be781511dc512a8c155ed09bb8b6ef66db604618e83e718bfafcd5d882676afc273b"

definition ModSize2048SHA512_256_SaltVal :: octets where
  "ModSize2048SHA512_256_SaltVal = []"

lemma ModSize2048SHA512_256_SaltInputValid:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign_inputValid ModSize2048SHA512_256_SaltVal"
  by eval

lemma ModSize2048SHA512_256_TestVector0:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg0 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S0" 
  by eval

definition ModSize2048SHA512_256_Msg1 :: octets where
  "ModSize2048SHA512_256_Msg1 = nat_to_octets 0x6315b1755461ac2790fc33cc32a1e41a6bcc1b8727cdbb01ed1b2be007ec9e19e40298b4bac8ae806f9d8d05ba703dba868da77897b6552f6f767ad873b232aa4a810a91863ec3dc86db53359a772dd76933c2fb904248938c40ba3bdac5206d5c3910f4ffea75a39b5b8f461be03bd9dd6775f85c991b970c22f3f3854cf0c8"

definition ModSize2048SHA512_256_S1 :: octets where
  "ModSize2048SHA512_256_S1 = nat_to_octets 0x406231681c7ad1cf287f97daa602eca3547eb0e1ad196aa94c833fba93e95dcbe7f6fd71158940d4c1df03d86cb44ce4746c333444c385110dc431c9006140274ab49d66789a87507b025511d166bd9c42f20f62a407cbe473c7da815ff282d5d727898dac2e8ef735e1720dbdffac02e7956ddde13e355211c5922daaff52ab95c40cec6a4b3de46087319dc62354e156834d0b8431026b8607e079714ffeb9397706449900908adb26de948ad1960915b2fe26b47747a7bf034bedfdcb37fc57938c2f40a9de9683e78906da005c305acea3f6c1a186fba5bd36508cf0976d45204c3a2d90bb2f14f7b5d441d372b2e1c65ff9e774f01adc72f392c989d40d"

lemma ModSize2048SHA512_256_TestVector1:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg1 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S1"
  by eval

definition ModSize2048SHA512_256_Msg2 :: octets where
  "ModSize2048SHA512_256_Msg2 = nat_to_octets 0x4088572485b70f746faf4998c4a7b79057bd4999413196fe6fd17d315db40c1a202ba0afaaf54ec54ab28225729ae6e3bd6f86eb30b031ddc110221b1527e0208e6662138550779bd4e765f69865d045352dde2a9a019995c67595db8aa4d2099121e3779f3150a016373a30be6f3d5fc5df9b7e058b96cf86e91d9a4494ab7d"

definition ModSize2048SHA512_256_S2 :: octets where
  "ModSize2048SHA512_256_S2 = nat_to_octets 0x27572f4dc4785c626fa30adf0fc67202babb69fa731378e9aa30072fa70c9d5cc54494136d394e57bd380c5503debd0d041030617c9f3cb45915e6037c183699c708f24dc1c34de0b0d3395ec4f7f23d959e2a6536824bb6457e7bfaf9006ae23970b0b5b356204fdec8a134c15dab604edb79f91c9c676500a11c62deab67953d4fc01f633d7c159927ca44da0a41c748cd7871395e60028366e69257adfeb4f079a4f11903d1c46a4387bd29f3c4f2b135bf1f683c2d1dc62761d65c84a0d914bf22a0af025810ea9f75e0a50c6c1df1cc07212df625bc6f4ae70754dbaf7a6a41a46b8c2318260ef098220517b9cbadba89f918c895f52f48bf146aa3e177"

lemma ModSize2048SHA512_256_TestVector2:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg2 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S2"
  by eval

definition ModSize2048SHA512_256_Msg3 :: octets where
  "ModSize2048SHA512_256_Msg3 = nat_to_octets 0x29bcd97286a17dced9b367f4039f9f977d507790470f1f2521ef748cfe6819abb642c922fbb4eb8b8ece6700b214b9dee26c44c9bf3ae8f14cc9d6935deda3c24de69c67f0885a87c89996c47c7b3e27850ac71c2bc8c6beb038ba55cb872c1d5871fb4a4d63f148f0dd9947471b55f7d0f4ab907302e016b503c8db2e7fdc45"

definition ModSize2048SHA512_256_S3 :: octets where
  "ModSize2048SHA512_256_S3 = nat_to_octets 0x84183b2f03a27954833e90ccd8ce5dacf6d1b68fbc87862f48b113dd1e50c395ac3c86eeaa0a8b0c6909f47eb798987b24a69b3c1b114652c5fec23584db9dd5eaae0ea8ff9498c6942b7ecb51bb0969710b3a47b9e41380826d54668bc8eaf5da5c46c836689a950630df22adc5eb6f6a3acba79e5c11bef042070ce695ad92e9a45f9c831d237e439d284f7f62d52902a995651c3c0fa8729d7954c937eff7c77d106536b2042e2d6ce7840b1d1e0772b9fa5f23d1450133b11729e1478d20e5fbf1f38a3c95d938bdca362ce947d2aab1b9ecfcd4fc8876434c1bf845e810aeb0b1d9117376f0b93d35084bd435701b70fdfc6930d754a1f7b1e120750e56"

lemma ModSize2048SHA512_256_TestVector3:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg3 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S3"
  by eval

definition ModSize2048SHA512_256_Msg4 :: octets where
  "ModSize2048SHA512_256_Msg4 = nat_to_octets 0x6259622d0aea50b8a69ee33aae19f7ad84469d7258a91b4249f13467cccda92c5201ff9225b98344931d8ccd4f25000914af19d98bcf691b6f661cdaeff67ec154b4bdd6e3dfef6505515639a554e312dab6fa54c62075fdbea3ebd9aa9432f9af9a22610c059c014261cbe7784baab21d84c74acf4446ce7cd128cec74fcebb"

definition ModSize2048SHA512_256_S4 :: octets where
  "ModSize2048SHA512_256_S4 = nat_to_octets 0x0bb0c8cf7aa68abe7d1f3f65166bbd110b8d371f859312afed10241fe007a7cb977d01275d512a97d70d9b114b082e61516043b1958ab759bd86e0efc52b13b6c449c3fd4fd122737ad0d51244a83ddc7d4da6f66a6c56fc5e724c264ef627717ca28439ea8fe9b444d56ef096010142e21b910c10d0ad662cbe45b71c550783d0216ded08bb6dc5aa238023d953d7b6eaa5943452561e48dcd340ff41e989f19a76c99f0f3ee2bd1951e5623c9fdd32373982c1da91bab73833516b51107a13b2e8908465d9c1a91d3cdda4f9ccce1db3fa6b6a7ac23eeaa4c95f77ccab558377331420075bf1d1946abe139331a0818aecb32a6cf9e65ba8979bb5627d22c5"

lemma ModSize2048SHA512_256_TestVector4:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg4 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S4"
  by eval

definition ModSize2048SHA512_256_Msg5 :: octets where
  "ModSize2048SHA512_256_Msg5 = nat_to_octets 0x356a946ad7f0f8997ea518b8e36d19e7f97f253cd1bc6cb5ba3e6971ac336720e7ec43b9d731736b3bd847d586966f798514be6e43452e562af823906aa9f4af9f9da72aae2efc54ef63ae8f92c3f5bd3b6b4ff8f05f8083351ed7007579b4e3a4a44726238e9a3fe46ed24fce9eb29c63ad6041a0b06c2424d80e29954aafa5"

definition ModSize2048SHA512_256_S5 :: octets where
  "ModSize2048SHA512_256_S5 = nat_to_octets 0xa995981fc9e3022e31e8f1e951ff4e1597bb614789a40dec0347f17ce3511df0882b60becadbb34d7ab3ed74f58dc539bbe5910b9060facbdc815859b2f6fe8069b710b1919913bc143081ffeb7af33a50858bcb0e985660f5e9fac4fa9c39afa76e7a57a160f1cf8143cc09d8758109635588469aaf0ef3cfaba3e815b2712e9ec1b6acc0e0c887187414b70fa546df49eb45f4ae9ca1743311b4d4f11d22d3934f1a3a11aa700f7b99b517586ca1d7c1f4e2e44a75a4c1b9c864d9b0a176c7ef08ffd1f4e10c9f9c8efa926605b15dd110a6d6c83b75ea445c07b5756289e69d0daf9478f468ab3de45b1e5151ad7c0afdda46bd55e8cd92c25c8e9e43691a"

lemma ModSize2048SHA512_256_TestVector5:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg5 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S5"
  by eval

definition ModSize2048SHA512_256_Msg6 :: octets where
  "ModSize2048SHA512_256_Msg6 = nat_to_octets 0xabd35f9e6bd9bc82151b770a8dbbbffb9a37a672f433d4c79e7978b6753e85c10aa71ad0ad8b411bca7bdd4979ffded95023b7c27b3212560fc2c26c9cf0f9be02edbb9085ba9293232f840824424228f486a2c42ef24f29f9e4bf46976566113baf2a261bed16b1c741528fb90b53b02d694fc033faf40602e8598c8f253580"

definition ModSize2048SHA512_256_S6 :: octets where
  "ModSize2048SHA512_256_S6 = nat_to_octets 0x63271499bfb0661dc5b28e39e19a7c1dd03f740ec9af3babaf739b2650af5eb876665cf7fa2c684eff47dcc1536d4f74040abd27380462886f1d558e92fc8760ae05f99db35705051f9ec765440a43c429d2064c8e51e23fc35432de3f0b5f4b712d2d6f06e0f73e5165df0ef27f5326f88732ed215e291dac2eb511190a8d14a8fff9ba10e69e4d2d3064746b8b8674b75048f54859eca43a62988f003f49ae87d36bf4404fa7cef5d30416f254fb044b420f949fb189dc431f3e43887fad4896956f5e16faeb67264cb02e29b3317abbe9312ec25bd2fa06e84178a39fa541e3510d28f35f90a206ba4734afa349528f2eb24c213699ff9953ff0b5cc7ad6f"

lemma ModSize2048SHA512_256_TestVector6:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg6 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S6"
  by eval

definition ModSize2048SHA512_256_Msg7 :: octets where
  "ModSize2048SHA512_256_Msg7 = nat_to_octets 0x1fba005c70aace58878615351e7472e6f0939b1f6ddeaa5db354b826ba56ae92ce50580a439bbb5064a2a9bfac4492d5397a9dee7d3af752379b6b72a139346febdb0fdce95394c509a6c5f0876de862e47b922594c00549f76dbb298a5943f05fa44c5bca9a00c05eda934f17b71b98d9dea24d19397949da14d0d2dc7f841b"

definition ModSize2048SHA512_256_S7 :: octets where
  "ModSize2048SHA512_256_S7 = nat_to_octets 0x248bea977c17b32876452b645309dc7bf989cf60090de1451e9776d09107eaa4c29897ed6c45e74a0042e8d82846e3ea15a3c09c1bd4b9a7c0a482ccfac324aeab4e209ac3738801084b8706f603413bbf5bf7fc10aeaf2f690792a27e47462f842a2213bdd46e2f006489d6f7f030daf32b0bab6f7c15854ab95870620b289a170ad4d8922b263f82e47e4f06c51af2b021eaf0448a7b3ecb731ea94a0822945868229b8e2a1981d81aac6315b2de197e2963f349ba5cea98147eecb3a8673250366038b5b73b2c43f589e08bad52ea817ab7e5c888e4dc41dd484b3d7439f53657749c5f12fd443ff863c11dbb9ac11aa0f475da16d76918affa68452a0732"

lemma ModSize2048SHA512_256_TestVector7:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg7 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S7"
  by eval

definition ModSize2048SHA512_256_Msg8 :: octets where
  "ModSize2048SHA512_256_Msg8 = nat_to_octets 0x73228209ad875ca1b92e458b47d68f24594f5e4e52395d5b500eaf2ebc63299c206abe1838bc3a904b553492bbe03db3dc365e310221c2d7de65af210a01bba1e2b23ca196b9000a7dde3e85acb5cddfc82094b218154242dea13fa5e82de2276201e4ecee0614d7f7d04dab41dba570c515e819bd9d4563fbcb46007e7006f5"

definition ModSize2048SHA512_256_S8 :: octets where
  "ModSize2048SHA512_256_S8 = nat_to_octets 0x96db5837e5644d02af09f74a91e12d9aec84f68e7c2f5b3228ec17e00ee25806ccf7f705b5c82166d8a043c8a4110fd289210a559e93b8ad9839bcbf18a3a79767d3617729d8c318d7e2019a330d7816a8e6cd637819aa7ace36df615853ff90253cad34d7b8aeaf86208e6154c8c691632982096d380631693dcae3492eaa6ff8ffc3454f3602bca6ec93cf3d56d338b7f1ae45d9afd12d1c0338fa73694a61c3c2b019bf444cdea8eac94245b089cf9caa8aa6fae776d43941a143532fde33348818b620bc1bea4e791909d7b64f44474a0c1c20c9ef4d0c467d4f9371927e2c8d2bba4cd8618fccf5f91bbba1336ce49b2f5de13b8f4d792d70a070b306ff"

lemma ModSize2048SHA512_256_TestVector8:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg8 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S8"
  by eval

definition ModSize2048SHA512_256_Msg9 :: octets where
  "ModSize2048SHA512_256_Msg9 = nat_to_octets 0x09d1932d2a8376d487b833ca5f43a09ed741b379414eebf79df9eb356075692c7591463d82e9fe0c6c5e43921dc5e56e85dcf57cde822aa93527830626812e1be780a97d888527a378cf35f54c359d26bc1b8bc4ee9fee0df8132105a0b0cbc565880416c4bdb93eb4f1511a73fd906d84e6bc78f90dffcbeea50d5a566a06d3"

definition ModSize2048SHA512_256_S9 :: octets where
  "ModSize2048SHA512_256_S9 = nat_to_octets 0x78248f02a777283a462dc6fcf94d7f0b0c4e6f10622af034f38f326469e0ad1bd8efc22bb441f9e7a8cda25c851a7aa6d690819cc6ff163fa3c0ebd583392256621a21dc8bbc193060b51eb194f8295438b10f0bf774f2eb48d030b6b6206cbe791698e89c71da2ba3c05b78996709904b3288fc6e2d5bb5929eab74e9b028092b45dd4acf11edfdf49aa8259c9a639868b70f0273c69991ca088855b3d1c7fb534d54bf8e507a33966b0185b0bd5204592515fd402da922ba68a6834e4b7176df5eb3114efa32dc5d328480b2cd0c018c783be87b267ff2c595a0392a6d920b023c21620aa58ebae4b0cff347ddf08418189cd16047a80dca087c8e0abe2907"

lemma ModSize2048SHA512_256_TestVector9:
  "ModSize2048SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize2048SHA512_256_Msg9 ModSize2048SHA512_256_SaltVal 
         = ModSize2048SHA512_256_S9"
  by eval

subsection \<open>RSASSA-PSS: Truncated SHAs - Mod Size 3072\<close>
text\<open>NIST has test vectors for RSASSA_PSS using SHA-512/224 and SHA-512/256, but in a different
file and using different moduli from the test vectors above.  The test vectors in this and the
previous subsection may be found in SigGenPSS_186-3_TruncatedSHAs.txt, which is included in the
zip file linked at the top of this theory.\<close>

definition n3072t :: nat where
  "n3072t = 0xa9d6499f2f8bd5c848194a6b444ea48700b13a1988753cbd187d6e5ad8b99347a27a0f0c3bdc038e74b8dab1a958fb1988377de00e4a1c8b9fde61df9cbf6c6df20c57d1ebb99988208784cb2ccf067e4c1bd269f74d8b897896aaf7e4901b7861143440f054c7f53f0e3a29248677d707e4624e4e2c5d075b98bf0a18be780905a1588aa3440ce2d5760ecc767b1c43cbd00924428478923fbe6f4602fce36184d21fb895b04e6a8cde5f0b8798110cb0497155be5336b9fbc0529ab9980c85ba0edcb4af2dbc7cd268b2f699d15f2a7e91510fd782c581672dfc1d1ca8e798f70ee56080db77470118cfc398efa728471e5c4ffdadddfb3232251e1bf61e295acf80d874ccc2ec052ac1806276f98eaf25d2f9156853ea3f27a3f0ad6b9cff46b0deed82fd9f5175b6f845768b45881fb5e584129033161232a4da5375a719729c8f427390c2859997a5ac21bfc7c4cb3c433d29265a19399868a8c16744bbb5e44350c8b2b3acf766966ee04e91db3b564081d7b456d9d78d46ac438577bb"

lemma n3072t_gr_1: "1 < n3072t" 
  using n3072t_def by presburger

definition e3072t :: nat where
  "e3072t = 0x1fdecf"

definition d3072t :: nat where
  "d3072t = 0x18402aa33d47f27bd0a21ff764132aa93da95e75e6d5fcd038b0bc89c94ca0fc65ff7d4145d50dec72d0a6d4a2ab331b5cdef5977db2251bd3ab0da528193f5c47afd4432525d075866c1543489a925352d97e91af471bb918176f9f4c6ff91d98560b073df25ccb850fb6bf6a1cfebb895e11e500f51cd55e3ff85203e753be3797fadba4e710ac1838fc1917ac12b4a8d01acf9d9fb1092f95ea861288ca4b618793754d2ecbec3d165e08133bf61e12ce799d5757811cc9fe1b2e63c9fd19b4f11390f8dcdc85667239cb77627e9307054a65a2dcd5411ea468adc6602eb9e71892c4a32fa1f353dd3c9559d2bf2f5f3731045745879e1b5a4de46c5aea1380016823eb48e4e2e0f5845407f03c2c34ec6cd09604d87c36f31c2f09b194f77ac27b56dce1bc582c55c439897876f49e8da0f6f15fd355e05e2254cc67c34671182622424dac86f680f08eb326a146e494d127168c4ff0b223c12cf761cf1ad2ed6cc5def7ff28b912b8a2cd313083950284bd7170839a4828f672ef22efdf"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.  Note that we can't do a global interpretation inside a locale.  So we just have to
assume p and q exists.\<close>
axiomatization where MissingPandQt3072: "\<exists>p q. PKCS1_validRSAprivateKey n3072t d3072t p q e3072t"

lemma FunctionalInverses1t3072: "\<forall>m<n3072t. PKCS1_RSADP n3072t d3072t (PKCS1_RSAEP n3072t e3072t m) = m"
  by (meson MissingPandQt3072 PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2t3072: "\<forall>c<n3072t. PKCS1_RSAEP n3072t e3072t (PKCS1_RSADP n3072t d3072t c) = c"
  by (meson MissingPandQt3072 PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

subsubsection \<open>with SHA-512/224 (Salt len: 0)\<close>

text \<open>Now with our encryption/decryption primitives set up, and the appropriate EMSA_PSS locale,
we can interpret the RSASSA-PSS (probabilistic signature scheme) with those functions.\<close>
global_interpretation RSASSA_PSS_ModSize3072SHA512_224: 
  RSASSA_PSS MGF1wSHA512_224 SHA512_224octets 28 "PKCS1_RSAEP n3072t e3072t" "PKCS1_RSADP n3072t d3072t" n3072t
  defines ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA512_224.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA512_224.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA512_224_k                                = "RSASSA_PSS_ModSize3072SHA512_224.k"
  and     ModSize3072SHA512_224_modBits                          = "RSASSA_PSS_ModSize3072SHA512_224.modBits"
  and     ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize3072SHA512_224.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA512_224 SHA512_224octets 28" by (simp add: EMSA_PSS_SHA512_224.EMSA_PSS_axioms) 
  have 5: "0 < n3072t"                                   using zero_less_numeral n3072t_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072t e3072t m < n3072t"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072t d3072t c < n3072t" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072t. PKCS1_RSADP n3072t d3072t (PKCS1_RSAEP n3072t e3072t m) = m" 
    using FunctionalInverses1t3072 by blast
  have 9: "\<forall>c<n3072t. PKCS1_RSAEP n3072t e3072t (PKCS1_RSADP n3072t d3072t c) = c" 
    using FunctionalInverses2t3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072t e3072t) (PKCS1_RSADP n3072t d3072t) n3072t" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512_224 SHA512_224octets 28 (PKCS1_RSAEP n3072t e3072t) (PKCS1_RSADP n3072t d3072t) n3072t" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-512/224. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA512_224_Msg0 :: octets where
  "ModSize3072SHA512_224_Msg0 = nat_to_octets 0xc642a5a32850266844f96a1800a11c42fe728f80c1f0ffab11d41a4ba017be51ed4d050969347f4ad98dbef0fb2a188b6c49a859c920967214b998435a00b93d931b5acecaf976917e2e2ac247fe74f4bdb73b0695458f530d0033298bc8587d8054acdc93c793a5fc84b4762d44b8e4b8664e6f6d8673b4c250f0e579962477"

definition ModSize3072SHA512_224_S0 :: octets where
  "ModSize3072SHA512_224_S0 = nat_to_octets 0x341bec7948589d9deb40c0a65d17864229a7d221243883d1b10aff74181ff0a07db7d74e0b99203e668cacbb89b184e7e613e1129f6b61f7487beba7f1a9d5db81457c8c6269f2fc35972554dea977a73b42e6e9ed880bae8c66190bdf8937f1084a15c2a14f78784836ff566dd83533147c85773a10324a39d19e91abdc172542aa24b92ee09bb72d3ffb446ebd9ff61503e9629f09af6bd0903d484a6d8fef4b85759c932b67ac36bf65a691d42ef422e3e350e5779fa8e717641d8181a2543f7cb8162d41812b5560b8e178086666bdc7f9d3797959731718e8c9808967ca61d1657f07a28e523caef586c1894f66482b4d2f7c31a5247f0cbc4587b3c1aeeb9b32cc9f5d9907c47067a69aa0e1ba174c46ac15c1687f12287899413ab549f48a590c50a69bcab9498b0e48e220d5137efb4fbcf8b511ba9c20d8c5ebbe41459375956236bc87b208c10df1caa3f5ec349185bf4e89b6edddb6467056e197679390598abf8ef0ab98a5f2ecb6361cb895c6b9fd0ebf28eea48ffc5f2ae034"

definition ModSize3072SHA512_224_SaltVal :: octets where
  "ModSize3072SHA512_224_SaltVal = []"

lemma ModSize3072SHA512_224_SaltInputValid:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA512_224_SaltVal"
  by eval

lemma ModSize3072SHA512_224_TestVector0:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg0 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S0" 
  by eval

definition ModSize3072SHA512_224_Msg1 :: octets where
  "ModSize3072SHA512_224_Msg1 = nat_to_octets 0x0de36b28a6f8ce5e2b3cce3560ad862b5c5bd37ef61263f07b390fc7a2fa6b19c1a49b46404d68c64ebb9325d485684ba7759701023140b1331a4d6d94750433bdc9dc70f88790c2f6f07302c0340382efd7c09320593f4ba3167a85736b6a286b1ad8adb6f070db88a517d50b037e579d4af73d38d4884531f53e152625c480"

definition ModSize3072SHA512_224_S1 :: octets where
  "ModSize3072SHA512_224_S1 = nat_to_octets 0x9f4647d2c195b9d468bcfef71577ce312ea4249f9f97cbe11b45951b55d0f7a3ec7911a6a82b3b365c8b63b9567b8180a434d652ccb9397002e9016ca4e4565b60e960a5bfe5f861627879a2864cb4f27b377fe3b42540fb71a4b385e69f089bfa3da3eae608329a533bfd8822a0c2e33c9d4372ee0fa6b72820cfe700e68f7cd3c30ea5380269384fb01628d83a56452fd94cae62a17294dc42dd25fc83250e0f90e1c0693d7e95270c220cc206d68ce8f01127b9be0f05fe51f2dc1191887367c880bda23bf815b980074a4427e9bb587b771dc782eebb805cb5d3cbce4b4e0fde6f79f4770e911aaa7fd07b5a2d52ea1b7a2258d1dbdeb5b59915a55e859657604d4367d68a20d8c6fb2f26ce98b4e8695b9da0ed2473aecf6a118e5781bcb189542b77705a37155cdde702fbaa04ee8bb687c3995c0bf7e3a350c0acba2862e6b41d7edff4747d0d52e7645f3731ac4fbe32ca97ab76956190314ad86c83f04feb36e1ad5f73fa1fc291ecca8458d725d61ad0e0203292e3c08753b09ea6"

lemma ModSize3072SHA512_224_TestVector1:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg1 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S1"
  by eval

definition ModSize3072SHA512_224_Msg2 :: octets where
  "ModSize3072SHA512_224_Msg2 = nat_to_octets 0x15984a7560c9bc4d8e5deb3e807cee541d42022ba5c27b10424b0163e1eaf83f3f2f405e47341f369bdc7b6871594d5ba0f15224fa0104aadd42c807054b6931a457c5d9b549c6938ded9438b3810988f1746614ab6d445c708fcd34cffc2b6c6c9741af530f99ac8b199e74effc0c233953a4c3600e246d24bb76b1e6042839"

definition ModSize3072SHA512_224_S2 :: octets where
  "ModSize3072SHA512_224_S2 = nat_to_octets 0x47f0f2e59c57d1368d8f7af9fbd9a276ba5664b7cceed05453af3a19e39221753a483afbb69b0ad2c3cb9eeba8a89b15fab2176c4d6f23d49901e755b26bcaa023a2d204ec3f9b1b86e884f915206e9700f1e3440c72ee82ef9cc9586e614bfcffe5f1ce5c1e88ca395dffe17092661763dd1f59342e85da7164877f34435549cc2f46beae3bda75cad2bb6245d95a78f42c35543df768fedc82c0c3eba0f8c9f0a9c9c49acf0659bb31c15e48f5210b40c2c908a7d16b741149f7a99ab662fb93ff03d2e1d1a9c747431a3bde0fc6bda2ca97ff0702c566a802850193f6015541b192d025fb4a066ac86fc3fac60dc126c8aab7407f96c57a9036f8c87101804f63d533bc27030108e9d818a0e781fccf84b1843491d2014d80e504499ffcc9652fae595536eeab6025e4349afbbbc39d98ef3651f9e396e440e10720d0088ddac25aa74c9678daa7009b27831455d724b92a7f385e30ce01348df8953757574d75db554253d6f0a98f44b6e1545bac6ba2ea9089ef53d50e74bf660f31a579"

lemma ModSize3072SHA512_224_TestVector2:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg2 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S2"
  by eval

definition ModSize3072SHA512_224_Msg3 :: octets where
  "ModSize3072SHA512_224_Msg3 = nat_to_octets 0x6ecef36b3e3f3eeec7b2fcafd5d3fad44a0cc643c09f715a6ff294e15129913c85fa1be5f2bdf91a2cc306d39be97df7da6d73cf5d00a5bb571c7424da972eb140798fbecb0b880a88303eaf79f85658f27370ae44c3f113997506931f12e61769f057dc124e7324a3a0ac2cb6280e5d5cc6c4c6bd11decafea6511668c13fd7"

definition ModSize3072SHA512_224_S3 :: octets where
  "ModSize3072SHA512_224_S3 = nat_to_octets 0x8dfb3af8566d416b0651852316ca2dbf80b4eedb88bbee9c616760cfea3b6460877d7e63d745c634b3c775498148566ab5c71c69bd476dc2d5db0b5914e1d649ee7648a0dcedcb0132616a696cb665bb872792f1e2e7880ce29ef4226de033b84c0a518a6b1805dbe164ff176fd252e8d784f4696967f444e585e087a1e694a123f0d7e10b1e5ad4894d9ee43107f32665be9ce11ebfb4b722f9e2c6b151a8dd8695156ee1e98f228556c8dc47dfe029ec22fb5c4cf96d8c4c190de823509f57a9674578d705e35d9423449e0519f056a04c47eaa042204d064dff84bf0c6f7e77478c93c4fa2a17fa617b51db9b3ef021501cedce2948119b015200e3f79dec13ebf5d872a9c24f4388e6fea5930e0fce2353543c5de84299d7cb30c7b92bca46a75e5f1d589cc6cf9012ba8754bc288127ca7a47338c2479b560ba66be39333888a3fb408fa6bffa87ae363c2b8dd17ee8091add784cac3d84f7ef9d31829b2bfb9f960918e8a9a703635f2b817dd4d33e34af595460f25d20952513390a4d"

lemma ModSize3072SHA512_224_TestVector3:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg3 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S3"
  by eval

definition ModSize3072SHA512_224_Msg4 :: octets where
  "ModSize3072SHA512_224_Msg4 = nat_to_octets 0x9d3851f81c9bcdd9bf1b49abb051cdedc3ce75d79eb0ba911d73f2a2f5091aab972cd45557f3ac88cda39fde7bc8de57b185cf4eae2955ab0802515b4e7669fdeb4f08de4d57a52847254956b4364beb5e405e641ec2cf6b44e0074d386e57ae624bf57c48f04121f6484dfda3c39d1391a62b0235a5ae3898b31c62fd196e26"

definition ModSize3072SHA512_224_S4 :: octets where
  "ModSize3072SHA512_224_S4 = nat_to_octets 0x8ad5a0410d3321c6db10825bb6cb6aff9b535ece860e234af1a765598deba1a3c0f9bcae8026d15fcdefa062465e24262f06444a0a3507742c867d35ea39df96d791970b2feed352987c70c138c7ec51555a6c74f86c7f2289881e10f1e97621397b1ff9664720f9d86ebe6baa42e0fadcacdaaaf72e0973e1d7f282818629697b2fc1bf513e52542ed79d9df500488582ca5bb27811a1f5cc22e9387ff1eb37e09cca5eca7599a17117cc58a5ed1cfb1cd09843a0ab617cdcaafb7657b166a6e2fc994506d728f1b4092fdd6c413922c4224ca9cf13bfde332f26659f93dfae176eeea066a4c5ab6f839c109a227f57b1bdbc7c282d4e683974bfd07184dde9af2ad9e0d5480c18680200cc7a4796188c970ded598610069709b7e57986087c583e46e19469956de5b7a2ec55d800db0483581cf1adface34db109fc1a32b2700a55722a920527511b3afcbe5205ae167f592b5e825770fd412f4c80a76fcaa18f49356dd9512a784350cd312b0b978234c178fa6db7523622fdec936b6ea65"

lemma ModSize3072SHA512_224_TestVector4:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg4 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S4"
  by eval

definition ModSize3072SHA512_224_Msg5 :: octets where
  "ModSize3072SHA512_224_Msg5 = nat_to_octets 0xd2d812b3558e77320d0a5ac5e028764a08cc74d517d10f4739427622bacdf19bc874c8f1798661fe10cea80c7c0ab3e9219fa73edb8ad51c409a29d826dcc5196657e92fdffa16a6bdd3731bfb826f4f26eca87a64340ce2b6e73dab7a763af134ea3d148dd3df539c81829d6577f0a39f1d4032bbb5fac021907b45bd829a4c"

definition ModSize3072SHA512_224_S5 :: octets where
  "ModSize3072SHA512_224_S5 = nat_to_octets 0x0c928fde1ba0d751a3416a9945a6d2d92348dcbded370d44ea2fd798d3909d616111cd7d7c1d53d213b94ff485a2c83a61eac10cfa52f5502d077b16b845c7d647fed022bca6ac5662ca71c9c7556750ee421cf3ca83c09227c95739cc1b9b2bd2d04ba65743b719aec6316f8d2a03b0bf09b79c56fa6c78180fb404253fb351945a3967303056a5d9d40640ae3d9089b894415a13dd525b9e68a0c431b0e2d97d99d88b20c63e8b44aff02b6ee7d6e919633e9b66f7cd4767993617ec29dd27714c10aa24fada7fdd3ca4c1f7eeef473e2426d59925337b1c0bcc5a408127c379cf0e5a3b003b15eebab349f1fa1744c0890cdc826bb498eda3d8f595f3b4d068e0c1670fd96e1d4ebec885322defa6ae3cf58501e9a23446004ac7301cfd239807fb03796dd5e07ab33f64bcadf2a51b41daac5e7030b3507b819627d67309ba591361a414964e109e98ccf9aa12b4f855c9f248d9c3546ba5553bd2fc355125375ed8ee5cd75ad32d44fcb58584670b397e8d7797fef0e0cb6968be1532a3"

lemma ModSize3072SHA512_224_TestVector5:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg5 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S5"
  by eval

definition ModSize3072SHA512_224_Msg6 :: octets where
  "ModSize3072SHA512_224_Msg6 = nat_to_octets 0x80a5889f08f13fe823fc42b0939ae58fdd448de4376bb8c7a70c3d3f6a85d4b593a7d8a9f40c4ca441aa1d6e73a9a6806b7279bcd8095d5c5a9c9329e85c5eed6f8bc22abbd68b0c9be6919d40323b38e7174240b82ab711edcd48373600bfdf5c7acb8a25f9030979d628a5c2dcaa9e995a6ed79e77cfcfa7c6e3d31e1aff72"

definition ModSize3072SHA512_224_S6 :: octets where
  "ModSize3072SHA512_224_S6 = nat_to_octets 0x0aa0c1be7e36c187a5cd2c0720fe266794df19bee8623dd1291717396abaa02093ca436b76f9cb335b70a19e7712714312eba39c60eecd78748a7cec932f7dbf10daeb18160bd5926e6c5dbcb3e74111521d637f460b6f44b1a3df562f0c93d0fae165fd2e48c03251c95983fa1e6ab61249dafa206cd476cb7fbf672e7084bb358c221b2e94ee268e41b96d32a83a481aba41560e81ffd2e6a3087d88b0e3433255217370b7be41299b0888ea570b74c3cd063c0f02bfcb6ebf77ed4221cfc4d7d3909b7bc087c7a5f0787cfe3dea8f84106488261af265243eb395219acee63011a11d49027703e8a7c11f397925ef0812611be315d209c3138e32238c3755a2021b28706f33f2f8f3f03df24790f013dbccff8455e38e460555818d44f3c400e3105a6464e3955df9f9435bb6b34dbb18ad3477831b45ca84be381f52c2699932e0d9e51fe043be5246d66f6e27892a42fe9d91a258de9da71e0b059e4a34ee683c363f09ce14881d8d34facb67499f0c4e6d98442bb1996f8c4df939a592"

lemma ModSize3072SHA512_224_TestVector6:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg6 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S6"
  by eval

definition ModSize3072SHA512_224_Msg7 :: octets where
  "ModSize3072SHA512_224_Msg7 = nat_to_octets 0xee436b6a38d986c178896a803f6e5146bdc518ccd8acf3c7802a60103c705902095ece2365495207a7fc157291fc12bd2811897bc301b05c639fa6514204a8f0af1d871b186659dc69f46f9495b988557104448cc947dce3ae1d0f650d8b60e386867e977ab60408667a622d702c1bd540a632471105de2508ad8596c48de8a3"

definition ModSize3072SHA512_224_S7 :: octets where
  "ModSize3072SHA512_224_S7 = nat_to_octets 0x37773bb5e8fd6f59b29cd58b5aa6ae9a94b9a317ee96d045ae5450dfea51b0dfef5f82d364349769bcafb987186a163a4091b4d4caae5a961afdfad05e0ede656c10f2914e20b73865e6809b081410b539ee7b0c077803c27e315bb3dc6c40fd05409f306a2d6a6600f6051d974a108d96c54c8dfa33a346799209beedc46842579cd9d668cb809b7c305e8941709ab005cdfeaadf4df17eba04b9f976546a83ae155c66c7f391b5f978509e515356c925df1d41f56db3d4f980ad8dd86408460b772d5ef8fe9b634aa092664085fe750debfe7863052db8124eb8deeb9f2bf4f5f78648c327925bab1cf8e62405b6f38ee85271e5575d42fd0c4f0c9cd0caf8ca22393f8209fbb692731fb2f5e8b0051149651efc83e8ae1a7c979611c0254fce70b78ad81bd4ff8a8988478492e07e12a80c020a42684e57f5c0d55790eaef9756b7f8e4504bf577909eea870a0b2d859f4dac1e2784f3eabaabde6534dc13c23ca3fb4e2ddbef9afd1dee1fbac74470d23ea8ea51b6191cd160f157070c91"

lemma ModSize3072SHA512_224_TestVector7:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg7 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S7"
  by eval

definition ModSize3072SHA512_224_Msg8 :: octets where
  "ModSize3072SHA512_224_Msg8 = nat_to_octets 0xa0f16e1a5ea9b152f46a250fb197b26adab0e8829f7794c44e519169c7eee13f302cfcadea3968f1c3f88aad6da7bca22fbea0bbda1ab34dff5a259d5f8ae8a3a3ff070d4d813987efb0b63a9aa049929ac7a6456019ff91c071d2c55d330502612f344371c94a9be0574ebe22cb80c38492a5281bbc9f17fa5c40e7a83260e6"

definition ModSize3072SHA512_224_S8 :: octets where
  "ModSize3072SHA512_224_S8 = nat_to_octets 0x32d142de909db1cc8aa6bc7648c3dbe15cf37c51c5c68b68e631eeca93cb59c3cb063f70ad68bd5c48341fa36d8050ce0d05c691d21b91ee172dd201bd7fdb12e4938e16488990d9fd73efd1223d2502a55c7444e03ab5acca23be2a8ba0af2b3e2281f08de6eee5dd6c3b7a9e6cb94b1e9c5a0eec16b3aefb4f19656d36a555f299811df683107fa7d23834e2aa2fc33a72b7b9a1a8a46ceebd51304fac650e3364c7852b5a339c14be424de63d879b3e5baa97d25a83089cec27963f15ed05dd01aa670b22e12f33c692e3944e60e7d2760e34f05c52de4b983977bf54cfc20a953f631917556609d9f1ad99822c3f522aa9559976ce43cd299cb2fc36e3ac4a462ad2fdd18e30f69b284e720ab073eabeaf3a8b703f1626f722711fb607a0bfdbc282acedb642d780db89de0b01436d41cf48680dd9da79620e2dc862e6fb89d6afa6d9446c8c203d239f888e2cae4c080487f7bc8e290c4cbf283f1b6605d3f3d97b1d725357631b729e0cb01ac1df37a773d0ed6c41143cd8d90d325a7d"

lemma ModSize3072SHA512_224_TestVector8:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg8 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S8"
  by eval

definition ModSize3072SHA512_224_Msg9 :: octets where
  "ModSize3072SHA512_224_Msg9 = nat_to_octets 0x947fca2fdd2e5fd21080e50c45804dd61b9a6697f4feafa362456a01dc57f171b68c4dad501105f08d8e34b58605dec180fe84631ce1f6fbcea369b990a4c9a7d8d851eac7265845a30d6ede878da745594537b2fdd93f8ec896e7353859adfbe2acfd6dab3301d93b47ba10afe0506a8eb8a60bffad326539670cfe3a3c4473"

definition ModSize3072SHA512_224_S9 :: octets where
  "ModSize3072SHA512_224_S9 = nat_to_octets 0x4a9bf3cd69369cebe2346d866aa502765983d52221a26b33528c97fb8b3e33bc8386619012f3eb0c21326798f63be2969fdb853cc19fa1788649be7b59445f5fa8118f5228080d3e80f5e71405b7ecf0f12ad153fec738ddf8196ed174a3d066297d90f0224eeae935af243b04ff39172d61609ce6d46c8490478c5b2240b85830c2e8e4d4c18188277fe9b8318260d7463845f86ef172fb607eaf3ab65eb871016269242ec4de6700e163f3711c237c07ee181477ea6d8e5f01c1519fb4f4bf18b68b58e0e849895b85eadd1ad9c8f5a59c1e6161f23fc1274fd428dd2c446a5764d7163e3852d742c7fd599fd71a47a87bb52b1ce2180b9f028fc0104847b8f6fa8428a4b5830415e58d7ccc5f5d0316d9af988b75bb81814ce47591247ab6f392d7b79f0842664bb7a666dc376461a92c74abbc72925685bf4de29def70890c8127445cf1820060e6378fb9aafb32ac4e4573f0c7cfeb8b1d2abf27e77aacb06fc96deaaac3d42ed91e23b3d187a36e1355df5b7340db434d0ecab713df08"

lemma ModSize3072SHA512_224_TestVector9:
  "ModSize3072SHA512_224_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_224_Msg9 ModSize3072SHA512_224_SaltVal 
         = ModSize3072SHA512_224_S9"
  by eval

subsubsection \<open>with SHA-512/256 (Salt len: 0)\<close>

text \<open>Now with our encryption/decryption primitives set up, and the appropriate EMSA_PSS locale,
we can interpret the RSASSA-PSS (probabilistic signature scheme) with those functions.\<close>
global_interpretation RSASSA_PSS_ModSize3072SHA512_256: 
  RSASSA_PSS MGF1wSHA512_256 SHA512_256octets 32 "PKCS1_RSAEP n3072t e3072t" "PKCS1_RSADP n3072t d3072t" n3072t
  defines ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize3072SHA512_256.PKCS1_RSASSA_PSS_Sign"
  and     ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize3072SHA512_256.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize3072SHA512_256_k                                = "RSASSA_PSS_ModSize3072SHA512_256.k"
  and     ModSize3072SHA512_256_modBits                          = "RSASSA_PSS_ModSize3072SHA512_256.modBits"
  and     ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize3072SHA512_256.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA512_256 SHA512_256octets 32" by (simp add: EMSA_PSS_SHA512_256.EMSA_PSS_axioms) 
  have 5: "0 < n3072t"                                   using zero_less_numeral n3072t_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n3072t e3072t m < n3072t"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n3072t d3072t c < n3072t" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n3072t. PKCS1_RSADP n3072t d3072t (PKCS1_RSAEP n3072t e3072t m) = m" 
    using FunctionalInverses1t3072 by blast
  have 9: "\<forall>c<n3072t. PKCS1_RSAEP n3072t e3072t (PKCS1_RSADP n3072t d3072t c) = c" 
    using FunctionalInverses2t3072 by blast
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n3072t e3072t) (PKCS1_RSADP n3072t d3072t) n3072t" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA512_256 SHA512_256octets 32 (PKCS1_RSAEP n3072t e3072t) (PKCS1_RSADP n3072t d3072t) n3072t" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

text \<open>Now we can test the vectors for Mod Size 3072 with SHA-512/256. We take the values from the
NIST documentation and do some simple data conversions to put everything into octets.  If we sign
Msg with the salt SaltVal, we should get the signature S.  There are 10 (sets of) test vectors
for this modulus n and hash algorithm.  The salt used is the same within the set of 10 examples.\<close>
definition ModSize3072SHA512_256_Msg0 :: octets where
  "ModSize3072SHA512_256_Msg0 = nat_to_octets 0xdede9344f021a6bfaab1f31a1156bae87cd631d9ec0477de9bf9c98dd8a2f8c8117b1a99329980612eeee932dac9f579029cdde0b7026072e60001002f8b6fc4f34b4545af9ff37a89e1fc3229eb63b4cada5fa2911256231d8209405f290d8facd87a0f103ae754e61395e4a5c5eae0fd1821e7233a413769054b151181b870"

definition ModSize3072SHA512_256_S0 :: octets where
  "ModSize3072SHA512_256_S0 = nat_to_octets 0x552e173156b6a9fad3e7a696b0aebf594d2c4c8cfea3b3d5cc16398b1c88d4257faa9398bbf1bd96cde845411e4b0e46f062b0cb6d02300246b6788c50300a399f5f55c89ed1a7d5f7ce95c0e1b4446f0bb11c3fedf79cad0ecadac9b3304ec734ebaf63588a7701355aa715d16ed9e2a3b338abd5a96b12bd3a7a28555440e1d22e010350fa329dab5d08aaa53c23f344962cc71d6a00593344d16b6b8d92e41fb68dc3fe321374a17146c1b1d33d434725f9c9716d3afc0cc0fcca755725b95931e9539282271423fb329bcd482c8388b8b79c6a24593586616a7380d5fa7ccba2dee30151ac8ef92150459c630c05ea15ec907964bdde7167a6c6491facacd8e7bcae2e564612e2bcaba4459f10c1cd6e5c608774165d2ff11752a88e1e2394f8750229ecc82173d7aa57e6f8a4b20b7e9f676dbef75229c281468d7c1a3c0be1a71987161bc469140f9c224d67e01ece5da69f09f0ec282500ddd351806791f4b363c35920f00e02c2fd49bda9ff7d5111d38d1aacbc3f795cfc2679148c"

definition ModSize3072SHA512_256_SaltVal :: octets where
  "ModSize3072SHA512_256_SaltVal = []"

lemma ModSize3072SHA512_256_SaltInputValid:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign_inputValid ModSize3072SHA512_256_SaltVal"
  by eval

lemma ModSize3072SHA512_256_TestVector0:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg0 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S0" 
  by eval

definition ModSize3072SHA512_256_Msg1 :: octets where
  "ModSize3072SHA512_256_Msg1 = nat_to_octets 0xed654056cf27081d61fa37d5a91b2940e7194001cb38c417e613eea55f863ff4e7cb16baeee3829d173855f3ea807acccae48832266296aff370521059e24d69ac0d99599f2d968fb404098df7c46eacec2f9061c6fd56bed97ee03c5280d2b72673f0ba48cbecfd1fa67b2c37afaeea3742801613d1ac4d8286c1b0b32977e7"

definition ModSize3072SHA512_256_S1 :: octets where
  "ModSize3072SHA512_256_S1 = nat_to_octets 0x2694ab79aa110de26e5bb0c5738280c13e4c4075d850f7bc249076f1b4bef6d189cd55c1207d77915ca19513f110a7dfa2e595f6a840fe45a996ac8ff2fae2aeda666ede3148df4cf4112725ea4c638b7393e52ae1e8c756cd139ebad9f69b7a5e2d6ef65dd06248b06669fd4a90cf6a6f957fc6923e1bd2cafe73a798f7473eb25c153a5d003002e036782e41ae7c3a9c2176ee59e9c3b4957d6f7dcadbf3a033da5ff4cd980f638ce0b49bd0ec1468511a91d31ab25978282058426874aa5e4a3228a6758962280340db921cd727137545cdff946d39db072183770edc815eda2dea83667f1a426cd1510419703078faac7dd6a593789c95ae8c206510fd5a653c58d2e158d6b3a4d50444679583f8009217c72a076f78da6074a7758be3d894f7fb0cd6054df29af04acc53df1c6f6af544e363698da5c72af039f2fd52f51eee27051bacaeafedd56b433ae144e52203b838d0a550aac92f1d7640f7e27c0b07e4421f4b2e87674c1c94c4028886032836c3f9d4fc573a62301b3e938e68"

lemma ModSize3072SHA512_256_TestVector1:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg1 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S1"
  by eval

definition ModSize3072SHA512_256_Msg2 :: octets where
  "ModSize3072SHA512_256_Msg2 = nat_to_octets 0x78a462d13bced2fa9b5f4b5096b0d09a6c54b9a150fa06356495f470e4bbce3fa14b061db253842266313e3d7df809be9715ae17ec3241e33e5aae270c5e95d80978589ecc2f72d8c97a0ae08028c790f47fe7055f248ba2243b555805ce3525967380dbf1294323ac84d6c1080ab41a6bdc89f311998d7bfe7f118c37d3572e"

definition ModSize3072SHA512_256_S2 :: octets where
  "ModSize3072SHA512_256_S2 = nat_to_octets 0x6cde4917f5580de2a552238f2a866f34dba7817ccb913cf83e7b1fdb24f9768afb88d372a06fb01f1b904819e2c612d0d4b7dbb07484deb12a5135cdb7bacb79ca29aca60d3d5be245844efc15bb3d8fefb07f5e34b87c7bff61e5f68b71b55f5e7c41f88305100a3326e6dede69e8f9f5ed98de0fe5b3da716511188b4915c5e17b876d4e69c080da9ac3890499f9fb0c3af999a0f53f751c19736a17753e3de0e4bf597302f717424ccd628de245dd2f58dea65cf8ba70291f9ead1d11e68a83518ac9f43fd95eb308083ca5b1a9c750dd71a24e6604b752157eaa4ec12bde9cd10e5e6d2fe74bcef128059d260c9d3e43500099aa9df1bd1fc351878efb7d5e9096af9a453328a2bc4aa4d6cd95f16769bc5a639bfc3429a1ee3424680c74f558e0e716f18961e49b6f818f5ef2fb91b665835f703d3354aa3af41dd219b30162e58acdd0c42991d5929fcba63901681128bf10367df4caabdd3f788c3284d45b15f09a12031c2d79e3df43ff9c0c844332a458295417c9d1b5920b2b8c11"

lemma ModSize3072SHA512_256_TestVector2:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg2 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S2"
  by eval

definition ModSize3072SHA512_256_Msg3 :: octets where
  "ModSize3072SHA512_256_Msg3 = nat_to_octets 0x0bffa55ea33452b4cb7e729d75952abe7f73e0ed35c0e847188e607cde46586eb9e237fbdc5d59163c68fd1d935f5f66ab7b211cd949ef49c75b6333773d26ec85aa5925ad0033438cf2ebb5ab7dd884b91dd72b1840edaa9cfb2dd68ffcdcf3f8c0d4841c0626624683030cc4d7dd3e32c0c9c5fb8d28911cd6860c2b6bc2aa"

definition ModSize3072SHA512_256_S3 :: octets where
  "ModSize3072SHA512_256_S3 = nat_to_octets 0x090aedc468b0fbc38c4dbdab04a683f174c6896b0d1063f87adc78f2152aa4e74b728e370aa9e766a4ee80b569a8abf9cd9891f68832f8e6f05561dc8ae111ead42be07e10bbcf5430e062fb6b49ab61e7cf3cd9c58ec79094e1db324903df577b509e9b29a5f95d8a7ef2b252ad7f48d16c08fa273e389738c457b36651097a859329d04be44d529bf75c41d1d14562537ecf3e919221e22a05fd9d2c9d775793f4d69614c8f9e8bbeaf7faa75f046a1ede659f15674fd2c89de67c64f99d2c29715a188932831beaa73e93273a17730067289c161a9c217b5a60c6c38473a4e2c2b62f93fcc99963a8dffdcb7ff0d36fb03d913e72e024b22e2f1c87d79c3801dfef2b5c17e0b3189db14100f7c31eee6dd92454adebef3237a6f50f1c5966ba4e44a012afd4c98f171009b31daee4ab671ae8b669e71d65e7c79181c7d31079766f578c923293405472a6fbbb121355260394e890697bf2f39f552cd5bcafb0670661dd31b531843a89e5566845873c6d05acec03ce1aeafd0e2b4fe8af97"

lemma ModSize3072SHA512_256_TestVector3:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg3 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S3"
  by eval

definition ModSize3072SHA512_256_Msg4 :: octets where
  "ModSize3072SHA512_256_Msg4 = nat_to_octets 0x48031877336bb181d872f7dd7c9d6ecdeadd556965b433e8e299b21b749eb03a085094e352dede60077e03294d0d77a970f50b45d654799b355b3d0703f4a76c2ea72f310ebe088998a7f8f8d49b6613917db5875705d05c9d1d067b3c8b196e24d191684d515685f1b57e52f98e6490b53bfa35cf0d60b482a9b57e07ad2dc9"

definition ModSize3072SHA512_256_S4 :: octets where
  "ModSize3072SHA512_256_S4 = nat_to_octets 0x8e1e2ecd1b9b955fef52b996b25a20aa00c0bce4d6cbf8d2d3d9e6711411fa6b89a950a8168c43676050aa9a1d09461cb286891082e34aeb1693ba10bffc8669128009a480eb79b51ce708f31f31559d2111c3df4a1096cd8d3002ba24a4be18443f260d1c31ce4850b767fde5820645fdf1b6768c1c4edfe4c743ecaa656c4f26cd81a10df845bc7f109b7aba8b2b9ddf67eef88b3e715cfca8368c85c80949338007aebab6b821308e2bc5a1edbda48408f9a214d8694913da474135bb9a3e1ad6f9dfc30c78338b43f503ce62977bd34bea7eb3da52627c508db66ba80c02ea8c6082cfc0f06b2f47532f79f7364cce2ca80e24e65ad63620d1beb58ddf9ec940cc7896465f986a6bd5688ecb1099604f41f964722cc8aecbb31295b8ea02d7e71c4650183456c6d5f1a4dbb0e46407cce598174f5f42358d1948fdf5723b66839c35730c66b9beb04affedbd0624ebdea47e3f27f1ac7da98fa19a5210eb97961c6165c2f133651b74f6e6309bac135073034f0af5c3db8953b021c32de0"

lemma ModSize3072SHA512_256_TestVector4:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg4 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S4"
  by eval

definition ModSize3072SHA512_256_Msg5 :: octets where
  "ModSize3072SHA512_256_Msg5 = nat_to_octets 0x7d462b2bd2ddec9aae0c50d9ee912f304c8f3276d331e5d497900dcba2d73b7831a5a11721b225c7a4b6b48c3886d99ada808ed1762a5284a3167b7e8d09ce47325b4da3d2a1505ca08ad741be071f6f68af73cf706145e0ea2b7db7286a1144e933d6d6cdf296e10c516200685c293660e28a79a71ee771d496bb7d5b442df7"

definition ModSize3072SHA512_256_S5 :: octets where
  "ModSize3072SHA512_256_S5 = nat_to_octets 0x2845dae6c700ae0b12b4ee09387f532c1df75e4d4d6b8ec2baacfa66d5baac53257b09b090587e0b8e524c366c3b330f668a7b3229f7b16776a598b48e9018c04f074b75abd30d016af665d9f8a8fbf81fede76c3102cf15de174ab69d8160bb28637b257636e7ea69bee46c128afc57bf2c8d1fd639e01d049997c90d286d75f82121ab51fa9d92951724d32725e559961de1345fac18dafc9b472e235dd32bbcda8dd544ff01338189dc191d69141a79b39b7edb56adb48cbdb2e370a0425beb78cfa980e30b92daddabd9e10dac6f13ab0d5a29cabba60d5d637ac9c6abfaeded5672941761d3eeec3763951823b86b4df20838f7170cfe509deff4b1597c5fe3785df0a0a62d70e7fb75f183f6f73a134b4d89004a559edba910157068157e29e25b10c18aa37d1569a484387218712c847a8aad93023fe00cdc71e55aab46ea371bc52fc0496139cf30c7a53e6cf043ef0b9aea086efdba8fd2cbd15c6b82493cae581500040821ccceebbe51de2a2b356006afacb90cbd39f3cee7c99a"

lemma ModSize3072SHA512_256_TestVector5:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg5 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S5"
  by eval

definition ModSize3072SHA512_256_Msg6 :: octets where
  "ModSize3072SHA512_256_Msg6 = nat_to_octets 0x8ea2309acbdbf827b4af0a7f418741e147392587a474bc2abc5ea3c92a7b5ca7afd1ea936e4a9b6b5c5926e3f2e0f5832552c4ef97156b6b0f2af89e270f019644e4390dcbce40eb9299c00c95a1b542ebf20c9ef8ae70ebe3af617c4a6e862835234492492e8fae3fb60080949028278162251b2d0872b3223604eafd5f9262"

definition ModSize3072SHA512_256_S6 :: octets where
  "ModSize3072SHA512_256_S6 = nat_to_octets 0x3f5094a438d4bcdd51b54860f3d0e74f87350a0b230b125a7d7ba6c7782f5a38841a3c4dc89e2c51262f355661517184803f0324c83f54453bc3852348cea3683e48013222261bf28c5e1ed47c4f63f1bff0998f7551f71e427c5aca89e8b6558f802a7bfefdaa9c2834a08535d4b8ffc8734fd7d3e3eb903b50a96ba79eec6d114deb6e8cb1a3d301edb343b1f280fb1d6619f5aa980ab98c7fbe423854715226dfa87d2a065b0f77df1d3cc0f724af3764f1dd27dcc763c856c8b2ba64820fec6b8e3e837f31115aa36de077a54c3eb3d91b9bd162468a9036332cadbd295574fa57608ce24161d17a6421dc7425cd31f610fa4835d120a225fc0cba537b96ee5c03b135b62fe14fc95e10dea7a277cbeea8ce3364f284c691573e05fcb58f64b96634d9b49d13a9b271770e521abf4f6b67240a47f76a5cb30ddf33cfd6b0b608509e83b06f3166a8b544979520b5d7ffdcdd9520ea92a2437f33631c82d10ad722da93d16e873e5a279a77edf90924db213067ec94332c447e56b4c86a28"

lemma ModSize3072SHA512_256_TestVector6:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg6 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S6"
  by eval

definition ModSize3072SHA512_256_Msg7 :: octets where
  "ModSize3072SHA512_256_Msg7 = nat_to_octets 0x81dd6c87d05cef3d2ff53f42830ff45ccbb9af3a47425ba9e003b20bc480030451b03376349803b0d21f90e2e71d20d46cb51bd8bfe558fefe5b9a86b38a5b9bb7fec83e50ec0c809d0ed1f434ad04640900d9c392b4106328cc7668b1abae7d7c6f31c56c819414596a0a60b3e929726842f1e108d80a4128fe4d98040b8611"

definition ModSize3072SHA512_256_S7 :: octets where
  "ModSize3072SHA512_256_S7 = nat_to_octets 0x5be4d75ed981159652b7794287be96d502cf7705618f590ae7209b7e43df10276009014eb0b101f1aa216af8ed4bd3406e0c98bcca7642324e4727d501d50d8d7e4aa071711bf387ec926eeff74d985078560157f05f4f95c4ae0e1f2adc512f076ae1920a3c197e928c591b7bf3376f0d854ee7c243f08dbb8451ae2547d8f1fcc7f776541f8a98a8d93c50096ae44b366e2a0ac1f8747871676a742f14fea1de0bf2c2857c7d3911b9a5166a3122941d0df4ad80a091fbcc1a700bf381d59a25b0546b2e24c702e33e0216d0c2b800409f84797040373e1f61e0ba73e1c6bbec397dfbca4ce399fef9f48064eca462c3fb0a01c47644e07b43bccf077ba2f0c30be391805f09180c6d996c41ef79bfa2f6ea8fc39db007cf122ec29746f9b4a322a62ac22d5216c77682801921324e72d542a8ab8b6e624da5156e2ace2d7cbcf09200056657369797d1c194b08ee073e7b3b302321611f8706f82924b5c6f5a5a3bc6e1fcfc381555a0350cba6152bda463313ed0f6353e99f05125141236"

lemma ModSize3072SHA512_256_TestVector7:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg7 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S7"
  by eval

definition ModSize3072SHA512_256_Msg8 :: octets where
  "ModSize3072SHA512_256_Msg8 = nat_to_octets 0xef2d179cb22c7b89dd1c9f86f007b01630b0bb27a981cda074c559393617d98fe91ab878df6b709303d4f02463c3401febfa678373878de9fdf75d5d37c7ad6c481b617ec8b28c67101ad938b5202a5b4f8b7edf7f0a1810306ade4b1c0cff109297d85977ea192a8c55236aee08b5f1e3cbc8e2d3f0b73b9586a3aaedd016a3"

definition ModSize3072SHA512_256_S8 :: octets where
  "ModSize3072SHA512_256_S8 = nat_to_octets 0x131d2cdb1a5ef38ad4ed19ebca4b8cc14533bbde7039c957c026c6ccd82a6d1d6088949a88dde506b94fe8cf679a352ba505b982ba9e6c91cecc62c3da3592ac39505ef43e77feedc2b1e4b749a37d56e8fa55b6b579927248bf6a669d61be6923db46062a97ade441a0c43a68cbcec4dbd440a08ee9355aade4327eb18a4fca6bf73b23a557a27074a588e704d9687a1a66d2be3b9851d9fb7869228213e39a6173d60b3f5f2ddeb3fb6bf8ec85dfcfc6685eda41390ea8f8390f9336b181c39e779b930bc93c2867414a4382f47ecd713531425b9fe6ee1573827cde76c01e34d5918d8754a37777fab7d63111970ab806caf53cae6976a1d8409ffb47309d651bb22ab90d474c52bb42367e6a44cee2fb76d2e61b9b2f1fa31e1673f68c8affb551990d5e2ba369b4614cefda05bf21209c44b4033d754b43a8a5585274b6cd198e99b2a17f69c57fe283f3a8f573e7bb92348973acab578a56f4d0a742442c3cbcc323ace0b1605834add2b8d759537c8b773a60f175d7bef555dd15fd08"

lemma ModSize3072SHA512_256_TestVector8:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg8 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S8"
  by eval

definition ModSize3072SHA512_256_Msg9 :: octets where
  "ModSize3072SHA512_256_Msg9 = nat_to_octets 0x2393f956864f57c5dd9cbcf27d89ca8da2772d1c0e2b68a7f321d4b51323e578261bb0457c26aa47e3e9b373cb2853bea894438e98e52f6f4629ba080e5cc34d6238e6f66c4e462ff4568a9185c42651cb9cdcb7408682d20825056b18a5ae379e93a4509df2b3e6d88b4b32f284ccacd334007e4e36e93800bcbec57b26309e"

definition ModSize3072SHA512_256_S9 :: octets where
  "ModSize3072SHA512_256_S9 = nat_to_octets 0x523cfd39492fdc70370d02763e2185abdbaa5ed331694a52ee7ad0382c4d2aa0c78b0fd0bc0d7debdef5b471dfe5c59962fca60a0b1d7cf68f1cf2d44ef8d9e110abb4e1531a9cb26bf4b585d486fd6ef5ee4d7eb7b6e4d6a930090d0d9d201ecab88fcf5c4c9231fbd5fe4285538ff85554073f9e49b084ba6c03ee6d6966afa029318b07dbea55a1570911579149efe87d67391e665b52774bc498a9f7194b4f0d304c8adf0998461ad7e1902ddcc0f7c326f7d5062f7c32f8d7e0fd3b5189b2ccda6451b7a93db018c93baad28ad871a464a4f0da5a32c81f645a77f9e1b6da16aaf96eb32fcf7d658e1846aad21f85f4af856b9853adf16f5cf5b7ea1ac2136fc13fb735df03b010ae854068bc758e3b875c319df322cba923f4ee6668087d59d80f2e55fdf6e44e5f2dfa1e747d0fb8bb3542d5466c47a2324334c8f5d4edb5a1fcc760a2c71d79b4146cd9d6821d92c308b58ac48502da31a63cc525157d63b25fd59f31a73b5398ecafe12739af44c2f441dc47b93f7f4d10c4b2e484"

lemma ModSize3072SHA512_256_TestVector9:
  "ModSize3072SHA512_256_PKCS1_RSASSA_PSS_Sign ModSize3072SHA512_256_Msg9 ModSize3072SHA512_256_SaltVal 
         = ModSize3072SHA512_256_S9"
  by eval

subsection \<open>RSASSA-PSS Failure Cases\<close>
text \<open>Above we have a lot of examples of where the signature matches the message.  NIST also
provides some cases where the signature check should fail.  We run a few of those failure
cases here.  For fun we are going to use test vectors where the factorization of n is given.  We
want to see how hard it is to prove that the given values form a valid RSA key.  Well, the only
hard part is proving that p and q are prime.  For small numbers, like say 17, eval can determine
primality.  But these values are sufficiently large that eval doesn't work.  But if we 
take it on faith that p and q are prime, then showing that the rest of the conditions of being
a valid key are shown quickly by eval.  These test vectors may be found in SigVerPSS_186-3.rsp,
which is contained in the zip file linked at the top of this theory.\<close>

definition n1024 :: nat where
  "n1024 = 0xec996bc93e81094436fd5fc2eef511782eb40fe60cc6f27f24bc8728d686537f1caa82cfcfa5c323604b6918d7cd0318d98395c855c7c7ada6fc447f192283cdc81e7291e232336019d4dac12356b93a349883cd2c0a7d2eae9715f1cc6dd657cea5cb2c46ce6468794b326b33f1bff61a00fa72931345ca6768365e1eb906dd"

definition p1024 :: nat where
  "p1024 = 0xf71840f8a6472ebdc7f54d9884e86428ebd368324d87298fa00d9ccfb3d9afc21e0e2a10b15eb4a08f80cca7268a36a762f4900866a6a07419f9543ac3101a8b"

definition q1024 :: nat where
  "q1024 = 0xf520558d02718b19a113fec43f4d086b76bb50e6d83772f1b07131b60a19a2baa553715df82a9e5dece4c79a5388949bcd9cf6a6c8c010903e681e195d3b5937"

definition e1024 :: nat where
  "e1024 = 0x90c6d3"

definition d1024 :: nat where
  "d1024 = 0x4333e93f386b41556edcdc7ce6c61445265f52f45b87d17141de1db50c35295bb62443fcf3943708944c7fe14fd4aacf1c5a78c762b7c2d60e884f488303a83ee1dea71e31a2806ee413ae5014cd2049bc164356b0a787678baad03127302e5b0cbd62b18d0b4defa62f203f63aa00f79e784698747318647e8381cec44e27a1"

axiomatization where p1024_prime: "prime p1024"
axiomatization where q1024_prime: "prime q1024"

lemma validPublicKey1024: "PKCS1_validRSApublicKey n1024 e1024 p1024 q1024" 
proof - 
  have p1: "2 < p1024"            by eval
  have q1: "2 < q1024"            by eval
  have pq1: "p1024 \<noteq> q1024"       by eval
  have pq2: "p1024*q1024 = n1024" by eval
  have e1: "2 < e1024"            by eval
  have e2: "e1024 < n1024"        by eval
  let ?l = "lcm (p1024 - 1) (q1024 - 1)"
  have e3: "gcd e1024 ?l = 1"     by eval
  show ?thesis
    using p1024_prime q1024_prime p1 q1 pq1 pq2 e1 e2 e3 PKCS1_validRSApublicKey_def by algebra
qed

lemma validPrivateKey1024: "PKCS1_validRSAprivateKey n1024 d1024 p1024 q1024 e1024" 
proof - 
  let ?l = "lcm (p1024 - 1) (q1024 - 1)"
  have 1: "0 < d1024"              by eval
  have 2: "d1024 < n1024"          by eval
  have 3: "e1024*d1024 mod ?l = 1" by eval
  show ?thesis using 1 2 3 validPublicKey1024 PKCS1_validRSAprivateKey_def by algebra
qed

global_interpretation RSASSA_PSS_ModSize1024SHA1: 
  RSASSA_PSS MGF1wSHA1 SHA1octets 20 "PKCS1_RSAEP n1024 e1024" "PKCS1_RSADP n1024 d1024" n1024
  defines ModSize1024SHA1_PKCS1_RSASSA_PSS_Sign            = "RSASSA_PSS_ModSize1024SHA1.PKCS1_RSASSA_PSS_Sign"
  and     ModSize1024SHA1_PKCS1_RSASSA_PSS_Sign_inputValid = "RSASSA_PSS_ModSize1024SHA1.PKCS1_RSASSA_PSS_Sign_inputValid"
  and     ModSize1024SHA1_k                                = "RSASSA_PSS_ModSize1024SHA1.k"
  and     ModSize1024SHA1_modBits                          = "RSASSA_PSS_ModSize1024SHA1.modBits"
  and     ModSize1024SHA1_PKCS1_RSASSA_PSS_Verify          = "RSASSA_PSS_ModSize1024SHA1.PKCS1_RSASSA_PSS_Verify"
proof - 
  have A: "EMSA_PSS MGF1wSHA1 SHA1octets 20" by (simp add: EMSA_PSS_SHA1.EMSA_PSS_axioms) 
  have 5: "0 < n1024"                        using zero_less_numeral n1024_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n1024 e1024 m < n1024"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n1024 d1024 c < n1024" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n1024. PKCS1_RSADP n1024 d1024 (PKCS1_RSAEP n1024 e1024 m) = m"
    using PKCS1_RSAEP_messageValid_def RSAEP_RSADP validPrivateKey1024 by presburger 
  have 9: "\<forall>c<n1024. PKCS1_RSAEP n1024 e1024 (PKCS1_RSADP n1024 d1024 c) = c"
    using PKCS1_RSAEP_messageValid_def RSADP_RSAEP validPrivateKey1024 by presburger 
  have B: "RSASSA_PSS_axioms (PKCS1_RSAEP n1024 e1024) (PKCS1_RSADP n1024 d1024) n1024" 
    using 5 6 7 8 9 by (simp add: RSASSA_PSS_axioms.intro) 
  show "RSASSA_PSS MGF1wSHA1 SHA1octets 20 (PKCS1_RSAEP n1024 e1024) (PKCS1_RSADP n1024 d1024) n1024" 
    using A B by (simp add: RSASSA_PSS.intro) 
qed

definition ModSize1024SHA1_Msg0 :: octets where
  "ModSize1024SHA1_Msg0 = nat_to_octets 0xa4ceb81c341237facdf5c8dab1f5fdd725985939df0b623cbb08f714affce42d016ab4b7b78ac7625037a466b1088fc762bc5fd7fadb8afcd89a82b314ff44d5b5472d1a258510dbe28b871c750d86c9a8043640f451001039a3e700b29a1c54272dcc4b64493decebba1902e64f0a665f39867cb3b5ed0044ebd1036f159430"

definition ModSize1024SHA1_S0 :: octets where
  "ModSize1024SHA1_S0 = nat_to_octets 0xc12ad0a80b116cd65a8c81aadd81f05bde5d6adc60e4deffa3d7c68ed8df5314c98b70979c4ce5f9e1c3f0e52fab15725c4f22dc0c4b182a1d7cd81dc24f54e768dd2518a6cee3952922e653b8feaa32745f92ea01907aa4ff2c5f64ed9bad461e2825eafdc31158fafd38afb39fa10f5f833faca076c8771cabe406be6df648"

definition ModSize1024SHA1_SaltVal :: octets where
  "ModSize1024SHA1_SaltVal = nat_to_octets 0x2393183e18581e6924cd38f24192d1acc145633a"

text \<open>Reminder: this is a failure case.  The verification method should return false.\<close>
lemma ModSize1024SHA1_TestVector0:
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Sign ModSize1024SHA1_Msg0 ModSize1024SHA1_SaltVal 
         \<noteq> ModSize1024SHA1_S0"
  by eval

lemma ModSize1024SHA1_TestVector0':
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Verify ModSize1024SHA1_Msg0 ModSize1024SHA1_S0 20 = False"
  by eval

definition ModSize1024SHA1_Msg1 :: octets where
  "ModSize1024SHA1_Msg1 = nat_to_octets 0xada7d6e417da2c55aba768f60df46b73496cc07866c7d2193f4c5c728e94228a4a90df7e33ce7edbabf78c4bc79dee74a633cf1d015ddd92046bb54a5c1f9bc892b76fbf9727dc79a0a7d379336d386082bcdb0df91da90813ed2421711710542d236ff06c70b0f932bd24ca7beeb1fe870dca9175909e4313da903df504e8f7"

definition ModSize1024SHA1_S1 :: octets where
  "ModSize1024SHA1_S1 = nat_to_octets 0xdd45ac85aa560159b2b9890cd61b8c082bb02b55529afec05e7f3fc1d73e30a09e0a7a422c20c074bd25c1271924a94d7576d99125d9200e0190979dd4238db8bdd286eba5d3e46a48fa2b18e43d7926aca3312eaa93970797c20c7e12a64c47858d1deabe5260620f01ee528d63e073f90f5044ea92804f3c1500cc2b958289"

text \<open>Reminder: this is a failure case.  The verification method should return false.\<close>
lemma ModSize1024SHA1_TestVector1:
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Sign ModSize1024SHA1_Msg1 ModSize1024SHA1_SaltVal 
         \<noteq> ModSize1024SHA1_S1"
  by eval

lemma ModSize1024SHA1_TestVector1':
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Verify ModSize1024SHA1_Msg1 ModSize1024SHA1_S1 20 = False"
  by eval

definition ModSize1024SHA1_Msg2 :: octets where
  "ModSize1024SHA1_Msg2 = nat_to_octets 0xa4daf4621676917e28493a585d9baffca3755e77e1f18e3ccfb3dec60ab8ee7e684f5cde8864f2d7ae041d70ce1ea1b1e7878cbf93416848dbfdb5214fde972e5780cb83c439dfc8aa9fa3e2724adbd02bdb36d2213c84d1b12a23fb5bf1baae19772a97ef7cc21bc420b3f570a6c321167745f9b46a489ff8420f9a5679c1c4"

definition ModSize1024SHA1_S2 :: octets where
  "ModSize1024SHA1_S2 = nat_to_octets 0x319c62984acd52423e59a17d27d4eca7722703b054a71a1ee5f7a218b6f4a274632eaf8ef2a577a7e8a7f654b8deb1ec9b1e529cf93459cc8af4c6df6fffabc3edded0c421604ea2aae35836b05fd9de7abd78540d45fd6d0ea714733a3427b00d9d6404db8ede4a27932b47d88243eefcbffe1e55841823def30c57de7562cf"

text \<open>Note: this is a passing case.  The verification method should return true.\<close>
lemma ModSize1024SHA1_TestVector2:
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Sign ModSize1024SHA1_Msg2 ModSize1024SHA1_SaltVal 
         = ModSize1024SHA1_S2"
  by eval

lemma ModSize1024SHA1_TestVector2':
  "ModSize1024SHA1_PKCS1_RSASSA_PSS_Verify ModSize1024SHA1_Msg2 ModSize1024SHA1_S2 20 = True"
  by eval

subsection \<open>RSASSA v1.5\<close>
text \<open>At this point we have exercised a lot of our HOL translations of PKCS #1 v2.2 and 
FIPS 180-4.  Of course, we ran test vectors for the SHA standard in FIPS180_4_TestVectors.thy.
But above we have exercised the PKCS #1 v2.2 definition of MGF1 with all of the SHAs in
FIPS 180-4.  Here we want just a few test vectors to exercise the definitions of the EMSA v1.5
encoding method and the RSASSA v1.5 signature scheme that uses the v1.5 encoding method.  We
will use both passing and failing test vectors.\<close>

subsubsection \<open>Failure Cases\<close>
text \<open>These test vectors are found in SigVer15_186-3.rsp, which is included in the zip file 
linked at the top of this theory. We run two failing and one passing case.  Because d is not
provided, we can only run the signature verification routine.\<close>


definition n1024v :: nat where
  "n1024v = 0xdd07f43534adefb5407cc163aacc7abe9f93cb749643eaec22a3ef16e77813d77df20e84a755088872fde21d3d3192f9a78d726ef3d0daa9d6bc19daf6822eb834fbf837ed03d0f84a7fc7709be382e880e77ba3ce3d91ca1cbf567fc2e62169843489188a128ec853079e7942e6590508ea2faab1cf87b860b21b9546442455"

definition e1024v :: nat where
  "e1024v = 0xfe3fa1"

text \<open>We are not given d, p, or q for the pair (n,e).  We don't need those values to verify the
given signature matches (or doesn't) the message.  Without d we cannot sign a message.\<close>

definition d1024v :: nat where
  "d1024v = 0"

definition p1024v :: nat where
  "p1024v = 0"

definition q1024v :: nat where
  "q1024v = 0"

axiomatization where 
  validPrivateKey1024v: "PKCS1_validRSAprivateKey n1024v d1024v p1024v q1024v e1024v"

global_interpretation RSASSA_v1_5_ModSize1024SHA1: 
  RSASSA_v1_5 SHA1octets 20 "PKCS1_AlgorithmID tSHA1" "PKCS1_RSAEP n1024v e1024v" "PKCS1_RSADP n1024v d1024v" n1024v
  defines ModSize1024SHA1_PKCS1_RSASSA_v1_5_Sign   = "RSASSA_v1_5_ModSize1024SHA1.PKCS1_RSASSA_v1_5_Sign"
  and     ModSize1024SHA1_PKCS1_RSASSA_v1_5_Verify = "RSASSA_v1_5_ModSize1024SHA1.PKCS1_RSASSA_v1_5_Verify"
  and     ModSize1024SHA1_v1_5_k                   = "RSASSA_v1_5_ModSize1024SHA1.k"
proof - 
  have A: "EMSA_v1_5 SHA1octets 20 (PKCS1_AlgorithmID tSHA1)" using EMSA_v1_5_SHA1.EMSA_v1_5_axioms by blast 
  have 5: "0 < n1024v"                               using zero_less_numeral n1024v_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n1024v e1024v m < n1024v" by (simp add: 5 PKCS1_RSAEP_def)
  have 7: "\<forall>c. PKCS1_RSADP n1024v d1024v c < n1024v" by (simp add: 5 PKCS1_RSAEP_def)
  have 8: "\<forall>m<n1024v. PKCS1_RSADP n1024v d1024v (PKCS1_RSAEP n1024v e1024v m) = m"
    using PKCS1_RSAEP_messageValid_def RSAEP_RSADP validPrivateKey1024v by presburger 
  have 9: "\<forall>c<n1024v. PKCS1_RSAEP n1024v e1024v (PKCS1_RSADP n1024v d1024v c) = c"
    using PKCS1_RSAEP_messageValid_def RSADP_RSAEP validPrivateKey1024v by presburger 
  have B: "RSASSA_v1_5_axioms (PKCS1_RSAEP n1024v e1024v) (PKCS1_RSADP n1024v d1024v) n1024v" 
    using 5 6 7 8 9 by (simp add: RSASSA_v1_5_axioms.intro) 
  show "RSASSA_v1_5 SHA1octets 20 (PKCS1_AlgorithmID tSHA1) (PKCS1_RSAEP n1024v e1024v) (PKCS1_RSADP n1024v d1024v) n1024v"
    using A B by (simp add: RSASSA_v1_5.intro) 
qed

definition ModSize1024SHA1v_Msg0 :: octets where
  "ModSize1024SHA1v_Msg0 = nat_to_octets 0x98245960c6d4da684d9da2e78cf59d2a63ca53ac39740c9f44e837c9042e0c911115715a17251a0f1fd5f5ff10fec5ec75900c5e80842f3d4f11d59f6f2390df9f09bfefd66db3ef878a10fe23997650e08c6180b9ff4e28b56c20b06d9ec163c8680cc80a96eb2f0d24bc8acdaefa7e2b2819baeacfb188fe5fdfa10687e946"

definition ModSize1024SHA1v_S0 :: octets where
  "ModSize1024SHA1v_S0 = nat_to_octets 0x1ea751e8c5329879a9003f529eba19514c153ee0bdd8caac9c94fbbf95a41ebdb9ad54a976bc1218a94b53e69cf3362b0472a8781b8df4af3e9aa584099c71f9622a6fcc3fd3935b033f68c1c970676eb6d2184056f1b524acec26c51df6dbe9bf3b4e1fc144b8edf563a03f28ad78d457485b4a57ed0ce81e409245f5ce1014"

text \<open>Reminder: this is a failure case.  The verification method should return false.\<close>
lemma ModSize1024SHA1v_TestVector0':
  "ModSize1024SHA1_PKCS1_RSASSA_v1_5_Verify ModSize1024SHA1v_Msg0 ModSize1024SHA1v_S0 = False"
  by eval

definition ModSize1024SHA1v_Msg1 :: octets where
  "ModSize1024SHA1v_Msg1 = nat_to_octets 0xd7eabc57c2803382d1deb56a146767ac80c89183382e01990bb5aa1d3d2391168ad6eaf768fb7d738d014f92b14d7f0595306eb7441622a49800edee0134492d82320707fceba902af2e0c95fe634a85727bde6f022709a09248752db9a71941c7e75cb107b87dd6414d329b830f8fd521932ad3fbc97d36fe778b03eee6c7f7"

definition ModSize1024SHA1v_S1 :: octets where
  "ModSize1024SHA1v_S1 = nat_to_octets 0x9dac630d264a6a53cb81a6901ac0baabfb24d73b60ad3a4ed3a0eb98a2118a573c3cfe294178fbee63da7c27c5826fa5e6d1682eb254da53a961ba4473672f57a27aec22d4b205f79819ab4cb18b0f3842684bbdeca71cfcbc30d1866d22c9f1fa9dbe9e1a2f5f6f68fd4fff6909fd2c1a9904204a3cfa30da4c87de35a769a9"

text \<open>Reminder: this is a failure case.  The verification method should return false.\<close>
lemma ModSize1024SHA1v_TestVector1':
  "ModSize1024SHA1_PKCS1_RSASSA_v1_5_Verify ModSize1024SHA1v_Msg1 ModSize1024SHA1v_S1 = False"
  by eval

definition ModSize1024SHA1v_Msg2 :: octets where
  "ModSize1024SHA1v_Msg2 = nat_to_octets 0x73ef115a1dec6d91e1aa51c5e11708ead45b2419fb0313d9565ff39e1928a78f5a662b8c0c91247030f7bc934a5dac9412e99a556d40a6469beb40e7b2ff3c884bfd28537bf7dd8d05f45419cd96bb3e90fac8aad3e04eb6190c0eeb59eccfc5af7ab1b85264be71c66ac25e53085c70b5565620152c32b0388905b3f73689cf"

definition ModSize1024SHA1v_S2 :: octets where
  "ModSize1024SHA1v_S2 = nat_to_octets 0x25493b7d70cc07e9269a248632c2c89c8514fe8298ed84319ec664f01db980e24bbb59eea5867316792fec36cbe9ee9d3c69346b992377f35c08d19de0d6dd37482074cf5d3c5cd2b54d09a3ed296187f4ee5b30926a7aa794c88a2c0f9d09f721436e5a9bd4fef62e20e43095faee7f5f1e6ce87705c27aa5cdb08d50bd2cf0"

text \<open>Note: this is a passing case.  The verification method should return true.\<close>
lemma ModSize1024SHA1v_TestVector2':
  "ModSize1024SHA1_PKCS1_RSASSA_v1_5_Verify ModSize1024SHA1v_Msg2 ModSize1024SHA1v_S2 = True"
  by eval

subsubsection \<open>Check Signature Generation\<close>
text \<open>In the Failure Cases subsubsection above, d was not given so we could not test our signature
generation method for RSASSA v1.5.  Here we run some test vectors found in SigGen15_186-3.txt 
to exercise our signature generation definition.  Specifically we run the first 5 test vectors
given for the modulus of size 2048 using the encoding with SHA-224.\<close>

definition n2048v :: nat where
  "n2048v = 0xcea80475324c1dc8347827818da58bac069d3419c614a6ea1ac6a3b510dcd72cc516954905e9fef908d45e13006adf27d467a7d83c111d1a5df15ef293771aefb920032a5bb989f8e4f5e1b05093d3f130f984c07a772a3683f4dc6fb28a96815b32123ccdd13954f19d5b8b24a103e771a34c328755c65ed64e1924ffd04d30b2142cc262f6e0048fef6dbc652f21479ea1c4b1d66d28f4d46ef7185e390cbfa2e02380582f3188bb94ebbf05d31487a09aff01fcbb4cd4bfd1f0a833b38c11813c84360bb53c7d4481031c40bad8713bb6b835cb08098ed15ba31ee4ba728a8c8e10f7294e1b4163b7aee57277bfd881a6f9d43e02c6925aa3a043fb7fb78d"

definition e2048v :: nat where
  "e2048v = 0x260445"

definition d2048v :: nat where
  "d2048v = 0x0997634c477c1a039d44c810b2aaa3c7862b0b88d3708272e1e15f66fc9389709f8a11f3ea6a5af7effa2d01c189c50f0d5bcbe3fa272e56cfc4a4e1d388a9dcd65df8628902556c8b6bb6a641709b5a35dd2622c73d4640bfa1359d0e76e1f219f8e33eb9bd0b59ec198eb2fccaae0346bd8b401e12e3c67cb629569c185a2e0f35a2f741644c1cca5ebb139d77a89a2953fc5e30048c0e619f07c8d21d1e56b8af07193d0fdf3f49cd49f2ef3138b5138862f1470bd2d16e34a2b9e7777a6c8c8d4cb94b4e8b5d616cd5393753e7b0f31cc7da559ba8e98d888914e334773baf498ad88d9631eb5fe32e53a4145bf0ba548bf2b0a50c63f67b14e398a34b0d"

definition p2048v :: nat where
  "p2048v = 0"

definition q2048v :: nat where
  "q2048v = 0"

axiomatization where 
  validPrivateKey2048v: "PKCS1_validRSAprivateKey n2048v d2048v p2048v q2048v e2048v"


global_interpretation RSASSA_v1_5_ModSize2048SHA224: 
  RSASSA_v1_5 SHA224octets 28 "PKCS1_AlgorithmID tSHA224" "PKCS1_RSAEP n2048v e2048v" "PKCS1_RSADP n2048v d2048v" n2048v
  defines ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign   = "RSASSA_v1_5_ModSize2048SHA224.PKCS1_RSASSA_v1_5_Sign"
  and     ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify = "RSASSA_v1_5_ModSize2048SHA224.PKCS1_RSASSA_v1_5_Verify"
  and     ModSize2048SHA224_v1_5_k                   = "RSASSA_v1_5_ModSize2048SHA224.k"
proof - 
  have A: "EMSA_v1_5 SHA224octets 28 (PKCS1_AlgorithmID tSHA224)" using EMSA_v1_5_SHA224.EMSA_v1_5_axioms by blast 
  have 5: "0 < n2048v"                               using zero_less_numeral n2048v_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n2048v e2048v m < n2048v" by (simp add: 5 PKCS1_RSAEP_def)
  have 7: "\<forall>c. PKCS1_RSADP n2048v d2048v c < n2048v" by (simp add: 5 PKCS1_RSAEP_def)
  have 8: "\<forall>m<n2048v. PKCS1_RSADP n2048v d2048v (PKCS1_RSAEP n2048v e2048v m) = m"
    using PKCS1_RSAEP_messageValid_def RSAEP_RSADP validPrivateKey2048v by presburger 
  have 9: "\<forall>c<n2048v. PKCS1_RSAEP n2048v e2048v (PKCS1_RSADP n2048v d2048v c) = c"
    using PKCS1_RSAEP_messageValid_def RSADP_RSAEP validPrivateKey2048v by presburger 
  have B: "RSASSA_v1_5_axioms (PKCS1_RSAEP n2048v e2048v) (PKCS1_RSADP n2048v d2048v) n2048v" 
    using 5 6 7 8 9 by (simp add: RSASSA_v1_5_axioms.intro) 
  show "RSASSA_v1_5 SHA224octets 28 (PKCS1_AlgorithmID tSHA224) (PKCS1_RSAEP n2048v e2048v) (PKCS1_RSADP n2048v d2048v) n2048v"
    using A B by (simp add: RSASSA_v1_5.intro) 
qed

definition ModSize2048SHA224v_Msg0 :: octets where
  "ModSize2048SHA224v_Msg0 = nat_to_octets 0x74230447bcd492f2f8a8c594a04379271690bf0c8a13ddfc1b7b96413e77ab2664cba1acd7a3c57ee5276e27414f8283a6f93b73bd392bd541f07eb461a080bb667e5ff095c9319f575b3893977e658c6c001ceef88a37b7902d4db31c3e34f3c164c47bbeefde3b946bad416a752c2cafcee9e401ae08884e5b8aa839f9d0b5"

definition ModSize2048SHA224v_S0 :: octets where
  "ModSize2048SHA224v_S0 = nat_to_octets 0x27da4104eace1991e08bd8e7cfccd97ec48b896a0e156ce7bdc23fd570aaa9a00ed015101f0c6261c7371ceca327a73c3cecfcf6b2d9ed920c9698046e25c89adb2360887d99983bf632f9e6eb0e5df60715902b9aeaa74bf5027aa246510891c74ae366a16f397e2c8ccdc8bd56aa10e0d01585e69f8c4856e76b53acfd3d782b8171529008fa5eff030f46956704a3f5d9167348f37021fc277c6c0a8f93b8a23cfbf918990f982a56d0ed2aa08161560755adc0ce2c3e2ab2929f79bfc0b24ff3e0ff352e6445d8a617f1785d66c32295bb365d61cfb107e9993bbd93421f2d344a86e4127827fa0d0b2535f9b1d547de12ba2868acdecf2cb5f92a6a159a"

lemma ModSize2048SHA224v_TestVector0:
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign ModSize2048SHA224v_Msg0 = ModSize2048SHA224v_S0"
  by eval

lemma ModSize2048SHA224v_TestVector0':
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify ModSize2048SHA224v_Msg0 ModSize2048SHA224v_S0"
  by eval

definition ModSize2048SHA224v_Msg1 :: octets where
  "ModSize2048SHA224v_Msg1 = nat_to_octets 0x9af2c5a919e5dadc668799f365fc23da6231437ea51ca5314645425043851f23d00d3704eeabb5c43f49674a19b7707dd9aa3d657a04ba8c6655c5ab8ba2e382b26631080cd79ec40e6a587b7f99840bd0e43297ab1690e4cec95d031a2ca131e7049cfb9bf1fca67bf353cdc12cc74ceee80c5d61da8f0129a8f4a218abc3f6"

definition ModSize2048SHA224v_S1 :: octets where
  "ModSize2048SHA224v_S1 = nat_to_octets 0xc5dfbefd35cec846e2c7b2434dc9c46a5a9b1b6ce65b2b18665aedb1404de1f466e024f849eec308c2d2f2f0193df1898a581c9ea32581185553b171b6507082617c5c018afe0c3af64d2ec5a563795aa585e77753cd18836f6f0c29535f6200ca899928fe78e949b0a216ec47a6adf2223e17236cfc167cf00ed6136f03cf6ffd4f3f7787aeb005840978d8d6ba593d4f4cfe6920be102b9847d10140dff86b0db14ffccc9a96e673c672c1128ae45489d2cbfe6e195ca5206eda519cad3d6e0abf4653e36b5a264e87494a4d63ee91ff7c35a6ab12adfa3bb537f6198b06f5de0717076b0ec83ae0da9ea419cc0c96669d1d7c9e529271428401e09e04888a"

lemma ModSize2048SHA224v_TestVector1:
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign ModSize2048SHA224v_Msg1 = ModSize2048SHA224v_S1"
  by eval

lemma ModSize2048SHA224v_TestVector1':
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify ModSize2048SHA224v_Msg1 ModSize2048SHA224v_S1"
  by eval

definition ModSize2048SHA224v_Msg2 :: octets where
  "ModSize2048SHA224v_Msg2 = nat_to_octets 0x59b5b85b9dc246d30a3fc8a2de3c9dfa971643b0c1f7c9e40c9c87e4a15b0c4eb664587560474c06a9b65eece38c91703c0fa5a592728a03889f1b52d93309caecc91578a97b83e38ca6cbf0f7ee9103cd82d7673ca172f0da5ebadef4a08605226c582b1f67d4b2d8967777c36985f972f843be688c67f22b61cd529baa6b48"

definition ModSize2048SHA224v_S2 :: octets where
  "ModSize2048SHA224v_S2 = nat_to_octets 0x29b5ac417226444bc8570a279e0e561a4c39707bdbea936064ed603ba96889eb3d786b1999b5180cd5d0611788837a9df1496bacea31cbf8f24a1a2232d4158913c963f5066aad4b65e617d0903359696d759d84c1392e22c246d5f5bed4b806f4091d5e8f71a513f1319bb4e56971cd3e168c9a7e2789832293991a73d3027072ecee6863514549029fb3553478c8f4103bf62d7de1fb53fe76ce9778ada3bb9efa62da44cd00d02bb0eb7488ac24da3814c653cba612301373837a0c3f11885493cbf3024c3572eaed396d0ebb8039ddf843c218d8bc7783549046c33586fb3428562cb8046090040c0e4eea50a19a428bde34626277ff48a84faa189b5440"

lemma ModSize2048SHA224v_TestVector2:
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign ModSize2048SHA224v_Msg2 = ModSize2048SHA224v_S2"
  by eval

lemma ModSize2048SHA224v_TestVector2':
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify ModSize2048SHA224v_Msg2 ModSize2048SHA224v_S2"
  by eval

definition ModSize2048SHA224v_Msg3 :: octets where
  "ModSize2048SHA224v_Msg3 = nat_to_octets 0x49a5f3930ad45aca5e22caac6646f0bede1228838d49f8f2e0b2dd27d26a4b590e7eef0c58b9378829bb1489994bff3882ef3a5ae3b958c88263ff1fd69fedb823a839dbe71ddb2f750f6f75e05936761a2f5e3a5dfa837bca63755951ae3c50d04a59667fa64fa98b4662d801159f61eefd1c8bc5b581f500dac73f0a424007"

definition ModSize2048SHA224v_S3 :: octets where
  "ModSize2048SHA224v_S3 = nat_to_octets 0x604eb637ca54bea5ad1fd3165911f3baa2e06c859dc73945a38bca7ff9bfa9ed39435348623d3e60f1ce487443840c6b2c000f1582e8526067a5e8923f1a1bdaabb1a40c0f49ee6906a4c8fc9b8cfa6d07c2cc5bdf2ada65c53d79548089c524fa364319a90d46213febdce6db795914cbda04d7bbbf26bbb299fc7d1449dcc81d139e3c33d4c1de96473994730a4b639633d677db25695ffd157e591bddead03dd2f1c1b8f5c8a213b785879bf7c9a992bb11dd5e91df3aff0931ca76c406230a19e307f33419c9d9d3f6f64bf8881c0ddf74a5716cbc433329368d6e55f1f751d7b9f9b0a26eb5811772f5f698530efc1eaceee6e1dc6839b2133c2fccfa8c"

lemma ModSize2048SHA224v_TestVector3:
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign ModSize2048SHA224v_Msg3 = ModSize2048SHA224v_S3"
  by eval

lemma ModSize2048SHA224v_TestVector3':
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify ModSize2048SHA224v_Msg3 ModSize2048SHA224v_S3"
  by eval

definition ModSize2048SHA224v_Msg4 :: octets where
  "ModSize2048SHA224v_Msg4 = nat_to_octets 0x9bfc4dac8c2232387216a532ce62d98c1aafa35c65dc388e3d4d37d6d186eae957f8c9edac1a3f2e3abcb1121f99bd4f8c2bbf5b6ac39a2544d8b502619f43ea30ddc8e4eafad8bf7256220380e0ae27fee46304b224cc8a1e2b1cb2a4de6fb3ee5452798de78653e08b01ec385f367c3982963f8428572793ed74cee369f5ae"

definition ModSize2048SHA224v_S4 :: octets where
  "ModSize2048SHA224v_S4 = nat_to_octets 0x444f7efbfef586fad431e17fea1a2d59f19b3d619bb6fa3664301833a4db1243459e31aa6a703b22572f0912754e56f7231a55ac7abca514c79d9fb3564214b4af835d7d1eaf2b58ceb6a344f1c36890f5e83b50188c0147d6d1156da289ccf4bdb0b9a66f1e4a1f2643591d5ffb53702cf70ddf351592575488f1929010aca37714b234eeb5b952b9323ae26533e9ecd516df26392d1254228bd9ca21a369bb6ab0a33d5eb44cee92b0ea7471ffe5fa43c21de2a8975d4c5c8e185fcb7aab33d88a8365ddf0119c108803c56288643a056e781abd4a0242a92e2529d405efcfd4248662cfbb332d6e6fad6aceb90b5b58a5541abe07bef25d9d89215e398426"

lemma ModSize2048SHA224v_TestVector4:
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Sign ModSize2048SHA224v_Msg4 = ModSize2048SHA224v_S4"
  by eval

lemma ModSize2048SHA224v_TestVector4':
  "ModSize2048SHA224_PKCS1_RSASSA_v1_5_Verify ModSize2048SHA224v_Msg4 ModSize2048SHA224v_S4"
  by eval

section \<open>Wycheproof Test Vectors\<close>

text \<open>
https://github.com/google/wycheproof

"Project Wycheproof tests crypto libraries against known attacks. It is developed and maintained
by members of Google Security Team, but it is not an official Google product. ... 
Project Wycheproof provides tests for most cryptographic algorithms, including RSA, elliptic curve
crypto and authenticated encryption." 

We use test vectors here for parts of the PKCS #1 standard that were not covered by the FIPS 186
test vectors.  The only remaining parts of the standard to check are the encryption schemes found
in section 7 of PKCS #1 v2.2.\<close>

subsection \<open>RSAES-OAEP\<close>

text \<open>
https://github.com/google/wycheproof/blob/master/testvectors/rsa_oaep_2048_sha224_mgf1sha1_test.json

  "algorithm" : "RSAES-OAEP",
  "generatorVersion" : "0.8r12",
  "numberOfTests" : 29,
  "header" : [
    "Test vectors of type RsaOeapDecrypt are intended to check the decryption",
    "of RSA encrypted ciphertexts."
  ]
  "testGroups" : [
    {
      "d" : "56d0756ceddf7b1e5b258f783b99e036e25675eca054ae9b6ed7552776c69b2728f76e08973556b0a35ddbade9d462ed12bfc46fd254a07ef4ee043ab24d1ef00f8d214cd1d906911e92c4a212d9a981da74b8d18208153d583035d6642b87a23371787867efd02c336eab01486266c853a052490deaea430c6043a6b240b6e9d71e16f29255f2ceeb35d1a4ae25ae0dc9a436fb5dc30381cce982acc824961976df683173a02a540c403f3c8560243ceb5b798abcdc20f3c85d9532b0f0b0826f1b6352c5adac757fe3224b822455cc529fcdc8a220b0469f321f56bd1853d8a70b893f404cc06317e084173770c7d4c836281ac251353fcee4ac393838a1a1",
      "e" : "010001",
      "keysize" : 2048,
      "mgf" : "MGF1",
      "mgfSha" : "SHA-1",
      "n" : "00c32cd0e1441fde8a2896ca3a133735be2d1010777cfc739afc77b6daa66f367d4876dccb3021fc22c25450a68d6cfb1191d485cbfba5ec45b49286d7cae2bdae553f47e10b94f867abcc6d0affc733bacc725e5ab4de1aba19a39d748b4c1355d5a6a710a52bd04c0c24e7bc3bdab8f3ce3ae86ecb31c4b45e10b40ddb5fdd40cb2411bcf5b1d392e1eef959cff2709a6e02b20ff3b4343641a6b78599586edc9b673d9f3f5e9d339ceebf96a1a31655876c39fcb00b1c3e571908c9b744765047abb5c23ecc42e551e13755e38cc9a13e1e02bcd5dcec9c301fab75be3e1a8ee9c42981607aba7855f4bbe76c8c160e80468b54bdf9f438b177c33dee30b0f5",
      "privateKeyPem" : "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAwyzQ4UQf3ooolso6Ezc1vi0QEHd8/HOa/He22qZvNn1IdtzL\nMCH8IsJUUKaNbPsRkdSFy/ul7EW0kobXyuK9rlU/R+ELlPhnq8xtCv/HM7rMcl5a\ntN4auhmjnXSLTBNV1aanEKUr0EwMJOe8O9q488466G7LMcS0XhC0Ddtf3UDLJBG8\n9bHTkuHu+VnP8nCabgKyD/O0NDZBpreFmVhu3JtnPZ8/Xp0znO6/lqGjFlWHbDn8\nsAscPlcZCMm3RHZQR6u1wj7MQuVR4TdV44zJoT4eArzV3OycMB+rdb4+Go7pxCmB\nYHq6eFX0u+dsjBYOgEaLVL359Dixd8M97jCw9QIDAQABAoIBAFbQdWzt33seWyWP\neDuZ4DbiVnXsoFSum27XVSd2xpsnKPduCJc1VrCjXdut6dRi7RK/xG/SVKB+9O4E\nOrJNHvAPjSFM0dkGkR6SxKIS2amB2nS40YIIFT1YMDXWZCuHojNxeHhn79AsM26r\nAUhiZshToFJJDerqQwxgQ6ayQLbp1x4W8pJV8s7rNdGkriWuDcmkNvtdwwOBzOmC\nrMgklhl232gxc6AqVAxAPzyFYCQ861t5irzcIPPIXZUysPCwgm8bY1LFrax1f+Mi\nS4IkVcxSn83IoiCwRp8yH1a9GFPYpwuJP0BMwGMX4IQXN3DH1Mg2KBrCUTU/zuSs\nOTg4oaECgYEA6mAQoAF9QHMZhhDQ52HyhuOhEz7u1xtP1N+w2LUuHh2P/FjZwQOW\nYplS6wAjabIrucMxPIAzDB86t6P8+ND79aHA+3k27yDVE3OyG+py/Lf3AnWsQdl7\nVmtx9yejLwAG3hXn+bzPzDIkEG9rGuYtWTgAZaSO970BXubauuD514kCgYEA1S7Y\nCNdKebOrUVtPL+e0ECdHLDeF6yVYeuMdNQC/PG7yDEJ+Ij76TykRzTjPxEefKK5J\nX+PojpTCNsC8EyPXECeropBmn/vX4Pu29hXfHJ5P5au1qQ1NC20d6grisknmpRAg\nksmYtg3ZINCaLm7PKmEXkwFrwMkt47nZJ0S8Bw0CgYEAy2T2yITCV64LVmc9g69i\ns2DTpkoVJ6PSEeDWLhp9nTD2hX3t6yzb01FPvhTupokynREhp2lx43EumbO8k4l5\nPt9TBGlbHQaXIzxiMwuxIlPcDsxj4vmDqamwy1YgrWcOjqjgGcCbbI+O8JxgjIV4\nkVaiMZMvZxslF2CsLUWUTFECgYEAtha+/D44JN+sU190sextRublygTa5FEP1Fct\nWVp7/fid0o7xAftc/kSMKgh+np62eZ70mW0n9LFnejEB9C9GwUvBNKe2oKwSZt9a\nFbP00JMAl6IlFnJ//mSDiqclnze0RAUUbYy4XbhSX88OAt8vIHmyEyTBjvfHtJ3H\nt9zj5fkCgYBA+9ouVxBglxzGrqDBzIK+q0+gNh3kOlW9KzmfJe2J4zxImD9AnZ8n\nKSdw1cCsGzGt92YEXmDWe4mVfIHA87dwbD4UGJJr/sugJCulTtla4bxztn3bHj9B\nYTgMu/HbfT2++FLrs4BjvCVEycKfR/QW8U6x6jzyurkz0hwsCRKTzg==\n-----END RSA PRIVATE KEY-----",
      "privateKeyPkcs8" : "308204be020100300d06092a864886f70d0101010500048204a8308204a40201000282010100c32cd0e1441fde8a2896ca3a133735be2d1010777cfc739afc77b6daa66f367d4876dccb3021fc22c25450a68d6cfb1191d485cbfba5ec45b49286d7cae2bdae553f47e10b94f867abcc6d0affc733bacc725e5ab4de1aba19a39d748b4c1355d5a6a710a52bd04c0c24e7bc3bdab8f3ce3ae86ecb31c4b45e10b40ddb5fdd40cb2411bcf5b1d392e1eef959cff2709a6e02b20ff3b4343641a6b78599586edc9b673d9f3f5e9d339ceebf96a1a31655876c39fcb00b1c3e571908c9b744765047abb5c23ecc42e551e13755e38cc9a13e1e02bcd5dcec9c301fab75be3e1a8ee9c42981607aba7855f4bbe76c8c160e80468b54bdf9f438b177c33dee30b0f502030100010282010056d0756ceddf7b1e5b258f783b99e036e25675eca054ae9b6ed7552776c69b2728f76e08973556b0a35ddbade9d462ed12bfc46fd254a07ef4ee043ab24d1ef00f8d214cd1d906911e92c4a212d9a981da74b8d18208153d583035d6642b87a23371787867efd02c336eab01486266c853a052490deaea430c6043a6b240b6e9d71e16f29255f2ceeb35d1a4ae25ae0dc9a436fb5dc30381cce982acc824961976df683173a02a540c403f3c8560243ceb5b798abcdc20f3c85d9532b0f0b0826f1b6352c5adac757fe3224b822455cc529fcdc8a220b0469f321f56bd1853d8a70b893f404cc06317e084173770c7d4c836281ac251353fcee4ac393838a1a102818100ea6010a0017d4073198610d0e761f286e3a1133eeed71b4fd4dfb0d8b52e1e1d8ffc58d9c10396629952eb002369b22bb9c3313c80330c1f3ab7a3fcf8d0fbf5a1c0fb7936ef20d51373b21bea72fcb7f70275ac41d97b566b71f727a32f0006de15e7f9bccfcc3224106f6b1ae62d59380065a48ef7bd015ee6dabae0f9d78902818100d52ed808d74a79b3ab515b4f2fe7b41027472c3785eb25587ae31d3500bf3c6ef20c427e223efa4f2911cd38cfc4479f28ae495fe3e88e94c236c0bc1323d71027aba290669ffbd7e0fbb6f615df1c9e4fe5abb5a90d4d0b6d1dea0ae2b249e6a5102092c998b60dd920d09a2e6ecf2a611793016bc0c92de3b9d92744bc070d02818100cb64f6c884c257ae0b56673d83af62b360d3a64a1527a3d211e0d62e1a7d9d30f6857dedeb2cdbd3514fbe14eea689329d1121a76971e3712e99b3bc9389793edf5304695b1d0697233c62330bb12253dc0ecc63e2f983a9a9b0cb5620ad670e8ea8e019c09b6c8f8ef09c608c85789156a231932f671b251760ac2d45944c5102818100b616befc3e3824dfac535f74b1ec6d46e6e5ca04dae4510fd4572d595a7bfdf89dd28ef101fb5cfe448c2a087e9e9eb6799ef4996d27f4b1677a3101f42f46c14bc134a7b6a0ac1266df5a15b3f4d0930097a22516727ffe64838aa7259f37b44405146d8cb85db8525fcf0e02df2f2079b21324c18ef7c7b49dc7b7dce3e5f902818040fbda2e571060971cc6aea0c1cc82beab4fa0361de43a55bd2b399f25ed89e33c48983f409d9f27292770d5c0ac1b31adf766045e60d67b89957c81c0f3b7706c3e1418926bfecba0242ba54ed95ae1bc73b67ddb1e3f4161380cbbf1db7d3dbef852ebb38063bc2544c9c29f47f416f14eb1ea3cf2bab933d21c2c091293ce",
      "sha" : "SHA-224",
      "type" : "RsaesOaepDecrypt",
\<close>

definition n_wp1 :: nat where
  "n_wp1 = 0x00c32cd0e1441fde8a2896ca3a133735be2d1010777cfc739afc77b6daa66f367d4876dccb3021fc22c25450a68d6cfb1191d485cbfba5ec45b49286d7cae2bdae553f47e10b94f867abcc6d0affc733bacc725e5ab4de1aba19a39d748b4c1355d5a6a710a52bd04c0c24e7bc3bdab8f3ce3ae86ecb31c4b45e10b40ddb5fdd40cb2411bcf5b1d392e1eef959cff2709a6e02b20ff3b4343641a6b78599586edc9b673d9f3f5e9d339ceebf96a1a31655876c39fcb00b1c3e571908c9b744765047abb5c23ecc42e551e13755e38cc9a13e1e02bcd5dcec9c301fab75be3e1a8ee9c42981607aba7855f4bbe76c8c160e80468b54bdf9f438b177c33dee30b0f5"

lemma n_wp1_gr_1: "1 < n_wp1" 
  using n_wp1_def by presburger

definition e_wp1 :: nat where
  "e_wp1 = 0x010001" 

definition d_wp1 :: nat where
  "d_wp1 = 0x56d0756ceddf7b1e5b258f783b99e036e25675eca054ae9b6ed7552776c69b2728f76e08973556b0a35ddbade9d462ed12bfc46fd254a07ef4ee043ab24d1ef00f8d214cd1d906911e92c4a212d9a981da74b8d18208153d583035d6642b87a23371787867efd02c336eab01486266c853a052490deaea430c6043a6b240b6e9d71e16f29255f2ceeb35d1a4ae25ae0dc9a436fb5dc30381cce982acc824961976df683173a02a540c403f3c8560243ceb5b798abcdc20f3c85d9532b0f0b0826f1b6352c5adac757fe3224b822455cc529fcdc8a220b0469f321f56bd1853d8a70b893f404cc06317e084173770c7d4c836281ac251353fcee4ac393838a1a1"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.\<close>
axiomatization where MissingPandQ_wp1: "\<exists>p q. PKCS1_validRSAprivateKey n_wp1 d_wp1 p q e_wp1"

lemma FunctionalInverses1__wp1: "\<forall>m<n_wp1. PKCS1_RSADP n_wp1 d_wp1 (PKCS1_RSAEP n_wp1 e_wp1 m) = m"
  by (meson MissingPandQ_wp1 PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2__wp1: "\<forall>c<n_wp1. PKCS1_RSAEP n_wp1 e_wp1 (PKCS1_RSADP n_wp1 d_wp1 c) = c"
  by (meson MissingPandQ_wp1 PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

global_interpretation OAEP_WP1: 
  OAEP MGF1wSHA1 SHA224octets 28 "PKCS1_RSAEP n_wp1 e_wp1" "PKCS1_RSADP n_wp1 d_wp1" n_wp1
  defines WP1_k                              = "OAEP_WP1.k"
  and     WP1_PKCS1_OAEP_PS                  = "OAEP_WP1.PKCS1_OAEP_PS"
  and     WP1_PKCS1_OAEP_DB                  = "OAEP_WP1.PKCS1_OAEP_DB"
  and     WP1_PKCS1_OAEP_dbMask              = "OAEP_WP1.PKCS1_OAEP_dbMask"
  and     WP1_PKCS1_OAEP_maskedDB            = "OAEP_WP1.PKCS1_OAEP_maskedDB"
  and     WP1_PKCS1_OAEP_seedMask            = "OAEP_WP1.PKCS1_OAEP_seedMask"
  and     WP1_PKCS1_OAEP_maskedSeed          = "OAEP_WP1.PKCS1_OAEP_maskedSeed"
  and     WP1_PKCS1_OAEP_EM                  = "OAEP_WP1.PKCS1_OAEP_EM"
  and     WP1_PKCS1_OAEP_Encrypt_lengthValid = "OAEP_WP1.PKCS1_RSAES_OAEP_Encrypt_lengthValid"
  and     WP1_PKCS1_OAEP_Encrypt             = "OAEP_WP1.PKCS1_RSAES_OAEP_Encrypt"
  and     WP1_PKCS1_OAEP_decode_Y            = "OAEP_WP1.PKCS1_OAEP_decode_Y"
  and     WP1_PKCS1_OAEP_decode_maskedSeed   = "OAEP_WP1.PKCS1_OAEP_decode_maskedSeed"
  and     WP1_PKCS1_OAEP_decode_maskedDB     = "OAEP_WP1.PKCS1_OAEP_decode_maskedDB"
  and     WP1_PKCS1_OAEP_decode_seedMask     = "OAEP_WP1.PKCS1_OAEP_decode_seedMask"
  and     WP1_PKCS1_OAEP_decode_seed         = "OAEP_WP1.PKCS1_OAEP_decode_seed"
  and     WP1_PKCS1_OAEP_decode_dbMask       = "OAEP_WP1.PKCS1_OAEP_decode_dbMask"
  and     WP1_PKCS1_OAEP_decode_DB           = "OAEP_WP1.PKCS1_OAEP_decode_DB"
  and     WP1_PKCS1_OAEP_decode_lHash        = "OAEP_WP1.PKCS1_OAEP_decode_lHash"
  and     WP1_PKCS1_OAEP_decode_validPS      = "OAEP_WP1.PKCS1_OAEP_decode_validPS"
  and     WP1_PKCS1_OAEP_decode_PSlen        = "OAEP_WP1.PKCS1_OAEP_decode_PSlen"
  and     WP1_PKCS1_OAEP_decode_M            = "OAEP_WP1.PKCS1_OAEP_decode_M"
  and     WP1_PKCS1_OAEP_Decrypt_validInput  = "OAEP_WP1.PKCS1_RSAES_OAEP_Decrypt_validInput"
  and     WP1_PKCS1_OAEP_Decrypt             = "OAEP_WP1.PKCS1_RSAES_OAEP_Decrypt"
  and     WP1_PKCS1_OAEP_Decrypt_seed        = "OAEP_WP1.PKCS1_RSAES_OAEP_Decrypt_seed"
  and     WP1_PKCS1_OAEP_Decrypt_lHash       = "OAEP_WP1.PKCS1_RSAES_OAEP_Decrypt_lHash"
  and     WP1_PKCS1_OAEP_Decrypt_validPS     = "OAEP_WP1.PKCS1_RSAES_OAEP_Decrypt_validPS"
proof - 
  have 1: "\<forall>x y. octets_valid (MGF1wSHA1 x y)" using MGF1wSHA1_valid by blast  
  have 2: "\<forall>x y. length (MGF1wSHA1 x y) = y"   using MGF1wSHA1_len by blast   
  have 3: "\<forall>x. octets_valid (SHA224octets x)"  using SHA224octets_valid2 by blast    
  have 4: "\<forall>x. length (SHA224octets x) = 28"   using SHA224octets_len2 by blast 
  have 5: "0 < n_wp1"                          using zero_less_numeral n_wp1_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n_wp1 e_wp1 m < n_wp1"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n_wp1 d_wp1 c < n_wp1" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n_wp1. PKCS1_RSADP n_wp1 d_wp1 (PKCS1_RSAEP n_wp1 e_wp1 m) = m" 
    using FunctionalInverses1__wp1 by blast
  have 9: "\<forall>c<n_wp1. PKCS1_RSAEP n_wp1 e_wp1 (PKCS1_RSADP n_wp1 d_wp1 c) = c" 
    using FunctionalInverses2__wp1 by blast
  show "OAEP MGF1wSHA1 SHA224octets 28 (PKCS1_RSAEP n_wp1 e_wp1) (PKCS1_RSADP n_wp1 d_wp1) n_wp1" 
    using 1 2 3 4 5 6 7 8 9  by (simp add: OAEP.intro) 
qed

text \<open>Test Vector "tcId" : 1\<close>

definition WP1_msg1 :: octets where
  "WP1_msg1 = []"

definition WP1_label1 :: octets where
  "WP1_label1 = []"

definition WP1_lHash1 :: octets where
  "WP1_lHash1 = SHA224octets WP1_label1"

definition WP1_ct1 :: octets where
  "WP1_ct1 = nat_to_octets 0x03aea385d1f1321eeac78684a79ea101f54adae40474a54c8e574e1ae3871634050e5b596461730c345cfc93224deb7a26ae40f30a0497d7c6f0e141e9657b84bf9e20606fa7fe6e1c921d8de5032ad8ecc37b7c3247a56b3992c7c63dfc3fe2f22d7c4904fbddc371f560fef052f3ed89202bcc5f92f5a7fced461f984406554eadb85ab7d2bd7fc576d333b8876f82860c94aabb705e34e5f385cc2d7acfc5463a0135a15ed3c417789e0b8873d5fa0241c9a0d9894f617cf55c11fc45a47b3fcc04fa5b57e9e188addcf259a0f8051f254b6a57c2af22cbd4eb2c411e229045efbb577da4f480989d173a2fa367af721088547a8a219ff2466561eaa877e1"

text \<open>We show that the ciphertext ct1 is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg1\<close>
lemma WP1_TestVector1: "WP1_PKCS1_OAEP_Decrypt WP1_ct1  = WP1_msg1"
  by eval

lemma WP1_TestVector1_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct1 WP1_lHash1"
  by eval

text \<open>Going a bit further, we can recover the seed from ct1 and RSA-OAEP encrypt the message msg1
with the label label1 and the recovered seed and observe that the result is ct1.\<close>
definition WP1_seed1 :: octets where
  "WP1_seed1 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct1"

lemma WP1_TestVector1_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg1 WP1_label1 WP1_seed1 = WP1_ct1"
  by eval

text \<open>Test Vector "tcId" : 2\<close>

definition WP1_msg2 :: octets where
  "WP1_msg2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]"

definition WP1_label2 :: octets where
  "WP1_label2 = []"

definition WP1_lHash2 :: octets where
  "WP1_lHash2 = SHA224octets WP1_label2"

definition WP1_ct2 :: octets where
  "WP1_ct2 = nat_to_octets 0x5d19107e5f9422dd3d9e2207ca637f7347454c338c3191ef2eb5687a49f6570f723aab7ebbd78abba840942e74aea052dc24792c9eef1d72c148733c19776216431f917b81a9a80ff4b1883daba20dc6c368c525a2105550715a374583b56f9030df876d67b229fba732369113585166e41f8b5bb7735afc50970396f47921cb2d6c8bdedd5ff1f0411c804e412c2523da5354a0232a46bf9268402fb952f0ca00d04bfc4504c2ecd9772001b2d77be4731e131f90b46e0d0f51a6f7d787d95f01ce64f78b0c4759db1e4546857658b4bb899cb2e024d15b8bd14d0f2fd02a4001be3b6ab35ac589a83234d8d906750dec3e509332ca081969b26a1dd0ac7614"

text \<open>We show that the ciphertext ct2 is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg2\<close>
lemma WP1_TestVector2: "WP1_PKCS1_OAEP_Decrypt WP1_ct2  = WP1_msg2"
  by eval

lemma WP1_TestVector2_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct2 WP1_lHash2"
  by eval

text \<open>Going a bit further, we can recover the seed from ct2 and RSA-OAEP encrypt the message msg2
with the label label2 and the recovered seed and observe that the result is ct2.\<close>
definition WP1_seed2 :: octets where
  "WP1_seed2 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct2"

lemma WP1_TestVector2_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg2 WP1_label2 WP1_seed2 = WP1_ct2"
  by eval

text \<open>Test Vector "tcId" : 3\<close>

definition WP1_msg3 :: octets where
  "WP1_msg3 = [0x54, 0x65, 0x73, 0x74]"

definition WP1_label3 :: octets where
  "WP1_label3 = []"

definition WP1_lHash3 :: octets where
  "WP1_lHash3 = SHA224octets WP1_label3"

text \<open>Take care: the high octet is 0.  Could handle this in many ways.  This is the easiest.\<close>
definition WP1_ct3 :: octets where
  "WP1_ct3 = 0 # nat_to_octets 0x00d7ab45e49e37e0d73d9ec5d477985b51d9e1b7b9eb67a8e0224f49d8a3432c0dd8df02b5dbe8962b8a3d749d71e56c7871c0b4137d98de5b77d5f94bb448e124b57b2af9c24004bb693baf2d9f54fefe770f6f320cbe73c0405276b09b1d0627b3018787a3b27e09aa0b3ce50a79f946fc45746de72a93554b993936d3a41bf90bd9f2913f5580c8c1c1b853271286dacf275280faa981c78dfefcd4dd09b6f09bd5dde3ec11b02eb4538e43fbae835e40f903c81744797f04f5a38409a502f3a7eb9447a342dccd82fb192601d40f57192255f751f102e14fedc7e7aa81c770c6b72dcb853366b7a18fb11b8e3b3ee218e59f2dd74feba1bb6e06a87405d7"

text \<open>We show that the ciphertext ct3 is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg3\<close>
lemma WP1_TestVector3: "WP1_PKCS1_OAEP_Decrypt WP1_ct3  = WP1_msg3"
  by eval

lemma WP1_TestVector3_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct3 WP1_lHash3"
  by eval

text \<open>Going a bit further, we can recover the seed from ct3 and RSA-OAEP encrypt the message msg3
with the label label3 and the recovered seed and observe that the result is ct3.\<close>
definition WP1_seed3 :: octets where
  "WP1_seed3 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct3"

lemma WP1_TestVector3_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg3 WP1_label3 WP1_seed3 = WP1_ct3"
  by eval


text \<open>Test Vector "tcId" : 4\<close>

definition WP1_msg4 :: octets where
  "WP1_msg4 = [0x31, 0x32, 0x33, 0x34, 0x30, 0x30]"

definition WP1_label4 :: octets where
  "WP1_label4 = []"

definition WP1_lHash4 :: octets where
  "WP1_lHash4 = SHA224octets WP1_label4"

definition WP1_ct4 :: octets where
  "WP1_ct4 = nat_to_octets 0x942fc136ac976cfc686ed13a38314c9c8b570a4afa2b18ae0a3cc39173a1430c1cab8893d530d4bfbf98251035d1fc18d18d905ac86792a1f597c08de11d9e2487dd78900a0bf79239f75e155eb0fc6d151cd7acd4664ac606c396494969422c6a321e12fe747a3b0601afaa43a0d9c08c776a7bacd68ca04b3b5dd9e8c9dee6773cfe652b923ff9d4e82d353113fd7e0264189556b1f28011dabf2fed6beb47498af5a6a8b0b1ac9640e5acb53ebb90bf29b7783a01ad6b4f4595e067711a49f8f1cf00443292251d2c0551f89e4271140b03681e8f4fdfe62e588f565c2e5288b3b14a488f14751b5a493290dd9365a48ea33011ffadbd2b898bec921bb1ba"

text \<open>We show that the ciphertext ct- is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg-\<close>
lemma WP1_TestVector4: "WP1_PKCS1_OAEP_Decrypt WP1_ct4  = WP1_msg4"
  by eval

lemma WP1_TestVector4_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct4 WP1_lHash4"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed4 :: octets where
  "WP1_seed4 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct4"

lemma WP1_TestVector4_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg4 WP1_label4 WP1_seed4 = WP1_ct4"
  by eval


text \<open>Test Vector "tcId" : 5\<close>

definition WP1_msg5 :: octets where
  "WP1_msg5 = [0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65]"

definition WP1_label5 :: octets where
  "WP1_label5 = []"

definition WP1_lHash5 :: octets where
  "WP1_lHash5 = SHA224octets WP1_label5"

definition WP1_ct5 :: octets where
  "WP1_ct5 = nat_to_octets 0x36deb3f715d91d4f2c5a21a028f87b227dafedb7c0e064712dad36c276fc15bea7d0d3671b115323849ecf52e6326e5f2b205033177410eddd8e29fb06a1b93e99ff62ac8f7dbb973345947de615e9a8da910b5c810732985c3020d93e7485c69801b7ed49433ad66a0708f26d51c0fbd1c73cafc4c89f50a20a09369db4d065e9cd7845be623e86f497a0c3e9485701f18006b8130210cf09c69dcab7ec0e3c166fbbc5cc78c89dbd0cdaf7219b03dc580b4b8f7497c1f9f36d1c61e1609be1f67b892871ded426121c5f83e38d39127c7b574157e2f4ca589efe094c3472348bad8ec5b07b4a2f3f68d4176b6f381930ef377c640ae8491b5bc3249a5296fb"

text \<open>We show that the ciphertext ct- is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg-\<close>
lemma WP1_TestVector5: "WP1_PKCS1_OAEP_Decrypt WP1_ct5  = WP1_msg5"
  by eval

lemma WP1_TestVector5_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct5 WP1_lHash5"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed5 :: octets where
  "WP1_seed5 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct5"

lemma WP1_TestVector5_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg5 WP1_label5 WP1_seed5 = WP1_ct5"
  by eval


text \<open>Test Vector "tcId" : 6\<close>

definition WP1_msg6 :: octets where
  "WP1_msg6 = [0x61]"

definition WP1_label6 :: octets where
  "WP1_label6 = []"

definition WP1_lHash6 :: octets where
  "WP1_lHash6 = SHA224octets WP1_label6"

definition WP1_ct6 :: octets where
  "WP1_ct6 = nat_to_octets 0x39f8f5ee290e93d4a36b96aa94a3bb7edb33c0fb6565ca6a99fe2434222be6b6846af4daa933bc6ecb62e963d2e107f51bba8a92ea5a4e6490402102dd378a55c0ee2224e77395e27bf28a216c6f929db2c2c95721d1448160e888aa93251c966858535146a70188d87443416101e530cef68a1781f10368ceb43c287c73cd8c44592c56bd8f2bd501284c3118fa0f0402b42ca7c4ea3a917afe71ea82df1655a39c650ea6adc9d73e789970d9b3bbe3f34d0fc4dc5fd51529cd328a62dee0c30eafbaf7dd51de3c31090833024124741966bc8722a157a8e71ed60bb3ef4704ebfabeba4ef67edfc5a120a0ee3316797e0e6a9ddb4d3bc7dcc9f4c262fe022d"

text \<open>We show that the ciphertext ct- is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg-\<close>
lemma WP1_TestVector6: "WP1_PKCS1_OAEP_Decrypt WP1_ct6  = WP1_msg6"
  by eval

lemma WP1_TestVector6_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct6 WP1_lHash6"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed6 :: octets where
  "WP1_seed6 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct6"

lemma WP1_TestVector6_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg6 WP1_label6 WP1_seed6 = WP1_ct6"
  by eval


text \<open>Test Vector "tcId" : 7\<close>

definition WP1_msg7 :: octets where
  "WP1_msg7 = nat_to_octets 0xe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"

definition WP1_label7 :: octets where
  "WP1_label7 = []"

definition WP1_lHash7 :: octets where
  "WP1_lHash7 = SHA224octets WP1_label7"

definition WP1_ct7 :: octets where
  "WP1_ct7 = nat_to_octets 0xb798998999f0e4318470e72841a57733c842f174121247fbf3e59e7724bfd9501425234f8616d288f0dc8206c727aba50c13016d4be6f3bb64bed9dc5122b94522b8987a9db93403975302ef6fd585cad02556a735ffc5332d362272a07c1ddde4484639ab767e39881fa1c0077aed9e8ea4f6349f59940953c956f52065fde0a97624d0840fa610a46dcbdd12b8ea3c56c5873e9fb3f58e43ac719d50c75b434b01fd7f65c7eabd5a71f305561088ffd2fa7bb8698d16455a81d233a4dcc4c1f12280bae89741ac47885552d21b37523ffa8901a2256b3f7fd410b6d842a786ce2cd6ab81a7596ce5479eee98aa3836a22ee8307888d9365a962f2746b01430"

text \<open>We show that the ciphertext ct- is a valid input for the RSA-OAEP decrypt function and also
that when decrypted, we get the plaintext message msg-\<close>
lemma WP1_TestVector7: "WP1_PKCS1_OAEP_Decrypt WP1_ct7  = WP1_msg7"
  by eval

lemma WP1_TestVector7_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct7 WP1_lHash7"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed7 :: octets where
  "WP1_seed7 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct7"

lemma WP1_TestVector7_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg7 WP1_label7 WP1_seed7 = WP1_ct7"
  by eval


text \<open>Test Vector "tcId" : 8\<close>

definition WP1_msg8 :: octets where
  "WP1_msg8 = nat_to_octets 0x313233343030"

definition WP1_label8 :: octets where
  "WP1_label8 = [0, 0, 0, 0, 0, 0, 0, 0]"

definition WP1_lHash8 :: octets where
  "WP1_lHash8 = SHA224octets WP1_label8"

definition WP1_ct8 :: octets where
  "WP1_ct8 = nat_to_octets 0x2860d0785fcecef5d43ea029d6ef89b978b25b091a2bb64ee1b95da7dd257ed644a5e4ae1437bb20840715895adc9b2dfaaa1a427ab35d6380c0a6840c022a2fa1eff9b6de19568cf8276ce549365c768a0ee6d84c4c4f4c582ed93c297e83507c8495b3951279b274215cbae88de81447ff5d5d9421fb025a821a934d0103b9efa6d36067cfd394751251ccf4418e32c283ace982f8ee86635b9489aa2e756ccf6d2773a4c8613b899b7764c319153762a9ad14352538507d36f70f56e47c74e2786b8197ad42e2380324ba8cfc80d354eb4487e3642dba175cdcd8382f074e170e326f2cdce0cbdc3831aae1e1abb87756e503520b87a18eff17fca24fe20c"

lemma WP1_TestVector8: "WP1_PKCS1_OAEP_Decrypt WP1_ct8  = WP1_msg8"
  by eval

lemma WP1_TestVector8_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct8 WP1_lHash8"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed8 :: octets where
  "WP1_seed8 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct8"

lemma WP1_TestVector8_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg8 WP1_label8 WP1_seed8 = WP1_ct8"
  by eval


text \<open>Test Vector "tcId" : 9\<close>

definition WP1_msg9 :: octets where
  "WP1_msg9 = nat_to_octets 0x313233343030"

text \<open>Take care: the high octet is 0.  Could handle this in many ways.  This is the easiest.\<close>
definition WP1_label9 :: octets where
  "WP1_label9 = 0 # nat_to_octets 0x000102030405060708090a0b0c0d0e0f10111213"

definition WP1_lHash9 :: octets where
  "WP1_lHash9 = SHA224octets WP1_label9"

definition WP1_ct9 :: octets where
  "WP1_ct9 = nat_to_octets 0xa13447bed3796370d356bca37fe2ce27d19022301007dcaafa7162de0897698bf706c3c4594107e9a3585091178a25f458aed6e63eda039b1ab89704757d80a94751ee21c1fb672ca1a8f448fe8d959ec226867bb13dedd1b870986a9e7fec6893fd2d8d533ff13e60b7d61303e123d1f50b7301ac9dbce4480cb3d334b72e048f8740a5b9739bd07beef64265dcd6576dbbc956095aa586a1f22962dc96a00baf953faf836dce03568f3bea85696b074c9e1180dc2f801efe48a47e0735195944891a866d3e2cd1edb8333bf5164b94e618b1204af410644d966fab0e49b23efb23ee2038dfa88bf231ed1deab19346c4833f17ead5f1a2f15d695eef4e14df"

lemma WP1_TestVector9: "WP1_PKCS1_OAEP_Decrypt WP1_ct9  = WP1_msg9"
  by eval

lemma WP1_TestVector9_Valid: "WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct9 WP1_lHash9"
  by eval

text \<open>Going a bit further, we can recover the seed from ct- and RSA-OAEP encrypt the message msg-
with the label label- and the recovered seed and observe that the result is ct-.\<close>
definition WP1_seed9 :: octets where
  "WP1_seed9 = WP1_PKCS1_OAEP_Decrypt_seed WP1_ct9"

lemma WP1_TestVector9_Encode : "WP1_PKCS1_OAEP_Encrypt WP1_msg9 WP1_label9 WP1_seed9 = WP1_ct9"
  by eval

text \<open>Test Vector "tcId" : 12
Note that this is an invalid test vector.  It should fail.\<close>

definition WP1_msg12 :: octets where
  "WP1_msg12 = nat_to_octets 0x313233343030"

definition WP1_label12 :: octets where
  "WP1_label12 = []"

definition WP1_lHash12 :: octets where
  "WP1_lHash12 = SHA224octets WP1_label12"

definition WP1_ct12 :: octets where
  "WP1_ct12 = nat_to_octets 0xbdcbfb51335812a53e7db2c1b73ed5585fd7899936adb790f4b10327ee075714e21e7df55bddc6888adce032ffe1935d37178adb4dbff608eb5f4cf9e29bc32554358a829ad0b84b1cde5da1018440fa31f60ca72407f5604ea216a139c34034705d295bad65cb9fade9951e17d1ee85f4a46dd4ce81bc878daeddd800d0296eaa90345dcfd83f6dff5cb3ed87c7a8b5985b2ccd7f925b67d39920438b66c1ae1c1321fea7a8a90023f57cd97a50081c42d012de9ba5b98a1aec7da9929cf783def9efdafeaa8d9302da9fd44ec252cb5a97d5dd4fc6f68daddaa9d0f431b7968386df1a514f407f1342e33b996ee9c4b5af934f1aa2fe1e1ad485438d497afd"

lemma WP1_TestVector12: "WP1_PKCS1_OAEP_Decrypt WP1_ct12  = WP1_msg12"
  by eval

lemma WP1_TestVector12_inValid: "\<not> WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct12 WP1_lHash12"
  by eval

text \<open>The source of the failure is in the lHash, so that the decoded lHash does not match the
hash of the given label.\<close>
definition WP1_decode_lHash12 :: octets where
  "WP1_decode_lHash12 = WP1_PKCS1_OAEP_Decrypt_lHash WP1_ct12"

lemma WP1_TestVector12_lHashError : "\<not> WP1_decode_lHash12 = WP1_lHash12"
  by eval

text \<open>Test Vector "tcId" : 16
Note that this is an invalid test vector.  It should fail.\<close>

definition WP1_msg16 :: octets where
  "WP1_msg16 = nat_to_octets 0x313233343030"

definition WP1_label16 :: octets where
  "WP1_label16 = []"

definition WP1_lHash16 :: octets where
  "WP1_lHash16 = SHA224octets WP1_label16"

definition WP1_ct16 :: octets where
  "WP1_ct16 = nat_to_octets 0x916331689c162246baef783597f0448e34dc5d358b7f00fa47d5549f4fb52c7607c3a3d571b0930705ea61da60d59e96f9b4cb9fa6aac7fc737cbf6615c98b4f8ecd4a0c27878f469edba1bfc1108b104f73d90f089621ba85a938714818efa68c0483359e014c69c84209e1560b8692b8ac90e6164796cd1bc0578805d9e7318bbf08345835c67397eddc2d326468f594b2d4ddaaf8c67f5dfd998eab7c2fecb6a9ce63bde38cf23e0b0f252dbe964647da61dd054d10c5ea82abf730b0ef1722f98aeb15dda842a099501246700dc37d696177f52345c7a8be7bf55d0fb0f134731fc138ece8feee540bfc0da05edb375a1c0035e6fb0168a6424cf25bec5f"

lemma WP1_TestVector16_inValid: "\<not> WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct16 WP1_lHash16"
  by eval

text \<open>The source of the error is the padding string PS.\<close>

lemma WP1_TestVector16_inValidPS: "\<not> WP1_PKCS1_OAEP_Decrypt_validPS WP1_ct16"
  by eval

text \<open>Test Vector "tcId" : 22
Note that this is an invalid test vector.  It should fail.\<close>

definition WP1_msg22 :: octets where
  "WP1_msg22 = nat_to_octets 0x313233343030"

definition WP1_label22 :: octets where
  "WP1_label22 = []"

definition WP1_lHash22 :: octets where
  "WP1_lHash22 = SHA224octets WP1_label22"

definition WP1_ct22 :: octets where
  "WP1_ct22 = nat_to_octets 0x91a3872121d32ba547703f8a0b9c9aca280f099b9c559998fb39d8841f7ab6a1fdf05a81f246c324ce435d7d9ea135fbc989e15a56df082b5e1c47b3b40f86cd5db01304ffdd328ae99d205d4185bbdf506acba181cdcd2d1d48be3b860d96e0c6ca54ce626372a2a749121af68523decff2c4f02d9d6bfb3d3b9a175e9ce1f03e4616230d32d691a4a8455ec09995962d651cb6f85d2cad6b09e35274368f2eee8ae5c7aa123a16407bcdb200bb351ede750f4798b083ce82f2800e04b66fd2be942b4a64d56dd582de56e3da7facc71157ddaa124502cdae10591eac676df0c94224649cd109027af09cb147dbfd9938488e7be36cb1146753e7656421e90c"

text \<open>The source of the problem is that the high byte of the data block DB (called Y) is not 0.
But if you just drop the high byte, ignoring that it should have been 0, you can decrypt the
cipher and get the message.\<close>
lemma WP1_TestVector22_inValid: "\<not> WP1_PKCS1_OAEP_Decrypt_validInput WP1_ct22 WP1_lHash22"
  by eval

lemma WP1_TestVector22: "WP1_PKCS1_OAEP_Decrypt WP1_ct22 = WP1_msg22"
  by eval

subsection \<open>RSAES-PKCS1-v1_5\<close>

text \<open>
https://github.com/google/wycheproof/blob/master/testvectors/rsa_pkcs1_2048_test.json

{
  "algorithm" : "RSAES-PKCS1-v1_5",
  "generatorVersion" : "0.8r12",
  "numberOfTests" : 65,
  "header" : [
    "Test vectors of type RsaesPkcs1Decrypt are intended to check the decryption",
    "of RSA encrypted ciphertexts."
  ],
  "notes" : {
    "InvalidPkcs1Padding" : "This is a test vector with an invalid PKCS #1 padding. Implementations must ensure that different error conditions cannot be distinguished, since the information about the error condition can be used for a padding oracle attack. (RFC 8017 Section 7.2.2)"
  },
  "schema" : "rsaes_pkcs1_decrypt_schema.json",
  "testGroups" : [
    {
      "d" : "1a502d0eea6c7b69e21d5839101f705456ed0ef852fb47fe21071f54c5f33c8ceb066c62d727e32d26c58137329f89d3195325b795264c195d85472f7507dbd0961d2951f935a26b34f0ac24d15490e1128a9b7138915bc7dbfa8fe396357131c543ae9c98507368d9ceb08c1c6198a3eda7aea185a0e976cd42c22d00f003d9f19d96ea4c9afcbfe1441ccc802cfb0689f59d804c6a4e4f404c15174745ed6cb8bc88ef0b33ba0d2a80e35e43bc90f350052e72016e75b00d357a381c9c0d467069ca660887c987766349fcc43460b4aa516bce079edd87ba164307b752c277ed9528ad3ba0bf1877349ed3b7966a6c240110409bf4d0fade0c68fdadd847fd",
      "e" : "010001",
      "keysize" : 2048,
      "n" : "00b3510a2bcd4ce644c5b594ae5059e12b2f054b658d5da5959a2fdf1871b808bc3df3e628d2792e51aad5c124b43bda453dca5cde4bcf28e7bd4effba0cb4b742bbb6d5a013cb63d1aa3a89e02627ef5398b52c0cfd97d208abeb8d7c9bce0bbeb019a86ddb589beb29a5b74bf861075c677c81d430f030c265247af9d3c9140ccb65309d07e0adc1efd15cf17e7b055d7da3868e4648cc3a180f0ee7f8e1e7b18098a3391b4ce7161e98d57af8a947e201a463e2d6bbca8059e5706e9dfed8f4856465ffa712ed1aa18e888d12dc6aa09ce95ecfca83cc5b0b15db09c8647f5d524c0f2e7620a3416b9623cadc0f097af573261c98c8400aa12af38e43cad84d",

\<close>

definition n_wp2 :: nat where
  "n_wp2 = 0x00b3510a2bcd4ce644c5b594ae5059e12b2f054b658d5da5959a2fdf1871b808bc3df3e628d2792e51aad5c124b43bda453dca5cde4bcf28e7bd4effba0cb4b742bbb6d5a013cb63d1aa3a89e02627ef5398b52c0cfd97d208abeb8d7c9bce0bbeb019a86ddb589beb29a5b74bf861075c677c81d430f030c265247af9d3c9140ccb65309d07e0adc1efd15cf17e7b055d7da3868e4648cc3a180f0ee7f8e1e7b18098a3391b4ce7161e98d57af8a947e201a463e2d6bbca8059e5706e9dfed8f4856465ffa712ed1aa18e888d12dc6aa09ce95ecfca83cc5b0b15db09c8647f5d524c0f2e7620a3416b9623cadc0f097af573261c98c8400aa12af38e43cad84d"

lemma n_wp2_gr_1: "1 < n_wp2" 
  using n_wp2_def by presburger

definition e_wp2 :: nat where
  "e_wp2 = 0x010001" 

definition d_wp2 :: nat where
  "d_wp2 = 0x1a502d0eea6c7b69e21d5839101f705456ed0ef852fb47fe21071f54c5f33c8ceb066c62d727e32d26c58137329f89d3195325b795264c195d85472f7507dbd0961d2951f935a26b34f0ac24d15490e1128a9b7138915bc7dbfa8fe396357131c543ae9c98507368d9ceb08c1c6198a3eda7aea185a0e976cd42c22d00f003d9f19d96ea4c9afcbfe1441ccc802cfb0689f59d804c6a4e4f404c15174745ed6cb8bc88ef0b33ba0d2a80e35e43bc90f350052e72016e75b00d357a381c9c0d467069ca660887c987766349fcc43460b4aa516bce079edd87ba164307b752c277ed9528ad3ba0bf1877349ed3b7966a6c240110409bf4d0fade0c68fdadd847fd"

text \<open>The test vectors don't tell us the factorization of n, so we just assume that the n, e, and
d are from a valid RSA key.  I am not going to be able to factor n at the moment, so we will just
go with it.\<close>
axiomatization where MissingPandQ_wp2: "\<exists>p q. PKCS1_validRSAprivateKey n_wp2 d_wp2 p q e_wp2"

lemma FunctionalInverses1__wp2: "\<forall>m<n_wp2. PKCS1_RSADP n_wp2 d_wp2 (PKCS1_RSAEP n_wp2 e_wp2 m) = m"
  by (meson MissingPandQ_wp2 PKCS1_RSAEP_messageValid_def RSAEP_RSADP)

lemma FunctionalInverses2__wp2: "\<forall>c<n_wp2. PKCS1_RSAEP n_wp2 e_wp2 (PKCS1_RSADP n_wp2 d_wp2 c) = c"
  by (meson MissingPandQ_wp2 PKCS1_RSAEP_messageValid_def RSADP_RSAEP)

global_interpretation RSAES_PKCS1_v1_5_WP2: 
  RSAES_PKCS1_v1_5 "PKCS1_RSAEP n_wp2 e_wp2" "PKCS1_RSADP n_wp2 d_wp2" n_wp2
  defines WP2_k                                   = "RSAES_PKCS1_v1_5_WP2.k"
  and     WP2_RSAES_PKCS1_v1_5_Encrypt_EM         = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Encrypt_EM"
  and     WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Encrypt_inputValid"
  and     WP2_RSAES_PKCS1_v1_5_Encrypt            = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Encrypt"
  and     WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decrypt_inputValid"
  and     WP2_RSAES_PKCS1_v1_5_Decrypt            = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decrypt"
  and     WP2_RSAES_PKCS1_v1_5_Decrypt_PS         = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decrypt_PS"
  and     WP2_RSAES_PKCS1_v1_5_Decrypt_EM         = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decrypt_EM"
  and     WP2_RSAES_PKCS1_v1_5_Decode_M           = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decode_M"
  and     WP2_RSAES_PKCS1_v1_5_Decode_validEM     = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decode_validEM"
  and     WP2_RSAES_PKCS1_v1_5_Decode_PS          = "RSAES_PKCS1_v1_5_WP2.RSAES_PKCS1_v1_5_Decode_PS"
proof - 
  have 5: "0 < n_wp2"  using zero_less_numeral n_wp2_def by linarith 
  have 6: "\<forall>m. PKCS1_RSAEP n_wp2 e_wp2 m < n_wp2"
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger
  have 7: "\<forall>c. PKCS1_RSADP n_wp2 d_wp2 c < n_wp2" 
    using 5 PKCS1_RSAEP_messageValid_def encryptValidCiphertext by presburger 
  have 8: "\<forall>m<n_wp2. PKCS1_RSADP n_wp2 d_wp2 (PKCS1_RSAEP n_wp2 e_wp2 m) = m" 
    using FunctionalInverses1__wp2 by blast
  have 9: "\<forall>c<n_wp2. PKCS1_RSAEP n_wp2 e_wp2 (PKCS1_RSADP n_wp2 d_wp2 c) = c" 
    using FunctionalInverses2__wp2 by blast
  have 10: "11 < octet_length n_wp2" by eval
  show "RSAES_PKCS1_v1_5  (PKCS1_RSAEP n_wp2 e_wp2) (PKCS1_RSADP n_wp2 d_wp2) n_wp2" 
    using 5 6 7 8 9 10 by (simp add: RSAES_PKCS1_v1_5.intro) 
qed

text \<open>Test Vector "tcId" : 1\<close>

definition WP2_msg1 :: octets where
  "WP2_msg1 = []"

definition WP2_ct1 :: octets where
  "WP2_ct1 = nat_to_octets 0x5999ccb0cfdd584a3fd9daf247b9cd7314323f8bba4864258f98c6bafc068fe672641bab25ef5b1a7a2b88f67f12af3ca4fe3c493b2062bbb11ad3b1ba0640025c814326ff50ed52b176bd7f606ea9e209bcdcc67c0a0c4b8ed30b9959c57e90fd1efdf99895e2608095f92caff9070dec900fb96d5ce5efd2b2e66b80cff27d482d242b307cb813e7dc818fce31b67ac9a94501b5bc4621b547ba9d81808dd297d600dfc1a7deeb061570cde8894e398453328740adfd77cf76075a109d41ad296651ac817382424a4907d5a342d06cf19c09d5b37a147dd69045bf7d378e19dbbbbfb25282e3d9a4dc9793c8c32ab5a45c0b43dba4daca367b6eb5f4432a62"

text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector1: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct1  = WP2_msg1"
  by eval

lemma WP2_TestVector1_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct1"
  by eval

definition WP2_PS1 :: octets where
  "WP2_PS1 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct1"

lemma WP2_TestVector1': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg1 WP2_PS1 = WP2_ct1"
  by eval

lemma WP2_TestVector1'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg1 WP2_PS1"
  by eval

text \<open>Test Vector "tcId" : 2\<close>

definition WP2_msg2 :: octets where
  "WP2_msg2 = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]"

definition WP2_ct2 :: octets where
  "WP2_ct2 = nat_to_octets 0xa9acec7e58761d9191249ff7ea5db499cadccc51d29f8e7fd0aa2cb9962095626f1cadae29666f04ce2afd4b650be59d071d06446d59107eb508cc60545727b0567dfb4f2f94ca60b939c60be111172f367dfd235516e4a60061648c67f5536650821ac2a60744be3cf6befa8f66e76a3e7c5fbc6dfa4dda55ecbdbffdc98d610de5667a4f485f6168b52bbe470e6014253874ce7b78e509937e0bc5f02857e1ad3cf55139bbe6dc7ac4b1ed5097bf781b7671ca9bb58187aa6c71c58ac0561c5aacf96c35deb24e395b6823de7fc96b8031b5906a34c4dc57e4f1226157b9abd849e1367dda014fbf9ed4ca515a7a04cf87787945007e4f63c0366a5bbc3489"

text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector2: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct2  = WP2_msg2"
  by eval

lemma WP2_TestVector2_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct2"
  by eval

definition WP2_PS2 :: octets where
  "WP2_PS2 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct2"

lemma WP2_TestVector2': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg2 WP2_PS2 = WP2_ct2"
  by eval

lemma WP2_TestVector2'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg2 WP2_PS2"
  by eval

text \<open>Test Vector "tcId" : 3\<close>

definition WP2_msg3 :: octets where
  "WP2_msg3 = nat_to_octets 0x54657374"

definition WP2_ct3 :: octets where
  "WP2_ct3 = nat_to_octets 0x4501b4d669e01b9ef2dc800aa1b06d49196f5a09fe8fbcd037323c60eaf027bfb98432be4e4a26c567ffec718bcbea977dd26812fa071c33808b4d5ebb742d9879806094b6fbeea63d25ea3141733b60e31c6912106e1b758a7fe0014f075193faa8b4622bfd5d3013f0a32190a95de61a3604711bc62945f95a6522bd4dfed0a994ef185b28c281f7b5e4c8ed41176d12d9fc1b837e6a0111d0132d08a6d6f0580de0c9eed8ed105531799482d1e466c68c23b0c222af7fc12ac279bc4ff57e7b4586d209371b38c4c1035edd418dc5f960441cb21ea2bedbfea86de0d7861e81021b650a1de51002c315f1e7c12debe4dcebf790caaa54a2f26b149cf9e77d"
 
text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector3: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct3  = WP2_msg3"
  by eval

lemma WP2_TestVector3_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct3"
  by eval

definition WP2_PS3 :: octets where
  "WP2_PS3 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct3"

lemma WP2_TestVector3': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg3 WP2_PS3 = WP2_ct3"
  by eval

lemma WP2_TestVector3'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg3 WP2_PS3"
  by eval

text \<open>Test Vector "tcId" : 4\<close>

definition WP2_msg4 :: octets where
  "WP2_msg4 = nat_to_octets 0x313233343030"

definition WP2_ct4 :: octets where
  "WP2_ct4 = nat_to_octets 0x455fe8c7c59d08c068b5ff739d8dab912b639c8e9eade5d0519d58f4ead7208d5a753b4a88fe771475adc82d10ab29ded28caf03f9034d3a111b520440c02276e1b6417c42eec0257f1f05482868987f2f75bd33d1ec3dbc799d7b5bf25c4a0543793a4d3ce305cc43646bc450344e624fd381e24d8e57ef2840dd9d576da554ba408ee6580159e6d88438a28d66250b3b3fe3bc6624406022a9e4ee2778c38230674f635f56b9d6adcf2be6bfab34a8a431169d769876422f7077ded31fa6f29993dd1972b2d2d24b0513a7a193f6a88d53c49cde2c030f85e3ddfbc9f99b4a667fd9c652382238166f3d39eb2b78de53ad24c97699fe5738a7a705a2ab141b"
 
text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector4: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct4  = WP2_msg4"
  by eval

lemma WP2_TestVector4_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct4"
  by eval

definition WP2_PS4 :: octets where
  "WP2_PS4 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct4"

lemma WP2_TestVector4': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg4 WP2_PS4 = WP2_ct4"
  by eval

lemma WP2_TestVector4'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg4 WP2_PS4"
  by eval

text \<open>Test Vector "tcId" : 5\<close>

definition WP2_msg5 :: octets where
  "WP2_msg5 = nat_to_octets 0x4d657373616765"

definition WP2_ct5 :: octets where
  "WP2_ct5 = nat_to_octets 0x1cf861ef8b6c29474666605d3ddb663a259a9ae838417abcc7f7dd42d471d5f3812cdf90e3041c4c5bfd38ac1e4d95fd71661bddac45f5f8e3e89629a335bbf2eff116030f1c5ace8336cf7e94c2e8bf5a1d6116e54ec42b9da5fc651a41ac8fd38194e5029489cfde1f7fc850c0dfb3dc00021f74ae3847327c69afdb1355c7587bb93d5f4d2cfb35a7f70bcabd43eb32300585b6ee32f14a68c2a08434e923adb76dfcdf3ea5133edffa5ca20425083b28ecb045e69562b44286d320d87285e7a2e3bedded083c010401ae22c8f278b080112c4264a3cad3ed9fa31cf19e052aabbda9f8ecef1d64786258202bb61128b3140a355d65b982b0239764d77d24"

text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector5: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct5  = WP2_msg5"
  by eval

lemma WP2_TestVector5_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct5"
  by eval

definition WP2_PS5 :: octets where
  "WP2_PS5 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct5"

lemma WP2_TestVector5': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg5 WP2_PS5 = WP2_ct5"
  by eval

lemma WP2_TestVector5'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg5 WP2_PS5"
  by eval

text \<open>Test Vector "tcId" : 6\<close>

definition WP2_msg6 :: octets where
  "WP2_msg6 = [0x61]"

definition WP2_ct6 :: octets where
  "WP2_ct6 = nat_to_octets 0x8122b33665648346f6cf728f285667cff7f3c20907e76438e64db81a6a5e74c34c5694fb5b4c826067bae94c5176e152eb16884d9c2b63d2ff41d06140c9c39469a4ae05cda86c81ccb208894266f6b24a0f79132f71521e10683faa05c8e68b77dd6c0c04cbfef55a9d1b68291c286e08907c3df029c52e15539027f534c7df8da5637db99355b24576b873c119ff1d74b3c913b70c48f366887ccbe6d206c11657401f41baad9290fe6ae01855a99891700d71775fb36237bd3597ad240fff4c03d1fe599cdec65baef11fbc4889575a55f255b51ec8298595dbcc89659382d35c2b85a941c33746a7937f3d18e27079fc3d2252904aa533fbfd2ebed2e059"

text \<open>We show that the ciphertext ct- is a valid input for the decrypt function and also
that when decrypted, we get the plaintext message msg-.  We can also show that the message is a
valid input for the encrypt function and that when encrypted, we get the ciphertext ct-.  To
do this, we need to recover the padding string PS.\<close>
lemma WP2_TestVector6: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct6  = WP2_msg6"
  by eval

lemma WP2_TestVector6_Valid: "WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct6"
  by eval

definition WP2_PS6 :: octets where
  "WP2_PS6 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct6"

lemma WP2_TestVector6': "WP2_RSAES_PKCS1_v1_5_Encrypt WP2_msg6 WP2_PS6 = WP2_ct6"
  by eval

lemma WP2_TestVector6'_Valid: "WP2_RSAES_PKCS1_v1_5_Encrypt_inputValid WP2_msg6 WP2_PS6"
  by eval

text \<open>Test Vector "tcId" : 9\<close>

definition WP2_msg9 :: octets where
  "WP2_msg9 = nat_to_octets 0x54657374"

definition WP2_ct9 :: octets where
  "WP2_ct9 = nat_to_octets 0x6e0d507f66e16d4b7373a504c6d48692aaa541fdd59eeb5d4a2cd91f6000ce9b5734a232d6541a78729ac82152d3a30b51950a24ae379a108ed20fa4ec7542fe2281c2dd5de685564d15182f3c73e9c0135ebc993f5acd240a343d3257997582328c31be215c7349375406aa78a3ac35327226839bee2f1a4a0f8e6e06986cb33806c93e0b0c1d6cfd23f4a68c1f2a38c74b8df70f280984a840c710c52279034d04f61e313d4bcd8b3b5c58468a44565a1acb2eefc6d49044be7163e64ed84b5e7991ecba274a3a7ee4defb842a86ac4cbf2d3bfc9cf870ae025a3e2fbc775916a59579763c06eb84ad8edd1d03787e609ad446de43ebed16330ab06716fa73"

text \<open>This is a failure case.  The padding used was all 0 when the rule is that the padding should
not have any 0 bytes.  Because the PS is all 0, the decrypt routine will find that 
PS = [] (empty).\<close>
lemma WP2_TestVector9: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct9 \<noteq> WP2_msg9"
  by eval

lemma WP2_TestVector9_Valid: "\<not> WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct9"
  by eval

definition WP2_PS9 :: octets where
  "WP2_PS9 = WP2_RSAES_PKCS1_v1_5_Decrypt_PS WP2_ct9"

lemma WP2_TestVector9_PS: "WP2_PS9 = []"
  by eval

text \<open>Test Vector "tcId" : 14\<close>

definition WP2_msg14 :: octets where
  "WP2_msg14 = nat_to_octets 0x54657374"

definition WP2_ct14 :: octets where
  "WP2_ct14 = nat_to_octets 0x3307264f64d4ca8b62c4e7da4cac117262e5d3a3dbc19a529ac5167c1987bce56e358726d0ecfc6cb591a12bd5f7531cd2249439254c366ad3cb7a608f845e1eca931018295208ba5c6198027b22191224c4568856ab331e2acf530fc434870865d3321ac90327a8c61f27cac9859dac8e3c38d8453349d2ef8e4a7e8011f6badd1530eae710e0c60d35905f20d7a2d118e7ce18ebb220f04b4089778cbf091bcb3e02aca83b4b9ba5319c3069188c7b00c7d32ebe1dd6e6535b5f667ce972f00ba773d4cf6a556ccf65bacc1eca2312881caf6a89ff5d83960846a5d9dd31477dcc9ee4ae50ab0cb2e574a685bd9d7b7a74c7ca9876f08fd64d1d5f196786be"

text \<open>This is a failure case.  The padding used had the 7th byte = 0.  So the recovered message
will include part of the padding string (byte 8 and above).\<close>
lemma WP2_TestVector14: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct14 \<noteq> WP2_msg14"
  by eval

lemma WP2_TestVector14_Valid: "\<not> WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct14"
  by eval

text \<open>Test Vector "tcId" : 16\<close>

definition WP2_msg16 :: octets where
  "WP2_msg16 = nat_to_octets 0x54657374"

definition WP2_ct16 :: octets where
  "WP2_ct16 = nat_to_octets 0x25f67bc6c1320a13fa91a23d4d1801cc73594161a7f344ffa195d6dd1894c1e39d6cd81866462d05e0e16c02459a3f1dc5f0ecc52657f70385fd0b33de214216a2298b4814550af1ecd929170bc69b74e08299bea50de33021468f4fe2a2e4a43233d6872d15379ccea03450145d909c5eb11ca5f524e17b2065768b9bb06438e81b0b8ca816bfcc7eddcffba59b33e2a0b4ad8df215c2eafa240e553f1526dad66038e54f305a6d3fd6460e781239c9dc424ab6df7f75bb4327d873d0e8d7ecab1b09b8779cb841e002ee45f8dbebd2d483de2d7136ae7e350580dc8a48bcd6359a677bccd689bbdf879f2520d8976fc2b92e64dda8e7399719a13b8182c739"

text \<open>This is a failure case.  The padding string is "missing" but the enocded message has 
extraneous leading 0s (of the length that PS would have been.\<close>
lemma WP2_TestVector16: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct16 \<noteq> WP2_msg16"
  by eval

lemma WP2_TestVector16_Valid: "\<not> WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct16"
  by eval

text \<open>Test Vector "tcId" : 20\<close>

definition WP2_msg20 :: octets where
  "WP2_msg20 = nat_to_octets 0x54657374"

definition WP2_ct20 :: octets where
  "WP2_ct20 = nat_to_octets 0x794ab724aeb176c4415a597e9d69cb567cece4479e6e4c9c19530b0877b53719d7f6318be8e970874c4be19984c632825dee7a38561a6904e23c776ccce71128847c24d5609e6790e3c9112393660ffd208771916d2e80d2c2fb35ff7936bab6c03e07646f15d09a88fd2ff8e70b624c66da4eb7dae241907ef328697c219d1ff347ada945e24ab526b6cea4e6b7f386560ab56f16751f6e2de0f7922a8946ae9afb9ce95369418f540163827f452f5d2a5029a1ce417453324eb015fd83ca2147331c02c762c457fc52ca5f097610c60430b69b6b0fc1c0877513bdb51923bca03e9af9174d3094530a007253958bfed03606e6f75cb5854443eaa363614116"

text \<open>This is a failure case.  The first byte is not zero, so this will fail the valid input
check.  But if you just ignore that check, when you decrypt you will recover the plaintext.\<close>
lemma WP2_TestVector20: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct20 = WP2_msg20"
  by eval

lemma WP2_TestVector20_Valid: "\<not> WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct20"
  by eval

text \<open>Test Vector "tcId" : 24\<close>

definition WP2_msg24 :: octets where
  "WP2_msg24 = nat_to_octets 0x54657374"

definition WP2_ct24 :: octets where
  "WP2_ct24 = nat_to_octets 0x910ad40ae0d8af151f512354e1cf12af7c4851cff0b659026e90a9ec4dea6c1e4b2b33cbe8260501493df2e7fa2cd77f020a7cfac1ca379eed3fe6d003335653a5f022f6bf5010e5f58c41fc91253d75eac2072479d4bb3509e1351a66f700ff4ac470115490021734bb8099e66c35f904f09d167303e26163393ed556cdccdfae95f239ebf0bd361a8adad927fb9544ca30132195735cb026dd0dc66c6efa0db41b73fc1c917be384a430e0788f5f872785cd709f70793204753d7b207fbce2d0bfbab11d3d614b99bf87bcc9a34db639fd203c9c081ddeecb9c85221e03cb9171685dafcfeaba470c5f1921a6fe016ba4b816a2328eee9853fa6994ec313d8"

text \<open>This is a failure case.  The encoded message does not have the correct format.  It pads the
message on the left with all 0s.\<close>
lemma WP2_TestVector24: "WP2_RSAES_PKCS1_v1_5_Decrypt WP2_ct24 \<noteq> WP2_msg24"
  by eval

lemma WP2_TestVector24_Valid: "\<not> WP2_RSAES_PKCS1_v1_5_Decrypt_inputValid WP2_ct24"
  by eval



end
