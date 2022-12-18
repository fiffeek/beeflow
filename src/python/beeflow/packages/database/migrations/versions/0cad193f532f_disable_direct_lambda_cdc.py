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

"""disable direct lambda cdc

Revision ID: 0cad193f532f
Revises: 287c35cfdecb
Create Date: 2022-12-18 18:43:14.322518

"""

import sqlalchemy as sa
from alembic import op


# revision identifiers, used by Alembic.
revision = '0cad193f532f'
down_revision = '287c35cfdecb'
branch_labels = None
depends_on = None


def upgrade():
    """Apply disable direct lambda cdc"""
    conn = op.get_bind()
    conn.execute("DROP TRIGGER IF EXISTS upsert_ti_trigger ON task_instance;")
    conn.execute("DROP TRIGGER IF EXISTS new_dag_trigger ON dag;")
    conn.execute("DROP TRIGGER IF EXISTS update_dag ON dag;")
    conn.execute("DROP TRIGGER IF EXISTS update_dag_run ON dag_run;")



def downgrade():
    """Unapply disable direct lambda cdc"""
    pass
