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

"""trigger event on dag update

Revision ID: cd20f435f053
Revises: a7836d0f25b8
Create Date: 2022-09-19 18:23:43.134145

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = 'cd20f435f053'
down_revision = 'a7836d0f25b8'
branch_labels = None
depends_on = None


def upgrade():
    """Apply trigger event on task instance creation or update"""
    conn = op.get_bind()
    conn.execute("DROP TRIGGER IF EXISTS update_dag ON dag;")
    conn.execute("""
CREATE TRIGGER update_dag
  AFTER UPDATE ON dag
  FOR EACH ROW
  EXECUTE PROCEDURE passthrough_all_data();
    """)


def downgrade():
    """Unapply trigger event on dag update"""
    pass
