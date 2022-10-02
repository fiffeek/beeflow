#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

"""trigger events on dag_run updates

Revision ID: 97d9c84a82ae
Revises: cd20f435f053
Create Date: 2022-10-02 22:08:57.336217

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = '97d9c84a82ae'
down_revision = 'cd20f435f053'
branch_labels = None
depends_on = None


def upgrade():
    """Apply trigger events on dag_run updates"""
    conn = op.get_bind()
    conn.execute("DROP TRIGGER IF EXISTS update_dag_run ON dag_run;")
    conn.execute("""
    CREATE TRIGGER update_dag_run
      AFTER INSERT OR UPDATE ON dag_run
      FOR EACH ROW
      EXECUTE PROCEDURE passthrough_all_data();
        """)


def downgrade():
    """Unapply trigger events on dag_run updates"""
    pass
