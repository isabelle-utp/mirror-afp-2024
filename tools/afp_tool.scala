package afp


import isabelle._

import afp.migration._


class Admin_Tools extends Isabelle_Scala_Tools(
  AFP_Migrate_Metadata.isabelle_tool,
  AFP_Build_Python.isabelle_tool,
  AFP_Build_Hugo.isabelle_tool,
)

class Tools extends Isabelle_Scala_Tools(
  AFP_Site_Gen.isabelle_tool,
  AFP_Check_Roots.isabelle_tool,
  AFP_Dependencies.isabelle_tool,
)
